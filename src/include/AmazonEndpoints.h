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

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif


typedef enum
{
    US_EAST_1      = 0,
    US_WEST_1      = 1,
    EU_WEST_1      = 2,
    AP_SOUTHEAST_1 = 3,
    AP_NORTHEAST_1 = 4,
    US_WEST_2      = 5,
    SA_EAST_1      = 6,
    AP_SOUTHEAST_2 = 7
} AmazonRegion;

// Port 80
#define AMAZON_S3_US_EAST_1_ENDPOINT          @"http://s3.amazonaws.com"
#define AMAZON_S3_US_WEST_1_ENDPOINT          @"http://s3-us-west-1.amazonaws.com"
#define AMAZON_S3_US_WEST_2_ENDPOINT          @"http://s3-us-west-2.amazonaws.com"
#define AMAZON_S3_EU_WEST_1_ENDPOINT          @"http://s3-eu-west-1.amazonaws.com"
#define AMAZON_S3_AP_SOUTHEAST_1_ENDPOINT     @"http://s3-ap-southeast-1.amazonaws.com"
#define AMAZON_S3_AP_SOUTHEAST_2_ENDPOINT     @"http://s3-ap-southeast-2.amazonaws.com"
#define AMAZON_S3_AP_NORTHEAST_1_ENDPOINT     @"http://s3-ap-northeast-1.amazonaws.com"
#define AMAZON_S3_SA_EAST_1_ENDPOINT          @"http://s3-sa-east-1.amazonaws.com"

#define AMAZON_SDB_US_EAST_1_ENDPOINT         @"http://sdb.amazonaws.com"
#define AMAZON_SDB_US_WEST_1_ENDPOINT         @"http://sdb.us-west-1.amazonaws.com"
#define AMAZON_SDB_US_WEST_2_ENDPOINT         @"http://sdb.us-west-2.amazonaws.com"
#define AMAZON_SDB_EU_WEST_1_ENDPOINT         @"http://sdb.eu-west-1.amazonaws.com"
#define AMAZON_SDB_AP_SOUTHEAST_1_ENDPOINT    @"http://sdb.ap-southeast-1.amazonaws.com"
#define AMAZON_SDB_AP_SOUTHEAST_2_ENDPOINT    @"http://sdb.ap-southeast-2.amazonaws.com"
#define AMAZON_SDB_AP_NORTHEAST_1_ENDPOINT    @"http://sdb.ap-northeast-1.amazonaws.com"
#define AMAZON_SDB_SA_EAST_1_ENDPOINT         @"http://sdb.sa-east-1.amazonaws.com"

#define AMAZON_SNS_US_EAST_1_ENDPOINT         @"http://sns.us-east-1.amazonaws.com"
#define AMAZON_SNS_US_WEST_1_ENDPOINT         @"http://sns.us-west-1.amazonaws.com"
#define AMAZON_SNS_US_WEST_2_ENDPOINT         @"http://sns.us-west-2.amazonaws.com"
#define AMAZON_SNS_EU_WEST_1_ENDPOINT         @"http://sns.eu-west-1.amazonaws.com"
#define AMAZON_SNS_AP_SOUTHEAST_1_ENDPOINT    @"http://sns.ap-southeast-1.amazonaws.com"
#define AMAZON_SNS_AP_SOUTHEAST_2_ENDPOINT    @"http://sns.ap-southeast-2.amazonaws.com"
#define AMAZON_SNS_AP_NORTHEAST_1_ENDPOINT    @"http://sns.ap-northeast-1.amazonaws.com"
#define AMAZON_SNS_SA_EAST_1_ENDPOINT         @"http://sns.sa-east-1.amazonaws.com"

