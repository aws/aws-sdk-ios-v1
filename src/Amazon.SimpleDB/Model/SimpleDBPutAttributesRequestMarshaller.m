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

#import "SimpleDBPutAttributesRequestMarshaller.h"

@implementation SimpleDBPutAttributesRequestMarshaller

+(AmazonServiceRequest *)createRequest:(SimpleDBPutAttributesRequest *)putAttributesRequest
{
    AmazonServiceRequest *request = [[SimpleDBRequest alloc] init];

    [request setParameterValue:@"PutAttributes"           forKey:@"Action"];
    [request setParameterValue:@"2009-04-15"   forKey:@"Version"];

    [request setDelegate:[putAttributesRequest delegate]];
    [request setCredentials:[putAttributesRequest credentials]];
    [request setEndpoint:[putAttributesRequest requestEndpoint]];
    [request setRequestTag:[putAttributesRequest requestTag]];

    if (putAttributesRequest != nil) {
        if (putAttributesRequest.domainName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", putAttributesRequest.domainName] forKey:[NSString stringWithFormat:@"%@", @"DomainName"]];
        }
    }
    if (putAttributesRequest != nil) {
        if (putAttributesRequest.itemName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", putAttributesRequest.itemName] forKey:[NSString stringWithFormat:@"%@", @"ItemName"]];
        }
    }

    if (putAttributesRequest != nil) {
        int attributesListIndex = 1;
        for (SimpleDBReplaceableAttribute *attributesListValue in putAttributesRequest.attributes) {
            if (attributesListValue != nil) {
                if (attributesListValue.name != nil) {
                    [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.name] forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Attribute", attributesListIndex, @"Name"]];
                }
            }
            if (attributesListValue != nil) {
                if (attributesListValue.value != nil) {
                    [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.value] forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Attribute", attributesListIndex, @"Value"]];
                }
            }
            if (attributesListValue != nil) {
                if (attributesListValue.replaceIsSet) {
                    [request setParameterValue:(attributesListValue.replace ? @"true":@"false")forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Attribute", attributesListIndex, @"Replace"]];
                }
            }

            attributesListIndex++;
        }
    }
    if (putAttributesRequest != nil) {
        SimpleDBUpdateCondition *expected = putAttributesRequest.expected;
        if (expected != nil) {
            if (expected.name != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", expected.name] forKey:[NSString stringWithFormat:@"%@.%@", @"Expected", @"Name"]];
            }
        }
        if (expected != nil) {
            if (expected.value != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", expected.value] forKey:[NSString stringWithFormat:@"%@.%@", @"Expected", @"Value"]];
            }
        }
        if (expected != nil) {
            if (expected.existsIsSet) {
                [request setParameterValue:(expected.exists ? @"true":@"false")forKey:[NSString stringWithFormat:@"%@.%@", @"Expected", @"Exists"]];
            }
        }
    }


    return [request autorelease];
}

@end

