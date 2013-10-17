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
 

#import "CloudFormationCancelUpdateStackResponse.h"
#import "CloudFormationCancelUpdateStackRequest.h"
#import "CloudFormationCreateStackResponse.h"
#import "CloudFormationCreateStackRequest.h"
#import "CloudFormationDeleteStackResponse.h"
#import "CloudFormationDeleteStackRequest.h"
#import "CloudFormationDescribeStackEventsResponse.h"
#import "CloudFormationDescribeStackEventsRequest.h"
#import "CloudFormationDescribeStackResourceResponse.h"
#import "CloudFormationDescribeStackResourceRequest.h"
#import "CloudFormationDescribeStackResourcesResponse.h"
#import "CloudFormationDescribeStackResourcesRequest.h"
#import "CloudFormationDescribeStacksResponse.h"
#import "CloudFormationDescribeStacksRequest.h"
#import "CloudFormationEstimateTemplateCostResponse.h"
#import "CloudFormationEstimateTemplateCostRequest.h"
#import "CloudFormationGetTemplateResponse.h"
#import "CloudFormationGetTemplateRequest.h"
#import "CloudFormationListStackResourcesResponse.h"
#import "CloudFormationListStackResourcesRequest.h"
#import "CloudFormationListStacksResponse.h"
#import "CloudFormationListStacksRequest.h"
#import "CloudFormationUpdateStackResponse.h"
#import "CloudFormationUpdateStackRequest.h"
#import "CloudFormationValidateTemplateResponse.h"
#import "CloudFormationValidateTemplateRequest.h"
#ifdef AWS_MULTI_FRAMEWORK
#import <AWSRuntime/AmazonWebServiceClient.h>
#else
#import "../AmazonWebServiceClient.h"
#endif

/** \defgroup CloudFormation Amazon CloudFormation */
	    	
/** <summary>
 * Interface for accessing Amazon.
 *
 *  Amazon 
 * </summary>
 *
 * See our blog to learn more about Managing Credentials in Mobile Applications.
 * @see http://mobile.awsblog.com/post/Tx31X75XISXHRH8/Managing-Credentials-in-Mobile-Applications
 */
@interface AmazonCloudFormationClient:AmazonWebServiceClient
{
}

/**
 * <p>
 * Cancels an update on the specified stack. If the call completes successfully, the stack will roll back the
      update and revert to the previous stack configuration.</p><div class="aws-note"><p class="aws-note">Note</p><p>Only stacks that are in the UPDATE_IN_PROGRESS state can be canceled.
 * </p>
 *
 * @param cancelUpdateStackRequest Container for the necessary parameters to execute the CancelUpdateStack service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the CancelUpdateStack service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationCancelUpdateStackRequest
 * @see CloudFormationCancelUpdateStackResponse
 */
-(CloudFormationCancelUpdateStackResponse *)cancelUpdateStack:(CloudFormationCancelUpdateStackRequest *)cancelUpdateStackRequest;

/**
 * <p>
 * Creates a stack as specified in the template. After the call completes successfully, the stack creation
         starts. You can check the status of the stack via the <a class="xref" href="API_DescribeStacks.html" title="DescribeStacks">DescribeStacks</a> API.</p><div class="aws-note"><p class="aws-note">Note</p><p> Currently, the limit for stacks is 20 stacks per account per region. 
 * </p>
 *
 * @param createStackRequest Container for the necessary parameters to execute the CreateStack service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the CreateStack service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationCreateStackRequest
 * @see CloudFormationCreateStackResponse
 */
-(CloudFormationCreateStackResponse *)createStack:(CloudFormationCreateStackRequest *)createStackRequest;

/**
 * <p>
 * Deletes a specified stack. Once the call completes successfully, stack deletion starts. Deleted stacks do not
         show up in the <a class="xref" href="API_DescribeStacks.html" title="DescribeStacks">DescribeStacks</a> API if the deletion has been completed successfully.
 * </p>
 *
 * @param deleteStackRequest Container for the necessary parameters to execute the DeleteStack service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the DeleteStack service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationDeleteStackRequest
 * @see CloudFormationDeleteStackResponse
 */
