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
 
#import "CloudFormationEstimateTemplateCostRequestMarshaller.h"


@implementation CloudFormationEstimateTemplateCostRequestMarshaller


+(AmazonServiceRequest *)createRequest:(CloudFormationEstimateTemplateCostRequest *)estimateTemplateCostRequest
{
    AmazonServiceRequest *request = [[CloudFormationRequest alloc] init];

    [request setParameterValue:@"EstimateTemplateCost" forKey:@"Action"];
    [request setParameterValue:@"2010-05-15" forKey:@"Version"];

    [request setDelegate:[estimateTemplateCostRequest delegate]];
    [request setCredentials:[estimateTemplateCostRequest credentials]];
    [request setEndpoint:[estimateTemplateCostRequest requestEndpoint]];
    [request setRequestTag:[estimateTemplateCostRequest requestTag]];
    
    if (estimateTemplateCostRequest != nil) {
        int parametersListIndex = 1;
        for (CloudFormationParameter *parametersListValue in estimateTemplateCostRequest.parameters) {
            if (parametersListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", parametersListValue] forKey:[NSString stringWithFormat:@"%@.member.%d", @"Parameters", parametersListIndex]];
            }
            
            parametersListIndex++;
        }
        
    }

	if (estimateTemplateCostRequest != nil) {
        if (estimateTemplateCostRequest.templateBody != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", estimateTemplateCostRequest.templateBody] forKey:[NSString stringWithFormat:@"%@", @"TemplateBody"]];
        }
	}				

	if (estimateTemplateCostRequest != nil) {
        if (estimateTemplateCostRequest.templateURL != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", estimateTemplateCostRequest.templateURL] forKey:[NSString stringWithFormat:@"%@", @"TemplateURL"]];
        }
	}				


    return [request autorelease];
}
@end