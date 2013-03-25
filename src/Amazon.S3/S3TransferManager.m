/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "S3TransferManager.h"

#import "S3PutObjectOperation_Internal.h"
#import "S3MultipartUploadOperation_Internal.h"
#import "S3AbortMultiplartUploadsOperation_Internal.h"
#import "AmazonErrorHandler.h"

// Private Constants
NSUInteger const S3MultipartMinimumUploadSize = 5242880;
NSInteger const S3DefaultMaxConcurrentOperationCount = 3;

@interface S3TransferManager ()
{
}

@end

@implementation S3TransferManager

@synthesize delegate = _delegate;
@synthesize s3 = _s3;
@synthesize minimumUploadPartSize = _minimumUploadPartSize;
@synthesize multipartUploadThreshold = _multipartUploadThreshold;
@synthesize noSyncMethodsOnMainThread = _noSyncMethodsOnMainThread;

#pragma mark - Class lifecycle Methods

- (id)init
{
    if(self = [super init])
    {
        _minimumUploadPartSize = S3MultipartMinimumUploadSize;
        _multipartUploadThreshold = S3MultipartMinimumUploadSize;
        _noSyncMethodsOnMainThread = YES;
    }

    return self;
}

- (void)dealloc
{
    [_s3 release];

    [super dealloc];
}

#pragma mark - Synchronous Upload Methods

- (AmazonServiceResponse *)synchronouslyUpload:(S3PutObjectRequest *)putObjectRequest
{
    if(self.noSyncMethodsOnMainThread
       && [NSThread isMainThread])
    {
        AmazonClientException *exception = [AmazonClientException exceptionWithMessage:@"A synchronous method was called on the main thread. You need to call it from a background thread."];
        NSError *error = [AmazonErrorHandler errorFromExceptionWithThrowsExceptionOption:exception];

        AmazonServiceResponse *response = [AmazonServiceResponse new];
        response.error = error;

        return [response autorelease];
    }

    [putObjectRequest validate];

    if([self shouldUseMutipartUpload:putObjectRequest])
    {
        // Multipart Upload
        S3MultipartUploadOperation_Internal *multipartUploadOperation = [S3MultipartUploadOperation_Internal new];
        multipartUploadOperation.s3 = self.s3;
        multipartUploadOperation.request = putObjectRequest;
        multipartUploadOperation.partSize = self.minimumUploadPartSize;
        multipartUploadOperation.delegate = self.delegate;

        [self.operationQueue addOperations:[NSArray arrayWithObject:multipartUploadOperation] waitUntilFinished:YES];
        [multipartUploadOperation autorelease];

        if(multipartUploadOperation.response)
        {
            return multipartUploadOperation.response;
        }
        else if(multipartUploadOperation.error) // Check error before exception. When an error occurs, an exception object will be generated tool
        {
            AmazonServiceResponse *response = [[AmazonServiceResponse new] autorelease];
            response.error = multipartUploadOperation.error;

            return response;
        }
        else if(multipartUploadOperation.exception)
        {
            @throw multipartUploadOperation.exception;
        }
    }
    else
    {
        // Put
        S3PutObjectOperation_Internal *putObjectOperation = [S3PutObjectOperation_Internal new];
        putObjectOperation.s3 = self.s3;
        putObjectOperation.request = putObjectRequest;
        putObjectOperation.delegate = self.delegate;

        [self.operationQueue addOperations:[NSArray arrayWithObject:putObjectOperation] waitUntilFinished:YES];
        [putObjectOperation autorelease];

        if(putObjectOperation.response)
        {
            return putObjectOperation.response;
        }
        else if(putObjectOperation.error) // Check error before exception. When an error occurs, an exception object will be generated tool
        {
            S3PutObjectResponse *response = [[S3PutObjectResponse new] autorelease];
            response.error = putObjectOperation.error;

            return response;
        }
        else if(putObjectOperation.exception)
        {
            @throw putObjectOperation.exception;
        }
    }

    return nil;
}

- (AmazonServiceResponse *)synchronouslyUploadData:(NSData *)data bucket:(NSString *)bucket key:(NSString *)key
{
    S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest new] autorelease];
    putObjectRequest.data = data;
    putObjectRequest.bucket = bucket;
    putObjectRequest.key = key;

    return [self synchronouslyUpload:putObjectRequest];
}

- (AmazonServiceResponse *)synchronouslyUploadFile:(NSString *)filename bucket:(NSString *)bucket key:(NSString *)key
{
    S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest new] autorelease];
    putObjectRequest.filename = filename;
    putObjectRequest.bucket = bucket;
    putObjectRequest.key = key;

    return [self synchronouslyUpload:putObjectRequest];
}

- (AmazonServiceResponse *)synchronouslyUploadStream:(NSInputStream *)stream contentLength:(int64_t)contentLength bucket:(NSString *)bucket key:(NSString *)key
{
    S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest new] autorelease];
    putObjectRequest.stream = stream;
    putObjectRequest.contentLength = contentLength;
    putObjectRequest.bucket = bucket;
    putObjectRequest.key = key;

    return [self synchronouslyUpload:putObjectRequest];
}

#pragma mark - Asynchronous Upload Methods

