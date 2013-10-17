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
 
#import "CloudFormationValidateTemplateResponse.h"


@implementation CloudFormationValidateTemplateResponse

@synthesize capabilities;
@synthesize capabilitiesReason;
@synthesize description;
@synthesize parameters;

-(id)init
{
    if (self = [super init]) {

		capabilities = [[NSMutableArray alloc] initWithCapacity:1];
		capabilitiesReason = nil;
		description = nil;
		parameters = [[NSMutableArray alloc] initWithCapacity:1];
    }

    return self;
}

-(void)setException:(AmazonServiceException *)theException
{
    AmazonServiceException *newException = nil;



    if (newException != nil) {
        [newException setPropertiesWithException:theException];
        [exception release];
        exception = newException;
    }
    else {
        [exception release];
        exception = [theException retain];
    }
}

-(NSString *)capabilitiesObjectAtIndex:(int)index;
{
	return (NSString *)[capabilities objectAtIndex:index];
}

-(CloudFormationTemplateParameter *)parametersObjectAtIndex:(int)index;
{
	return (CloudFormationTemplateParameter *)[parameters objectAtIndex:index];
}

-(NSString *)description
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    [buffer appendString:@"{"];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Capabilities: %@,", capabilities] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"CapabilitiesReason: %@,", capabilitiesReason] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Description: %@,", description] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Parameters: %@,", parameters] autorelease]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}

-(void)dealloc
{
	[capabilities release];
	[capabilitiesReason release];
	[description release];
	[parameters release];
    
    [super dealloc];
}

@end