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

#import "S3UploadPartRequest.h"


@implementation S3UploadPartRequest

@synthesize contentMD5;
@synthesize uploadId;
@synthesize partNumber;
@synthesize data;

-(id)initWithMultipartUpload:(S3MultipartUpload *)multipartUpload
{
    [self init];
    self.bucket   = multipartUpload.bucket;
    self.key      = multipartUpload.key;
    self.uploadId = multipartUpload.uploadId;

    return self;
}

-(NSMutableURLRequest *)configureURLRequest
{
    self.subResource = [NSString stringWithFormat:@"%@=%d&%@=%@", kS3QueryParamPartNumber, self.partNumber, kS3QueryParamUploadId, self.uploadId];

    if (self.contentLength < 1) {
        self.contentLength = [data length];
    }

    [super configureURLRequest];

    [self.urlRequest setHTTPBody:self.data];
    if (nil != self.contentMD5) {
        [self.urlRequest setValue:self.contentMD5 forHTTPHeaderField:kHttpHdrContentMD5];
    }

    [urlRequest setHTTPMethod:kHttpMethodPut];

    return urlRequest;
}

-(void)dealloc
{
    [contentMD5 release];
    [uploadId release];
    [data release];

    [super dealloc];
}

@end
