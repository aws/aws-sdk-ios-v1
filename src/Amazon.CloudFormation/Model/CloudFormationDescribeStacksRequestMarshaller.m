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
 
#import "CloudFormationDescribeStacksRequestMarshaller.h"


@implementation CloudFormationDescribeStacksRequestMarshaller


+(AmazonServiceRequest *)createRequest:(CloudFormationDescribeStacksRequest *)describeStacksRequest
{
    AmazonServiceRequest *request = [[CloudFormationRequest alloc] init];

    [request setParameterValue:@"DescribeStacks" forKey:@"Action"];
    [request setParameterValue:@"2010-05-15" forKey:@"Version"];

    [request setDelegate:[describeStacksRequest delegate]];
    [request setCredentials:[describeStacksRequest credentials]];
    [request setEndpoint:[describeStacksRequest requestEndpoint]];
    [request setRequestTag:[describeStacksRequest requestTag]];


	if (describeStacksRequest != nil) {
        if (describeStacksRequest.nextToken != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", describeStacksRequest.nextToken] forKey:[NSString stringWithFormat:@"%@", @"NextToken"]];
        }
	}				

	if (describeStacksRequest != nil) {
        if (describeStacksRequest.stackName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", describeStacksRequest.stackName] forKey:[NSString stringWithFormat:@"%@", @"StackName"]];
        }
	}				


    return [request autorelease];
}
@end