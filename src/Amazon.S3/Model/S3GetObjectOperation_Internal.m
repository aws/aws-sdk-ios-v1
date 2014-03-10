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

#import "S3GetObjectOperation_Internal.h"
#import "AmazonServiceRequest.h"
#import <CommonCrypto/CommonDigest.h>

const int32_t kBufferSize = 32768;
const int32_t kNotStarted = -1;

@interface S3GetObjectOperation_Internal ()
{
    BOOL _isExecuting;
    BOOL _isFinished;
    CC_MD5_CTX md5sum;
}

@property (nonatomic, assign) int32_t retryCount;
@property (nonatomic, assign) int64_t s3FileSize;
@property (nonatomic, assign) NSString *etag;
@property (nonatomic, assign) id<AmazonServiceRequestDelegate> delegate;
@property (nonatomic, retain) NSOutputStream *outputStream;

@end

@implementation S3GetObjectOperation_Internal

@synthesize transferRequestType = _transferRequestType;

#pragma mark - Class Lifecycle

- (id)init
{
    if (self = [super init])
    {
        _isExecuting = NO;
        _isFinished = NO;
        
        _retryCount = 0;
        _transferRequestType = S3TRANSFER_DOWNLOAD;
    }
    
    return self;
}

- (void)dealloc
{
    [_response release];
    
    [_outputStream release];
    [super dealloc];
}

#pragma mark - Overriding NSOperation Methods

