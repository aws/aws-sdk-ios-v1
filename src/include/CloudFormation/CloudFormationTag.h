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
 * Tag 
 */
@interface CloudFormationTag:NSObject
{
	NSString *key;
	NSString *value;
}

	    
/**
 * Default constructor for a new  object.  Callers should use the
 * property methods to initialize this object after creating it.
 */
-(id)init;


/**
 * <span><em>Required</em></span>. A string used to identify this tag. You can specify
 * a maximum of 128 characters for a tag key. Tags
 * owned by Amazon Web Services (AWS) have the reserved prefix:
 * <code>aws:</code>.
 */
@property (nonatomic, retain) NSString *key;
 
/**
 * <span><em>Required</em></span>. A string containing the value for this tag. You can
 * specify a maximum of 256 characters for a tag value.
 *
 */
@property (nonatomic, retain) NSString *value;
 

	    
/**
 * Returns a string representation of this object; useful for testing and
 * debugging.
 *
 * @return A string representation of this object.
 */
-(NSString *)description;

@end