- (void)upload:(S3PutObjectRequest *)putObjectRequest
{
    [putObjectRequest validate];

    if([self shouldUseMutipartUpload:putObjectRequest])
    {
        // Multipart Upload
        S3MultipartUploadOperation_Internal *multipartUploadOperation = [S3MultipartUploadOperation_Internal new];
        multipartUploadOperation.s3 = self.s3;
        multipartUploadOperation.request = putObjectRequest;
        multipartUploadOperation.partSize = self.minimumUploadPartSize;

        if(putObjectRequest.delegate == nil)
        {
            multipartUploadOperation.delegate = self.delegate;
        }
        else
        {
            multipartUploadOperation.delegate = putObjectRequest.delegate;
        }

        [self.operationQueue addOperation:multipartUploadOperation];
        [multipartUploadOperation release];
    }
    else
    {
        // Put
        S3PutObjectOperation_Internal *putObjectOperation = [S3PutObjectOperation_Internal new];
        putObjectOperation.s3 = self.s3;
        putObjectOperation.request = putObjectRequest;
        
        if(putObjectRequest.delegate == nil)
        {
            putObjectOperation.delegate = self.delegate;
        } else {
            putObjectOperation.delegate = putObjectRequest.delegate;
        }

        [self.operationQueue addOperation:putObjectOperation];
        [putObjectOperation release];
    }
}

- (void)uploadData:(NSData *)data bucket:(NSString *)bucket key:(NSString *)key
{
    S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest new] autorelease];
    putObjectRequest.data = data;
    putObjectRequest.bucket = bucket;
    putObjectRequest.key = key;

    [self upload:putObjectRequest];
}

- (void)uploadFile:(NSString *)filename bucket:(NSString *)bucket key:(NSString *)key
{
    S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest new] autorelease];
    putObjectRequest.filename = filename;
    putObjectRequest.bucket = bucket;
    putObjectRequest.key = key;

    [self upload:putObjectRequest];
}

- (void)uploadStream:(NSInputStream *)stream contentLength:(long)contentLength bucket:(NSString *)bucket key:(NSString *)key
{
    S3PutObjectRequest *putObjectRequest = [[S3PutObjectRequest new] autorelease];
    putObjectRequest.stream = stream;
    putObjectRequest.contentLength = contentLength;
    putObjectRequest.bucket = bucket;
    putObjectRequest.key = key;

    [self upload:putObjectRequest];
}

#pragma mark - Abort Multipart Uploads

- (void)abortMultipartUploads:(NSString *)bucket initiatedBefore:(NSDate *)date
{
    S3AbortMultiplartUploadsOperation_Internal *abortMultiplartUploadsOperation = [S3AbortMultiplartUploadsOperation_Internal new];
    abortMultiplartUploadsOperation.s3 = self.s3;
    abortMultiplartUploadsOperation.delegate = self.delegate;
    abortMultiplartUploadsOperation.bucket = bucket;
    abortMultiplartUploadsOperation.date = date;

    [self.operationQueue addOperation:abortMultiplartUploadsOperation];
    [abortMultiplartUploadsOperation release];
}

- (void)abortMultipartUploads:(NSString *)bucket forKey:(NSString *)key
{
    S3AbortMultiplartUploadsOperation_Internal *abortMultiplartUploadsOperation = [S3AbortMultiplartUploadsOperation_Internal new];
    abortMultiplartUploadsOperation.s3 = self.s3;
    abortMultiplartUploadsOperation.delegate = self.delegate;
    abortMultiplartUploadsOperation.bucket = bucket;
    abortMultiplartUploadsOperation.key = key;

    [self.operationQueue addOperation:abortMultiplartUploadsOperation];
    [abortMultiplartUploadsOperation release];
}

#pragma mark - Helper Methods

- (NSOperationQueue *)operationQueue
{
    static NSOperationQueue *_operationQueue = nil;

    if(_operationQueue == nil)
    {
        @synchronized(self)
        {
            if(_operationQueue == nil)
            {
                _operationQueue = [NSOperationQueue new];
                _operationQueue.maxConcurrentOperationCount = S3DefaultMaxConcurrentOperationCount;
            }
        }
    }

    return _operationQueue;
}

- (BOOL)shouldUseMutipartUpload:(S3PutObjectRequest *)putObjectRequest
{
    if(putObjectRequest.data)
    {
        return putObjectRequest.data.length > self.multipartUploadThreshold;
    }
    else
    {
        return putObjectRequest.contentLength > self.multipartUploadThreshold;
    }
}

- (void)setuploadPartSize:(NSUInteger)minimumUploadPartSize
{
    if(minimumUploadPartSize > S3MultipartMinimumUploadSize)
    {
        _minimumUploadPartSize = minimumUploadPartSize;
    }
}

- (NSUInteger)multipartUploadThreshold
{
    if(_multipartUploadThreshold < self.minimumUploadPartSize)
    {
        return self.minimumUploadPartSize;
    }
    else
    {
        return _multipartUploadThreshold;
    }
}

- (void)setMultipartUploadThreshold:(NSUInteger)multipartUploadThreshold
{
    if(multipartUploadThreshold > S3MultipartMinimumUploadSize)
    {
        _multipartUploadThreshold = multipartUploadThreshold;
    }
}

- (AmazonS3Client *)s3
{
    @synchronized(self)
    {
        return _s3;
    }
}

- (void)setS3:(AmazonS3Client *)s3
{
    @synchronized(self)
    {
        [_s3 release];

        _s3 = [s3 copy];

        if(![_s3.userAgent hasPrefix:AWSS3TransferManagerUserAgentPrefix])
        {
            _s3.userAgent = AWSS3TransferManagerUserAgentPrefix;
        }
    }
}

#pragma mark -

@end