- (void)start
{
    // if cancel has been called on operation then we do not want to start the operation
    if (self.isCancelled) {
        [self cleanup];
        [self finish];
        return;
    }
    
    // Makes sure that start method always runs on the main thread.
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self start];
        });
        
        return;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    self.delegate = self.getRequest.delegate;
    self.getRequest.delegate = self;
    
    if (self.isCancelled) {
        [self cleanup];
        [self finish];
        return;
    }
    
    // Initialize MD5Sum calculation
    CC_MD5_Init(&md5sum);
    
    // Initialize s3FileSize so we know whether to do a range request or not
    self.s3FileSize = kNotStarted;
        
    // Check if file we're downloading has already been downloaded
    if (self.getRequest.targetFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:self.getRequest.targetFilePath]) {
        
        // If file exists on disk, get the s3 filesize and etag for comparison
        if (![self getFileMetaData]) {
            return;
        }

        //calculate md5 of file so far
        uint8_t buffer[kBufferSize];
        
        NSInputStream *inputStream = [NSInputStream inputStreamWithFileAtPath:self.getRequest.targetFilePath];
        [inputStream open];
        
        int32_t bytesRead = -1;
        while((bytesRead = (int32_t)[inputStream read:buffer maxLength:kBufferSize])>0){
            CC_MD5_Update(&md5sum, buffer, bytesRead);
        }
        
        [inputStream close];
        
        //if local file size matches remote filesize
        if ([self getTargetedFileSize] == self.s3FileSize) {
            //if the md5sum matches, throw an exception to let the developer know local file already matches remote file.
            if([self checkMD5Sum]) {
                [self cleanup];
                [self finish];
                
                AmazonClientException *ace = [[AmazonClientException alloc] initWithMessage:@"Operation cannot be completed. Local file already exists and matches file in S3."];
                if([self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                    [self.delegate request:self.getRequest didFailWithError:[AmazonErrorHandler errorFromException:ace]];
                } else if([self.delegate respondsToSelector:@selector(request:didFailWithServiceException:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [self.delegate request:self.getRequest didFailWithServiceException:ace];
#pragma clang diagnostic pop
                }
                [ace release];
                return;
            }else {
                // MD55sum didn't match, delete file and start over
                // Initialize MD5Sum calculation
                CC_MD5_Init(&md5sum);
                
                self.s3FileSize = kNotStarted;
                
                // delete existing file so we can start over
                NSError *error = nil;
                [[NSFileManager defaultManager] removeItemAtPath:self.getRequest.targetFilePath error:&error];
                if (error != nil) {
                    if ([self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                        AMZLog(@"Integrity check failed, unable to delete file at location %@ to start over.", self.getRequest.targetFilePath);
                        [self.delegate request:self.getRequest didFailWithError:error];
                    }
                    [self cleanup];
                    [self finish];
                    return;
                }
            }
        } else {
            
            // Set range to remaining bytes to download
            [self setGetRangeForRequest];
        }
    }
    
    // Get how many bytes have been transferred
    self.totalBytesTransferred = [self getTargetedFileSize];
    
    if(self.getRequest.targetFilePath !=nil){
        // initialize the output stream and set append to YES so if anything goes wrong, we can resume and append data
        self.outputStream = [[[NSOutputStream alloc] initToFileAtPath:self.getRequest.targetFilePath append:YES ] autorelease];
    
        [self.outputStream open];
        
        self.getRequest.outputStream = self.outputStream;
    }
    
    
    [self.s3 getObject:self.getRequest];
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

#pragma mark - AmazonServiceRequestDelegate Implementations

- (void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)response
{
    if (self.isCancelled) {
        if([self.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)])
        {
            [self.delegate request:request didCompleteWithResponse:response];
        }
        [self cleanup];
        [self finish];
        return;
    }
    
    if (!self.isFinished && self.isExecuting && !self.isCancelled) {
        self.response = response;
        
        // Response has to be S3GetObjectResponse
        if ([response isKindOfClass:[S3GetObjectResponse class]]) {
            
            self.etag = ((S3GetObjectResponse *)response).etag;

            //check md5sum
            if (![self checkMD5Sum]) {
                    
                    NSString *msg = [NSString stringWithFormat:@"Unable to verify integrity of data download. Client calculated content hash didn't match hash calculated by Amazon S3: %@.", self.etag];
                    AmazonClientException *exception = [[AmazonClientException alloc] initWithMessage:msg];
                    
                    if ([self.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
                        NSError *error = [AmazonErrorHandler errorFromException:exception];
                        [self.delegate request:request didFailWithError:error];
                    }
                    else if ([self.delegate respondsToSelector:@selector(request:didFailWithServiceException:)]) {
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
                        [self.delegate request:request didFailWithServiceException:exception];
    #pragma clang diagnostic pop
                    }
                    
                    [self cleanup];
                    [self finish];
                    
                    [exception release];
                    return;
            }
        }
        
        if([self.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)])
        {
            [self.delegate request:request didCompleteWithResponse:response];
        }
        
        [self cleanup];
        [self finish];
    }
}

- (void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    if (self.isCancelled) {
        [self.getRequest cancel];
        if ([self.delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
            [self.delegate request:request didReceiveResponse:response];
        }
        [self cleanup];
        [self finish];
        return;
    }

    NSDictionary * headers = ((NSHTTPURLResponse *)response).allHeaderFields;
    //if content-range is not set (this is not a range download), content-length is the length of the file
    if ([headers objectForKey:(@"Content-Range")] == nil) {
        self.s3FileSize = [[headers objectForKey:(@"Content-Length")] longLongValue];
    }
    
    if ([self.delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [self.delegate request:request didReceiveResponse:response];
    }
}

- (void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data
{
    if (self.isCancelled) {
        [self.getRequest cancel];
        if([self.delegate respondsToSelector:@selector(request:didReceiveData:)]) {
            [self.delegate request:request didReceiveData:data];
        }
        [self cleanup];
        [self finish];
        return;
    }
    
    if (!self.isFinished && self.isExecuting && !self.isCancelled) {
        // increment bytes transferred so far
        self.totalBytesTransferred += data.length;

        if(data.length > UINT32_MAX)
        {
            @throw [AmazonClientException exceptionWithMessage:@"The NSData size is too large. The maximum allowable size is UINT32_MAX."];
        }
        
        // update md5sum
        CC_MD5_Update(&md5sum, data.bytes, (uint32_t)data.length);
        
        if([self.delegate respondsToSelector:@selector(request:didReceiveData:)]) {
            [self.delegate request:request didReceiveData:data];
        }
    }
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    AMZLog(@"Failed with error: %@", error);
    
    if (self.isCancelled) {
        [self.getRequest cancel];
        if([self.delegate respondsToSelector:@selector(request:didFailWithError:)])
        {
            [self.delegate request:request didFailWithError:error];
        }
        [self cleanup];
        [self finish];
        return;
    }
    
    if (!self.isFinished && self.isExecuting && !self.isCancelled) {
        self.error = error;
        self.exception = [AmazonServiceException exceptionWithMessage:[error description] andError:error];
        
        if(self.s3.maxRetries > self.retryCount && ([self.s3 shouldRetry:nil exception:self.exception] || [self shouldRetry]))
        {
            // Set the range from where we need to download
            [self setGetRangeForRequest];
            
            [self.s3 getObject:self.getRequest];
            self.retryCount++;
            
            return;
        }
        
        if([self.delegate respondsToSelector:@selector(request:didFailWithError:)])
        {
            [self.delegate request:request didFailWithError:error];
        }
        
        [self cleanup];
        [self finish];
    }
}

- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    AMZLog(@"Failed with exception: %@", exception);
    
    if (self.isCancelled) {
        [self.getRequest cancel];
        if([self.delegate respondsToSelector:@selector(request:didFailWithServiceException:)])
        {
            [self.delegate request:request didFailWithServiceException:exception];
        }
        [self cleanup];
        [self finish];
        return;
    }
    
    if (!self.isFinished && self.isExecuting && !self.isCancelled) {
        self.exception = exception;
        
        if(self.s3.maxRetries > self.retryCount && ([self.s3 shouldRetry:nil exception:self.exception] || [self shouldRetry]))
        {
            // Set the range from where we need to download
            [self setGetRangeForRequest];
            
            [self.s3 getObject:self.getRequest];
            self.retryCount++;
            
            return;
        }
        
        if([self.delegate respondsToSelector:@selector(request:didFailWithServiceException:)])
        {
            [self.delegate request:request didFailWithServiceException:exception];
        }
        
        [self cleanup];
        [self finish];
    }
}

#pragma mark - Helper Methods

- (void)cleanup
{
    //close the outputstream if it exists
    if (self.getRequest.outputStream && self.getRequest.outputStream.streamStatus == NSStreamStatusOpen)
    {
        [self.getRequest.outputStream close];
    }
    
    if (self.isCancelled && !self.isPaused && self.getRequest.targetFilePath != nil) {
        NSError *error = nil;
        [[NSFileManager defaultManager] removeItemAtPath:self.getRequest.targetFilePath error:&error];
        if (error != nil) {
            AMZLogDebug(@"Error when removing file during cleanup: %@", error);
        }
    }
    [super cleanup];
}

- (void)finish
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    _isExecuting = NO;
    _isFinished  = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

/**
 * Check client exception for errors. This is ignored in shouldRetry method of AmazonAbstractWebServiceClient
 * because that method checks response.exception, however the above delegate methods pass nil for 
 * the response.
 **/
- (BOOL)shouldRetry
{
    if ([[self.error.userInfo valueForKey:@"message"] isEqualToString:@"Request timed out."]) {
        return YES;
    }
    
    if ([self.exception isKindOfClass:[AmazonClientException class]]) {
        AmazonClientException *ace = (AmazonClientException *)self.exception;
        
        if([ace.error.domain isEqualToString:NSURLErrorDomain] && ace.error.code == NSURLErrorNetworkConnectionLost)
        {
            // The network connection was lost.
            return YES;
        }
        
        if([ace.error.domain isEqualToString:NSURLErrorDomain] && ace.error.code == NSURLErrorTimedOut)
        {
            // The request timed out.
            return YES;
        }
        
        if([ace.error.domain isEqualToString:NSURLErrorDomain] && ace.error.code == NSURLErrorCannotFindHost)
        {
            // S3 sometimes returns this error even when the bucket exists.
            return YES;
        }
    }
    
    return NO;
}

- (void)setGetRangeForRequest
{
    //if we know the s3FileSize, make a range request
    //instead of a request for the whole file
    if(self.s3FileSize !=  kNotStarted) {
        // set the start and end range for download
        unsigned long long localFileSize = [self getTargetedFileSize];
        [self.getRequest setRangeStart:localFileSize rangeEnd:self.s3FileSize];
    }
}

- (unsigned long long)getTargetedFileSize
{
    if (self.getRequest.targetFilePath == nil || ![[NSFileManager defaultManager] fileExistsAtPath:self.getRequest.targetFilePath]) {
        return 0;
    }
    
    NSError *attributesError = nil;
    NSDictionary *fileAttributes = [[NSFileManager defaultManager]
                                    attributesOfItemAtPath:self.getRequest.targetFilePath error:&attributesError];
    
    if (nil != attributesError) {
        AMZLog(@"Error when getting file attributes for %@: %@", self.getRequest.targetFilePath, attributesError);
    }
    
    return [fileAttributes fileSize];
}

- (BOOL)getFileMetaData
{
    // Get the size of the file that is being downloaded
    S3GetObjectMetadataRequest *metadataRequest = nil;
    if (nil == self.getRequest.versionId) {
        metadataRequest = [[S3GetObjectMetadataRequest alloc]
                           initWithKey:self.getRequest.key
                           withBucket:self.getRequest.bucket];
    }
    else {
        metadataRequest = [[S3GetObjectMetadataRequest alloc]
                           initWithKey:self.getRequest.key
                           withBucket:self.getRequest.bucket
                           withVersionId:self.getRequest.versionId];
    }
    S3GetObjectMetadataResponse *metadata;
    
    @try {
        metadata = [self.s3 getObjectMetadata:metadataRequest];
        if (metadata.error != nil) {
            self.error = metadata.error;
            self.exception = [AmazonServiceException exceptionWithMessage:[self.error description] andError:self.error];
        }
    }
    @catch (NSException *exception) {
        self.exception = exception;
        self.error = [AmazonErrorHandler errorFromException:exception];
    }
    
    // If the metadata call fails, report back
    if (self.error != nil) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([self.delegate respondsToSelector:@selector(request:didFailWithError:)])
            {
                [self.delegate request:metadataRequest didFailWithError:self.error];
            }
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_async(queue, ^{
                [self cleanup];
                [self finish];
            });
        });
        return NO;
    }
    
    self.s3FileSize = [metadata contentLength];
    self.etag =[metadata etag];
    [metadataRequest release];
    
    return YES;
}

/**
 * Check md5sum of file on disk against S3 etag.
 * @return YES if etag is multipart and no md5sum check is possible, or etag and md5sum match.
 */
- (BOOL)checkMD5Sum
{
    // Only do md5sum check if etag isn't multipart
    if ([self.etag rangeOfString:@"-"].location == NSNotFound) {
        // Finalize MD5Sum of the downloaded data to compare with etag
        unsigned char digest[CC_MD5_DIGEST_LENGTH];
        CC_MD5_Final(digest, &md5sum);
        
        // Convert to hex
        NSMutableString* md5 = [[NSMutableString alloc] init];
        for (int i = 0 ; i < CC_MD5_DIGEST_LENGTH; i++)
        {
            [md5 appendFormat: @"%02x", digest[i]];
        }
        
        // S3 response wraps etag in quotes, strip them.
        self.etag = [self.etag stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        BOOL md5IsEqual = [md5 isEqualToString:self.etag];
        if(!md5IsEqual){
            AMZLogDebug(@"Integrity check failed, S3 md5sum was:%@ local md5sum was: %@", self.etag, md5);
        }
        return md5IsEqual;
    }
    return YES;
}

@end
