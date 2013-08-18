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
 
#import "CloudFormationDescribeStackResourcesRequestMarshaller.h"


@implementation CloudFormationDescribeStackResourcesRequestMarshaller


+(AmazonServiceRequest *)createRequest:(CloudFormationDescribeStackResourcesRequest *)describeStackResourcesRequest
{
    AmazonServiceRequest *request = [[CloudFormationRequest alloc] init];

    [request setParameterValue:@"DescribeStackResources" forKey:@"Action"];
    [request setParameterValue:@"2010-05-15" forKey:@"Version"];

    [request setDelegate:[describeStackResourcesRequest delegate]];
    [request setCredentials:[describeStackResourcesRequest credentials]];
    [request setEndpoint:[describeStackResourcesRequest requestEndpoint]];
    [request setRequestTag:[describeStackResourcesRequest requestTag]];


	if (describeStackResourcesRequest != nil) {
        if (describeStackResourcesRequest.logicalResourceId != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", describeStackResourcesRequest.logicalResourceId] forKey:[NSString stringWithFormat:@"%@", @"LogicalResourceId"]];
        }
	}				

	if (describeStackResourcesRequest != nil) {
        if (describeStackResourcesRequest.physicalResourceId != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", describeStackResourcesRequest.physicalResourceId] forKey:[NSString stringWithFormat:@"%@", @"PhysicalResourceId"]];
        }
	}				

	if (describeStackResourcesRequest != nil) {
        if (describeStackResourcesRequest.stackName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", describeStackResourcesRequest.stackName] forKey:[NSString stringWithFormat:@"%@", @"StackName"]];
        }
	}				


    return [request autorelease];
}
@end