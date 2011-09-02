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

#import "SimpleDBGetAttributesRequestMarshaller.h"

@implementation SimpleDBGetAttributesRequestMarshaller

+(AmazonServiceRequest *)createRequest:(SimpleDBGetAttributesRequest *)getAttributesRequest
{
    AmazonServiceRequest *request = [[SimpleDBRequest alloc] init];

    [request setParameterValue:@"GetAttributes"           forKey:@"Action"];
    [request setParameterValue:@"2009-04-15"   forKey:@"Version"];

    [request setDelegate:[getAttributesRequest delegate]];
    [request setCredentials:[getAttributesRequest credentials]];
    [request setEndpoint:[getAttributesRequest requestEndpoint]];
    [request setRequestTag:[getAttributesRequest requestTag]];

    if (getAttributesRequest != nil) {
        if (getAttributesRequest.domainName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", getAttributesRequest.domainName] forKey:[NSString stringWithFormat:@"%@", @"DomainName"]];
        }
    }
    if (getAttributesRequest != nil) {
        if (getAttributesRequest.itemName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", getAttributesRequest.itemName] forKey:[NSString stringWithFormat:@"%@", @"ItemName"]];
        }
    }
    if (getAttributesRequest != nil) {
        int attributeNamesListIndex = 1;
        for (NSString *attributeNamesListValue in getAttributesRequest.attributeNames) {
            if (attributeNamesListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", attributeNamesListValue] forKey:[NSString stringWithFormat:@"%@.%d", @"AttributeName", attributeNamesListIndex]];
            }
            attributeNamesListIndex++;
        }
    }
    if (getAttributesRequest != nil) {
        if (getAttributesRequest.consistentReadIsSet) {
            [request setParameterValue:(getAttributesRequest.consistentRead ? @"true":@"false")forKey:[NSString stringWithFormat:@"%@", @"ConsistentRead"]];
        }
    }


    return [request autorelease];
}

@end

