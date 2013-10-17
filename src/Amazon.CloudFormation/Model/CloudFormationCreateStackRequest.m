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
 
#import "CloudFormationCreateStackRequest.h"


@implementation CloudFormationCreateStackRequest

@synthesize capabilities;
@synthesize disableRollback;
@synthesize disableRollbackIsSet;
@synthesize notificationARNs;
@synthesize onFailure;
@synthesize parameters;
@synthesize stackName;
@synthesize tags;
@synthesize templateBody;
@synthesize templateURL;
@synthesize timeoutInMinutes;

-(id)init
{
    if (self = [super init]) {

		capabilities = [[NSMutableArray alloc] initWithCapacity:1];
		disableRollback = NO;
		disableRollbackIsSet = NO;
		notificationARNs = [[NSMutableArray alloc] initWithCapacity:1];
		onFailure = nil;
		parameters = [[NSMutableArray alloc] initWithCapacity:1];
		stackName = nil;
		tags = [[NSMutableArray alloc] initWithCapacity:1];
		templateBody = nil;
		templateURL = nil;
		timeoutInMinutes = nil;
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

-(void)setDisableRollback:(bool)theValue
{
    disableRollback = theValue;
    disableRollbackIsSet = YES;
}

-(void)addNotificationARN:(NSString *)notificationARNObject
{
	if (notificationARNs == nil) {
		notificationARNs = [[NSMutableArray alloc] initWithCapacity:1];
	}
	
	[notificationARNs addObject:notificationARNObject];
}

-(void)addParameter:(CloudFormationParameter *)parameterObject
{
	if (parameters == nil) {
		parameters = [[NSMutableArray alloc] initWithCapacity:1];
	}
	
	[parameters addObject:parameterObject];
}

-(void)addTag:(CloudFormationTag *)tagObject
{
	if (tags == nil) {
		tags = [[NSMutableArray alloc] initWithCapacity:1];
	}
	
	[tags addObject:tagObject];
}

-(NSString *)description
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    [buffer appendString:@"{"];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Capabilities: %@,", capabilities] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"DisableRollback: %d,", disableRollback] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"NotificationARNs: %@,", notificationARNs] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"OnFailure: %@,", onFailure] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Parameters: %@,", parameters] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackName: %@,", stackName] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Tags: %@,", tags] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"TemplateBody: %@,", templateBody] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"TemplateURL: %@,", templateURL] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"TimeoutInMinutes: %@,", timeoutInMinutes] autorelease]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}

-(void)dealloc
{
	[capabilities release];
	[notificationARNs release];
	[onFailure release];
	[parameters release];
	[stackName release];
	[tags release];
	[templateBody release];
	[templateURL release];
	[timeoutInMinutes release];
    
    [super dealloc];
}

@end