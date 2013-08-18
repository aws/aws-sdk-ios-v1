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
 
#import "CloudFormationUpdateStackRequest.h"


@implementation CloudFormationUpdateStackRequest

@synthesize capabilities;
@synthesize parameters;
@synthesize stackName;
@synthesize templateBody;
@synthesize templateURL;

-(id)init
{
    if (self = [super init]) {

		capabilities = [[NSMutableArray alloc] initWithCapacity:1];
		parameters = [[NSMutableArray alloc] initWithCapacity:1];
		stackName = nil;
		templateBody = nil;
		templateURL = nil;
    }

    return self;
}

-(void)addCapability:(NSString *)capabilityObject
{
	if (capabilities == nil) {
		capabilities = [[NSMutableArray alloc] initWithCapacity:1];
	}
	
	[capabilities addObject:capabilityObject];
}

-(void)addParameter:(CloudFormationParameter *)parameterObject
{
	if (parameters == nil) {
		parameters = [[NSMutableArray alloc] initWithCapacity:1];
	}
	
	[parameters addObject:parameterObject];
}

-(NSString *)description
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    [buffer appendString:@"{"];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Capabilities: %@,", capabilities] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Parameters: %@,", parameters] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackName: %@,", stackName] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"TemplateBody: %@,", templateBody] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"TemplateURL: %@,", templateURL] autorelease]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}

-(void)dealloc
{
	[capabilities release];
	[parameters release];
	[stackName release];
	[templateBody release];
	[templateURL release];
    
    [super dealloc];
}

@end