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
 
#import "AmazonCloudFormationClient.h"
#import "AmazonEndpoints.h"
#import "AmazonServiceRequest.h"
#import "CloudFormationCancelUpdateStackResponseUnmarshaller.h"
#import "CloudFormationCancelUpdateStackRequestMarshaller.h"
#import "CloudFormationCreateStackResponseUnmarshaller.h"
#import "CloudFormationCreateStackRequestMarshaller.h"
#import "CloudFormationDeleteStackResponseUnmarshaller.h"
#import "CloudFormationDeleteStackRequestMarshaller.h"
#import "CloudFormationDescribeStackEventsResponseUnmarshaller.h"
#import "CloudFormationDescribeStackEventsRequestMarshaller.h"
#import "CloudFormationDescribeStackResourceResponseUnmarshaller.h"
#import "CloudFormationDescribeStackResourceRequestMarshaller.h"
#import "CloudFormationDescribeStackResourcesResponseUnmarshaller.h"
#import "CloudFormationDescribeStackResourcesRequestMarshaller.h"
#import "CloudFormationDescribeStacksResponseUnmarshaller.h"
#import "CloudFormationDescribeStacksRequestMarshaller.h"
#import "CloudFormationEstimateTemplateCostResponseUnmarshaller.h"
#import "CloudFormationEstimateTemplateCostRequestMarshaller.h"
#import "CloudFormationGetTemplateResponseUnmarshaller.h"
#import "CloudFormationGetTemplateRequestMarshaller.h"
#import "CloudFormationListStackResourcesResponseUnmarshaller.h"
#import "CloudFormationListStackResourcesRequestMarshaller.h"
#import "CloudFormationListStacksResponseUnmarshaller.h"
#import "CloudFormationListStacksRequestMarshaller.h"
#import "CloudFormationUpdateStackResponseUnmarshaller.h"
#import "CloudFormationUpdateStackRequestMarshaller.h"
#import "CloudFormationValidateTemplateResponseUnmarshaller.h"
#import "CloudFormationValidateTemplateRequestMarshaller.h"

@implementation AmazonCloudFormationClient

-(id)initWithAccessKey:(NSString *)theAccessKey withSecretKey:(NSString *)theSecretKey
{
    if (self = [super initWithAccessKey:theAccessKey withSecretKey:theSecretKey]) {
        self.endpoint = AMAZON_CF_US_EAST_1_ENDPOINT_SECURE;
    }
    return self;
}

-(id)initWithCredentials:(AmazonCredentials *)theCredentials
{
    if (self = [super initWithCredentials:theCredentials]) {
        self.endpoint = AMAZON_CF_US_EAST_1_ENDPOINT_SECURE;
    }
    return self;
}

-(id)initWithCredentialsProvider:(id<AmazonCredentialsProvider> )theProvider
{
    if (self = [super initWithCredentialsProvider:theProvider]) {
        self.endpoint = AMAZON_CF_US_EAST_1_ENDPOINT_SECURE;
    }
    return self;
}

