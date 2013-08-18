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
 * Validate Template Request
 */
@interface CloudFormationValidateTemplateRequest:AmazonServiceRequestConfig
{
	NSString *templateBody;
	NSString *templateURL;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * String containing the template body. (For more information, go to the
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
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;

@end