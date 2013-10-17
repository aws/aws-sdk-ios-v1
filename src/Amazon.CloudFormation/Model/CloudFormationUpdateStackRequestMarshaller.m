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
 
#import "CloudFormationUpdateStackRequestMarshaller.h"


@implementation CloudFormationUpdateStackRequestMarshaller


+(AmazonServiceRequest *)createRequest:(CloudFormationUpdateStackRequest *)updateStackRequest
{
    AmazonServiceRequest *request = [[CloudFormationRequest alloc] init];

    [request setParameterValue:@"UpdateStack" forKey:@"Action"];
    [request setParameterValue:@"2010-05-15" forKey:@"Version"];

    [request setDelegate:[updateStackRequest delegate]];
    [request setCredentials:[updateStackRequest credentials]];
    [request setEndpoint:[updateStackRequest requestEndpoint]];
    [request setRequestTag:[updateStackRequest requestTag]];


	if (updateStackRequest != nil) {
        int capabilitiesListIndex = 1;
        for (NSString *capabilitiesListValue in updateStackRequest.capabilities) {
            if (capabilitiesListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", capabilitiesListValue] forKey:[NSString stringWithFormat:@"%@.member.%d", @"Capabilities", capabilitiesListIndex]];
            }

            capabilitiesListIndex++;
        }
    }
    
    if (updateStackRequest != nil) {
        int parametersListIndex = 1;
        for (CloudFormationParameter *parametersListValue in updateStackRequest.parameters) {
            if (parametersListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", parametersListValue] forKey:[NSString stringWithFormat:@"%@.member.%d", @"Parameters", parametersListIndex]];
            }
            
            parametersListIndex++;
        }
        
    }

	if (updateStackRequest != nil) {
        if (updateStackRequest.stackName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", updateStackRequest.stackName] forKey:[NSString stringWithFormat:@"%@", @"StackName"]];
        }
	}				

	if (updateStackRequest != nil) {
        if (updateStackRequest.templateBody != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", updateStackRequest.templateBody] forKey:[NSString stringWithFormat:@"%@", @"TemplateBody"]];
        }
	}				

	if (updateStackRequest != nil) {
        if (updateStackRequest.templateURL != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", updateStackRequest.templateURL] forKey:[NSString stringWithFormat:@"%@", @"TemplateURL"]];
        }
	}				


    return [request autorelease];
}
@end