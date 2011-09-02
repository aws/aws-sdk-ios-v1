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

#import "SimpleDBDeleteAttributesRequestMarshaller.h"

@implementation SimpleDBDeleteAttributesRequestMarshaller

+(AmazonServiceRequest *)createRequest:(SimpleDBDeleteAttributesRequest *)deleteAttributesRequest
{
    AmazonServiceRequest *request = [[SimpleDBRequest alloc] init];

    [request setParameterValue:@"DeleteAttributes"           forKey:@"Action"];
    [request setParameterValue:@"2009-04-15"   forKey:@"Version"];

    [request setDelegate:[deleteAttributesRequest delegate]];
    [request setCredentials:[deleteAttributesRequest credentials]];
    [request setEndpoint:[deleteAttributesRequest requestEndpoint]];
    [request setRequestTag:[deleteAttributesRequest requestTag]];
    
    if (deleteAttributesRequest != nil) {
        if (deleteAttributesRequest.domainName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", deleteAttributesRequest.domainName] forKey:[NSString stringWithFormat:@"%@", @"DomainName"]];
        }
    }
    if (deleteAttributesRequest != nil) {
        if (deleteAttributesRequest.itemName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", deleteAttributesRequest.itemName] forKey:[NSString stringWithFormat:@"%@", @"ItemName"]];
        }
    }

    if (deleteAttributesRequest != nil) {
        int attributesListIndex = 1;
        for (SimpleDBAttribute *attributesListValue in deleteAttributesRequest.attributes) {
            if (attributesListValue != nil) {
                if (attributesListValue.name != nil) {
                    [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.name] forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Attribute", attributesListIndex, @"Name"]];
                }
            }
            if (attributesListValue != nil) {
                if (attributesListValue.alternateNameEncoding != nil) {
                    [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.alternateNameEncoding] forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Attribute", attributesListIndex, @"AlternateNameEncoding"]];
                }
            }
            if (attributesListValue != nil) {
                if (attributesListValue.value != nil) {
                    [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.value] forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Attribute", attributesListIndex, @"Value"]];
                }
            }
            if (attributesListValue != nil) {
                if (attributesListValue.alternateValueEncoding != nil) {
                    [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.alternateValueEncoding] forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Attribute", attributesListIndex, @"AlternateValueEncoding"]];
                }
            }

            attributesListIndex++;
        }
    }
    if (deleteAttributesRequest != nil) {
        SimpleDBUpdateCondition *expected = deleteAttributesRequest.expected;
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

