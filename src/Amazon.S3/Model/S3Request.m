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

#import "S3Request.h"
#import "S3BucketNameUtilities.h"

@implementation S3Request

#pragma mark Properties

@synthesize authorization;
@synthesize contentLength;
@synthesize contentType;
@synthesize date;
@synthesize securityToken;
@synthesize bucket;
@synthesize key;
@synthesize subResource;

#pragma mark methods

-(AmazonURLRequest *)configureURLRequest
{
    [super configureURLRequest];
    [self setHttpMethod:kHttpMethodGet];

    [self.urlRequest setValue:[NSString stringWithFormat:@"%lld", self.contentLength] forHTTPHeaderField:kHttpHdrContentLength];

    [self.urlRequest setValue:self.host forHTTPHeaderField:kHttpHdrHost];
    [self.urlRequest setValue:[self.date stringWithRFC822Format] forHTTPHeaderField:kHttpHdrDate];

    if (nil != self.httpMethod) {
        [self.urlRequest setHTTPMethod:self.httpMethod];
    }
    if (nil != self.contentType) {
        [self.urlRequest setValue:self.contentType forHTTPHeaderField:kHttpHdrContentType];
    }
    if (nil != self.securityToken) {
        [self.urlRequest setValue:self.securityToken forHTTPHeaderField:kHttpHdrAmzSecurityToken];
    }

    [self.urlRequest setURL:self.url];

    return urlRequest;
}

-(NSString *)timestamp
{
    return [[self date] stringWithRFC822Format];
}

#pragma mark accessors

-(NSURL *)url
{
    NSString *keyPath;
    NSString *resQuery;

    if (self.bucket == nil || [S3BucketNameUtilities isDNSBucketName:self.bucket]) {
        keyPath  = (self.key == nil ? @"" : [NSString stringWithFormat:@"%@", [self.key stringWithURLEncoding]]);
    }
    else {
        keyPath  = (self.key == nil ? [NSString stringWithFormat:@"%@/", self.bucket] : [NSString stringWithFormat:@"%@/%@", self.bucket, [self.key stringWithURLEncoding]]);
    }
    resQuery = (self.subResource == nil ? @"" : [NSString stringWithFormat:@"?%@", self.subResource]);

    return [NSURL URLWithString:[NSString stringWithFormat:@"%@://%@/%@%@", [self protocol], self.host, keyPath, resQuery]];
}

-(NSString *)host
{
    if (nil != self.bucket) {
        if ( [S3BucketNameUtilities isDNSBucketName:self.bucket]) {
            return [NSString stringWithFormat:@"%@.%@", self.bucket, [super hostName]];
        }
    }

    return [self hostName];
}

-(NSDate *)date
{
    if (date == nil) {
        date = [[NSDate date] retain];
    }
    return date;
}

-(NSString *)protocol
{
    if ( [self.endpoint hasPrefix:@"http://"]) {
        return @"http";
    }
    else {
        return @"https";
    }
}

-(NSString *)endpointHost
{
    return [super hostName];
}


#pragma mark memory management

-(void)dealloc
{
    delegate = nil;

    [authorization release];
    [contentType release];
    [date release];
    [securityToken release];
    [httpMethod release];
    [subResource release];
    [key release];
    [bucket release];

    [super dealloc];
}

@end

