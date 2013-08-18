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
 
#import "CloudFormationGetTemplateRequestMarshaller.h"


@implementation CloudFormationGetTemplateRequestMarshaller


+(AmazonServiceRequest *)createRequest:(CloudFormationGetTemplateRequest *)getTemplateRequest
{
    AmazonServiceRequest *request = [[CloudFormationRequest alloc] init];

    [request setParameterValue:@"GetTemplate" forKey:@"Action"];
    [request setParameterValue:@"2010-05-15" forKey:@"Version"];

    [request setDelegate:[getTemplateRequest delegate]];
    [request setCredentials:[getTemplateRequest credentials]];
    [request setEndpoint:[getTemplateRequest requestEndpoint]];
    [request setRequestTag:[getTemplateRequest requestTag]];


	if (getTemplateRequest != nil) {
        if (getTemplateRequest.stackName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", getTemplateRequest.stackName] forKey:[NSString stringWithFormat:@"%@", @"StackName"]];
        }
	}				


    return [request autorelease];
}
@end