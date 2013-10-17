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
 
#import "CloudFormationOutput.h"
#import "CloudFormationParameter.h"
#import "CloudFormationTag.h"


	    	
/**
 * Stack 
 */
@interface CloudFormationStack:NSObject

{
	NSMutableArray *capabilities;
	NSDate *creationTime;
	NSString *description;
	bool disableRollback;
	bool disableRollbackIsSet;
	NSDate *lastUpdatedTime;
	NSMutableArray *notificationARNs;
	NSMutableArray *outputs;
	NSMutableArray *parameters;
	NSString *stackId;
	NSString *stackName;
	NSString *stackStatus;
	NSString *stackStatusReason;
	NSMutableArray *tags;
	NSNumber *timeoutInMinutes;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * The capabilities allowed in the stack.
 */
@property (nonatomic, retain) NSMutableArray *capabilities;
 
/**
 * Time at which the stack was created.
 */
@property (nonatomic, retain) NSDate *creationTime;
 
/**
 * User defined description associated with the stack.
 */
@property (nonatomic, retain) NSString *description;
 
/**
 * Boolean to enable or disable rollback on stack creation failures:
 */
@property (nonatomic) bool disableRollback;

@property (nonatomic, readonly) bool disableRollbackIsSet;
 
/**
 * The time the stack was last updated. This field will only
 * be returned if the stack has been updated at least
 * once.
 */
@property (nonatomic, retain) NSDate *lastUpdatedTime;
 
/**
 * SNS topic ARNs to which stack related events are published.
 */
@property (nonatomic, retain) NSMutableArray *notificationARNs;
 
/**
 * A list of output structures.
 */
@property (nonatomic, retain) NSMutableArray *outputs;
 
/**
 * A list of <code>Parameter</code> structures.
 */
@property (nonatomic, retain) NSMutableArray *parameters;
 
/**
 * Unique identifier of the stack.
 */
@property (nonatomic, retain) NSString *stackId;
 
/**
 * The name associated with the stack.
 */
@property (nonatomic, retain) NSString *stackName;
 
/**
 * Current status of the stack.
 */
@property (nonatomic, retain) NSString *stackStatus;
 
/**
 * Success/failure message associated with the stack status.
 */
@property (nonatomic, retain) NSString *stackStatusReason;
 
/**
 * A list of <code>Tag</code>s that specify cost allocation information for the
 * stack.
 */
@property (nonatomic, retain) NSMutableArray *tags;
 
/**
 * The amount of time within which stack creation should complete.
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
 * Adds a single object to outputs.
 * This function will alloc and init outputs if not already done.
 */
-(void)addOutput:(CloudFormationOutput *)outputObject;
 
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