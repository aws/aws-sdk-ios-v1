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

#import "AmazonEndpoints.h"

@implementation AmazonEndpoints {
}


+(NSString *)s3Endpoint:(AmazonRegion)region
{
    return [AmazonEndpoints s3Endpoint:region secure:YES];
}

+(NSString *)s3Endpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
        case US_EAST_1: return AMAZON_S3_US_EAST_1_ENDPOINT_SECURE;

        case US_WEST_1: return AMAZON_S3_US_WEST_1_ENDPOINT_SECURE;

        case US_WEST_2: return AMAZON_S3_US_WEST_2_ENDPOINT_SECURE;

        case EU_WEST_1: return AMAZON_S3_EU_WEST_1_ENDPOINT_SECURE;

        case AP_SOUTHEAST_1: return AMAZON_S3_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
        case AP_SOUTHEAST_2: return AMAZON_S3_AP_SOUTHEAST_2_ENDPOINT_SECURE;
                
        case AP_NORTHEAST_1: return AMAZON_S3_AP_NORTHEAST_1_ENDPOINT_SECURE;

        case SA_EAST_1: return AMAZON_S3_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
        case US_EAST_1: return AMAZON_S3_US_EAST_1_ENDPOINT;

        case US_WEST_1: return AMAZON_S3_US_WEST_1_ENDPOINT;

        case US_WEST_2: return AMAZON_S3_US_WEST_2_ENDPOINT;

        case EU_WEST_1: return AMAZON_S3_EU_WEST_1_ENDPOINT;

        case AP_SOUTHEAST_1: return AMAZON_S3_AP_SOUTHEAST_1_ENDPOINT;
                
        case AP_SOUTHEAST_2: return AMAZON_S3_AP_SOUTHEAST_2_ENDPOINT;

        case AP_NORTHEAST_1: return AMAZON_S3_AP_NORTHEAST_1_ENDPOINT;

        case SA_EAST_1: return AMAZON_S3_SA_EAST_1_ENDPOINT;
        };
    }

    return AMAZON_S3_US_EAST_1_ENDPOINT;
}

+(NSString *)sdbEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints sdbEndpoint:region secure:YES];
}

+(NSString *)sdbEndpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
        case US_EAST_1: return AMAZON_SDB_US_EAST_1_ENDPOINT_SECURE;

        case US_WEST_1: return AMAZON_SDB_US_WEST_1_ENDPOINT_SECURE;

        case US_WEST_2: return AMAZON_SDB_US_WEST_2_ENDPOINT_SECURE;

        case EU_WEST_1: return AMAZON_SDB_EU_WEST_1_ENDPOINT_SECURE;

        case AP_SOUTHEAST_1: return AMAZON_SDB_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
        case AP_SOUTHEAST_2: return AMAZON_SDB_AP_SOUTHEAST_2_ENDPOINT_SECURE;

        case AP_NORTHEAST_1: return AMAZON_SDB_AP_NORTHEAST_1_ENDPOINT_SECURE;

        case SA_EAST_1: return AMAZON_SDB_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
        case US_EAST_1: return AMAZON_SDB_US_EAST_1_ENDPOINT;

        case US_WEST_1: return AMAZON_SDB_US_WEST_1_ENDPOINT;

        case US_WEST_2: return AMAZON_SDB_US_WEST_2_ENDPOINT;

        case EU_WEST_1: return AMAZON_SDB_EU_WEST_1_ENDPOINT;

        case AP_SOUTHEAST_1: return AMAZON_SDB_AP_SOUTHEAST_1_ENDPOINT;
                
        case AP_SOUTHEAST_2: return AMAZON_SDB_AP_SOUTHEAST_2_ENDPOINT;

        case AP_NORTHEAST_1: return AMAZON_SDB_AP_NORTHEAST_1_ENDPOINT;

        case SA_EAST_1: return AMAZON_SDB_SA_EAST_1_ENDPOINT;
        };
    }

    return AMAZON_SDB_US_EAST_1_ENDPOINT;
}

+(NSString *)snsEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints snsEndpoint:region secure:YES];
}

