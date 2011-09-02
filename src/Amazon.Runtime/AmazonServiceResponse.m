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


#import "AmazonServiceResponse.h"
#import "AmazonServiceResponseUnmarshaller.h"
#import "AmazonLogger.h"

@implementation AmazonServiceResponse

@synthesize httpStatusCode;
@synthesize isFinishedLoading;
@synthesize request;
@synthesize requestId;
@synthesize didTimeout;
@synthesize unmarshallerDelegate;

-(id)init
{
    self = [super init];
    if (self != nil) {
        isFinishedLoading = NO;
        didTimeout        = NO;
        exception         = nil;
    }

    return self;
}

-(NSData *)body
{
    return [NSData dataWithData:body];
}

// TODO: Make the body property readonly when all operations are converted to the delegate technique.
-(void)setBody:(NSData *)data
{
    if (nil != body) {
        [body setLength:0];
    }
    body = [[NSMutableData dataWithData:data] retain];
    [self processBody];
}

// Override this to perform processing on the body.
-(void)processBody
{
    // Subclasses can use this to build object data from the response, for example
    // parsing XML content.
}

-(void)postProcess
{
}

-(void)timeout
{
    if (!isFinishedLoading && !exception) {
        didTimeout = YES;
        exception  = [[AmazonClientException exceptionWithMessage:@"Request timed out."] retain];

        if ([(NSObject *)request.delegate respondsToSelector:@selector(request:didFailWithServiceException:)]) {
            [request.delegate request:request didFailWithServiceException:exception];
        }
    }
}

-(NSException *)exception
{
    return exception;
}

#pragma mark NSURLConnection delegate methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;

    self.httpStatusCode = [httpResponse statusCode];

    [body setLength:0];

    if ([(NSObject *)self.request.delegate respondsToSelector:@selector(request:didReceiveResponse:)]) {
        [self.request.delegate request:self.request didReceiveResponse:response];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil == body) {
        body = [[NSMutableData data] retain];
    }

    [body appendData:data];

    if ([(NSObject *)self.request.delegate respondsToSelector:@selector(request:didReceiveData:)]) {
        [self.request.delegate request:self.request didReceiveData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    isFinishedLoading = YES;

    NSString *tmpStr = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];

    AMZLogDebug(@"Response Body:\n%@", tmpStr);
    [tmpStr release];
    NSXMLParser                       *parser         = [[NSXMLParser alloc] initWithData:body];
    AmazonServiceResponseUnmarshaller *parserDelegate = [[unmarshallerDelegate alloc] init];
    [parser setDelegate:parserDelegate];
    [parser parse];

    AmazonServiceResponse *tmpReq   = [parserDelegate response];
    AmazonServiceResponse *response = [tmpReq retain];

    [parser release];
    [parserDelegate release];

    if (response.exception) {
        NSException *exceptionFound = [[response.exception copy] autorelease];
        [response release];
        if ([(NSObject *)request.delegate respondsToSelector:@selector(request:didFailWithServiceException:)]) {
            [request.delegate request:request didFailWithServiceException:(AmazonServiceException *)exceptionFound];
            return;
        }
        else {
            @throw exceptionFound;
        }
    }

    [response postProcess];

    if ([(NSObject *)request.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)]) {
        [request.delegate request:request didCompleteWithResponse:response];
    }

    [response release];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSDictionary *info = [error userInfo];
    for (id key in info)
    {
        AMZLogDebug(@"UserInfo.%@ = %@", [key description], [[info valueForKey:key] description]);
    }
    exception = [[AmazonClientException exceptionWithMessage:[error description] andError:error] retain];
    AMZLogDebug(@"An error occured in the request: %@", [error description]);

    if ([(NSObject *)self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [self.request.delegate request:self.request didFailWithError:error];
    }
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([(NSObject *)self.request.delegate respondsToSelector:@selector(request:didSendData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.request.delegate request:self.request
         didSendData:bytesWritten
         totalBytesWritten:totalBytesWritten
         totalBytesExpectedToWrite:totalBytesExpectedToWrite];
    }
}

// When a request gets a redirect due to the bucket being in a different region,
// The request gets re-written with a GET http method. This is to set the method back to
// the appropriate method if necessary
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)proposedRequest redirectResponse:(NSURLResponse *)redirectResponse
{
    return proposedRequest;
}

#pragma mark memory management

-(void)dealloc
{
    [requestId release];
    [body release];
    [exception release];
    [request release];

    [super dealloc];
}

-(NSString *)description
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    [buffer appendString:@"{"];
    [buffer appendString:[[[NSString alloc] initWithFormat:@"requestId: %@", requestId] autorelease]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}

@end
