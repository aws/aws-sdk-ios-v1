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
 
#import "CloudFormationStackSummary.h"


@implementation CloudFormationStackSummary

@synthesize creationTime;
@synthesize deletionTime;
@synthesize lastUpdatedTime;
@synthesize stackId;
@synthesize stackName;
@synthesize stackStatus;
@synthesize stackStatusReason;
@synthesize templateDescription;

-(id)init
{
    if (self = [super init]) {

		creationTime = nil;
		deletionTime = nil;
		lastUpdatedTime = nil;
		stackId = nil;
		stackName = nil;
		stackStatus = nil;
		stackStatusReason = nil;
		templateDescription = nil;
    }

    return self;
}

-(NSString *)description
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    [buffer appendString:@"{"];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"CreationTime: %@,", creationTime] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"DeletionTime: %@,", deletionTime] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"LastUpdatedTime: %@,", lastUpdatedTime] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackId: %@,", stackId] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackName: %@,", stackName] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackStatus: %@,", stackStatus] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackStatusReason: %@,", stackStatusReason] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"TemplateDescription: %@,", templateDescription] autorelease]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}

-(void)dealloc
{
	[creationTime release];
	[deletionTime release];
	[lastUpdatedTime release];
	[stackId release];
	[stackName release];
	[stackStatus release];
	[stackStatusReason release];
	[templateDescription release];
    
    [super dealloc];
}

@end