#define AMAZON_SQS_US_EAST_1_ENDPOINT         @"http://sqs.us-east-1.amazonaws.com"
#define AMAZON_SQS_US_WEST_1_ENDPOINT         @"http://sqs.us-west-1.amazonaws.com"
#define AMAZON_SQS_US_WEST_2_ENDPOINT         @"http://sqs.us-west-2.amazonaws.com"
#define AMAZON_SQS_EU_WEST_1_ENDPOINT         @"http://sqs.eu-west-1.amazonaws.com"
#define AMAZON_SQS_AP_SOUTHEAST_1_ENDPOINT    @"http://sqs.ap-southeast-1.amazonaws.com"
#define AMAZON_SQS_AP_SOUTHEAST_2_ENDPOINT    @"http://sqs.ap-southeast-2.amazonaws.com"
#define AMAZON_SQS_AP_NORTHEAST_1_ENDPOINT    @"http://sqs.ap-northeast-1.amazonaws.com"
#define AMAZON_SQS_SA_EAST_1_ENDPOINT         @"http://sqs.sa-east-1.amazonaws.com"

#define AMAZON_CW_US_EAST_1_ENDPOINT          @"http://monitoring.us-east-1.amazonaws.com"
#define AMAZON_CW_US_WEST_1_ENDPOINT          @"http://monitoring.us-west-1.amazonaws.com"
#define AMAZON_CW_US_WEST_2_ENDPOINT          @"http://monitoring.us-west-2.amazonaws.com"
#define AMAZON_CW_EU_WEST_1_ENDPOINT          @"http://monitoring.eu-west-1.amazonaws.com"
#define AMAZON_CW_AP_SOUTHEAST_1_ENDPOINT     @"http://monitoring.ap-southeast-1.amazonaws.com"
#define AMAZON_CW_AP_SOUTHEAST_2_ENDPOINT     @"http://monitoring.ap-southeast-2.amazonaws.com"
#define AMAZON_CW_AP_NORTHEAST_1_ENDPOINT     @"http://monitoring.ap-northeast-1.amazonaws.com"
#define AMAZON_CW_SA_EAST_1_ENDPOINT          @"http://monitoring.sa-east-1.amazonaws.com"

#define AMAZON_EC2_US_EAST_1_ENDPOINT         @"http://ec2.us-east-1.amazonaws.com"
#define AMAZON_EC2_US_WEST_1_ENDPOINT         @"http://ec2.us-west-1.amazonaws.com"
#define AMAZON_EC2_US_WEST_2_ENDPOINT         @"http://ec2.us-west-2.amazonaws.com"
#define AMAZON_EC2_EU_WEST_1_ENDPOINT         @"http://ec2.eu-west-1.amazonaws.com"
#define AMAZON_EC2_AP_SOUTHEAST_1_ENDPOINT    @"http://ec2.ap-southeast-1.amazonaws.com"
#define AMAZON_EC2_AP_SOUTHEAST_2_ENDPOINT    @"http://ec2.ap-southeast-2.amazonaws.com"
#define AMAZON_EC2_AP_NORTHEAST_1_ENDPOINT    @"http://ec2.ap-northeast-1.amazonaws.com"
#define AMAZON_EC2_SA_EAST_1_ENDPOINT         @"http://ec2.sa-east-1.amazonaws.com"

//#define AMAZON_SES_US_EAST_1_ENDPOINT				@"http://"
//#define AMAZON_SES_US_WEST_1_ENDPOINT				@"http://"
//#define AMAZON_SES_US_WEST_2_ENDPOINT				@"http://"
//#define AMAZON_SES_EU_WEST_1_ENDPOINT				@"http://"
//#define AMAZON_SES_AP_SOUTHEAST_1_ENDPOINT		@"http://"
//#define AMAZON_SES_AP_NORTHEAST_1_ENDPOINT		@"http://"
//#define AMAZON_SES_SA_EAST_1_ENDPOINT             @"http://"

