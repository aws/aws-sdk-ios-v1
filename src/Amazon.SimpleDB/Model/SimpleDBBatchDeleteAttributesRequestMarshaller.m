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

#import "SimpleDBBatchDeleteAttributesRequestMarshaller.h"

@implementation SimpleDBBatchDeleteAttributesRequestMarshaller

+(AmazonServiceRequest *)createRequest:(SimpleDBBatchDeleteAttributesRequest *)batchDeleteAttributesRequest
{
    AmazonServiceRequest *request = [[SimpleDBRequest alloc] init];

    [request setParameterValue:@"BatchDeleteAttributes"           forKey:@"Action"];
    [request setParameterValue:@"2009-04-15"   forKey:@"Version"];

    [request setDelegate:[batchDeleteAttributesRequest delegate]];
    [request setCredentials:[batchDeleteAttributesRequest credentials]];
    [request setEndpoint:[batchDeleteAttributesRequest requestEndpoint]];
    [request setRequestTag:[batchDeleteAttributesRequest requestTag]];

    if (batchDeleteAttributesRequest != nil) {
        if (batchDeleteAttributesRequest.domainName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", batchDeleteAttributesRequest.domainName] forKey:[NSString stringWithFormat:@"%@", @"DomainName"]];
        }
    }

    if (batchDeleteAttributesRequest != nil) {
        int itemsListIndex = 1;
        for (SimpleDBDeletableItem *itemsListValue in batchDeleteAttributesRequest.items) {
            if (itemsListValue != nil) {
                if (itemsListValue.name != nil) {
                    [request setParameterValue:[NSString stringWithFormat:@"%@", itemsListValue.name] forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Item", itemsListIndex, @"ItemName"]];
                }
            }

            if (itemsListValue != nil) {
                int attributesListIndex = 1;
                for (SimpleDBAttribute *attributesListValue in itemsListValue.attributes) {
                    if (attributesListValue != nil) {
                        if (attributesListValue.name != nil) {
                            [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.name] forKey:[NSString stringWithFormat:@"%@.%d.%@.%d.%@", @"Item", itemsListIndex, @"Attribute", attributesListIndex, @"Name"]];
                        }
                    }
                    if (attributesListValue != nil) {
                        if (attributesListValue.alternateNameEncoding != nil) {
                            [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.alternateNameEncoding] forKey:[NSString stringWithFormat:@"%@.%d.%@.%d.%@", @"Item", itemsListIndex, @"Attribute", attributesListIndex, @"AlternateNameEncoding"]];
                        }
                    }
                    if (attributesListValue != nil) {
                        if (attributesListValue.value != nil) {
                            [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.value] forKey:[NSString stringWithFormat:@"%@.%d.%@.%d.%@", @"Item", itemsListIndex, @"Attribute", attributesListIndex, @"Value"]];
                        }
                    }
                    if (attributesListValue != nil) {
                        if (attributesListValue.alternateValueEncoding != nil) {
                            [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.alternateValueEncoding] forKey:[NSString stringWithFormat:@"%@.%d.%@.%d.%@", @"Item", itemsListIndex, @"Attribute", attributesListIndex, @"AlternateValueEncoding"]];
                        }
                    }

                    attributesListIndex++;
                }
            }

            itemsListIndex++;
        }
    }


    return [request autorelease];
}

@end

