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
 
#import "CloudFormationParameter.h"


	    	
#ifdef AWS_MULTI_FRAMEWORK
#import <AWSRuntime/AmazonServiceRequestConfig.h>
#else
#import "../AmazonServiceRequestConfig.h"
#endif

	    	
/**
 * Update Stack Request
 */
@interface CloudFormationUpdateStackRequest:AmazonServiceRequestConfig
{
	NSMutableArray *capabilities;
	NSMutableArray *parameters;
	NSString *stackName;
	NSString *templateBody;
	NSString *templateURL;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * The list of capabilities that you want to allow in the
 * stack. If your stack contains IAM resources, you must specify
 * the CAPABILITY_IAM value for this parameter; otherwise, this action returns
 * an InsufficientCapabilities error. IAM resources are the following: <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-accesskey.html">AWS::IAM::AccessKey</a>,
 * <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-group.html">AWS::IAM::Group</a>, <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-policy.html">AWS::IAM::Policy</a>, <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-user.html">AWS::IAM::User</a>, and <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-addusertogroup.html">AWS::IAM::UserToGroupAddition</a>.
 */
@property (nonatomic, retain) NSMutableArray *capabilities;
 
/**
 * A list of <code>Parameter</code> structures that specify input parameters for the
 * stack.
 */
@property (nonatomic, retain) NSMutableArray *parameters;
 
/**
 * The name or stack ID of the stack to update.
 */
@property (nonatomic, retain) NSString *stackName;
 
/**
 * Structure containing the template body. (For more information, go to the
 * <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide">AWS CloudFormation User Guide</a>.)
 */
@property (nonatomic, retain) NSString *templateBody;
 
/**
 * Location of file containing the template body. The URL must point
 * to a template located in an S3 bucket in the
 * same region as the stack. For more information, go to
 * the <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide">AWS CloudFormation User Guide</a>.
 */
@property (nonatomic, retain) NSString *templateURL;
 

/**
 * Adds a single object to capabilities.
 * This function will alloc and init capabilities if not already done.
 */
-(void)addCapability:(NSString *)capabilityObject;
 
/**
 * Adds a single object to parameters.
 * This function will alloc and init parameters if not already done.
 */
-(void)addParameter:(CloudFormationParameter *)parameterObject;
 
	    
/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;

@end