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
 
#import "CloudFormationValidateTemplateRequestMarshaller.h"


@implementation CloudFormationValidateTemplateRequestMarshaller


+(AmazonServiceRequest *)createRequest:(CloudFormationValidateTemplateRequest *)validateTemplateRequest
{
    AmazonServiceRequest *request = [[CloudFormationRequest alloc] init];

    [request setParameterValue:@"ValidateTemplate" forKey:@"Action"];
    [request setParameterValue:@"2010-05-15" forKey:@"Version"];

    [request setDelegate:[validateTemplateRequest delegate]];
    [request setCredentials:[validateTemplateRequest credentials]];
    [request setEndpoint:[validateTemplateRequest requestEndpoint]];
    [request setRequestTag:[validateTemplateRequest requestTag]];


	if (validateTemplateRequest != nil) {
        if (validateTemplateRequest.templateBody != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", validateTemplateRequest.templateBody] forKey:[NSString stringWithFormat:@"%@", @"TemplateBody"]];
        }
	}				

	if (validateTemplateRequest != nil) {
        if (validateTemplateRequest.templateURL != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", validateTemplateRequest.templateURL] forKey:[NSString stringWithFormat:@"%@", @"TemplateURL"]];
        }
	}				


    return [request autorelease];
}
@end