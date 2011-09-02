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

#import "SimpleDBSelectRequestMarshaller.h"

@implementation SimpleDBSelectRequestMarshaller

+(AmazonServiceRequest *)createRequest:(SimpleDBSelectRequest *)selectRequest
{
    AmazonServiceRequest *request = [[SimpleDBRequest alloc] init];

    [request setParameterValue:@"Select"           forKey:@"Action"];
    [request setParameterValue:@"2009-04-15"   forKey:@"Version"];

    [request setDelegate:[selectRequest delegate]];
    [request setCredentials:[selectRequest credentials]];
    [request setEndpoint:[selectRequest requestEndpoint]];
    [request setRequestTag:[selectRequest requestTag]];
    
    if (selectRequest != nil) {
        if (selectRequest.selectExpression != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", selectRequest.selectExpression] forKey:[NSString stringWithFormat:@"%@", @"SelectExpression"]];
        }
    }
    if (selectRequest != nil) {
        if (selectRequest.nextToken != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", selectRequest.nextToken] forKey:[NSString stringWithFormat:@"%@", @"NextToken"]];
        }
    }
    if (selectRequest != nil) {
        if (selectRequest.consistentReadIsSet) {
            [request setParameterValue:(selectRequest.consistentRead ? @"true":@"false")forKey:[NSString stringWithFormat:@"%@", @"ConsistentRead"]];
        }
    }


    return [request autorelease];
}

@end

