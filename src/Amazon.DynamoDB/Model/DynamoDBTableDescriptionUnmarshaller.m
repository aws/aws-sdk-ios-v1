/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import "DynamoDBTableDescriptionUnmarshaller.h"
#import "DynamoDBExceptionUnmarshaller.h"
#import "../AmazonSDKUtil.h"
#import "DynamoDBKeySchemaUnmarshaller.h"
#import "DynamoDBProvisionedThroughputDescriptionUnmarshaller.h"


@implementation DynamoDBTableDescriptionUnmarshaller


+(DynamoDBTableDescription *)unmarshall:(NSDictionary *)jsonObject
{
    DynamoDBTableDescription *tableDescription = [[[DynamoDBTableDescription alloc] init] autorelease];



    if ([jsonObject valueForKey:@"TableName"] != nil) {
        tableDescription.tableName = [jsonObject valueForKey:@"TableName"];
    }


    if ([jsonObject valueForKey:@"KeySchema"] != nil) {
        tableDescription.keySchema = [DynamoDBKeySchemaUnmarshaller unmarshall:[jsonObject valueForKey:@"KeySchema"]];
    }


    if ([jsonObject valueForKey:@"TableStatus"] != nil) {
        tableDescription.tableStatus = [jsonObject valueForKey:@"TableStatus"];
    }


    if ([jsonObject valueForKey:@"CreationDateTime"] != nil) {
        tableDescription.creationDateTime = [AmazonSDKUtil secondsSinceEpochToDate:[jsonObject valueForKey:@"CreationDateTime"]];
    }


    if ([jsonObject valueForKey:@"ProvisionedThroughput"] != nil) {
        tableDescription.provisionedThroughput = [DynamoDBProvisionedThroughputDescriptionUnmarshaller unmarshall:[jsonObject valueForKey:@"ProvisionedThroughput"]];
    }


    if ([jsonObject valueForKey:@"TableSizeBytes"] != nil) {
        tableDescription.tableSizeBytes = [jsonObject valueForKey:@"TableSizeBytes"];
    }


    if ([jsonObject valueForKey:@"ItemCount"] != nil) {
        tableDescription.itemCount = [jsonObject valueForKey:@"ItemCount"];
    }

    return tableDescription;
}

@end
