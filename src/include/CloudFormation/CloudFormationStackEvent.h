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
 * Stack Event 
 */
@interface CloudFormationStackEvent:NSObject

{
    
	NSString *eventId;
	NSString *logicalResourceId;
	NSString *physicalResourceId;
	NSString *resourceProperties;
	NSString *resourceStatus;
	NSString *resourceStatusReason;
	NSString *resourceType;
	NSString *stackId;
	NSString *stackName;
	NSDate *timestamp;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * The unique ID of this event.
 */
@property (nonatomic, retain) NSString *eventId;
 
/**
 * The logical name of the resource specified in the template.
 */
@property (nonatomic, retain) NSString *logicalResourceId;
 
/**
 * The name or unique identifier associated with the physical instance of
 * the resource.
 */
@property (nonatomic, retain) NSString *physicalResourceId;
 
/**
 * BLOB of the properties used to create the resource.
 */
@property (nonatomic, retain) NSString *resourceProperties;
 
/**
 * Current status of the resource.
 */
@property (nonatomic, retain) NSString *resourceStatus;
 
/**
 * Success/failure message associated with the resource.
 */
@property (nonatomic, retain) NSString *resourceStatusReason;
 
/**
 * Type of the resource. (For more information, go to the <a
 * href="http://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide">AWS CloudFormation User Guide</a>.)
 */
@property (nonatomic, retain) NSString *resourceType;
 
/**
 * The unique ID name of the instance of the stack.
 */
@property (nonatomic, retain) NSString *stackId;
 
/**
 * The name associated with a stack.
 */
@property (nonatomic, retain) NSString *stackName;
 
/**
 * Time the status was updated.
 */
@property (nonatomic, retain) NSDate *timestamp;
 

	    
/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;

@end