#define AMAZON_DDB_US_EAST_1_ENDPOINT             @"http://dynamodb.us-east-1.amazonaws.com"
#define AMAZON_DDB_US_WEST_1_ENDPOINT             @"http://dynamodb.us-west-1.amazonaws.com"
#define AMAZON_DDB_US_WEST_2_ENDPOINT             @"http://dynamodb.us-west-2.amazonaws.com"
#define AMAZON_DDB_EU_WEST_1_ENDPOINT             @"http://dynamodb.eu-west-1.amazonaws.com"
#define AMAZON_DDB_AP_SOUTHEAST_1_ENDPOINT        @"http://dynamodb.ap-southeast-1.amazonaws.com"
#define AMAZON_DDB_AP_SOUTHEAST_2_ENDPOINT        @"http://dynamodb.ap-southeast-2.amazonaws.com"
#define AMAZON_DDB_AP_NORTHEAST_1_ENDPOINT        @"http://dynamodb.ap-northeast-1.amazonaws.com"
#define AMAZON_DDB_SA_EAST_1_ENDPOINT             @"http://dynamodb.sa-east-1.amazonaws.com"

#define AMAZON_AS_US_EAST_1_ENDPOINT                 @"http://autoscaling.us-east-1.amazonaws.com"
#define AMAZON_AS_US_WEST_1_ENDPOINT                 @"http://autoscaling.us-west-1.amazonaws.com"
#define AMAZON_AS_US_WEST_2_ENDPOINT                 @"http://autoscaling.us-west-2.amazonaws.com"
#define AMAZON_AS_EU_WEST_1_ENDPOINT                 @"http://autoscaling.eu-west-1.amazonaws.com"
#define AMAZON_AS_AP_SOUTHEAST_1_ENDPOINT            @"http://autoscaling.ap-southeast-1.amazonaws.com"
#define AMAZON_AS_AP_SOUTHEAST_2_ENDPOINT            @"http://autoscaling.ap-southeast-2.amazonaws.com"
#define AMAZON_AS_AP_NORTHEAST_1_ENDPOINT            @"http://autoscaling.ap-northeast-1.amazonaws.com"
#define AMAZON_AS_SA_EAST_1_ENDPOINT                 @"http://autoscaling.sa-east-1.amazonaws.com"

#define AMAZON_ELB_US_EAST_1_ENDPOINT                @"http://elasticloadbalancing.us-east-1.amazonaws.com"
#define AMAZON_ELB_US_WEST_1_ENDPOINT                @"http://elasticloadbalancing.us-west-1.amazonaws.com"
#define AMAZON_ELB_US_WEST_2_ENDPOINT                @"http://elasticloadbalancing.us-west-2.amazonaws.com"
#define AMAZON_ELB_EU_WEST_1_ENDPOINT                @"http://elasticloadbalancing.eu-west-1.amazonaws.com"
#define AMAZON_ELB_AP_SOUTHEAST_1_ENDPOINT           @"http://elasticloadbalancing.ap-southeast-1.amazonaws.com"
#define AMAZON_ELB_AP_SOUTHEAST_2_ENDPOINT           @"http://elasticloadbalancing.ap-southeast-2.amazonaws.com"
#define AMAZON_ELB_AP_NORTHEAST_1_ENDPOINT           @"http://elasticloadbalancing.ap-northeast-1.amazonaws.com"
#define AMAZON_ELB_SA_EAST_1_ENDPOINT                @"http://elasticloadbalancing.sa-east-1.amazonaws.com"


// Port 443
#define AMAZON_S3_US_EAST_1_ENDPOINT_SECURE          @"https://s3.amazonaws.com"
#define AMAZON_S3_US_WEST_1_ENDPOINT_SECURE          @"https://s3-us-west-1.amazonaws.com"
#define AMAZON_S3_US_WEST_2_ENDPOINT_SECURE          @"https://s3-us-west-2.amazonaws.com"
#define AMAZON_S3_EU_WEST_1_ENDPOINT_SECURE          @"https://s3-eu-west-1.amazonaws.com"
#define AMAZON_S3_AP_SOUTHEAST_1_ENDPOINT_SECURE     @"https://s3-ap-southeast-1.amazonaws.com"
#define AMAZON_S3_AP_SOUTHEAST_2_ENDPOINT_SECURE     @"https://s3-ap-southeast-2.amazonaws.com"
#define AMAZON_S3_AP_NORTHEAST_1_ENDPOINT_SECURE     @"https://s3-ap-northeast-1.amazonaws.com"
#define AMAZON_S3_SA_EAST_1_ENDPOINT_SECURE          @"https://s3-sa-east-1.amazonaws.com"

