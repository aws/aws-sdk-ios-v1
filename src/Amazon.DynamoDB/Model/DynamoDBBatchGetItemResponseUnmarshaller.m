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

#import "DynamoDBBatchGetItemResponseUnmarshaller.h"
#import "DynamoDBExceptionUnmarshaller.h"

#import "AmazonSDKUtil.h"
#import "DynamoDBAttributeValueUnmarshaller.h"
#import "DynamoDBAttributeValueUnmarshaller.h"
#import "DynamoDBKeysAndAttributesUnmarshaller.h"
#import "DynamoDBKeysAndAttributesUnmarshaller.h"
#import "DynamoDBConsumedCapacityUnmarshaller.h"
#import "DynamoDBCapacityUnmarshaller.h"

@implementation DynamoDBBatchGetItemResponseUnmarshaller

+(DynamoDBBatchGetItemResponse *)unmarshall:(NSDictionary *)jsonObject
{
    DynamoDBBatchGetItemResponse *batchGetItemResult = [[[DynamoDBBatchGetItemResponse alloc] init] autorelease];


    if ([jsonObject valueForKey:@"__type"] != nil) {
        [batchGetItemResult setException:[DynamoDBExceptionUnmarshaller unmarshall:jsonObject]];
    }
    else {
        NSDictionary *responsesObject = [jsonObject valueForKey:@"Responses"];
        for (NSString *key in [responsesObject allKeys]) {
            NSMutableArray *arrayObject = [[[NSMutableArray alloc] init] autorelease];
            [batchGetItemResult.responses setValue:arrayObject forKey:key];



            NSArray *valueArray = [responsesObject valueForKey:key];
            for (NSDictionary *mapObject in valueArray) {
                NSMutableDictionary *member = [[[NSMutableDictionary alloc] init] autorelease];
                for (NSString *key in [mapObject allKeys]) {
                    NSDictionary *value = [mapObject valueForKey:key];
                    [member setValue:[DynamoDBAttributeValueUnmarshaller unmarshall:value] forKey:key];
                }


                [arrayObject addObject:member];
            }
        }


        NSDictionary *unprocessedKeysObject = [jsonObject valueForKey:@"UnprocessedKeys"];
        for (NSString *key in [unprocessedKeysObject allKeys]) {
            NSDictionary *value = [unprocessedKeysObject valueForKey:key];
            [batchGetItemResult.unprocessedKeys setValue:[DynamoDBKeysAndAttributesUnmarshaller unmarshall:value] forKey:key];
        }


        NSArray *consumedCapacityArray = [jsonObject valueForKey:@"ConsumedCapacity"];
        for (NSDictionary *memberObject in consumedCapacityArray) {
            [batchGetItemResult.consumedCapacity addObject:[DynamoDBConsumedCapacityUnmarshaller unmarshall:memberObject]];
        }
    }

    return batchGetItemResult;
}

@end
