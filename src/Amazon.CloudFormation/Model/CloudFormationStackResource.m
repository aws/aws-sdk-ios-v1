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
 
#import "CloudFormationStackResource.h"


@implementation CloudFormationStackResource

@synthesize description;
@synthesize logicalResourceId;
@synthesize physicalResourceId;
@synthesize resourceStatus;
@synthesize resourceStatusReason;
@synthesize resourceType;
@synthesize stackId;
@synthesize stackName;
@synthesize timestamp;

-(id)init
{
    if (self = [super init]) {

		description = nil;
		logicalResourceId = nil;
		physicalResourceId = nil;
		resourceStatus = nil;
		resourceStatusReason = nil;
		resourceType = nil;
		stackId = nil;
		stackName = nil;
		timestamp = nil;
    }

    return self;
}

-(NSString *)description
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    [buffer appendString:@"{"];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Description: %@,", description] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"LogicalResourceId: %@,", logicalResourceId] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"PhysicalResourceId: %@,", physicalResourceId] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"ResourceStatus: %@,", resourceStatus] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"ResourceStatusReason: %@,", resourceStatusReason] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"ResourceType: %@,", resourceType] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackId: %@,", stackId] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"StackName: %@,", stackName] autorelease]];
	[buffer appendString:[[[NSString alloc] initWithFormat:@"Timestamp: %@,", timestamp] autorelease]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}

-(void)dealloc
{
	[description release];
	[logicalResourceId release];
	[physicalResourceId release];
	[resourceStatus release];
	[resourceStatusReason release];
	[resourceType release];
	[stackId release];
	[stackName release];
	[timestamp release];
    
    [super dealloc];
}

@end