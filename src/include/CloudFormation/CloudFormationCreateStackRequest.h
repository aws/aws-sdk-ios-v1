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
#import "CloudFormationTag.h"


	    	
#ifdef AWS_MULTI_FRAMEWORK
#import <AWSRuntime/AmazonServiceRequestConfig.h>
#else
#import "../AmazonServiceRequestConfig.h"
#endif

	    	
/**
 * Create Stack Request
 */
@interface CloudFormationCreateStackRequest:AmazonServiceRequestConfig

{
    
	NSMutableArray *capabilities;
	bool disableRollback;
	bool disableRollbackIsSet;
	NSMutableArray *notificationARNs;
	NSString *onFailure;
	NSMutableArray *parameters;
	NSString *stackName;
	NSMutableArray *tags;
	NSString *templateBody;
	NSString *templateURL;
	NSNumber *timeoutInMinutes;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * The list of capabilities that you want to allow in the
 * stack. If your template contains IAM resources, you must specify
 * the CAPABILITY_IAM value for this parameter; otherwise, this action returns
 * an InsufficientCapabilities error. IAM resources are the following: <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-accesskey.html">AWS::IAM::AccessKey</a>,
 * <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-group.html">AWS::IAM::Group</a>, <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-policy.html">AWS::IAM::Policy</a>, <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-user.html">AWS::IAM::User</a>, and <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-iam-addusertogroup.html">AWS::IAM::UserToGroupAddition</a>.
 */
@property (nonatomic, retain) NSMutableArray *capabilities;
 
/**
 * Set to <code>true</code> to disable rollback of the stack if stack
 * creation failed. You can specify either <code>DisableRollback</code> or <code>OnFailure</code>, but
 * not both.
 */
@property (nonatomic) bool disableRollback;

@property (nonatomic, readonly) bool disableRollbackIsSet;
 
/**
 * The Simple Notification Service (SNS) topic ARNs to publish stack related
 * events. You can find your SNS topic ARNs using the
 * <a href="http://console.aws.amazon.com/sns">SNS console</a> or your Command Line Interface (CLI).
 */
@property (nonatomic, retain) NSMutableArray *notificationARNs;
 
/**
 * Determines what action will be taken if stack creation fails. This
 * must be one of: DO_NOTHING, ROLLBACK, or DELETE. You can
 * specify either <code>OnFailure</code> or <code>DisableRollback</code>, but not both.
 */
@property (nonatomic, retain) NSString *onFailure;
 
/**
 * A list of <code>Parameter</code> structures that specify input parameters for the
 * stack.
 */
@property (nonatomic, retain) NSMutableArray *parameters;
 
/**
 * The name associated with the stack. The name must be unique
 * within your AWS account.
 */
@property (nonatomic, retain) NSString *stackName;
 
/**
 * A set of user-defined <code>Tags</code> to associate with this stack, represented
 * by key/value pairs. Tags defined for the stack are propagated
 * to EC2 resources that are created as part of the
 * stack. A maximum number of 10 tags can be specified.
 *
 */
@property (nonatomic, retain) NSMutableArray *tags;
 
/**
 * Structure containing the template body. (For more information, go to the
 * <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide">AWS CloudFormation User Guide</a>.)
 */
@property (nonatomic, retain) NSString *templateBody;
 
/**
 * Location of file containing the template body. The URL must point
 * to a template (max size: 307,200 bytes) located in an
 * S3 bucket in the same region as the stack. For
 * more information, go to the <a href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide">AWS CloudFormation User Guide</a>.
 *
 */
@property (nonatomic, retain) NSString *templateURL;
 
/**
 * The amount of time that can pass before the stack status
 * becomes CREATE_FAILED; if <code>DisableRollback</code> is not set or is set
 * to <code>false</code>, the stack will be rolled back.
 */
@property (nonatomic, retain) NSNumber *timeoutInMinutes;
 

/**
 * Adds a single object to capabilities.
 * This function will alloc and init capabilities if not already done.
 */
-(void)addCapability:(NSString *)capabilityObject;
 
/**
 * Adds a single object to notificationARNs.
 * This function will alloc and init notificationARNs if not already done.
 */
-(void)addNotificationARN:(NSString *)notificationARNObject;
 
/**
 * Adds a single object to parameters.
 * This function will alloc and init parameters if not already done.
 */
-(void)addParameter:(CloudFormationParameter *)parameterObject;
 
/**
 * Adds a single object to tags.
 * This function will alloc and init tags if not already done.
 */
-(void)addTag:(CloudFormationTag *)tagObject;
 
	    
/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;

@end