#define AMAZON_SDB_US_EAST_1_ENDPOINT_SECURE         @"https://sdb.amazonaws.com"
#define AMAZON_SDB_US_WEST_1_ENDPOINT_SECURE         @"https://sdb.us-west-1.amazonaws.com"
#define AMAZON_SDB_US_WEST_2_ENDPOINT_SECURE         @"https://sdb.us-west-2.amazonaws.com"
#define AMAZON_SDB_EU_WEST_1_ENDPOINT_SECURE         @"https://sdb.eu-west-1.amazonaws.com"
#define AMAZON_SDB_AP_SOUTHEAST_1_ENDPOINT_SECURE    @"https://sdb.ap-southeast-1.amazonaws.com"
#define AMAZON_SDB_AP_SOUTHEAST_2_ENDPOINT_SECURE    @"https://sdb.ap-southeast-2.amazonaws.com"
#define AMAZON_SDB_AP_NORTHEAST_1_ENDPOINT_SECURE    @"https://sdb.ap-northeast-1.amazonaws.com"
#define AMAZON_SDB_SA_EAST_1_ENDPOINT_SECURE         @"https://sdb.sa-east-1.amazonaws.com"

#define AMAZON_SNS_US_EAST_1_ENDPOINT_SECURE         @"https://sns.us-east-1.amazonaws.com"
#define AMAZON_SNS_US_WEST_1_ENDPOINT_SECURE         @"https://sns.us-west-1.amazonaws.com"
#define AMAZON_SNS_US_WEST_2_ENDPOINT_SECURE         @"https://sns.us-west-2.amazonaws.com"
#define AMAZON_SNS_EU_WEST_1_ENDPOINT_SECURE         @"https://sns.eu-west-1.amazonaws.com"
#define AMAZON_SNS_AP_SOUTHEAST_1_ENDPOINT_SECURE    @"https://sns.ap-southeast-1.amazonaws.com"
#define AMAZON_SNS_AP_SOUTHEAST_2_ENDPOINT_SECURE    @"https://sns.ap-southeast-2.amazonaws.com"
#define AMAZON_SNS_AP_NORTHEAST_1_ENDPOINT_SECURE    @"https://sns.ap-northeast-1.amazonaws.com"
#define AMAZON_SNS_SA_EAST_1_ENDPOINT_SECURE         @"https://sns.sa-east-1.amazonaws.com"

#define AMAZON_SQS_US_EAST_1_ENDPOINT_SECURE         @"https://sqs.us-east-1.amazonaws.com"
#define AMAZON_SQS_US_WEST_1_ENDPOINT_SECURE         @"https://sqs.us-west-1.amazonaws.com"
#define AMAZON_SQS_US_WEST_2_ENDPOINT_SECURE         @"https://sqs.us-west-2.amazonaws.com"
#define AMAZON_SQS_EU_WEST_1_ENDPOINT_SECURE         @"https://sqs.eu-west-1.amazonaws.com"
#define AMAZON_SQS_AP_SOUTHEAST_1_ENDPOINT_SECURE    @"https://sqs.ap-southeast-1.amazonaws.com"
#define AMAZON_SQS_AP_SOUTHEAST_2_ENDPOINT_SECURE    @"https://sqs.ap-southeast-2.amazonaws.com"
#define AMAZON_SQS_AP_NORTHEAST_1_ENDPOINT_SECURE    @"https://sqs.ap-northeast-1.amazonaws.com"
#define AMAZON_SQS_SA_EAST_1_ENDPOINT_SECURE         @"https://sqs.sa-east-1.amazonaws.com"

