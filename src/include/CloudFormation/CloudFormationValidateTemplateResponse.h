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
 
#import "CloudFormationTemplateParameter.h"



	    
#import "CloudFormationResponse.h"

/**
 * Validate Template Result
 */
@interface CloudFormationValidateTemplateResponse:CloudFormationResponse
{
	NSMutableArray *capabilities;
	NSString *capabilitiesReason;
	NSString *description;
	NSMutableArray *parameters;
}

-(void)setException:(AmazonServiceException *)theException;

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * The capabilities found within the template. Currently, CAPABILITY_IAM is the only
 * capability detected. If your template contains IAM resources, you must
 * specify the CAPABILITY_IAM value for this parameter when you use
 * the <a href="API_CreateStack.html" title="CreateStack">CreateStack</a> or <a href="API_UpdateStack.html" title="UpdateStack">UpdateStack</a> actions with
 * your template; otherwise, those actions return an InsufficientCapabilities error.
 */
@property (nonatomic, retain) NSMutableArray *capabilities;
 
/**
 * The capabilities reason found within the template.
 */
@property (nonatomic, retain) NSString *capabilitiesReason;
 
/**
 * The description found within the template.
 */
@property (nonatomic, retain) NSString *description;
 
/**
 * A list of <code>TemplateParameter</code> structures.
 */
@property (nonatomic, retain) NSMutableArray *parameters;
 

/**
 * Returns a value from the capabilities array for the specified index.
 */
-(NSString *)capabilitiesObjectAtIndex:(int)index;
 
/**
 * Returns a value from the parameters array for the specified index.
 */
-(CloudFormationTemplateParameter *)parametersObjectAtIndex:(int)index;
 
	    
/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;
 
@end