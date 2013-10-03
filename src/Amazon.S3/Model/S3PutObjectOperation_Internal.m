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

@interface S3PutObjectOperation_Internal ()
{
    BOOL _isExecuting;
    BOOL _isFinished;
}

@property (nonatomic, assign) NSInteger retryCount;
@property (nonatomic, assign) id<AmazonServiceRequestDelegate> delegate;

@end

@implementation S3PutObjectOperation_Internal

@synthesize s3 = _s3;
@synthesize request = _request;
@synthesize response = _response;

@synthesize retryCount = _retryCount;
@synthesize delegate = _delegate;

#pragma mark - Class Lifecycle

- (id)init
{
    if (self = [super init])
    {
        _isExecuting = NO;
        _isFinished = NO;

        _retryCount = 0;
    }

    return self;
}

- (void)dealloc
{
    [_s3 release];
    [_request release];
    [_response release];
    
    [_error release];
    [_exception release];

    [super dealloc];
}

#pragma mark - Overwriding NSOperation Methods

- (void)start
{
    // Makes sure that start method always runs on the main thread.
    if (![NSThread isMainThread])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self start];
        });
        
        return;
    }
    if([self isCancelled]) {
        if(self.request) {
            [self.request cancel];
        }
        [self finish];
        return;
    }

    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];

    self.delegate = self.request.delegate;
    self.request.delegate = self;
    
    [self.s3 putObject:self.request];
}

-(void)cancel
{
    [self.request cancel];
    [super cancel];
    [self finish];
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

    [self finish];
}

- (void)request:(AmazonServiceRequest *)request didSendData:(long long)bytesWritten totalBytesWritten:(long long)totalBytesWritten totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite
{
    if([self isCancelled]) {
        [request cancel];
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
    if([self isCancelled]) {
        [self finish];
        return;
    }

    self.error = error;

    self.exception = [AmazonServiceException exceptionWithMessage:[error description] andError:error];

    if(self.s3.maxRetries > self.retryCount
       && [self.s3 shouldRetry:nil exception:self.exception])
    {
        [self.s3 putObject:self.request];
        self.retryCount++;

        return;
    }

    if([self.delegate respondsToSelector:@selector(request:didFailWithError:)])
    {
        [self.delegate request:request didFailWithError:error];
    }

    [self finish];
}

- (void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)exception
{
    AMZLogDebug(@"%@", exception);
    if([self isCancelled]) {
        [self finish];
        return;
    }

    self.exception = exception;

    if(self.s3.maxRetries > self.retryCount
       && [self.s3 shouldRetry:nil exception:self.exception])
    {        
        [self.s3 putObject:self.request];
        self.retryCount++;
        
        return;
    }

    if([self.delegate respondsToSelector:@selector(request:didFailWithServiceException:)])
    {
        [self.delegate request:request didFailWithServiceException:exception];
    }

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
