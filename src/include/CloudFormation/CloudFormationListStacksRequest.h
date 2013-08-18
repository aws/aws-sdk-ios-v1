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
 * List Stacks Request
 */
@interface CloudFormationListStacksRequest:AmazonServiceRequestConfig
{
	NSString *nextToken;
	NSMutableArray *stackStatusFilter;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * String that identifies the start of the next list of stacks,
 * if there is one.
 */
@property (nonatomic, retain) NSString *nextToken;
 
/**
 * Stack status to use as a filter. Specify one or more
 * stack status codes to list only stacks with the specified
 * status codes. For a complete list of stack status codes,
 * see the <code>StackStatus</code> parameter of the <a href="API_Stack.html" title="Stack">Stack</a> data
 * type.
 */
@property (nonatomic, retain) NSMutableArray *stackStatusFilter;
 

/**
 * Adds a single object to stackStatusFilter.
 * This function will alloc and init stackStatusFilter if not already done.
 */
-(void)addStackStatusFilter:(NSString *)stackStatusFilterObject;
 
	    
/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;

@end