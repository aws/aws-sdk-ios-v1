/*
 * Copyright 2010-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
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

#import <CoreData/CoreData.h>
#import <AWSiOSSDK/DynamoDB/AmazonDynamoDBClient.h>

extern NSString *const AWSPersistenceDynamoDBIncrementalStoreType;
extern NSString *const AWSPersistenceDynamoDBHashKey;
extern NSString *const AWSPersistenceDynamoDBRangeKey;
extern NSString *const AWSPersistenceDynamoDBVersionKey;
extern NSString *const AWSPersistenceDynamoDBDelegate;
extern NSString *const AWSPersistenceDynamoDBTableMapper;

extern NSString *const AWSPersistenceDynamoDBServiceErrorDomain;
extern NSString *const AWSPersistenceDynamoDBClientErrorDomain;

extern NSString *const AWSPersistenceDynamoDBObjectDeletedNotification;
extern NSString *const AWSPersistenceDynamoDBObjectDeletedNotificationHashKey;
extern NSString *const AWSPersistenceDynamoDBObjectDeletedNotificationEntityName;
extern NSString *const AWSPersistenceDynamoDBObjectDeletedNotificationObjectID;

extern NSString *const AWSPersistenceDynamoDBEndpoint;
extern NSString *const AWSPersistenceDynamoDBMaxRetries;
extern NSString *const AWSPersistenceDynamoDBTimeout;
extern NSString *const AWSPersistenceDynamoDBDelay;
extern NSString *const AWSPersistenceDynamoDBUserAgent;

@protocol AWSPersistenceDynamoDBIncrementalStoreDelegate;

@interface AWSPersistenceDynamoDBIncrementalStore : NSIncrementalStore
{
    NSMutableDictionary *objectIdToHashKey;
    id<AWSPersistenceDynamoDBIncrementalStoreDelegate> delegate;
    
    NSNumberFormatter *nf;
}

@property (assign) int initialBackoffTimeInSecond;
@property (assign) int retryCount;

@end

@protocol AWSPersistenceDynamoDBIncrementalStoreDelegate <NSObject>

@required

/*
 Every time AWSPersistenceDynamoDBIncrementalStore needs to access Amazon DynamoDB, 
 it calls this method to obtain a valid and non-expired credentials.
 */
- (AmazonCredentials *)credentials;

@optional

/*
 When AWSPersistenceDynamoDBIncrementalStore receives authentication related exceptions from the AWS services,
 it calls this method. The delegate should wipe out the locally stored credentials.
 */
- (void)handleAuthenticationFailure;

@end