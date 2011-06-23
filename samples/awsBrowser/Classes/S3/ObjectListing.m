/*
 * Copyright 2010-2011 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import <AWSiOSSDK/S3/AmazonS3Client.h>
#import "AddObjectViewController.h"
#import "ObjectViewController.h"
#import "Constants.h"

@implementation ObjectListing

@synthesize bucket;

-(id)init
{
    return [super initWithNibName:@"ObjectListing" bundle:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    @try {
        if (objects == nil) {
            objects = [[NSMutableArray alloc] init];
        }
        else {
            [objects removeAllObjects];
        }
        
        S3ListObjectsRequest  *listObjectRequest = [[[S3ListObjectsRequest alloc] initWithName:self.bucket] autorelease];

        S3ListObjectsResponse *listObjectResponse = [[Constants s3] listObjects:listObjectRequest];
        S3ListObjectsResult   *listObjectsResults = listObjectResponse.listObjectsResult;

        for (S3ObjectSummary *objectSummary in listObjectsResults.objectSummaries) {
            [objects addObject:[objectSummary key]];
        }
        [objects sortUsingSelector:@selector(compare:)];
    }
    @catch (AmazonClientException *exception) {
        NSLog(@"Exception = %@", exception);
        [objects addObject:@"Unable to load objects!"];
    }

    [objectsTableView reloadData];
}

-(IBAction)done:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)add:(id)sender
{
    AddObjectViewController *addObject = [[AddObjectViewController alloc] init];

    addObject.bucket               = self.bucket;
    addObject.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    [self presentModalViewController:addObject animated:YES];
    [addObject release];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [objects count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Configure the cell...
    cell.textLabel.text                      = [objects objectAtIndex:indexPath.row];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;

    return cell;
}

// Override to support conditional editing of the table view.
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        ObjectViewController *objectView = [[ObjectViewController alloc] init];
        objectView.bucket               = self.bucket;
        objectView.objectName           = [objects objectAtIndex:indexPath.row];
        objectView.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

        [self presentModalViewController:objectView animated:YES];
        [objectView release];
    }
    @catch (AmazonServiceException *exception) {
        NSLog(@"Exception = %@", exception);
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        @try {
            S3DeleteObjectRequest *dor = [[[S3DeleteObjectRequest alloc] init] autorelease];
            dor.bucket = self.bucket;
            dor.key    = [objects objectAtIndex:indexPath.row];

            [[Constants s3] deleteObject:dor];
            [objects removeObjectAtIndex:indexPath.row];

            NSArray *indexPaths = [NSArray arrayWithObjects:indexPath, nil];

            [tableView beginUpdates];
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            [tableView endUpdates];
        }
        @catch (AmazonServiceException *exception) {
            NSLog(@"Exception = %@", exception);
        }
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
    }
}

-(void)dealloc
{
    [objects release];
    [bucket release];
    [super dealloc];
}


@end

