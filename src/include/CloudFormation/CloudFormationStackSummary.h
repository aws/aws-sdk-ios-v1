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
 


	    	
/**
 * Stack Summary 
 */
@interface CloudFormationStackSummary:NSObject
{
	NSDate *creationTime;
	NSDate *deletionTime;
	NSDate *lastUpdatedTime;
	NSString *stackId;
	NSString *stackName;
	NSString *stackStatus;
	NSString *stackStatusReason;
	NSString *templateDescription;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * The time the stack was created.
 */
@property (nonatomic, retain) NSDate *creationTime;
 
/**
 * The time the stack was deleted.
 */
@property (nonatomic, retain) NSDate *deletionTime;
 
/**
 * The time the stack was last updated. This field will only
 * be returned if the stack has been updated at least
 * once.
 */
@property (nonatomic, retain) NSDate *lastUpdatedTime;
 
/**
 * Unique stack identifier.
 */
@property (nonatomic, retain) NSString *stackId;
 
/**
 * The name associated with the stack.
 */
@property (nonatomic, retain) NSString *stackName;
 
/**
 * The current status of the stack.
 */
@property (nonatomic, retain) NSString *stackStatus;
 
/**
 * Success/Failure message associated with the stack status.
 */
@property (nonatomic, retain) NSString *stackStatusReason;
 
/**
 * The template description of the template used to create the stack.
 *
 */
@property (nonatomic, retain) NSString *templateDescription;
 

	    
/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;

@end