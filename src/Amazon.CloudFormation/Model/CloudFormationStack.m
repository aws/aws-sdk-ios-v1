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
 
#import "CloudFormationStack.h"


@implementation CloudFormationStack

@synthesize capabilities;
@synthesize creationTime;
@synthesize description;
@synthesize disableRollback;
@synthesize disableRollbackIsSet;
@synthesize lastUpdatedTime;
@synthesize notificationARNs;
@synthesize outputs;
@synthesize parameters;
@synthesize stackId;
@synthesize stackName;
@synthesize stackStatus;
@synthesize stackStatusReason;
@synthesize tags;
@synthesize timeoutInMinutes;

-(id)init
{
    if (self = [super init]) {

		capabilities = [[NSMutableArray alloc] initWithCapacity:1];
		creationTime = nil;
		description = nil;
		disableRollback = NO;
		disableRollbackIsSet = NO;
		lastUpdatedTime = nil;
		notificationARNs = [[NSMutableArray alloc] initWithCapacity:1];
		outputs = [[NSMutableArray alloc] initWithCapacity:1];
		parameters = [[NSMutableArray alloc] initWithCapacity:1];
		stackId = nil;
		stackName = nil;
		stackStatus = nil;
		stackStatusReason = nil;
		tags = [[NSMutableArray alloc] initWithCapacity:1];
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

-(void)addOutput:(CloudFormationOutput *)outputObject
{
	if (outputs == nil) {
		outputs = [[NSMutableArray alloc] initWithCapacity:1];
	}
	
	[outputs addObject:outputObject];
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
	[buffer appendString:[[[NSString alloc] initWithFormat:@"CreationTime: %@,", creationTime] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Description: %@,", description] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"DisableRollback: %d,", disableRollback] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"LastUpdatedTime: %@,", lastUpdatedTime] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"NotificationARNs: %@,", notificationARNs] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Outputs: %@,", outputs] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Parameters: %@,", parameters] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackId: %@,", stackId] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackName: %@,", stackName] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackStatus: %@,", stackStatus] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackStatusReason: %@,", stackStatusReason] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Tags: %@,", tags] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"TimeoutInMinutes: %@,", timeoutInMinutes] autorelease]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}

-(void)dealloc
{
	[capabilities release];
	[creationTime release];
	[description release];
	[lastUpdatedTime release];
	[notificationARNs release];
	[outputs release];
	[parameters release];
	[stackId release];
	[stackName release];
	[stackStatus release];
	[stackStatusReason release];
	[tags release];
	[timeoutInMinutes release];
    
    [super dealloc];
}

@end