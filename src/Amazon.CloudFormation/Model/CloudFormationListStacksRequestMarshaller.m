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
 
#import "CloudFormationListStacksRequestMarshaller.h"


@implementation CloudFormationListStacksRequestMarshaller


+(AmazonServiceRequest *)createRequest:(CloudFormationListStacksRequest *)listStacksRequest
{
    AmazonServiceRequest *request = [[CloudFormationRequest alloc] init];

    [request setParameterValue:@"ListStacks" forKey:@"Action"];
    [request setParameterValue:@"2010-05-15" forKey:@"Version"];

    [request setDelegate:[listStacksRequest delegate]];
    [request setCredentials:[listStacksRequest credentials]];
    [request setEndpoint:[listStacksRequest requestEndpoint]];
    [request setRequestTag:[listStacksRequest requestTag]];


	if (listStacksRequest != nil) {
        if (listStacksRequest.nextToken != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", listStacksRequest.nextToken] forKey:[NSString stringWithFormat:@"%@", @"NextToken"]];
        }
	}				

	if (listStacksRequest != nil) {
        int stackStatusFilterListIndex = 1;
        for (NSString *stackStatusFilterListValue in listStacksRequest.stackStatusFilter) {
            if (stackStatusFilterListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", stackStatusFilterListValue] forKey:[NSString stringWithFormat:@"%@.member.%d", @"StackStatusFilter", stackStatusFilterListIndex]];
            }

            stackStatusFilterListIndex++;
        }
    }


    return [request autorelease];
}
@end