#define AMAZON_CW_US_EAST_1_ENDPOINT_SECURE          @"https://monitoring.us-east-1.amazonaws.com"
#define AMAZON_CW_US_WEST_1_ENDPOINT_SECURE          @"https://monitoring.us-west-1.amazonaws.com"
#define AMAZON_CW_US_WEST_2_ENDPOINT_SECURE          @"https://monitoring.us-west-2.amazonaws.com"
#define AMAZON_CW_EU_WEST_1_ENDPOINT_SECURE          @"https://monitoring.eu-west-1.amazonaws.com"
#define AMAZON_CW_AP_SOUTHEAST_1_ENDPOINT_SECURE     @"https://monitoring.ap-southeast-1.amazonaws.com"
#define AMAZON_CW_AP_SOUTHEAST_2_ENDPOINT_SECURE     @"https://monitoring.ap-southeast-2.amazonaws.com"
#define AMAZON_CW_AP_NORTHEAST_1_ENDPOINT_SECURE     @"https://monitoring.ap-northeast-1.amazonaws.com"
#define AMAZON_CW_SA_EAST_1_ENDPOINT_SECURE          @"https://monitoring.sa-east-1.amazonaws.com"

#define AMAZON_EC2_US_EAST_1_ENDPOINT_SECURE         @"https://ec2.us-east-1.amazonaws.com"
#define AMAZON_EC2_US_WEST_1_ENDPOINT_SECURE         @"https://ec2.us-west-1.amazonaws.com"
#define AMAZON_EC2_US_WEST_2_ENDPOINT_SECURE         @"https://ec2.us-west-2.amazonaws.com"
#define AMAZON_EC2_EU_WEST_1_ENDPOINT_SECURE         @"https://ec2.eu-west-1.amazonaws.com"
#define AMAZON_EC2_AP_SOUTHEAST_1_ENDPOINT_SECURE    @"https://ec2.ap-southeast-1.amazonaws.com"
#define AMAZON_EC2_AP_SOUTHEAST_2_ENDPOINT_SECURE    @"https://ec2.ap-southeast-2.amazonaws.com"
#define AMAZON_EC2_AP_NORTHEAST_1_ENDPOINT_SECURE    @"https://ec2.ap-northeast-1.amazonaws.com"
#define AMAZON_EC2_SA_EAST_1_ENDPOINT_SECURE         @"https://ec2.sa-east-1.amazonaws.com"

#define AMAZON_SES_US_EAST_1_ENDPOINT_SECURE         @"https://email.us-east-1.amazonaws.com"
//#define AMAZON_SES_US_WEST_1_ENDPOINT_SECURE		 @"https://"
#define AMAZON_SES_US_WEST_2_ENDPOINT_SECURE		 @"https://email.us-west-2.amazonaws.com"
#define AMAZON_SES_EU_WEST_1_ENDPOINT_SECURE		 @"https://email.eu-west-1.amazonaws.com"
//#define AMAZON_SES_AP_SOUTHEAST_1_ENDPOINT_SECURE	 @"https://"
//#define AMAZON_SES_AP_NORTHEAST_1_ENDPOINT_SECURE	 @"https://"
//#define AMAZON_SES_SA_EAST_1_ENDPOINT_SECURE       @"https://"

#define AMAZON_DDB_US_EAST_1_ENDPOINT_SECURE         @"https://dynamodb.us-east-1.amazonaws.com"
#define AMAZON_DDB_US_WEST_1_ENDPOINT_SECURE		 @"https://dynamodb.us-west-1.amazonaws.com"
#define AMAZON_DDB_US_WEST_2_ENDPOINT_SECURE		 @"https://dynamodb.us-west-2.amazonaws.com"
#define AMAZON_DDB_EU_WEST_1_ENDPOINT_SECURE		 @"https://dynamodb.eu-west-1.amazonaws.com"
#define AMAZON_DDB_AP_SOUTHEAST_1_ENDPOINT_SECURE	 @"https://dynamodb.ap-southeast-1.amazonaws.com"
#define AMAZON_DDB_AP_SOUTHEAST_2_ENDPOINT_SECURE	 @"https://dynamodb.ap-southeast-2.amazonaws.com"
#define AMAZON_DDB_AP_NORTHEAST_1_ENDPOINT_SECURE	 @"https://dynamodb.ap-northeast-1.amazonaws.com"
#define AMAZON_DDB_SA_EAST_1_ENDPOINT_SECURE         @"https://dynamodb.sa-east-1.amazonaws.com"