+(NSString *)snsEndpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
        case US_EAST_1: return AMAZON_SNS_US_EAST_1_ENDPOINT_SECURE;

        case US_WEST_1: return AMAZON_SNS_US_WEST_1_ENDPOINT_SECURE;

        case US_WEST_2: return AMAZON_SNS_US_WEST_2_ENDPOINT_SECURE;

        case EU_WEST_1: return AMAZON_SNS_EU_WEST_1_ENDPOINT_SECURE;

        case AP_SOUTHEAST_1: return AMAZON_SNS_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
        case AP_SOUTHEAST_2: return AMAZON_SNS_AP_SOUTHEAST_2_ENDPOINT_SECURE;

        case AP_NORTHEAST_1: return AMAZON_SNS_AP_NORTHEAST_1_ENDPOINT_SECURE;

        case SA_EAST_1: return AMAZON_SNS_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
        case US_EAST_1: return AMAZON_SNS_US_EAST_1_ENDPOINT;

        case US_WEST_1: return AMAZON_SNS_US_WEST_1_ENDPOINT;

        case US_WEST_2: return AMAZON_SNS_US_WEST_2_ENDPOINT;

        case EU_WEST_1: return AMAZON_SNS_EU_WEST_1_ENDPOINT;

        case AP_SOUTHEAST_1: return AMAZON_SNS_AP_SOUTHEAST_1_ENDPOINT;
                
        case AP_SOUTHEAST_2: return AMAZON_SNS_AP_SOUTHEAST_2_ENDPOINT;

        case AP_NORTHEAST_1: return AMAZON_SNS_AP_NORTHEAST_1_ENDPOINT;

        case SA_EAST_1: return AMAZON_SNS_SA_EAST_1_ENDPOINT;
        };
    }

    return AMAZON_SNS_US_EAST_1_ENDPOINT;
}

+(NSString *)sqsEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints sqsEndpoint:region secure:YES];
}

+(NSString *)sqsEndpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
        case US_EAST_1: return AMAZON_SQS_US_EAST_1_ENDPOINT_SECURE;

        case US_WEST_1: return AMAZON_SQS_US_WEST_1_ENDPOINT_SECURE;

        case US_WEST_2: return AMAZON_SQS_US_WEST_2_ENDPOINT_SECURE;

        case EU_WEST_1: return AMAZON_SQS_EU_WEST_1_ENDPOINT_SECURE;

        case AP_SOUTHEAST_1: return AMAZON_SQS_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
        case AP_SOUTHEAST_2: return AMAZON_SQS_AP_SOUTHEAST_2_ENDPOINT_SECURE;

        case AP_NORTHEAST_1: return AMAZON_SQS_AP_NORTHEAST_1_ENDPOINT_SECURE;

        case SA_EAST_1: return AMAZON_SQS_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
        case US_EAST_1: return AMAZON_SQS_US_EAST_1_ENDPOINT;

        case US_WEST_1: return AMAZON_SQS_US_WEST_1_ENDPOINT;

        case US_WEST_2: return AMAZON_SQS_US_WEST_2_ENDPOINT;

        case EU_WEST_1: return AMAZON_SQS_EU_WEST_1_ENDPOINT;

        case AP_SOUTHEAST_1: return AMAZON_SQS_AP_SOUTHEAST_1_ENDPOINT;
                
        case AP_SOUTHEAST_2: return AMAZON_SQS_AP_SOUTHEAST_2_ENDPOINT;

        case AP_NORTHEAST_1: return AMAZON_SQS_AP_NORTHEAST_1_ENDPOINT;

        case SA_EAST_1: return AMAZON_SQS_SA_EAST_1_ENDPOINT;
        };
    }

    return AMAZON_SQS_US_EAST_1_ENDPOINT;
}

+(NSString *)sesEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints sesEndpoint:region secure:YES];
}

+(NSString *)sesEndpoint:(AmazonRegion)region secure:(bool)useSSL
{
    return AMAZON_SES_US_EAST_1_ENDPOINT_SECURE;
}