-(CloudFormationDeleteStackResponse *)deleteStack:(CloudFormationDeleteStackRequest *)deleteStackRequest;

/**
 * <p>
 * Returns all stack related events for a specified stack. For more information about a stack's event history, go to the <a class="ulink" href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide" target="_blank">AWS CloudFormation User
            Guide</a>.</p><div class="aws-note"><p class="aws-note">Note</p><p>Events are returned, even if the stack never existed or has been successfully deleted.
 * </p>
 *
 * @param describeStackEventsRequest Container for the necessary parameters to execute the DescribeStackEvents service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the DescribeStackEvents service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationDescribeStackEventsRequest
 * @see CloudFormationDescribeStackEventsResponse
 */
-(CloudFormationDescribeStackEventsResponse *)describeStackEvents:(CloudFormationDescribeStackEventsRequest *)describeStackEventsRequest;

/**
 * <p>
 * Returns a description of the specified resource in the specified stack.</p><p>For deleted stacks, DescribeStackResource returns resource information for up to 90 days after the stack has
         been deleted.
 * </p>
 *
 * @param describeStackResourceRequest Container for the necessary parameters to execute the DescribeStackResource service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the DescribeStackResource service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationDescribeStackResourceRequest
 * @see CloudFormationDescribeStackResourceResponse
 */
-(CloudFormationDescribeStackResourceResponse *)describeStackResource:(CloudFormationDescribeStackResourceRequest *)describeStackResourceRequest;

/**
 * <p>
 * Returns AWS resource descriptions for running and deleted stacks. If <code class="code">StackName</code> is specified, all
         the associated resources that are part of the stack are returned. If <code class="code">PhysicalResourceId</code> is
         specified, the associated resources of the stack that the resource belongs to are returned.</p><div class="aws-note"><p class="aws-note">Note</p><p>Only the first 100 resources will be returned. If your stack has more resources than this, you should use
         <code class="code">ListStackResources</code> instead.
 * </p>
 *
 * @param describeStackResourcesRequest Container for the necessary parameters to execute the DescribeStackResources service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the DescribeStackResources service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationDescribeStackResourcesRequest
 * @see CloudFormationDescribeStackResourcesResponse
 */
-(CloudFormationDescribeStackResourcesResponse *)describeStackResources:(CloudFormationDescribeStackResourcesRequest *)describeStackResourcesRequest;

/**
 * <p>
 * Returns the description for the specified stack; if no stack name was specified, then it returns the
         description for all the stacks created.
 * </p>
 *
 * @param describeStacksRequest Container for the necessary parameters to execute the DescribeStacks service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the DescribeStacks service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationDescribeStacksRequest
 * @see CloudFormationDescribeStacksResponse
 */
-(CloudFormationDescribeStacksResponse *)describeStacks:(CloudFormationDescribeStacksRequest *)describeStacksRequest;

/**
 * <p>
 * Returns the estimated monthly cost of a template. The return value is an AWS Simple Monthly Calculator URL with
         a query string that describes the resources required to run the template.
 * </p>
 *
 * @param estimateTemplateCostRequest Container for the necessary parameters to execute the EstimateTemplateCost service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the EstimateTemplateCost service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationEstimateTemplateCostRequest
 * @see CloudFormationEstimateTemplateCostResponse
 */
-(CloudFormationEstimateTemplateCostResponse *)estimateTemplateCost:(CloudFormationEstimateTemplateCostRequest *)estimateTemplateCostRequest;

