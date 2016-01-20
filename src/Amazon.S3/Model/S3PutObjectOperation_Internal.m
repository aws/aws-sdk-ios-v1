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

#import "S3PutObjectOperation_Internal.h"
#import "AmazonServiceRequest.h"

@interface S3PutObjectOperation_Internal ()
{
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, weak) id<AmazonServiceRequestDelegate> delegate;

@end

@implementation S3PutObjectOperation_Internal

@synthesize transferRequestType = _transferRequestType;

#pragma mark - Class Lifecycle

- (id)init
{
    if (self = [super init])
    {
        _isExecuting = NO;
        _isFinished = NO;

        _retryCount = 0;
        _transferRequestType = S3TRANSFER_UPLOAD;
    }

    return self;
}

- (void)dealloc
{
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

    self.delegate = self.putRequest.delegate;
    self.putRequest.delegate = self;
    
    if (self.isCancelled) {
        [self cleanup];
        [self finish];
        return;
    }
    
    [self.s3 putObject:self.putRequest];
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
    self.response = response;

    if([self.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)])
    {
        [self.delegate request:request
       didCompleteWithResponse:response];
    }
    
    [self cleanup];
    [self finish];
}

- (void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    if (self.isCancelled) {
        [self.putRequest cancel];
        if([self.delegate respondsToSelector:@selector(request:didSendData:totalBytesWritten:totalBytesExpectedToWrite:)])
        {
            [self.delegate request:request
                       didSendData:bytesWritten
                 totalBytesWritten:totalBytesWritten
         totalBytesExpectedToWrite:totalBytesExpectedToWrite];
        }
        
        [self cleanup];
        [self finish];
        return;
    }
    
    if([self.delegate respondsToSelector:@selector(request:didSendData:totalBytesWritten:totalBytesExpectedToWrite:)])
    {
        [self.delegate request:request
                   didSendData:bytesWritten
             totalBytesWritten:totalBytesWritten
     totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

- (void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)error
{
    AMZLogDebug(@"%@", error);
    
    if (self.isCancelled) {
        [self.putRequest cancel];
        if([self.delegate respondsToSelector:@selector(request:didFailWithError:)])
        {
            [self.delegate request:request didFailWithError:error];
        }
        [self cleanup];
        [self finish];
        return;
    }

    self.error = error;

    self.exception = [AmazonServiceException exceptionWithMessage:[error description] andError:error];

    if(self.s3.maxRetries > self.retryCount
       && [self.s3 shouldRetry:nil exception:self.exception])
    {
        [self.s3 putObject:self.putRequest];
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

- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    AMZLogDebug(@"%@", exception);
    
    if (self.isCancelled) {
        [self.putRequest cancel];
        if([self.delegate respondsToSelector:@selector(request:didFailWithServiceException:)])
        {
            [self.delegate request:request didFailWithServiceException:exception];
        }
        [self cleanup];
        [self finish];
        return;
    }

    self.exception = exception;

    if(self.s3.maxRetries > self.retryCount
       && [self.s3 shouldRetry:nil exception:self.exception])
    {        
        [self.s3 putObject:self.putRequest];
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

#pragma mark -

@end
