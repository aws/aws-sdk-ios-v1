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


@implementation CloudFormationTemplateParameter

@synthesize defaultValue;
@synthesize description;
@synthesize noEcho;
@synthesize noEchoIsSet;
@synthesize parameterKey;

-(id)init
{
    if (self = [super init]) {

		defaultValue = nil;
		description = nil;
		noEcho = NO;
		noEchoIsSet = NO;
		parameterKey = nil;
    }

    return self;
}

-(void)setNoEcho:(bool)theValue
{
    noEcho = theValue;
    noEchoIsSet = YES;
}

-(NSString *)description
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    [buffer appendString:@"{"];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"DefaultValue: %@,", defaultValue] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Description: %@,", description] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"NoEcho: %d,", noEcho] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"ParameterKey: %@,", parameterKey] autorelease]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}

-(void)dealloc
{
	[defaultValue release];
	[description release];
	[parameterKey release];
    
    [super dealloc];
}

@end