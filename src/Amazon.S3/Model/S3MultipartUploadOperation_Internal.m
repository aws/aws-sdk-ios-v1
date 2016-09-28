/*
 * Copyright 2010-2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import "S3MultipartUploadOperation_Internal.h"
#import "AmazonErrorHandler.h"
#import "AmazonServiceRequest.h"

typedef void (^AbortMultipartUploadBlock)();

typedef struct _AWSRange {
    int64_t location;
    int64_t length;
} AWSRange;

@interface S3MultipartUploadOperation_Internal ()
{
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property (nonatomic, assign) int64_t contentLength;
@property (nonatomic, assign) int32_t currentPartNo;
@property (nonatomic, assign) int32_t numberOfParts;
@property (nonatomic, assign) int32_t retryCount;
@property (nonatomic, copy) AbortMultipartUploadBlock abortMultipartUpload;
@property (nonatomic, retain) S3InitiateMultipartUploadRequest *initRequest;
@property (nonatomic, retain) S3InitiateMultipartUploadResponse *initResponse;
@property (nonatomic, retain) S3MultipartUpload *multipartUpload;
@property (nonatomic, retain) S3CompleteMultipartUploadRequest *completeRequest;
@property (nonatomic, retain) NSData *dataForPart;

@end

@implementation S3MultipartUploadOperation_Internal

@synthesize transferRequestType = _transferRequestType;

#pragma mark - Class Lifecycle

- (id)init
{
    if (self = [super init])
    {
        _isExecuting = NO;
        _isFinished = NO;

        _contentLength = 0;
        _currentPartNo = 0;
        _numberOfParts = 0;
        _retryCount = 0;
        
        _transferRequestType = S3TRANSFER_UPLOAD;
    }

    return self;
}

- (id)initWithCurrentPartNo:(uint32_t)theCurrentPartNo
{
    if (self = [super init])
    {
        _isExecuting = NO;
        _isFinished = NO;
        
        _contentLength = 0;
        _currentPartNo = theCurrentPartNo;
        _numberOfParts = 0;
        _retryCount = 0;
        
        _transferRequestType = S3TRANSFER_UPLOAD;
    }
    
    return self;
}

- (void)dealloc
{
    [_response release];

    [_abortMultipartUpload release];
    [_initRequest release];
    [_initResponse release];
    [_multipartUpload release];
    [_completeRequest release];
    [_dataForPart release];

    [super dealloc];
}

#pragma mark - Overwriding NSOperation Methods

- (void)start
{
    // if cancel has been called on operation then we do not want to start the operation
    if ([self isCancelled]) {
        [self finish];
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    S3MultipartUpload *multipartUpload = nil;
    
    self.error = nil;
    self.exception = nil;
    
    // Check if the upload was already started
    S3ListMultipartUploadsRequest *listMPU = [[[S3ListMultipartUploadsRequest alloc] init] autorelease];
    listMPU.bucket = self.putRequest.bucket;
    S3ListMultipartUploadsResponse *listResponse = nil;
    @try {
        listResponse = [self.s3 listMultipartUploads:listMPU];
        if (listResponse.error != nil) {
            self.error = listResponse.error;
            self.exception = [AmazonServiceException exceptionWithMessage:[self.error description] andError:self.error];
        }
    }
    @catch (NSException *exception) {
        self.exception = exception;
        self.error = [AmazonErrorHandler errorFromException:exception];
    }
    
    // If the list multipart upload fails, report back
    if (self.error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.putRequest.delegate respondsToSelector:@selector(request:didFailWithError:)])
            {
                [self.putRequest.delegate request:listMPU didFailWithError:self.error];
            }
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [self cleanup];
                [self finish];
            });
        });
        return;
    }
    
    
    for (S3MultipartUpload *upload in listResponse.listMultipartUploadsResult.uploads) {
        if ([upload.key isEqualToString:self.putRequest.key]) {
            multipartUpload = upload;
            break;
        }
    }
    
    if (nil != multipartUpload) {
        // set this value manually because it was nil
        multipartUpload.bucket = self.putRequest.bucket;
        
        // Get all the uploaded parts from S3
        S3ListPartsRequest *listPartsReq = [[[S3ListPartsRequest alloc] initWithMultipartUpload:multipartUpload] autorelease];
        S3ListPartsResponse *listPartsResult = [self.s3 listParts:listPartsReq];
        
        // set the current part number to start uploading from
        self.currentPartNo = ((S3Part *)[listPartsResult.listPartsResult.parts lastObject]).partNumber + 1;
        
        self.multipartUpload = multipartUpload;
        
        // Add uploaded parts' partnumber and etag into a dictionary to later set the S3CompleteMultipartUploadRequest
        self.completeRequest = [[[S3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:self.multipartUpload] autorelease];
        for (S3Part *part in listPartsResult.listPartsResult.parts) {
            [self.completeRequest addPartWithPartNumber:part.partNumber withETag:part.etag];
        }
    }
    

    if (nil == self.completeRequest) {
        [self initiateUpload];
    } else {
        [self.putRequest.stream open];
        [self startUploadingParts];
    }
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _isExecuting;
}

- (BOOL)isFinished
{
    return _isFinished;
}

#pragma mark - Multipart Upload Methods

- (void)initiateUpload
{
    if ([self isCancelled]) {
        [self cleanup];
        [self finish];
        return;
    }
    
    S3InitiateMultipartUploadRequest *initRequest = [[S3InitiateMultipartUploadRequest alloc] initWithKey:self.putRequest.key
                                                                                                 inBucket:self.putRequest.bucket];
    self.initRequest = initRequest;
    [initRequest release];

    [self updateProperties:self.initRequest];
    self.initRequest.delegate = self;

    self.retryCount = 0;
    self.response = nil;
    
    if ([self isCancelled]) {
        [self cleanup];
        [self finish];
        return;
    }

    dispatch_sync(dispatch_get_main_queue(), ^{
        [self.s3 initiateMultipartUpload:self.initRequest];
    });
}

- (void)startUploadingParts
{
    if (nil == self.completeRequest) {
        S3CompleteMultipartUploadRequest *completeRequest = [[S3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:self.multipartUpload];
        self.completeRequest = completeRequest;
        [completeRequest release];
    }
    else if (nil == self.putRequest.data ) {
        // Read the stream up to the point where we left off before pausing
        uint8_t buffer[1024];
        long long bytesWrittenSoFar = (self.currentPartNo - 1) * self.partSize;
        long long totalStreamReadSoFar = 0;
        NSUInteger readLength = 0;
        
        for(int i = 0; i < ceil((double) bytesWrittenSoFar / 1024); i++)
        {
            @autoreleasepool
            {
                readLength = [self.putRequest.stream read:buffer maxLength:1024];
                totalStreamReadSoFar += readLength;
                
                if (totalStreamReadSoFar >= bytesWrittenSoFar) {
                    break;
                }
            }
        }
    }

    [self updateProperties:self.completeRequest];
    self.completeRequest.delegate = self;

    self.abortMultipartUpload = ^{

        if(self.multipartUpload)
        {
            @try {
                S3AbortMultipartUploadRequest *abortRequest = [[S3AbortMultipartUploadRequest alloc] initWithMultipartUpload:self.multipartUpload];
                [self.s3 abortMultipartUpload:abortRequest];
                [abortRequest release];
            }
            @catch (NSException *exception) {

            }
        }

    };

    self.contentLength = [self contentLengthForRequest:self.putRequest];
    self.numberOfParts = [self numberOfParts:self.contentLength];
    self.currentPartNo = self.currentPartNo != 0 ? self.currentPartNo : 1;

    self.retryCount = 0;
    
    if ([self isCancelled]) {
        [self cleanup];
        [self finish];
        [self executeAbort];
        
        return;
    }
    
    [self uploadPart:self.currentPartNo];
}

- (void)uploadPart:(NSInteger)partNo
{
    AWSRange dataRange = [self getDataRange:partNo withContentLength:self.contentLength];

    self.error = nil;
    self.exception = nil;

    if(self.retryCount > 0)
    {
        [self.s3 pauseExponentially:self.retryCount];
    }

    S3UploadPartRequest *uploadRequest = [[S3UploadPartRequest alloc] initWithMultipartUpload:self.multipartUpload];
    [self updateProperties:uploadRequest];
    uploadRequest.partNumber = partNo;

    if(self.dataForPart == nil)
    {
        if(self.putRequest.data != nil)
        {
            NSRange range;
            range.location = dataRange.location;
            range.length = dataRange.length;
            
            self.dataForPart = [self.putRequest.data subdataWithRange:range];
        }
        else
        {
            if(self.putRequest.stream.streamStatus == NSStreamStatusNotOpen)
            {
                [self.putRequest.stream open];
            }

            NSMutableData *dataForPart = [NSMutableData new];

            uint8_t buffer[1024];
            NSInteger readLength = 0;

            for(int i = 0; i < ceil((double) self.partSize / 1024); i++)
            {
                @autoreleasepool
                {
                    readLength = [self.putRequest.stream read:buffer maxLength:1024];
                    [dataForPart appendData:[NSData dataWithBytes:buffer length:readLength]];
                }
            }

            self.dataForPart = dataForPart;

            [dataForPart release];
        }
    }

    uploadRequest.contentLength = self.dataForPart.length;
    uploadRequest.data = self.dataForPart;
    uploadRequest.delegate = self;

    self.response = nil;

    if ([self isCancelled]) {
        [self cleanup:uploadRequest];
        [self finish];
        [uploadRequest release];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.s3 uploadPart:uploadRequest];
    });

    [uploadRequest release];
}

#pragma mark - AmazonServiceRequestDelegate Implementations

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    if ([self isCancelled]) {
        if([response isKindOfClass:[S3CompleteMultipartUploadResponse class]])
        {
            if([self.putRequest.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)])
            {
                [self.putRequest.delegate request:request
                          didCompleteWithResponse:response];
            }
        }else {
            [request cancel];
            [self executeAbort];
        }
        [self cleanup];
        [self finish];
        return;
    }
    
    if(!self.isFinished && self.isExecuting && !self.isCancelled)
    {
        self.response = response;

        if([response isKindOfClass:[S3InitiateMultipartUploadResponse class]])
        {
            self.initResponse = (S3InitiateMultipartUploadResponse *)self.response;
            self.multipartUpload = self.multipartUpload ? self.multipartUpload : self.initResponse.multipartUpload;

            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{

                [self startUploadingParts];
            });
        }
        else if([response isKindOfClass:[S3UploadPartResponse class]])
        {
            AMZLogDebug(@"UploadPart succeeded: %d", self.currentPartNo);

            S3UploadPartResponse *uploadPartResponse = (S3UploadPartResponse *)self.response;

            if(uploadPartResponse.etag == nil)
            {
                [self.s3 completeMultipartUpload:self.completeRequest];
            }
            else
            {

                if([self isCancelled]) {
                    if(self.request.stream)
                    {
                        [self.request.stream close];
                    }
                    
                    if(self.abortMultipartUpload)
                    {
                        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                        dispatch_async(queue, self.abortMultipartUpload);
                    }

                    [self finish];
                    return;
                }
                
                [self.completeRequest addPartWithPartNumber:self.currentPartNo withETag:uploadPartResponse.etag];

                self.dataForPart = nil;
                self.retryCount = 0;

                if(self.currentPartNo < self.numberOfParts)
                {
                    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                    dispatch_async(queue, ^{

                        self.currentPartNo++;
                        [self uploadPart:self.currentPartNo];
                    });
                }
                else
                {
                    [self.s3 completeMultipartUpload:self.completeRequest];
                }
            }
        }
        else if([response isKindOfClass:[S3CompleteMultipartUploadResponse class]])
        {
            if([self.putRequest.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)])
            {
                [self.putRequest.delegate request:request
                       didCompleteWithResponse:response];
            }
            
            [self cleanup];
            [self finish];
        }
        
    }
}

- (void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    if ([self isCancelled]) {
        [request cancel];
        if([request isKindOfClass:[S3UploadPartRequest class]])
        {
            if([self.putRequest.delegate respondsToSelector:@selector(request:didSendData:totalBytesWritten:totalBytesExpectedToWrite:)])
            {
                [self.putRequest.delegate request:request
                                      didSendData:bytesWritten
                                totalBytesWritten:(long long)(((long long) self.currentPartNo - 1) * self.partSize + totalBytesWritten)
                        totalBytesExpectedToWrite:(long long)self.contentLength];
            }
        }
        
        [self executeAbort];
        [self cleanup];
        [self finish];
        return;
    }
    
    if(!self.isFinished && self.isExecuting && !self.isCancelled)
    {
        if([request isKindOfClass:[S3UploadPartRequest class]])
        {
            if([self.putRequest.delegate respondsToSelector:@selector(request:didSendData:totalBytesWritten:totalBytesExpectedToWrite:)])
            {
                [self.putRequest.delegate request:request
                                   didSendData:bytesWritten
                             totalBytesWritten:(long long)(((long long) self.currentPartNo - 1) * self.partSize + totalBytesWritten)
                     totalBytesExpectedToWrite:(long long)self.contentLength];
            }
        }
    }
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    if ([self isCancelled]) {
        [request cancel];
        if([self.putRequest.delegate respondsToSelector:@selector(request:didFailWithError:)])
        {
            [self.putRequest.delegate request:request didFailWithError:error];
        }
        [self executeAbort];
        [self cleanup];
        [self finish];
        return;
    }
    
    if(!self.isFinished && self.isExecuting && !self.isCancelled)
    {
        AMZLogDebug(@"Error: %@", error);

        self.error = error;
        self.exception = [AmazonServiceException exceptionWithMessage:[error description] andError:error];

        if((self.s3.maxRetries > self.retryCount && (self.error || self.exception))
           && [self.s3 shouldRetry:nil exception:self.exception]
           && [self isExecuting]
           && ![self isCancelled])
        {
            AMZLogDebug(@"Retrying %@", [request class]);

            self.response = nil;
            self.retryCount++;

            if([request isKindOfClass:[S3InitiateMultipartUploadRequest class]])
            {
                [self.s3 initiateMultipartUpload:self.initRequest];
            }
            else if([request isKindOfClass:[S3UploadPartRequest class]])
            {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{

                    [self uploadPart:self.currentPartNo];
                });
            }
            else if([request isKindOfClass:[S3CompleteMultipartUploadRequest class]])
            {
                [self.s3 completeMultipartUpload:self.completeRequest];
            }

            return;
        }

        [self executeAbort];

        if([self.putRequest.delegate respondsToSelector:@selector(request:didFailWithError:)])
        {
            [self.putRequest.delegate request:request didFailWithError:error];
        }

        [self finish];
    }
}

- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    if ([self isCancelled]) {
        [request cancel];
        if([self.putRequest.delegate respondsToSelector:@selector(request:didFailWithServiceException:)])
        {
            [self.putRequest.delegate request:request didFailWithServiceException:exception];
        }
        [self executeAbort];
        [self cleanup];
        [self finish];
        return;
    }
    
    if(!self.isFinished && self.isExecuting && !self.isCancelled)
    {
        AMZLogDebug(@"Exception: %@", exception);

        self.exception = exception;

        if((self.s3.maxRetries > self.retryCount && (self.error || self.exception))
           && [self.s3 shouldRetry:nil exception:self.exception]
           && [self isExecuting]
           && ![self isCancelled])
        {
            AMZLogDebug(@"Retrying %@", [request class]);

            self.response = nil;
            self.retryCount++;

            if([request isKindOfClass:[S3InitiateMultipartUploadRequest class]])
            {
                [self.s3 initiateMultipartUpload:self.initRequest];
            }
            else if([request isKindOfClass:[S3UploadPartRequest class]])
            {
                dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
                dispatch_async(queue, ^{

                    [self uploadPart:self.currentPartNo];
                });
            }
            else if([request isKindOfClass:[S3CompleteMultipartUploadRequest class]])
            {
                [self.s3 completeMultipartUpload:self.completeRequest];
            }

            return;
        }

        [self executeAbort];

        if([self.putRequest.delegate respondsToSelector:@selector(request:didFailWithServiceException:)])
        {
            [self.putRequest.delegate request:request didFailWithServiceException:exception];
        }

        [self finish];
    }
}

#pragma mark - Helper Methods

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];

    _isExecuting = NO;
    _isFinished  = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (AWSRange)getDataRange:(NSInteger)partNo withContentLength:(int64_t)contentLength
{
    AWSRange range;
    range.length = self.partSize;
    range.location = (partNo - 1) * self.partSize;

    int64_t maxByte = partNo * self.partSize;
    if (contentLength < maxByte) {
        range.length = contentLength - range.location;
    }

    return range;
}

- (int64_t)contentLengthForRequest:(S3PutObjectRequest *)request
{
    if(request.data != nil)
    {
        return self.putRequest.data.length;
    }
    else
    {
        return request.contentLength;
    }
}

- (NSInteger)numberOfParts:(int64_t)contentLength
{
    return (NSInteger)ceil((double)contentLength / self.partSize);
}

- (void)updateProperties:(AmazonServiceRequest *)serviceRequest
{
    serviceRequest.requestTag = self.putRequest.requestTag;

    if([serviceRequest isKindOfClass:[S3Request class]])
    {
        S3Request *s3Request = (S3Request *)serviceRequest;
        s3Request.authorization = self.putRequest.authorization;
        s3Request.contentType = self.putRequest.contentType;
        s3Request.securityToken = self.putRequest.securityToken;
        s3Request.subResource = self.putRequest.subResource;

        if([serviceRequest isKindOfClass:[S3AbstractPutRequest class]])
        {
            S3AbstractPutRequest *abstractPutRequest = (S3AbstractPutRequest *)serviceRequest;

            abstractPutRequest.cannedACL = self.putRequest.cannedACL;
            abstractPutRequest.storageClass = self.putRequest.storageClass;
            abstractPutRequest.serverSideEncryption = self.putRequest.serverSideEncryption;
            abstractPutRequest.fullACL = self.putRequest.fullACL;

            if([self.putRequest.metadata count] > 0)
            {
                abstractPutRequest.metadata = [NSMutableDictionary dictionaryWithDictionary:self.putRequest.metadata];
            }

            if([serviceRequest isKindOfClass:[S3InitiateMultipartUploadRequest class]])
            {
                S3InitiateMultipartUploadRequest *initRequest = (S3InitiateMultipartUploadRequest *)serviceRequest;
                
                initRequest.cacheControl = self.putRequest.cacheControl;
                initRequest.contentDisposition = self.putRequest.contentDisposition;
                initRequest.contentEncoding = self.putRequest.contentEncoding;
                initRequest.redirectLocation = self.putRequest.redirectLocation;
            }
        }
        else if([serviceRequest isKindOfClass:[S3UploadPartRequest class]])
        {
            // No property to update.
        }
        else if([serviceRequest isKindOfClass:[S3CompleteMultipartUploadRequest class]])
        {
            // No property to update.
        }
    }
}

- (void)setS3CompleteMultipartUploadRequest:(S3MultipartUpload *)theMultipartUpload withParts:(NSMutableDictionary *)partEtags
{
    self.completeRequest = [[[S3CompleteMultipartUploadRequest alloc] initWithMultipartUpload:theMultipartUpload] autorelease];
    for (NSString *key in partEtags) {
        [self.completeRequest addPartWithPartNumber:(int32_t)[key integerValue] withETag:[partEtags objectForKey:key]];
    }
}

- (void)setS3MultipartUploadObject:(S3MultipartUpload *)theMultipartUpload
{
    [self setMultipartUpload:theMultipartUpload];
}

- (void)cleanup:(AmazonServiceRequest *)request
{
    [request cancel];
    [self executeAbort];
    [self cleanup];
}

- (void)executeAbort
{
    // We only want to cleanup S3 when request is cancelled
    if(self.abortMultipartUpload && !self.isPaused)
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_async(queue, self.abortMultipartUpload);
    }
}

#pragma mark -

@end
