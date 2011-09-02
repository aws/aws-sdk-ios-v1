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

#import "SimpleDBListDomainsRequestMarshaller.h"

@implementation SimpleDBListDomainsRequestMarshaller

+(AmazonServiceRequest *)createRequest:(SimpleDBListDomainsRequest *)listDomainsRequest
{
    AmazonServiceRequest *request = [[SimpleDBRequest alloc] init];

    [request setParameterValue:@"ListDomains"           forKey:@"Action"];
    [request setParameterValue:@"2009-04-15"   forKey:@"Version"];

    [request setDelegate:[listDomainsRequest delegate]];
    [request setCredentials:[listDomainsRequest credentials]];
    [request setEndpoint:[listDomainsRequest requestEndpoint]];
    [request setRequestTag:[listDomainsRequest requestTag]];

    if (listDomainsRequest != nil) {
        if (listDomainsRequest.maxNumberOfDomains != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", listDomainsRequest.maxNumberOfDomains] forKey:[NSString stringWithFormat:@"%@", @"MaxNumberOfDomains"]];
        }
    }
    if (listDomainsRequest != nil) {
        if (listDomainsRequest.nextToken != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", listDomainsRequest.nextToken] forKey:[NSString stringWithFormat:@"%@", @"NextToken"]];
        }
    }


    return [request autorelease];
}

@end

