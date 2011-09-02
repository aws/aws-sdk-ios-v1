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


#import "AmazonServiceRequest.h"
#import "AmazonAuthUtils.h"

@implementation AmazonServiceRequest

@synthesize httpMethod;
@synthesize parameters;
@synthesize endpoint;
@synthesize userAgent;
@synthesize credentials;
@synthesize urlConnection;
@synthesize requestTag;

-(void)sign
{
    [self setParameterValue:credentials.accessKey forKey:@"AWSAccessKeyId"];
    [self setParameterValue:@"2"                                        forKey:@"SignatureVersion"];
    [self setParameterValue:[NSDate ISO8061FormattedCurrentTimestamp]   forKey:@"Timestamp"];
    [self setParameterValue:@"HmacSHA256"                               forKey:@"SignatureMethod"];

    NSData   *dataToSign = [[AmazonAuthUtils getV2StringToSign:[NSURL URLWithString:self.endpoint] request:self] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *signature  = [AmazonAuthUtils HMACSign:dataToSign withKey:credentials.secretKey usingAlgorithm:kCCHmacAlgSHA256];

    [self setParameterValue:signature forKey:@"Signature"];
}

-(NSMutableURLRequest *)configureURLRequest
{
    [self.urlRequest setHTTPMethod:@"POST"];
    [self.urlRequest setHTTPBody:[[self queryString] dataUsingEncoding:NSUTF8StringEncoding]];
    [self.urlRequest setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];

    NSURL *url = [NSURL URLWithString:self.endpoint];
    [urlRequest setURL:url];
    [urlRequest setValue:[url host] forHTTPHeaderField:@"Host"];

    return self.urlRequest;
}

-(NSString *)queryString
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    NSArray         *keys       = [[self parameters] allKeys];
    NSArray         *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
    for (int index = 0; index < [sortedKeys count]; index++) {
        NSString *key   = [sortedKeys objectAtIndex:index];
        NSString *value = (NSString *)[[self parameters] valueForKey:key];

        [buffer appendString:[AmazonSDKUtil urlEncode:key]];
        [buffer appendString:@"="];
        [buffer appendString:[AmazonSDKUtil urlEncode:value]];

        if (index < [sortedKeys count] - 1) {
            [buffer appendString:@"&"];
        }
    }

    return [buffer autorelease];
}

-(AmazonURLRequest *)urlRequest
{
    if (nil == urlRequest) {
        urlRequest = [[AmazonURLRequest alloc] init];
    }

    return urlRequest;
}

-(void)setUrlRequest:(AmazonURLRequest *)request
{
    if (nil != urlRequest)
    {
        [urlRequest release];
        urlRequest = nil;
    }
    urlRequest = [request retain];
}

-(void)setParameterValue:(NSString *)theValue forKey:(NSString *)theKey
{
    if (nil == parameters) {
        parameters = [[NSMutableDictionary alloc] initWithCapacity:1];
    }
    [parameters setValue:theValue forKey:theKey];
}

-(NSURL *)url
{
    return nil;
}

-(void)setDelegate:(id<AmazonServiceRequestDelegate> )aDelegate
{
    delegate = aDelegate;
}

-(id<AmazonServiceRequestDelegate> )delegate
{
    return delegate;
}

-(void)dealloc
{
    [credentials release];
    [endpoint release];
    [urlRequest release];
    [parameters release];
    [userAgent release];
    [urlConnection release];

    [super dealloc];
}

@end