/**
 * <p>
 * Returns the template body for a specified stack. You can get the template for running or deleted
         stacks.</p><p>For deleted stacks, GetTemplate returns the template for up to 90 days after the stack has been deleted.</p><div class="aws-note"><p class="aws-note">Note</p><p> If the template does not exist, a <code class="code">ValidationError</code> is returned. 
 * </p>
 *
 * @param getTemplateRequest Container for the necessary parameters to execute the GetTemplate service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the GetTemplate service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationGetTemplateRequest
 * @see CloudFormationGetTemplateResponse
 */
-(CloudFormationGetTemplateResponse *)getTemplate:(CloudFormationGetTemplateRequest *)getTemplateRequest;

/**
 * <p>
 * Returns descriptions of all resources of the specified stack.</p><p>For deleted stacks, ListStackResources returns resource information for up to 90 days after the stack has been
         deleted.
 * </p>
 *
 * @param listStackResourcesRequest Container for the necessary parameters to execute the ListStackResources service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the ListStackResources service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationListStackResourcesRequest
 * @see CloudFormationListStackResourcesResponse
 */
-(CloudFormationListStackResourcesResponse *)listStackResources:(CloudFormationListStackResourcesRequest *)listStackResourcesRequest;

/**
 * <p>
 * Returns the summary information for stacks whose status matches the specified StackStatusFilter. Summary
         information for stacks that have been deleted is kept for 90 days after the stack is deleted. If no
         StackStatusFilter is specified, summary information for all stacks is returned (including existing stacks and
         stacks that have been deleted).
 * </p>
 *
 * @param listStacksRequest Container for the necessary parameters to execute the ListStacks service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the ListStacks service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationListStacksRequest
 * @see CloudFormationListStacksResponse
 */
-(CloudFormationListStacksResponse *)listStacks:(CloudFormationListStacksRequest *)listStacksRequest;

/**
 * <p>
 * Updates a stack as specified in the template. After the call completes successfully, the stack update starts.
         You can check the status of the stack via the <a class="xref" href="API_DescribeStacks.html" title="DescribeStacks">DescribeStacks</a> action.</p><p></p><p>
                  <span class="bold"><strong>Note: </strong></span>You cannot update <a class="ulink" href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-s3-bucket.html" target="_blank">AWS::S3::Bucket</a>
         resources, for example, to add or modify tags.</p><p></p><p>To get a copy of the template for an existing stack, you can use the <a class="xref" href="API_GetTemplate.html" title="GetTemplate">GetTemplate</a> action.</p><p>Tags that were associated with this stack during creation time will still be associated with the stack after an
      <code class="code">UpdateStack</code> operation.</p><p>For more information about creating an update template, updating a stack, and monitoring the progress of the
         update, see <a class="ulink" href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/using-cfn-updating-stacks.html" target="_blank">Updating a Stack</a>.
 * </p>
 *
 * @param updateStackRequest Container for the necessary parameters to execute the UpdateStack service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the UpdateStack service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationUpdateStackRequest
 * @see CloudFormationUpdateStackResponse
 */
-(CloudFormationUpdateStackResponse *)updateStack:(CloudFormationUpdateStackRequest *)updateStackRequest;

/**
 * <p>
 * Validates a specified template.
 * </p>
 *
 * @param validateTemplateRequest Container for the necessary parameters to execute the ValidateTemplate service method on
 *           AmazonCloudFormation.
 *
 * @return The response from the ValidateTemplate service method, as returned by AmazonCloudFormation.
 *
 *
 * @exception AmazonClientException If any internal errors are encountered inside the client while
 * attempting to make the request or handle the response.  For example
 * if a network connection is not available.  For more information see <AmazonClientException>.
 * @exception AmazonServiceException If an error response is returned by AmazonCloudFormation indicating
 * either a problem with the data in the request, or a server side issue.  For more information see <AmazonServiceException>.
 *
 * @see CloudFormationValidateTemplateRequest
 * @see CloudFormationValidateTemplateResponse
 */
-(CloudFormationValidateTemplateResponse *)validateTemplate:(CloudFormationValidateTemplateRequest *)validateTemplateRequest;

@end