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

#import "AmazonWebServiceClient.h"
#import "AmazonEndpoints.h"

@implementation AmazonWebServiceClient

@synthesize endpoint, maxRetries, timeout, userAgent;

-(id)initWithAccessKey:(NSString *)theAccessKey withSecretKey:(NSString *)theSecretKey
{
    if (self = [self init]) {
        credentials = [[AmazonCredentials alloc] initWithAccessKey:theAccessKey withSecretKey:theSecretKey];
        maxRetries  = 5;
        timeout     = 240;
        userAgent   = [[AmazonSDKUtil userAgentString] retain];
    }
    return self;
}

-(id)initWithCredentials:(AmazonCredentials *)theCredentials
{
    if (self = [self init]) {
        credentials = [theCredentials retain];
        maxRetries  = 5;
        timeout     = 240;
        userAgent   = [[AmazonSDKUtil userAgentString] retain];
    }
    return self;
}

+(id)constructResponseFromRequest:(AmazonServiceRequest *)request
{
    NSString *requestClassName  = NSStringFromClass([request class]);
    NSString *responseClassName = [[requestClassName substringToIndex:[requestClassName length] - 7] stringByAppendingFormat:@"Response"];

    id       response = [[NSClassFromString(responseClassName) alloc] init];

    if (nil == response) {
        response = [[AmazonServiceResponse alloc] init];
    }

    return [response autorelease];
}

-(AmazonServiceResponse *)invoke:(AmazonServiceRequest *)generatedRequest rawRequest:(AmazonServiceRequestConfig *)originalRequest unmarshallerDelegate:(Class)unmarshallerDelegate
{
    if (nil == generatedRequest) {
        @throw [AmazonClientException exceptionWithMessage : @"Request cannot be nil."];
    }

    [generatedRequest setUserAgent:self.userAgent];

    if (nil == generatedRequest.endpoint) {
        generatedRequest.endpoint = [self endpoint];
    }
    if (nil == generatedRequest.credentials) {
        [generatedRequest setCredentials:credentials];
    }

    NSMutableURLRequest *urlRequest = [generatedRequest configureURLRequest];
    [generatedRequest sign];
    [urlRequest setHTTPBody:[[generatedRequest queryString] dataUsingEncoding:NSUTF8StringEncoding]];

    AMZLogDebug(@"%@ %@", [urlRequest HTTPMethod], [urlRequest URL]);
    AMZLogDebug(@"Request body: ");
    NSString *rBody = [[NSString alloc] initWithData:[urlRequest HTTPBody] encoding:NSUTF8StringEncoding];
    AMZLogDebug(@"%@", rBody);
    [rBody release];

    AmazonServiceResponse *response = nil;
    int                   retries   = 0;
    while (retries < self.maxRetries) {
        AMZLogDebug(@"Begin Request: %@:%d", NSStringFromClass([generatedRequest class]), retries);

        response = [AmazonWebServiceClient constructResponseFromRequest:generatedRequest];
        [response setRequest:generatedRequest];
        response.unmarshallerDelegate = unmarshallerDelegate;

        [urlRequest setTimeoutInterval:self.timeout];

        // Setting this here and not the AmazonServiceRequest because S3 extends that class and sets its own Content-Type Header.
        [urlRequest addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];

        NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:response];

        originalRequest.urlConnection = urlConnection;

        if ([generatedRequest delegate] == nil) {
            NSTimer         *timeoutTimer  = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:response selector:@selector(timeout) userInfo:nil repeats:NO];
            generatedRequest.delegate = [[[AmazonRequestDelegate alloc] init] autorelease];

            while (![(AmazonRequestDelegate *)(generatedRequest.delegate)isFinishedOrFailed]) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }

            if (response.didTimeout) {
                [urlConnection cancel];
            }
            else {
                [timeoutTimer invalidate];     //  invalidate also releases the object.
            }

            AMZLogDebug(@"Response Status Code : %d", response.httpStatusCode);
            if ( [self shouldRetry:response]) {
                AMZLog(@"Retring Request: %d", retries);
                generatedRequest.delegate = nil;

                [self pauseExponentially:retries];
                retries++;
            }
            else {
                break;
            }
        }
        else {
            return nil;
        }
    }

    if (response.exception != nil) {
        @throw response.exception;
    }
    else {
        if (((AmazonRequestDelegate *)generatedRequest.delegate).exception != nil) {
            @throw((AmazonRequestDelegate *)generatedRequest.delegate).exception;
        }
        else if (((AmazonRequestDelegate *)generatedRequest.delegate).response != nil) {
            return ((AmazonRequestDelegate *)generatedRequest.delegate).response;
        }
        else {
            return nil; //TODO: Throw an exception here AmazonClientException
        }
    }
}

-(bool)shouldRetry:(AmazonServiceResponse *)response
{
    if (response.didTimeout ||
        response.httpStatusCode == 500 ||
        response.httpStatusCode == 503 ||
        (response.exception != nil &&
         response.exception.reason != nil &&
         [response.exception.reason rangeOfString:@"Throttling"].location != NSNotFound)) {
        return YES;
    }

    return NO;
}

-(void)pauseExponentially:(int)tryCount
{
    NSTimeInterval pause = 0.5 * (pow(2, tryCount));

    [NSThread sleepForTimeInterval:pause];
}

-(void)setUserAgent:(NSString *)newUserAgent
{
    userAgent = [[NSString stringWithFormat:@"%@, %@", newUserAgent, [AmazonSDKUtil userAgentString]] retain];
}

-(void)dealloc
{
    [credentials release];
    [endpoint release];
    [userAgent release];

    [super dealloc];
}

@end
