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

#import "SimpleDBBatchPutAttributesRequestMarshaller.h"

@implementation SimpleDBBatchPutAttributesRequestMarshaller

+(AmazonServiceRequest *)createRequest:(SimpleDBBatchPutAttributesRequest *)batchPutAttributesRequest
{
    AmazonServiceRequest *request = [[SimpleDBRequest alloc] init];

    [request setParameterValue:@"BatchPutAttributes"           forKey:@"Action"];
    [request setParameterValue:@"2009-04-15"   forKey:@"Version"];

    [request setDelegate:[batchPutAttributesRequest delegate]];
    [request setCredentials:[batchPutAttributesRequest credentials]];
    [request setEndpoint:[batchPutAttributesRequest requestEndpoint]];
    [request setRequestTag:[batchPutAttributesRequest requestTag]];

    if (batchPutAttributesRequest != nil) {
        if (batchPutAttributesRequest.domainName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", batchPutAttributesRequest.domainName] forKey:[NSString stringWithFormat:@"%@", @"DomainName"]];
        }
    }

    if (batchPutAttributesRequest != nil) {
        int itemsListIndex = 1;
        for (SimpleDBReplaceableItem *itemsListValue in batchPutAttributesRequest.items) {
            if (itemsListValue != nil) {
                if (itemsListValue.name != nil) {
                    [request setParameterValue:[NSString stringWithFormat:@"%@", itemsListValue.name] forKey:[NSString stringWithFormat:@"%@.%d.%@", @"Item", itemsListIndex, @"ItemName"]];
                }
            }

            if (itemsListValue != nil) {
                int attributesListIndex = 1;
                for (SimpleDBReplaceableAttribute *attributesListValue in itemsListValue.attributes) {
                    if (attributesListValue != nil) {
                        if (attributesListValue.name != nil) {
                            [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.name] forKey:[NSString stringWithFormat:@"%@.%d.%@.%d.%@", @"Item", itemsListIndex, @"Attribute", attributesListIndex, @"Name"]];
                        }
                    }
                    if (attributesListValue != nil) {
                        if (attributesListValue.value != nil) {
                            [request setParameterValue:[NSString stringWithFormat:@"%@", attributesListValue.value] forKey:[NSString stringWithFormat:@"%@.%d.%@.%d.%@", @"Item", itemsListIndex, @"Attribute", attributesListIndex, @"Value"]];
                        }
                    }
                    if (attributesListValue != nil) {
                        if (attributesListValue.replaceIsSet) {
                            [request setParameterValue:(attributesListValue.replace ? @"true":@"false")forKey:[NSString stringWithFormat:@"%@.%d.%@.%d.%@", @"Item", itemsListIndex, @"Attribute", attributesListIndex, @"Replace"]];
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

