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

#import "SimpleDBDomainMetadataRequestMarshaller.h"

@implementation SimpleDBDomainMetadataRequestMarshaller

+(AmazonServiceRequest *)createRequest:(SimpleDBDomainMetadataRequest *)domainMetadataRequest
{
    AmazonServiceRequest *request = [[SimpleDBRequest alloc] init];

    [request setParameterValue:@"DomainMetadata"           forKey:@"Action"];
    [request setParameterValue:@"2009-04-15"   forKey:@"Version"];

    [request setDelegate:[domainMetadataRequest delegate]];
    [request setCredentials:[domainMetadataRequest credentials]];
    [request setEndpoint:[domainMetadataRequest requestEndpoint]];
    [request setRequestTag:[domainMetadataRequest requestTag]];

    if (domainMetadataRequest != nil) {
        if (domainMetadataRequest.domainName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", domainMetadataRequest.domainName] forKey:[NSString stringWithFormat:@"%@", @"DomainName"]];
        }
    }


    return [request autorelease];
}

@end

