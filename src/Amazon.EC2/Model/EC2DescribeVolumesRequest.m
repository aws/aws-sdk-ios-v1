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

#import "EC2DescribeVolumesRequest.h"


@implementation EC2DescribeVolumesRequest

@synthesize dryRun;
@synthesize dryRunIsSet;
@synthesize volumeIds;
@synthesize filters;


-(id)init
{
    if (self = [super init]) {
        dryRun      = NO;
        dryRunIsSet = NO;
        volumeIds   = [[NSMutableArray alloc] initWithCapacity:1];
        filters     = [[NSMutableArray alloc] initWithCapacity:1];
    }

    return self;
}

-(id)initWithVolumeIds:(NSMutableArray *)theVolumeIds
{
    if (self = [self init]) {
        self.volumeIds = theVolumeIds;
    }

    return self;
}


-(void)addVolumeId:(NSString *)volumeIdObject
{
    if (volumeIds == nil) {
        volumeIds = [[NSMutableArray alloc] initWithCapacity:1];
    }

    [volumeIds addObject:volumeIdObject];
}

-(void)addFilter:(EC2Filter *)filterObject
{
    if (filters == nil) {
        filters = [[NSMutableArray alloc] initWithCapacity:1];
    }

    [filters addObject:filterObject];
}


-(NSString *)description
{
    NSMutableString *buffer = [[NSMutableString alloc] initWithCapacity:256];

    [buffer appendString:@"{"];
    [buffer appendString:[[[NSString alloc] initWithFormat:@"DryRun: %d,", dryRun] autorelease]];
    [buffer appendString:[[[NSString alloc] initWithFormat:@"VolumeIds: %@,", volumeIds] autorelease]];
    [buffer appendString:[[[NSString alloc] initWithFormat:@"Filters: %@,", filters] autorelease]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return [buffer autorelease];
}


-(void)setDryRun:(BOOL)theValue
{
    dryRun      = theValue;
    dryRunIsSet = YES;
}


-(void)dealloc
{
    [volumeIds release];
    [filters release];

    [super dealloc];
}


@end