-(CloudFormationCancelUpdateStackResponse *)cancelUpdateStack:(CloudFormationCancelUpdateStackRequest *)cancelUpdateStackRequest
{
    AmazonServiceRequest *request = [CloudFormationCancelUpdateStackRequestMarshaller createRequest:cancelUpdateStackRequest];

    return (CloudFormationCancelUpdateStackResponse *)[self invoke:request rawRequest:cancelUpdateStackRequest unmarshallerDelegate:[CloudFormationCancelUpdateStackResponseUnmarshaller class]];
}
-(CloudFormationCreateStackResponse *)createStack:(CloudFormationCreateStackRequest *)createStackRequest
{
    AmazonServiceRequest *request = [CloudFormationCreateStackRequestMarshaller createRequest:createStackRequest];

    return (CloudFormationCreateStackResponse *)[self invoke:request rawRequest:createStackRequest unmarshallerDelegate:[CloudFormationCreateStackResponseUnmarshaller class]];
}
-(CloudFormationDeleteStackResponse *)deleteStack:(CloudFormationDeleteStackRequest *)deleteStackRequest
{
    AmazonServiceRequest *request = [CloudFormationDeleteStackRequestMarshaller createRequest:deleteStackRequest];

    return (CloudFormationDeleteStackResponse *)[self invoke:request rawRequest:deleteStackRequest unmarshallerDelegate:[CloudFormationDeleteStackResponseUnmarshaller class]];
}
-(CloudFormationDescribeStackEventsResponse *)describeStackEvents:(CloudFormationDescribeStackEventsRequest *)describeStackEventsRequest
{
    AmazonServiceRequest *request = [CloudFormationDescribeStackEventsRequestMarshaller createRequest:describeStackEventsRequest];

    return (CloudFormationDescribeStackEventsResponse *)[self invoke:request rawRequest:describeStackEventsRequest unmarshallerDelegate:[CloudFormationDescribeStackEventsResponseUnmarshaller class]];
}
-(CloudFormationDescribeStackResourceResponse *)describeStackResource:(CloudFormationDescribeStackResourceRequest *)describeStackResourceRequest
{
    AmazonServiceRequest *request = [CloudFormationDescribeStackResourceRequestMarshaller createRequest:describeStackResourceRequest];

    return (CloudFormationDescribeStackResourceResponse *)[self invoke:request rawRequest:describeStackResourceRequest unmarshallerDelegate:[CloudFormationDescribeStackResourceResponseUnmarshaller class]];
}
-(CloudFormationDescribeStackResourcesResponse *)describeStackResources:(CloudFormationDescribeStackResourcesRequest *)describeStackResourcesRequest
{
    AmazonServiceRequest *request = [CloudFormationDescribeStackResourcesRequestMarshaller createRequest:describeStackResourcesRequest];

    return (CloudFormationDescribeStackResourcesResponse *)[self invoke:request rawRequest:describeStackResourcesRequest unmarshallerDelegate:[CloudFormationDescribeStackResourcesResponseUnmarshaller class]];
}
-(CloudFormationDescribeStacksResponse *)describeStacks:(CloudFormationDescribeStacksRequest *)describeStacksRequest
{
    AmazonServiceRequest *request = [CloudFormationDescribeStacksRequestMarshaller createRequest:describeStacksRequest];

    return (CloudFormationDescribeStacksResponse *)[self invoke:request rawRequest:describeStacksRequest unmarshallerDelegate:[CloudFormationDescribeStacksResponseUnmarshaller class]];
}
-(CloudFormationEstimateTemplateCostResponse *)estimateTemplateCost:(CloudFormationEstimateTemplateCostRequest *)estimateTemplateCostRequest
{
    AmazonServiceRequest *request = [CloudFormationEstimateTemplateCostRequestMarshaller createRequest:estimateTemplateCostRequest];

    return (CloudFormationEstimateTemplateCostResponse *)[self invoke:request rawRequest:estimateTemplateCostRequest unmarshallerDelegate:[CloudFormationEstimateTemplateCostResponseUnmarshaller class]];
}
-(CloudFormationGetTemplateResponse *)getTemplate:(CloudFormationGetTemplateRequest *)getTemplateRequest
{
    AmazonServiceRequest *request = [CloudFormationGetTemplateRequestMarshaller createRequest:getTemplateRequest];

    return (CloudFormationGetTemplateResponse *)[self invoke:request rawRequest:getTemplateRequest unmarshallerDelegate:[CloudFormationGetTemplateResponseUnmarshaller class]];
}
-(CloudFormationListStackResourcesResponse *)listStackResources:(CloudFormationListStackResourcesRequest *)listStackResourcesRequest
{
    AmazonServiceRequest *request = [CloudFormationListStackResourcesRequestMarshaller createRequest:listStackResourcesRequest];

    return (CloudFormationListStackResourcesResponse *)[self invoke:request rawRequest:listStackResourcesRequest unmarshallerDelegate:[CloudFormationListStackResourcesResponseUnmarshaller class]];
}
-(CloudFormationListStacksResponse *)listStacks:(CloudFormationListStacksRequest *)listStacksRequest
{
    AmazonServiceRequest *request = [CloudFormationListStacksRequestMarshaller createRequest:listStacksRequest];

    return (CloudFormationListStacksResponse *)[self invoke:request rawRequest:listStacksRequest unmarshallerDelegate:[CloudFormationListStacksResponseUnmarshaller class]];
}
-(CloudFormationUpdateStackResponse *)updateStack:(CloudFormationUpdateStackRequest *)updateStackRequest
{
    AmazonServiceRequest *request = [CloudFormationUpdateStackRequestMarshaller createRequest:updateStackRequest];

    return (CloudFormationUpdateStackResponse *)[self invoke:request rawRequest:updateStackRequest unmarshallerDelegate:[CloudFormationUpdateStackResponseUnmarshaller class]];
}
-(CloudFormationValidateTemplateResponse *)validateTemplate:(CloudFormationValidateTemplateRequest *)validateTemplateRequest
{
    AmazonServiceRequest *request = [CloudFormationValidateTemplateRequestMarshaller createRequest:validateTemplateRequest];

    return (CloudFormationValidateTemplateResponse *)[self invoke:request rawRequest:validateTemplateRequest unmarshallerDelegate:[CloudFormationValidateTemplateResponseUnmarshaller class]];
}
@end