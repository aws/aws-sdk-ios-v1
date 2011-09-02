/*
 * Copyright 2010-2011 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "AmazonRequestDelegate.h"
#import "AmazonLogger.h"

@implementation AmazonRequestDelegate

@synthesize response;
@synthesize error;
@synthesize exception;

-(id)init
{
    self = [super init];
    if (self)
    {
        response  = nil;
        exception = nil;
        error     = nil;
    }
    return self;
}

-(bool)isFinishedOrFailed
{
    return (response != nil || error != nil || exception != nil);
}

-(void)request:(AmazonServiceRequest *)request didReceiveResponse:(NSURLResponse *)aResponse
{
    AMZLogDebug(@"didReceiveResponse");
}

-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)aResponse
{
    AMZLogDebug(@"didCompleteWithResponse");
    [response release];
    response = [aResponse retain];
}

-(void)request:(AmazonServiceRequest *)request didReceiveData:(NSData *)data
{
    AMZLogDebug(@"didReceiveData");
}

-(void)request:(AmazonServiceRequest *)request didSendData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    AMZLogDebug(@"didSendData");
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
{
    AMZLogDebug(@"didFailWithError: %@", theError);
    [error release];
    error = [theError retain];
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)theException
{
    AMZLogDebug(@"didFailWithServiceException");
    [exception release];
    exception = [theException retain];
}

-(void)dealloc
{
    [error release];
    [exception release];
    [response release];

    [super dealloc];
}

@end





