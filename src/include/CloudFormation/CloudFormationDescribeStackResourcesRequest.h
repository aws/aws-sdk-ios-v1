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
 


	    	
#ifdef AWS_MULTI_FRAMEWORK
#import <AWSRuntime/AmazonServiceRequestConfig.h>
#else
#import "../AmazonServiceRequestConfig.h"
#endif

	    	
/**
 * Describe Stack Resources Request
 */
@interface CloudFormationDescribeStackResourcesRequest:AmazonServiceRequestConfig
{
	NSString *logicalResourceId;
	NSString *physicalResourceId;
	NSString *stackName;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * The logical name of the resource as specified in the template.
 *
 */
@property (nonatomic, retain) NSString *logicalResourceId;
 
/**
 * The name or unique identifier that corresponds to a physical instance
 * ID of a resource supported by AWS CloudFormation.
 */
@property (nonatomic, retain) NSString *physicalResourceId;
 
/**
 * The name or the unique identifier associated with the stack.
 */
@property (nonatomic, retain) NSString *stackName;
 

	    
/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;

@end