+(NSString *)ec2Endpoint:(AmazonRegion)region
{
    return [AmazonEndpoints ec2Endpoint:region secure:YES];
}

+(NSString *)ec2Endpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
        case US_EAST_1: return AMAZON_EC2_US_EAST_1_ENDPOINT_SECURE;

        case US_WEST_1: return AMAZON_EC2_US_WEST_1_ENDPOINT_SECURE;

        case US_WEST_2: return AMAZON_EC2_US_WEST_2_ENDPOINT_SECURE;

        case EU_WEST_1: return AMAZON_EC2_EU_WEST_1_ENDPOINT_SECURE;

        case AP_SOUTHEAST_1: return AMAZON_EC2_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
        case AP_SOUTHEAST_2: return AMAZON_EC2_AP_SOUTHEAST_2_ENDPOINT_SECURE;

        case AP_NORTHEAST_1: return AMAZON_EC2_AP_NORTHEAST_1_ENDPOINT_SECURE;

        case SA_EAST_1: return AMAZON_EC2_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
        case US_EAST_1: return AMAZON_EC2_US_EAST_1_ENDPOINT;

        case US_WEST_1: return AMAZON_EC2_US_WEST_1_ENDPOINT;

        case US_WEST_2: return AMAZON_EC2_US_WEST_2_ENDPOINT;

        case EU_WEST_1: return AMAZON_EC2_EU_WEST_1_ENDPOINT;

        case AP_SOUTHEAST_1: return AMAZON_EC2_AP_SOUTHEAST_1_ENDPOINT;
                
        case AP_SOUTHEAST_2: return AMAZON_EC2_AP_SOUTHEAST_1_ENDPOINT;

        case AP_NORTHEAST_1: return AMAZON_EC2_AP_NORTHEAST_1_ENDPOINT;

        case SA_EAST_1: return AMAZON_EC2_SA_EAST_1_ENDPOINT;
        };
    }

    return AMAZON_EC2_US_EAST_1_ENDPOINT;
}

+(NSString *)cwEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints cwEndpoint:region secure:YES];
}

+(NSString *)cwEndpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
        case US_EAST_1: return AMAZON_CW_US_EAST_1_ENDPOINT_SECURE;

        case US_WEST_1: return AMAZON_CW_US_WEST_1_ENDPOINT_SECURE;

        case US_WEST_2: return AMAZON_CW_US_WEST_2_ENDPOINT_SECURE;

        case EU_WEST_1: return AMAZON_CW_EU_WEST_1_ENDPOINT_SECURE;

        case AP_SOUTHEAST_1: return AMAZON_CW_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
        case AP_SOUTHEAST_2: return AMAZON_CW_AP_SOUTHEAST_2_ENDPOINT_SECURE;

        case AP_NORTHEAST_1: return AMAZON_CW_AP_NORTHEAST_1_ENDPOINT_SECURE;

        case SA_EAST_1: return AMAZON_CW_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
        case US_EAST_1: return AMAZON_CW_US_EAST_1_ENDPOINT;

        case US_WEST_1: return AMAZON_CW_US_WEST_1_ENDPOINT;

        case US_WEST_2: return AMAZON_CW_US_WEST_2_ENDPOINT;

        case EU_WEST_1: return AMAZON_CW_EU_WEST_1_ENDPOINT;

        case AP_SOUTHEAST_1: return AMAZON_CW_AP_SOUTHEAST_1_ENDPOINT;
                
        case AP_SOUTHEAST_2: return AMAZON_CW_AP_SOUTHEAST_2_ENDPOINT;

        case AP_NORTHEAST_1: return AMAZON_CW_AP_NORTHEAST_1_ENDPOINT;

        case SA_EAST_1: return AMAZON_CW_SA_EAST_1_ENDPOINT;
        };
    }

    return AMAZON_CW_US_EAST_1_ENDPOINT;
}

+(NSString *)cfEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints cfEndpoint:region secure:YES];
}

