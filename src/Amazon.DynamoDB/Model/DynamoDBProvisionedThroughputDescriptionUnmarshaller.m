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

#import "DynamoDBProvisionedThroughputDescriptionUnmarshaller.h"
#import "DynamoDBExceptionUnmarshaller.h"
#import "../AmazonSDKUtil.h"


@implementation DynamoDBProvisionedThroughputDescriptionUnmarshaller


+(DynamoDBProvisionedThroughputDescription *)unmarshall:(NSDictionary *)jsonObject
{
    DynamoDBProvisionedThroughputDescription *provisionedThroughputDescription = [[[DynamoDBProvisionedThroughputDescription alloc] init] autorelease];



    if ([jsonObject valueForKey:@"LastIncreaseDateTime"] != nil) {
        provisionedThroughputDescription.lastIncreaseDateTime = [AmazonSDKUtil secondsSinceEpochToDate:[jsonObject valueForKey:@"LastIncreaseDateTime"]];
    }


    if ([jsonObject valueForKey:@"LastDecreaseDateTime"] != nil) {
        provisionedThroughputDescription.lastDecreaseDateTime = [AmazonSDKUtil secondsSinceEpochToDate:[jsonObject valueForKey:@"LastDecreaseDateTime"]];
    }


    if ([jsonObject valueForKey:@"ReadCapacityUnits"] != nil) {
        provisionedThroughputDescription.readCapacityUnits = [jsonObject valueForKey:@"ReadCapacityUnits"];
    }


    if ([jsonObject valueForKey:@"WriteCapacityUnits"] != nil) {
        provisionedThroughputDescription.writeCapacityUnits = [jsonObject valueForKey:@"WriteCapacityUnits"];
    }

    return provisionedThroughputDescription;
}

@end