#define AMAZON_AS_US_EAST_1_ENDPOINT_SECURE          @"https://autoscaling.us-east-1.amazonaws.com"
#define AMAZON_AS_US_WEST_1_ENDPOINT_SECURE          @"https://autoscaling.us-west-1.amazonaws.com"
#define AMAZON_AS_US_WEST_2_ENDPOINT_SECURE          @"https://autoscaling.us-west-2.amazonaws.com"
#define AMAZON_AS_EU_WEST_1_ENDPOINT_SECURE          @"https://autoscaling.eu-west-1.amazonaws.com"
#define AMAZON_AS_AP_SOUTHEAST_1_ENDPOINT_SECURE     @"https://autoscaling.ap-southeast-1.amazonaws.com"
#define AMAZON_AS_AP_SOUTHEAST_2_ENDPOINT_SECURE     @"https://autoscaling.ap-southeast-2.amazonaws.com"
#define AMAZON_AS_AP_NORTHEAST_1_ENDPOINT_SECURE     @"https://autoscaling.ap-northeast-1.amazonaws.com"
#define AMAZON_AS_SA_EAST_1_ENDPOINT_SECURE          @"https://autoscaling.sa-east-1.amazonaws.com"

#define AMAZON_ELB_US_EAST_1_ENDPOINT_SECURE         @"https://elasticloadbalancing.us-east-1.amazonaws.com"
#define AMAZON_ELB_US_WEST_1_ENDPOINT_SECURE         @"https://elasticloadbalancing.us-west-1.amazonaws.com"
#define AMAZON_ELB_US_WEST_2_ENDPOINT_SECURE         @"https://elasticloadbalancing.us-west-2.amazonaws.com"
#define AMAZON_ELB_EU_WEST_1_ENDPOINT_SECURE         @"https://elasticloadbalancing.eu-west-1.amazonaws.com"
#define AMAZON_ELB_AP_SOUTHEAST_1_ENDPOINT_SECURE    @"https://elasticloadbalancing.ap-southeast-1.amazonaws.com"
#define AMAZON_ELB_AP_SOUTHEAST_2_ENDPOINT_SECURE    @"https://elasticloadbalancing.ap-southeast-2.amazonaws.com"
#define AMAZON_ELB_AP_NORTHEAST_1_ENDPOINT_SECURE    @"https://elasticloadbalancing.ap-northeast-1.amazonaws.com"
#define AMAZON_ELB_SA_EAST_1_ENDPOINT_SECURE         @"https://elasticloadbalancing.sa-east-1.amazonaws.com"

#define AMAZON_STS_ENDPOINT_SECURE    @"https://sts.amazonaws.com"


@interface AmazonEndpoints:NSObject {
}

+(NSString *)s3Endpoint:(AmazonRegion)region;
+(NSString *)s3Endpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)sdbEndpoint:(AmazonRegion)region;
+(NSString *)sdbEndpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)snsEndpoint:(AmazonRegion)region;
+(NSString *)snsEndpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)sqsEndpoint:(AmazonRegion)region;
+(NSString *)sqsEndpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)cwEndpoint:(AmazonRegion)region;
+(NSString *)cwEndpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)ec2Endpoint:(AmazonRegion)region;
+(NSString *)ec2Endpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)sesEndpoint:(AmazonRegion)region;
+(NSString *)sesEndpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)elbEndpoint:(AmazonRegion)region;
+(NSString *)elbEndpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)autoscalingEndpoint:(AmazonRegion)region;
+(NSString *)autoscalingEndpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)ddbEndpoint:(AmazonRegion)region;
+(NSString *)ddbEndpoint:(AmazonRegion)region secure:(bool)useSSL;
+(NSString *)stsEndpoint;

@end
