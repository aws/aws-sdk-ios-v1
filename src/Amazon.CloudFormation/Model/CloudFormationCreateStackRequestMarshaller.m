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

#import "CloudFormationCreateStackRequestMarshaller.h"


@implementation CloudFormationCreateStackRequestMarshaller


+(AmazonServiceRequest *)createRequest:(CloudFormationCreateStackRequest *)createStackRequest
{
    AmazonServiceRequest *request = [[CloudFormationRequest alloc] init];
    
    [request setParameterValue:@"CreateStack" forKey:@"Action"];
    [request setParameterValue:@"2010-05-15" forKey:@"Version"];
    
    [request setDelegate:[createStackRequest delegate]];
    [request setCredentials:[createStackRequest credentials]];
    [request setEndpoint:[createStackRequest requestEndpoint]];
    [request setRequestTag:[createStackRequest requestTag]];
    
    
	if (createStackRequest != nil) {
        int capabilitiesListIndex = 1;
        for (NSString *capabilitiesListValue in createStackRequest.capabilities) {
            if (capabilitiesListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", capabilitiesListValue] forKey:[NSString stringWithFormat:@"%@.member.%d", @"Capabilities", capabilitiesListIndex]];
            }
            
            capabilitiesListIndex++;
        }
    }
    
	if (createStackRequest != nil) {
        if (createStackRequest.disableRollbackIsSet) {
            [request setParameterValue:(createStackRequest.disableRollback ? @"true" :@"false") forKey:[NSString stringWithFormat:@"%@", @"DisableRollback"]];
        }
	}
    
	if (createStackRequest != nil) {
        int notificationARNsListIndex = 1;
        for (NSString *notificationARNsListValue in createStackRequest.notificationARNs) {
            if (notificationARNsListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", notificationARNsListValue] forKey:[NSString stringWithFormat:@"%@.member.%d", @"NotificationARNs", notificationARNsListIndex]];
            }
            
            notificationARNsListIndex++;
        }
    }
    
	if (createStackRequest != nil) {
        if (createStackRequest.onFailure != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", createStackRequest.onFailure] forKey:[NSString stringWithFormat:@"%@", @"OnFailure"]];
        }
	}
    
	if (createStackRequest != nil) {
        if (createStackRequest.stackName != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", createStackRequest.stackName] forKey:[NSString stringWithFormat:@"%@", @"StackName"]];
        }
	}
    
	if (createStackRequest != nil) {
        int tagsListIndex = 1;
        for (CloudFormationTag *tagsListValue in createStackRequest.tags) {
            if (tagsListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", tagsListValue] forKey:[NSString stringWithFormat:@"%@.member.%d", @"Tags", tagsListIndex]];
            }
            
            tagsListIndex++;
        }
        
    }
    
    if (createStackRequest != nil) {
        int parametersListIndex = 1;
        for (CloudFormationParameter *parametersListValue in createStackRequest.parameters) {
            if (parametersListValue != nil) {
                [request setParameterValue:[NSString stringWithFormat:@"%@", parametersListValue] forKey:[NSString stringWithFormat:@"%@.member.%d", @"Parameters", parametersListIndex]];
            }
            
            parametersListIndex++;
        }
        
    }
    
	if (createStackRequest != nil) {
        if (createStackRequest.templateBody != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", createStackRequest.templateBody] forKey:[NSString stringWithFormat:@"%@", @"TemplateBody"]];
        }
	}
    
	if (createStackRequest != nil) {
        if (createStackRequest.templateURL != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", createStackRequest.templateURL] forKey:[NSString stringWithFormat:@"%@", @"TemplateURL"]];
        }
	}
    
	if (createStackRequest != nil) {
        if (createStackRequest.timeoutInMinutes != nil) {
            [request setParameterValue:[NSString stringWithFormat:@"%@", createStackRequest.timeoutInMinutes] forKey:[NSString stringWithFormat:@"%@", @"TimeoutInMinutes"]];
        }
	}
    
    
    return [request autorelease];
}
@end