+(NSString *)cfEndpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
            case US_EAST_1: return AMAZON_CF_US_EAST_1_ENDPOINT_SECURE;
                
            case US_WEST_1: return AMAZON_CF_US_WEST_1_ENDPOINT_SECURE;
                
            case US_WEST_2: return AMAZON_CF_US_WEST_2_ENDPOINT_SECURE;
                
            case EU_WEST_1: return AMAZON_CF_EU_WEST_1_ENDPOINT_SECURE;
                
            case AP_SOUTHEAST_1: return AMAZON_CF_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
            case AP_SOUTHEAST_2: return AMAZON_CF_AP_SOUTHEAST_2_ENDPOINT_SECURE;
                
            case AP_NORTHEAST_1: return AMAZON_CF_AP_NORTHEAST_1_ENDPOINT_SECURE;
                
            case SA_EAST_1: return AMAZON_CF_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
            case US_EAST_1: return AMAZON_CF_US_EAST_1_ENDPOINT;
                
            case US_WEST_1: return AMAZON_CF_US_WEST_1_ENDPOINT;
                
            case US_WEST_2: return AMAZON_CF_US_WEST_2_ENDPOINT;
                
            case EU_WEST_1: return AMAZON_CF_EU_WEST_1_ENDPOINT;
                
            case AP_SOUTHEAST_1: return AMAZON_CF_AP_SOUTHEAST_1_ENDPOINT;
                
            case AP_SOUTHEAST_2: return AMAZON_CF_AP_SOUTHEAST_2_ENDPOINT;
                
            case AP_NORTHEAST_1: return AMAZON_CF_AP_NORTHEAST_1_ENDPOINT;
                
            case SA_EAST_1: return AMAZON_CF_SA_EAST_1_ENDPOINT;
        };
    }
    
    return AMAZON_CF_US_EAST_1_ENDPOINT;
}

+(NSString *)autoscalingEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints autoscalingEndpoint:region secure:YES];
}

+(NSString *)autoscalingEndpoint:(AmazonRegion)region secure:(bool)useSSL;
{
    if (useSSL) {
        switch (region) {
        case US_EAST_1: return AMAZON_AS_US_EAST_1_ENDPOINT_SECURE;

        case US_WEST_1: return AMAZON_AS_US_WEST_1_ENDPOINT_SECURE;

        case US_WEST_2: return AMAZON_AS_US_WEST_2_ENDPOINT_SECURE;

        case EU_WEST_1: return AMAZON_AS_EU_WEST_1_ENDPOINT_SECURE;

        case AP_SOUTHEAST_1: return AMAZON_AS_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
        case AP_SOUTHEAST_2: return AMAZON_AS_AP_SOUTHEAST_2_ENDPOINT_SECURE;

        case AP_NORTHEAST_1: return AMAZON_AS_AP_NORTHEAST_1_ENDPOINT_SECURE;

        case SA_EAST_1: return AMAZON_AS_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
        case US_EAST_1: return AMAZON_AS_US_EAST_1_ENDPOINT;

        case US_WEST_1: return AMAZON_AS_US_WEST_1_ENDPOINT;

        case US_WEST_2: return AMAZON_AS_US_WEST_2_ENDPOINT;

        case EU_WEST_1: return AMAZON_AS_EU_WEST_1_ENDPOINT;

        case AP_SOUTHEAST_1: return AMAZON_AS_AP_SOUTHEAST_1_ENDPOINT;
                
        case AP_SOUTHEAST_2: return AMAZON_AS_AP_SOUTHEAST_2_ENDPOINT;

        case AP_NORTHEAST_1: return AMAZON_AS_AP_NORTHEAST_1_ENDPOINT;

        case SA_EAST_1: return AMAZON_AS_SA_EAST_1_ENDPOINT;
        };
    }

    return AMAZON_AS_US_EAST_1_ENDPOINT;
}

+(NSString *)elbEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints elbEndpoint:region secure:YES];
}

