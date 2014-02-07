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

#import "DynamoDBConsumedCapacityUnmarshaller.h"
#import "DynamoDBExceptionUnmarshaller.h"

#import "AmazonSDKUtil.h"
#import "DynamoDBCapacityUnmarshaller.h"

@implementation DynamoDBConsumedCapacityUnmarshaller

+(DynamoDBConsumedCapacity *)unmarshall:(NSDictionary *)jsonObject
{
    DynamoDBConsumedCapacity *consumedCapacity = [[[DynamoDBConsumedCapacity alloc] init] autorelease];



    if ([jsonObject valueForKey:@"TableName"] != nil) {
        consumedCapacity.tableName = [jsonObject valueForKey:@"TableName"];
    }


    if ([jsonObject valueForKey:@"CapacityUnits"] != nil) {
        consumedCapacity.capacityUnits = [jsonObject valueForKey:@"CapacityUnits"];
    }


    if ([jsonObject valueForKey:@"Table"] != nil) {
        consumedCapacity.table = [DynamoDBCapacityUnmarshaller unmarshall:[jsonObject valueForKey:@"Table"]];
    }


    NSDictionary *localSecondaryIndexesObject = [jsonObject valueForKey:@"LocalSecondaryIndexes"];
    for (NSString *key in [localSecondaryIndexesObject allKeys]) {
        NSDictionary *value = [localSecondaryIndexesObject valueForKey:key];
        [consumedCapacity.localSecondaryIndexes setValue:[DynamoDBCapacityUnmarshaller unmarshall:value] forKey:key];
    }


    NSDictionary *globalSecondaryIndexesObject = [jsonObject valueForKey:@"GlobalSecondaryIndexes"];
    for (NSString *key in [globalSecondaryIndexesObject allKeys]) {
        NSDictionary *value = [globalSecondaryIndexesObject valueForKey:key];
        [consumedCapacity.globalSecondaryIndexes setValue:[DynamoDBCapacityUnmarshaller unmarshall:value] forKey:key];
    }

    return consumedCapacity;
}

@end
