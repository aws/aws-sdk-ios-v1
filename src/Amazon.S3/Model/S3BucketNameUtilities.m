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

#import "S3BucketNameUtilities.h"

@implementation S3BucketNameUtilities

+(AmazonClientException *)validateBucketName:(NSString *)theBucketName
{
    if (theBucketName == nil) {
        return [AmazonClientException exceptionWithMessage : @"Bucket name should not be nil."];
    }

    if ( [theBucketName length] < 3 || [theBucketName length] > 63) {
        return [AmazonClientException exceptionWithMessage : @"Bucket name should be between 3 and 63 characters in length."];
    }

    if ( [theBucketName hasSuffix:@"-"]) {
        return [AmazonClientException exceptionWithMessage : @"Bucket name should not end with a '-'."];
    }

    if ( [S3BucketNameUtilities contains:theBucketName searchString:@".."]) {
        return [AmazonClientException exceptionWithMessage : @"Bucket name should not contain two adjacent periods."];
    }

    if ( [S3BucketNameUtilities contains:theBucketName searchString:@"-."] ||
         [S3BucketNameUtilities contains:theBucketName searchString:@".-"]) {
        return [AmazonClientException exceptionWithMessage : @"Bucket name should not contain dashes next to periods."];
    }

    if ( [[theBucketName lowercaseString] isEqualToString:theBucketName] == NO) {
        return [AmazonClientException exceptionWithMessage : @"Bucket name should not contain upper case characters."];
    }
    
    return nil;
}

+(bool)isDNSBucketName:(NSString *)theBucketName;
{
    if (theBucketName == nil) {
        return NO;
    }

    if ( [theBucketName length] < 3 || [theBucketName length] > 63) {
        return NO;
    }

    if ( [theBucketName hasSuffix:@"-"]) {
        return NO;
    }

    if ( [S3BucketNameUtilities contains:theBucketName searchString:@"_"]) {
        return NO;
    }

    if ( [S3BucketNameUtilities contains:theBucketName searchString:@"."]) {
        return NO;
    }

    if ( [S3BucketNameUtilities contains:theBucketName searchString:@"-."] ||
         [S3BucketNameUtilities contains:theBucketName searchString:@".-"]) {
        return NO;
    }

    if ( [[theBucketName lowercaseString] isEqualToString:theBucketName] == NO) {
        return NO;
    }

    return YES;
}

+(bool)contains:(NSString *)sourceString searchString:(NSString *)searchString
{
    NSRange range = [sourceString rangeOfString:searchString];

    return (range.location != NSNotFound);
}


@end