+(NSString *)elbEndpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
        case US_EAST_1: return AMAZON_ELB_US_EAST_1_ENDPOINT_SECURE;

        case US_WEST_1: return AMAZON_ELB_US_WEST_1_ENDPOINT_SECURE;

        case US_WEST_2: return AMAZON_ELB_US_WEST_2_ENDPOINT_SECURE;

        case EU_WEST_1: return AMAZON_ELB_EU_WEST_1_ENDPOINT_SECURE;

        case AP_SOUTHEAST_1: return AMAZON_ELB_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
        case AP_SOUTHEAST_2: return AMAZON_ELB_AP_SOUTHEAST_2_ENDPOINT_SECURE;

        case AP_NORTHEAST_1: return AMAZON_ELB_AP_NORTHEAST_1_ENDPOINT_SECURE;

        case SA_EAST_1: return AMAZON_ELB_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
        case US_EAST_1: return AMAZON_ELB_US_EAST_1_ENDPOINT;

        case US_WEST_1: return AMAZON_ELB_US_WEST_1_ENDPOINT;

        case US_WEST_2: return AMAZON_ELB_US_WEST_2_ENDPOINT;

        case EU_WEST_1: return AMAZON_ELB_EU_WEST_1_ENDPOINT;

        case AP_SOUTHEAST_1: return AMAZON_ELB_AP_SOUTHEAST_1_ENDPOINT;
                
        case AP_SOUTHEAST_2: return AMAZON_ELB_AP_SOUTHEAST_2_ENDPOINT;

        case AP_NORTHEAST_1: return AMAZON_ELB_AP_NORTHEAST_1_ENDPOINT;

        case SA_EAST_1: return AMAZON_ELB_SA_EAST_1_ENDPOINT;
        };
    }

    return AMAZON_ELB_US_EAST_1_ENDPOINT;
}

+(NSString *)ddbEndpoint:(AmazonRegion)region
{
    return [AmazonEndpoints ddbEndpoint:region secure:YES];
}

+(NSString *)ddbEndpoint:(AmazonRegion)region secure:(bool)useSSL
{
    if (useSSL) {
        switch (region) {
            case US_EAST_1: return AMAZON_DDB_US_EAST_1_ENDPOINT_SECURE;
                
            case US_WEST_1: return AMAZON_DDB_US_WEST_1_ENDPOINT_SECURE;
                
            case US_WEST_2: return AMAZON_DDB_US_WEST_2_ENDPOINT_SECURE;
                
            case EU_WEST_1: return AMAZON_DDB_EU_WEST_1_ENDPOINT_SECURE;
                
            case AP_SOUTHEAST_1: return AMAZON_DDB_AP_SOUTHEAST_1_ENDPOINT_SECURE;
                
            case AP_SOUTHEAST_2: return AMAZON_DDB_AP_SOUTHEAST_2_ENDPOINT_SECURE;
                
            case AP_NORTHEAST_1: return AMAZON_DDB_AP_NORTHEAST_1_ENDPOINT_SECURE;
                
            case SA_EAST_1: return AMAZON_DDB_SA_EAST_1_ENDPOINT_SECURE;
        };
    }
    else {
        switch (region) {
            case US_EAST_1: return AMAZON_DDB_US_EAST_1_ENDPOINT;
                
            case US_WEST_1: return AMAZON_DDB_US_WEST_1_ENDPOINT;
                
            case US_WEST_2: return AMAZON_DDB_US_WEST_2_ENDPOINT;
                
            case EU_WEST_1: return AMAZON_DDB_EU_WEST_1_ENDPOINT;
                
            case AP_SOUTHEAST_1: return AMAZON_DDB_AP_SOUTHEAST_1_ENDPOINT;
                
            case AP_SOUTHEAST_2: return AMAZON_DDB_AP_SOUTHEAST_2_ENDPOINT;
                
            case AP_NORTHEAST_1: return AMAZON_DDB_AP_NORTHEAST_1_ENDPOINT;
                
            case SA_EAST_1: return AMAZON_DDB_SA_EAST_1_ENDPOINT;
        };
    }
    
    return AMAZON_DDB_US_EAST_1_ENDPOINT;
}

+(NSString *)stsEndpoint
{
    return AMAZON_STS_ENDPOINT_SECURE;
}

@end
