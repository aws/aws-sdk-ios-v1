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

#import "AWSPersistenceDynamoDBIncrementalStore.h"
#import <objc/message.h>
#import <AWSiOSSDK/AmazonErrorHandler.h>

// Public Constants
NSString *const AWSPersistenceDynamoDBIncrementalStoreType = @"AWSPersistenceDynamoDBIncrementalStore";
NSString *const AWSPersistenceDynamoDBHashKey = @"hashKeys";
NSString *const AWSPersistenceDynamoDBRangeKey = @"rangeKeys";
NSString *const AWSPersistenceDynamoDBVersionKey = @"versions";
NSString *const AWSPersistenceDynamoDBDelegate = @"delegate";
NSString *const AWSPersistenceDynamoDBTableMapper = @"tableMapper";

NSString *const AWSPersistenceDynamoDBServiceErrorDomain = @"com.amazonaws.coredata.AWSPersistenceDynamoDBServiceErrorDomain";
NSString *const AWSPersistenceDynamoDBClientErrorDomain = @"com.amazonaws.coredata.AWSPersistenceDynamoDBClientErrorDomain";

NSString *const AWSPersistenceDynamoDBObjectDeletedNotification = @"AWSPersistenceDynamoDBObjectDeletedNotification";
NSString *const AWSPersistenceDynamoDBObjectDeletedNotificationHashKey = @"hashKey";
NSString *const AWSPersistenceDynamoDBObjectDeletedNotificationEntityName = @"entityName";
NSString *const AWSPersistenceDynamoDBObjectDeletedNotificationObjectID = @"objectID";

// Private Constants
NSString *const AWSPersistenceDynamoDBUserAgentPrefix = @"Persistence Framework";

@implementation AWSPersistenceDynamoDBIncrementalStore

@synthesize initialBackoffTimeInSecond, retryCount;

#pragma mark - NSIncrementalStore Methods

- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root configurationName:(NSString *)name URL:(NSURL *)url options:(NSDictionary *)options
{
    AMZLogDebug(@"- (id)initWithPersistentStoreCoordinator:(NSPersistentStoreCoordinator *)root configurationName:(NSString *)name URL:(NSURL *)url options:(NSDictionary *)options called.");
    if (self = [super initWithPersistentStoreCoordinator:root configurationName:name URL:url options:options])
    {
        objectIdToHashKey = [NSMutableDictionary dictionaryWithCapacity:100];
        delegate = [options objectForKey:AWSPersistenceDynamoDBDelegate];

        nf = [NSNumberFormatter new];
        [nf setNumberStyle:NSNumberFormatterDecimalStyle];
        [nf setMaximumFractionDigits:38];
        [nf setMinimumFractionDigits:0];

        self.initialBackoffTimeInSecond = 0.8;
        self.retryCount = 3;
    }

    return self;
}

- (BOOL)loadMetadata:(NSError **)error
{
    AMZLogDebug(@"- (BOOL)loadMetadata:(NSError **)error called.");

    AmazonCredentials *credentials = [delegate credentials];
    if([credentials.accessKey length] > 0
       && [credentials.secretKey length] > 0
       && [credentials.securityToken length] > 0)
    {
        [self setMetadata:[NSDictionary dictionaryWithObjectsAndKeys:
                           AWSPersistenceDynamoDBIncrementalStoreType, NSStoreTypeKey,
                           [[NSProcessInfo processInfo] globallyUniqueString], NSStoreUUIDKey, nil]];
        return YES;
    }
    else
    {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"The protocol - (AmazonCredentials *)credentials didn't return a valid AmazonCredentials object.", @"message", nil];
        *error = [NSError errorWithDomain:AWSPersistenceDynamoDBClientErrorDomain code:-1 userInfo:userInfo];

        return NO;
    }
}

- (id)executeRequest:(NSPersistentStoreRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    AMZLogDebug(@"- (id)executeRequest:(NSPersistentStoreRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError **)error called.");

    if (request.requestType == NSFetchRequestType)
    {
        NSFetchRequest *fetchRequest = (NSFetchRequest *) request;
        NSString *entityHashKeyName = [self hashKeyForEntityName:fetchRequest.entity.name];
        NSString *entityRangeKeyName = [self rangeKeyForEntityName:fetchRequest.entity.name];
        
        if (fetchRequest.resultType == NSManagedObjectResultType)
        {
            NSMutableArray *resultArray = [NSMutableArray array];

            // Scan request
            if(fetchRequest.predicate == nil)
            {
                NSMutableArray *scanResult = [self scan:fetchRequest withContext:context error:error];
                if(scanResult != nil)
                {
                    [resultArray addObjectsFromArray:scanResult];
                }
                else
                {
                    return nil;
                }
            }
            // HashKey fetch
            else if([fetchRequest.predicate isKindOfClass:[NSComparisonPredicate class]])
            {
                NSComparisonPredicate *predicate = (NSComparisonPredicate *)fetchRequest.predicate;

                if([[[predicate leftExpression] keyPath] isEqualToString:entityHashKeyName])
                {
                    NSMutableArray *getItemResult = [self getItem:fetchRequest
                                                      withContext:context
                                                      withHashKey:[[predicate rightExpression] expressionValueWithObject:nil context:nil]
                                                            error:error];
                    if(getItemResult != nil)
                    {
                        [resultArray addObjectsFromArray:getItemResult];
                    }
                    else
                    {
                        return nil;
                    }
                }
            }
            // HashKey+RangeKey fetch or query
            else if([fetchRequest.predicate isKindOfClass:[NSCompoundPredicate class]])
            {
                NSCompoundPredicate *predicate = (NSCompoundPredicate *)fetchRequest.predicate;
                if([predicate compoundPredicateType] == NSAndPredicateType
                   && [[predicate subpredicates] count] == 2)
                {
                    NSComparisonPredicate *leftPredicate = [[predicate subpredicates] objectAtIndex:0];
                    NSComparisonPredicate *rightPredicate = [[predicate subpredicates] objectAtIndex:1];

                    if([[[leftPredicate leftExpression] keyPath] isEqualToString:entityHashKeyName]
                       && [[[rightPredicate leftExpression] keyPath] isEqualToString:entityRangeKeyName])
                    {
                        // simple equality
                        if(leftPredicate.predicateOperatorType == NSEqualToPredicateOperatorType
                           && rightPredicate.predicateOperatorType == NSEqualToPredicateOperatorType)
                        {
                                
                            id hashKeyValue = [[leftPredicate rightExpression] expressionValueWithObject:nil context:nil];
                            id rangeKeyValue = [[rightPredicate rightExpression] expressionValueWithObject:nil context:nil];
                            
                            NSMutableArray *getItemResult = [self getItem:fetchRequest
                                                              withContext:context
                                                              withHashKey:hashKeyValue
                                                             withRangeKey:rangeKeyValue
                                                                    error:error];
                            if(getItemResult != nil)
                            {
                                [resultArray addObjectsFromArray:getItemResult];
                            }
                            else
                            {
                                return nil;
                            }
                           
                        }
                        // equality + range query
                        else if(leftPredicate.predicateOperatorType == NSEqualToPredicateOperatorType
                                && rightPredicate.predicateOperatorType == NSBetweenPredicateOperatorType)
                        {
                            id hashKeyValue = [[leftPredicate rightExpression] expressionValueWithObject:nil context:nil];
                            NSArray *rangeKeyLimits = [[rightPredicate rightExpression] expressionValueWithObject:nil context:nil];
                            id rangeKeyMin = [rangeKeyLimits objectAtIndex:0];
                            id rangeKeyMax = [rangeKeyLimits objectAtIndex:1];
                            uint limit = fetchRequest.fetchLimit;
                            BOOL sortAscending = YES;
                            
                            if(fetchRequest.sortDescriptors != nil && fetchRequest.sortDescriptors.count > 0)
                            {
                                NSSortDescriptor *sortDescriptor = [fetchRequest.sortDescriptors objectAtIndex:0];
                                if([sortDescriptor.key isEqualToString:entityRangeKeyName])
                                {
                                    sortAscending = sortDescriptor.ascending;
                                }
                            }
                            
                            NSMutableArray *queryResult = [self query:fetchRequest
                                                           withContext:context
                                                          withHashKey:hashKeyValue
                                                      withRangeKeyMin:rangeKeyMin
                                                       andRangeKeyMax:rangeKeyMax
                                                        sortAscending:sortAscending
                                                                limit:limit
                                                                error:error];
                            if(queryResult != nil)
                            {
                                [resultArray addObjectsFromArray:queryResult];
                            }
                            else
                            {
                                return nil;
                            }
                        }
                    }
                }
            }


            return resultArray;
        }
        else
        {
            return nil;
        }
    }
    else if (request.requestType == NSSaveRequestType)
    {
        NSSaveChangesRequest *saveChangesRequest = (NSSaveChangesRequest*) request;

        if([saveChangesRequest insertedObjects] != nil)
        {
            AMZLogDebug(@"Inserting Objects...");

            [self insertObjects:[saveChangesRequest insertedObjects]
                          error:error];
            if(*error != nil)
            {
                return nil;
            }

            AMZLogDebug(@"Objects inserted.");
        }

        if([saveChangesRequest updatedObjects] != nil)
        {
            AMZLogDebug(@"Updating Objects...");

            [self updateObject:[saveChangesRequest updatedObjects]
            withDeletedObjects:[saveChangesRequest deletedObjects]
                         error:error];
            if(*error != nil)
            {
                return nil;
            }

            AMZLogDebug(@"Objects updated.");
        }

        if([saveChangesRequest deletedObjects] != nil)
        {
            AMZLogDebug(@"Deleting objects...");

            [self deleteObject:[saveChangesRequest deletedObjects]
                         error:error];
            if(*error != nil)
            {
                return nil;
            }

            AMZLogDebug(@"Objects deleted.");
        }

        if([saveChangesRequest lockedObjects] != nil)
        {
            // Ignores lock requests
        }

        return [NSArray array];
    }
    else
    {
        return nil;
    }
}

- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    AMZLogDebug(@"- (NSIncrementalStoreNode *)newValuesForObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError **)error called.");

    @try
    {
        DynamoDBKey *key;
        
        id hashUnknown = [objectIdToHashKey valueForKey:objectID.URIRepresentation.description];
        if([hashUnknown isKindOfClass:[NSDictionary class]])
        {
            // hash + range key
            NSDictionary *compositeHash = hashUnknown;
            
            DynamoDBAttributeValue *attributeValueHashKey = [self attributeValueFromObject:[compositeHash objectForKey:@"hashKey"]];
            DynamoDBAttributeValue *attributeValueRangeKey = [self attributeValueFromObject:[compositeHash objectForKey:@"rangeKey"]];
            key = [[DynamoDBKey alloc] initWithHashKeyElement:attributeValueHashKey andRangeKeyElement:attributeValueRangeKey];
        }
        else
        {
            // just hash key
            DynamoDBAttributeValue *attributeValue = [self attributeValueFromObject:hashUnknown];
            key = [[DynamoDBKey alloc] initWithHashKeyElement:attributeValue];
        }
        
        DynamoDBGetItemRequest *getItemRequest = [[DynamoDBGetItemRequest alloc] initWithTableName:[self tableNameForEntityName:objectID.entity.name]
                                                                                            andKey:key];
        getItemRequest.consistentRead = YES;

        AmazonDynamoDBClient *dynamoDBClient = [self dynamoDBClient];
        DynamoDBGetItemResponse *getItemResponse = [dynamoDBClient getItem:getItemRequest];

        if(getItemResponse.error == nil)
        {
            if([getItemResponse.item count] > 0)
            {
                NSDictionary *attributeClasses = [self attributeClassesForClassName:objectID.entity.name];

                NSMutableDictionary *values = [NSMutableDictionary dictionaryWithCapacity:10];
                for(NSString *key in getItemResponse.item)
                {
                    DynamoDBAttributeValue *attributeValue = (DynamoDBAttributeValue *)[getItemResponse.item valueForKey:key];
                    if([attributeClasses objectForKey:key] == [NSString class]
                       && attributeValue.s != nil)
                    {
                        [values setValue:attributeValue.s forKey:key];
                    }
                    else if([attributeClasses objectForKey:key] == [NSDate class]
                            && attributeValue.n != nil)
                    {
                        [values setValue:[NSDate dateWithTimeIntervalSince1970:[[nf numberFromString:attributeValue.n] doubleValue]] forKey:key];
                    }
                    else if(([attributeClasses objectForKey:key] == [NSDecimalNumber class]
                             && attributeValue.n != nil)
                            || ([attributeClasses objectForKey:key] == [NSNumber class]
                                && attributeValue.n != nil))
                    {
                        [values setValue:[nf numberFromString:attributeValue.n] forKey:key];
                    }
                    else if([attributeClasses objectForKey:key] != [NSSet class]
                            && [attributeClasses objectForKey:key] != [NSArray class]
                            && [attributeValue.nS count] == 1)
                    {
                        Class class = [attributeClasses objectForKey:key];
                        const char* classNameTmp = class_getName(class);
                        NSString *className = [[NSString alloc] initWithUTF8String:classNameTmp];

                        NSDictionary *destinationAttributeClasses = [self attributeClassesForClassName:className];

                        NSObject *hashKeyObject = [self convertString:[attributeValue.nS objectAtIndex:0] toClass:[destinationAttributeClasses objectForKey:[self hashKeyForEntityName:className]]];
                        NSManagedObjectID *innerObjectId = [self newObjectIDForEntity:[NSEntityDescription entityForName:className
                                                                                                  inManagedObjectContext:context]
                                                                      referenceObject:hashKeyObject];
                        [values setValue:innerObjectId forKey:key];
                    }
                    else if([attributeClasses objectForKey:key] != [NSSet class]
                            && [attributeClasses objectForKey:key] != [NSArray class]
                            && [attributeValue.sS count] == 1)
                    {
                        Class class = [attributeClasses objectForKey:key];
                        const char* classNameTmp = class_getName(class);
                        NSString *className = [[NSString alloc] initWithUTF8String:classNameTmp];

                        NSDictionary *destinationAttributeClasses = [self attributeClassesForClassName:className];

                        NSObject *hashKeyObject = [self convertString:[attributeValue.sS objectAtIndex:0] toClass:[destinationAttributeClasses objectForKey:[self hashKeyForEntityName:className]]];
                        NSManagedObjectID *innerObjectId = [self newObjectIDForEntity:[NSEntityDescription entityForName:className
                                                                                                  inManagedObjectContext:context]
                                                                      referenceObject:hashKeyObject];
                        [values setValue:innerObjectId forKey:key];
                    }
                }

                NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
                [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber * version = [numberFormatter numberFromString:((DynamoDBAttributeValue *)[getItemResponse.item valueForKey:[self versionKeyForEntityName:objectID.entity.name]]).n];

                return [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                                             withValues:values
                                                                version:[version unsignedLongLongValue]];
            }
            else
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:AWSPersistenceDynamoDBObjectDeletedNotification
                                                                    object:self
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                            [self hashKeyForEntityName:objectID.entity.name], AWSPersistenceDynamoDBObjectDeletedNotificationHashKey,
                                                                            [self tableNameForEntityName:objectID.entity.name], AWSPersistenceDynamoDBObjectDeletedNotificationEntityName,
                                                                            objectID, AWSPersistenceDynamoDBObjectDeletedNotificationObjectID,
                                                                            nil]];

                return [[NSIncrementalStoreNode alloc] initWithObjectID:objectID
                                                             withValues:nil
                                                                version:0];
            }
        }
        else
        {
            *error = getItemResponse.error;
        }
    }
    @catch (NSException *exception)
    {
        *error = [self errorFromException:exception];
        return nil;
    }
}

- (id)newValueForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    AMZLogDebug(@"- (id)newValueForRelationship:(NSRelationshipDescription *)relationship forObjectWithID:(NSManagedObjectID *)objectID withContext:(NSManagedObjectContext *)context error:(NSError **)error called.");
    @try
    {
        DynamoDBAttributeValue *attributeValue = [self attributeValueFromObject:[objectIdToHashKey valueForKey:objectID.URIRepresentation.description]];
        DynamoDBKey *key = [[DynamoDBKey alloc] initWithHashKeyElement:attributeValue];
        DynamoDBGetItemRequest *getItemRequest = [[DynamoDBGetItemRequest alloc] initWithTableName:[self tableNameForEntityName:objectID.entity.name]
                                                                                            andKey:key];
        getItemRequest.consistentRead = YES;

        AmazonDynamoDBClient *dynamoDBClient = [self dynamoDBClient];
        DynamoDBGetItemResponse *getItemResponse = [dynamoDBClient getItem:getItemRequest];

        if(getItemResponse.error == nil)
        {
            if([relationship isToMany])
            {
                NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:10];
                for(NSString *key in getItemResponse.item)
                {
                    DynamoDBAttributeValue *attributeValue = (DynamoDBAttributeValue *)[getItemResponse.item valueForKey:key];
                    NSMutableArray *arrayAttribute = nil;
                    if(attributeValue.sS != nil
                       && [attributeValue.sS count] > 0)
                    {
                        arrayAttribute = attributeValue.sS;
                    }
                    else if(attributeValue.nS != nil
                            && [attributeValue.nS count] > 0)
                    {
                        arrayAttribute = attributeValue.nS;
                    }

                    for(NSString *hashKey in arrayAttribute)
                    {
                        NSDictionary *attributeClasses = [self attributeClassesForClassName:relationship.destinationEntity.name];
                        Class class = [attributeClasses objectForKey:[self hashKeyForEntityName:relationship.destinationEntity.name]];
                        NSObject *hashKeyObject = [self convertString:hashKey toClass:class];

                        NSManagedObjectID *innerObjectId = [self newObjectIDForEntity:[NSEntityDescription entityForName:relationship.destinationEntity.name
                                                                                                  inManagedObjectContext:context]
                                                                      referenceObject:hashKeyObject];

                        [values addObject:innerObjectId];
                        [objectIdToHashKey setValue:hashKeyObject forKey:innerObjectId.URIRepresentation.description];
                    }
                }

                return values;
            }
            else
            {
                NSObject *innerObjectId = [NSNull null];
                for(NSString *key in getItemResponse.item)
                {
                    DynamoDBAttributeValue *attributeValue = (DynamoDBAttributeValue *)[getItemResponse.item valueForKey:key];
                    NSMutableArray *arrayAttribute = nil;
                    if(attributeValue.sS != nil
                       && [attributeValue.sS count] > 0)
                    {
                        arrayAttribute = attributeValue.sS;
                    }
                    else if(attributeValue.nS != nil
                            && [attributeValue.nS count] > 0)
                    {
                        arrayAttribute = attributeValue.nS;
                    }

                    for(NSString *hashKey in arrayAttribute)
                    {
                        NSDictionary *attributeClasses = [self attributeClassesForClassName:relationship.destinationEntity.name];
                        Class class = [attributeClasses objectForKey:[self hashKeyForEntityName:relationship.destinationEntity.name]];
                        NSObject *hashKeyObject = [self convertString:hashKey toClass:class];

                        innerObjectId = [self newObjectIDForEntity:[NSEntityDescription entityForName:relationship.destinationEntity.name
                                                                               inManagedObjectContext:context]
                                                   referenceObject:hashKeyObject];

                        [objectIdToHashKey setValue:hashKeyObject forKey:((NSManagedObjectID *)innerObjectId).URIRepresentation.description];
                    }
                }

                return innerObjectId;
            }
        }
        else
        {
            *error = getItemResponse.error;
        }
    }
    @catch (NSException *exception)
    {
        *error = [self errorFromException:exception];
        return nil;
    }
}

- (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array error:(NSError **)error
{
    AMZLogDebug(@"- (NSArray *)obtainPermanentIDsForObjects:(NSArray *)array error:(NSError **)error called.");

    // todo: if needed, modify to support range key.
    
    NSMutableArray *resultArray = [NSMutableArray arrayWithCapacity:[array count]];
    for(NSManagedObject *managedObject in array)
    {
        id hashKeyObject = [managedObject valueForKey:[self hashKeyForEntityName:managedObject.entity.name]];
        NSManagedObjectID *objectId = [self newObjectIDForEntity:managedObject.entity
                                                 referenceObject:hashKeyObject];

        [objectIdToHashKey setValue:hashKeyObject forKey:objectId.URIRepresentation.description];
        [resultArray addObject:objectId];
    }

    return [NSArray arrayWithArray:resultArray];
}

#pragma mark - DynamoDBClient Management Methods

- (AmazonDynamoDBClient *)dynamoDBClient
{
    AmazonDynamoDBClient *dynamoDBClient = [[AmazonDynamoDBClient alloc] initWithCredentials:[delegate credentials]];

    if(![dynamoDBClient.userAgent hasPrefix:AWSPersistenceDynamoDBUserAgentPrefix])
    {
        dynamoDBClient.userAgent = AWSPersistenceDynamoDBUserAgentPrefix;
    }

    return dynamoDBClient;
}

#pragma mark - DynamoDB Methods

- (NSMutableArray *)scan:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError **)error
{
    AMZLogDebug(@"- (NSMutableArray *)scan:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context error:(NSError **)error called.");
    @try
    {
        NSMutableArray *resultArray = [NSMutableArray array];

        DynamoDBScanRequest  *scanRequest  = [[DynamoDBScanRequest alloc] initWithTableName:[self tableNameForEntityName:request.entityName]];
        scanRequest.attributesToGet = [NSMutableArray arrayWithObject:[self hashKeyForEntityName:request.entity.name]];

        DynamoDBKey *lastEvaluatedKey = nil;
        DynamoDBScanResponse *response = nil;

        NSDictionary *attributeClasses = [self attributeClassesForClassName:request.entityName];

        do {
            scanRequest.exclusiveStartKey = lastEvaluatedKey;

            AmazonDynamoDBClient *dynamoDBClient = [self dynamoDBClient];
            response = [dynamoDBClient scan:scanRequest];

            if(response.error == nil)
            {
                for(NSDictionary *dic in response.items)
                {
                    NSString *hashKeyRetrieved;
                    NSString *rangeKeyRetrieved;
                    
                    DynamoDBAttributeValue *attributeValueHashKey = (DynamoDBAttributeValue *)[dic objectForKey:[self hashKeyForEntityName:request.entity.name]];
                    if(attributeValueHashKey.s != nil)
                    {
                        hashKeyRetrieved = attributeValueHashKey.s;
                    }
                    else if(attributeValueHashKey.n != nil)
                    {
                        hashKeyRetrieved = attributeValueHashKey.n;
                    }
                    
                    DynamoDBAttributeValue *attributeValueRangeKey = nil;
                    attributeValueRangeKey = (DynamoDBAttributeValue *)[dic objectForKey:[self rangeKeyForEntityName:request.entity.name]];
                    if(attributeValueRangeKey != nil)
                    {
                        if(attributeValueRangeKey.s != nil)
                        {
                            rangeKeyRetrieved = attributeValueRangeKey.s;
                        }
                        else if(attributeValueRangeKey.n != nil)
                        {
                            rangeKeyRetrieved = attributeValueRangeKey.n;
                        }
                    }
                    
                    
                    id hashKeyObject = [self convertString:hashKeyRetrieved toClass:[attributeClasses objectForKey:[self hashKeyForEntityName:request.entity.name]]];
                    id rangeKeyObject = nil;
                    if(rangeKeyRetrieved != nil)
                    {
                        rangeKeyObject = [self convertString:rangeKeyRetrieved toClass:[attributeClasses objectForKey:[self rangeKeyForEntityName:request.entity.name]]];
                    }
                    
                    id key;
                    if(rangeKeyObject == nil)
                    {
                        key = hashKeyObject;
                    }
                    else
                    {
                        key = [NSDictionary dictionaryWithObjectsAndKeys:hashKeyObject, @"hashKey", rangeKeyObject, @"rangeKey", nil];
                    }
                    
                    NSManagedObjectID *objectId = [self newObjectIDForEntity:request.entity referenceObject:[self referenceObjectIdForCoreData:key]];
                    NSManagedObject *managedObject = [context objectWithID:objectId];
                    [objectIdToHashKey setValue:key forKey:objectId.URIRepresentation.description];
                    [resultArray addObject:managedObject];
                }

                lastEvaluatedKey = response.lastEvaluatedKey;
            }
            else
            {
                *error = response.error;
                return nil;
            }
        } while (lastEvaluatedKey != nil);

        return resultArray;
    }
    @catch (NSException *exception)
    {
        *error = [self errorFromException:exception];
        return nil;
    }
}

- (NSMutableArray *)query:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context withHashKey:(id)hashKey withRangeKeyMin:(id)rangeKeyMin andRangeKeyMax:(id)rangeKeyMax sortAscending:(BOOL)ascending limit:(int)limit error:(NSError **)error
{
    AMZLogDebug(@"- (NSMutableArray *)query:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context withHashKey:(id)hashKey withRangeKeyMin:(id)rangeKeyMin andRangeKeyMax:(id)rangeKeyMax sortAscending:(BOOL)ascending error:(NSError **)error called.");
    @try
    {
        NSMutableArray *resultArray = [NSMutableArray array];
        NSMutableArray *attributesToGet = [NSMutableArray array];
 
        [attributesToGet addObject:[self hashKeyForEntityName:request.entity.name]];
        [attributesToGet addObject:[self rangeKeyForEntityName:request.entity.name]];
        
        DynamoDBAttributeValue *attributeValueHashKeyValue = [self attributeValueFromObject:hashKey];        
        DynamoDBAttributeValue *attributeValueRangeMinValue = [self attributeValueFromObject:rangeKeyMin];
        DynamoDBAttributeValue *attributeValueRangeMaxValue = [self attributeValueFromObject:rangeKeyMax];
        
        DynamoDBQueryRequest *queryRequest  = [[DynamoDBQueryRequest alloc] initWithTableName:[self tableNameForEntityName:request.entityName] andHashKeyValue:attributeValueHashKeyValue];
        queryRequest.attributesToGet = attributesToGet;
        queryRequest.rangeKeyCondition = [[DynamoDBCondition alloc] init];
        queryRequest.rangeKeyCondition.attributeValueList =
            [[NSMutableArray alloc] initWithObjects:attributeValueRangeMinValue, attributeValueRangeMaxValue, nil];
        queryRequest.rangeKeyCondition.comparisonOperator = @"BETWEEN";
        queryRequest.scanIndexForward = ascending;
        queryRequest.limit = [NSNumber numberWithInt:limit];
        
        DynamoDBKey *lastEvaluatedKey = nil;
        DynamoDBQueryResponse *response = nil;
        
        NSDictionary *attributeClasses = [self attributeClassesForClassName:request.entityName];
        
        
        int itemCount = 0;
        do {
            queryRequest.exclusiveStartKey = lastEvaluatedKey;
            
            AmazonDynamoDBClient *dynamoDBClient = [self dynamoDBClient];
            response = [dynamoDBClient query:queryRequest];
            
            if(response.error == nil)
            {
                for(NSDictionary *dic in response.items)
                {
                    NSString *hashKeyRetrieved;
                    NSString *rangeKeyRetrieved;
                    
                    DynamoDBAttributeValue *attributeValueHashKey = (DynamoDBAttributeValue *)[dic objectForKey:[self hashKeyForEntityName:request.entity.name]];
                    if(attributeValueHashKey.s != nil)
                    {
                        hashKeyRetrieved = attributeValueHashKey.s;
                    }
                    else if(attributeValueHashKey.n != nil)
                    {
                        hashKeyRetrieved = attributeValueHashKey.n;
                    }

                    DynamoDBAttributeValue *attributeValueRangeKey = nil;
                    attributeValueRangeKey = (DynamoDBAttributeValue *)[dic objectForKey:[self rangeKeyForEntityName:request.entity.name]];
                    
                    if(attributeValueRangeKey.s != nil)
                    {
                        rangeKeyRetrieved = attributeValueRangeKey.s;
                    }
                    else if(attributeValueRangeKey.n != nil)
                    {
                        rangeKeyRetrieved = attributeValueRangeKey.n;
                    }
                    
                    id hashKeyObject = [self convertString:hashKeyRetrieved toClass:[attributeClasses objectForKey:[self hashKeyForEntityName:request.entity.name]]];
                    id rangeKeyObject = [self convertString:rangeKeyRetrieved toClass:[attributeClasses objectForKey:[self rangeKeyForEntityName:request.entity.name]]];
                    
                    id key;
                    if(rangeKeyObject == nil)
                    {
                        key = hashKeyObject;
                    }
                    else
                    {
                        key = [NSDictionary dictionaryWithObjectsAndKeys:hashKeyObject, @"hashKey", rangeKeyObject, @"rangeKey", nil];
                    }
                    
                    NSManagedObjectID *objectId = [self newObjectIDForEntity:request.entity referenceObject:[self referenceObjectIdForCoreData:key]];
                    NSManagedObject *managedObject = [context objectWithID:objectId];
                    [objectIdToHashKey setValue:key forKey:objectId.URIRepresentation.description];
                    
                    [resultArray addObject:managedObject];
                    ++itemCount;
                    if(itemCount >= limit)
                    {
                        lastEvaluatedKey = nil;
                        break;
                    }
                }
                
                lastEvaluatedKey = response.lastEvaluatedKey;
            }
            else
            {
                *error = response.error;
                return nil;
            }
        } while (lastEvaluatedKey != nil);
        
        return resultArray;
    }
    @catch (NSException *exception)
    {
        *error = [self errorFromException:exception];
        return nil;
    }
}

- (NSMutableArray *)getItem:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context withHashKey:(id)hashKey error:(NSError **)error
{
    return [self getItem:request withContext:context withHashKey:hashKey withRangeKey:nil error:error];
}

- (NSMutableArray *)getItem:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context withHashKey:(id)hashKey withRangeKey:(id)rangeKey error:(NSError **)error
{
    AMZLogDebug(@"- (NSMutableArray *)getItem:(NSFetchRequest *)request withContext:(NSManagedObjectContext *)context withHashKey:(NSString *)hashKey error:(NSError **)error called.");
    @try
    {
        NSMutableArray *resultArray = [NSMutableArray array];

        
        DynamoDBKey *key;
        NSMutableArray *attributesToGet = [NSMutableArray array];
        if(rangeKey == nil)
        {
            DynamoDBAttributeValue *attributeValueHashKeyValue = [self attributeValueFromObject:hashKey];
            key = [[DynamoDBKey alloc] initWithHashKeyElement:attributeValueHashKeyValue];
            
            [attributesToGet addObject:[self hashKeyForEntityName:request.entity.name]];
        }
        else
        {
            DynamoDBAttributeValue *attributeValueHashKeyValue = [self attributeValueFromObject:hashKey];
            DynamoDBAttributeValue *attributeValueRangeKeyValue = [self attributeValueFromObject:rangeKey];
            key = [[DynamoDBKey alloc] initWithHashKeyElement:attributeValueHashKeyValue andRangeKeyElement:attributeValueRangeKeyValue];
            
            [attributesToGet addObject:[self hashKeyForEntityName:request.entity.name]];
            [attributesToGet addObject:[self rangeKeyForEntityName:request.entity.name]];
        }
        
        DynamoDBGetItemRequest *getItemRequest = [[DynamoDBGetItemRequest alloc] initWithTableName:[self tableNameForEntityName:request.entity.name]
                                                                                            andKey:key];
        getItemRequest.consistentRead = YES;
        getItemRequest.attributesToGet = attributesToGet;

        AmazonDynamoDBClient *dynamoDBClient = [self dynamoDBClient];
        DynamoDBGetItemResponse *getItemResponse = [dynamoDBClient getItem:getItemRequest];

        if(getItemResponse.error == nil)
        {
            if([getItemResponse.item count] > 0)
            {
                NSDictionary *attributeClasses = [self attributeClassesForClassName:request.entityName];
                
                NSString *hashKeyRetrieved;
                NSString *rangeKeyRetrieved;
                
                DynamoDBAttributeValue *attributeValueHashKey = (DynamoDBAttributeValue *)[getItemResponse.item objectForKey:[self hashKeyForEntityName:request.entity.name]];
                
                if(attributeValueHashKey.s != nil)
                {
                    hashKeyRetrieved = attributeValueHashKey.s;
                }
                else if(attributeValueHashKey.n != nil)
                {
                    hashKeyRetrieved = attributeValueHashKey.n;
                }

                
                DynamoDBAttributeValue *attributeValueRangeKey = nil;
                attributeValueRangeKey = (DynamoDBAttributeValue *)[getItemResponse.item objectForKey:[self rangeKeyForEntityName:request.entity.name]];
                if(attributeValueRangeKey != nil)
                {
                    if(attributeValueRangeKey.s != nil)
                    {
                        rangeKeyRetrieved = attributeValueRangeKey.s;
                    }
                    else if(attributeValueRangeKey.n != nil)
                    {
                        rangeKeyRetrieved = attributeValueRangeKey.n;
                    }
                }

                id hashKeyObject = [self convertString:hashKeyRetrieved toClass:[attributeClasses objectForKey:[self hashKeyForEntityName:request.entity.name]]];
                id rangeKeyObject = nil;
                if(rangeKeyRetrieved != nil)
                {
                    rangeKeyObject = [self convertString:rangeKeyRetrieved toClass:[attributeClasses objectForKey:[self rangeKeyForEntityName:request.entity.name]]];
                }
                
                id key;
                if(rangeKeyObject == nil)
                {
                    key = hashKeyObject;
                }
                else
                {
                    key = [NSDictionary dictionaryWithObjectsAndKeys:hashKeyObject, @"hashKey", rangeKeyObject, @"rangeKey", nil];
                }
                
                NSManagedObjectID *objectId = [self newObjectIDForEntity:request.entity referenceObject:[self referenceObjectIdForCoreData:key]];
                NSManagedObject *managedObject = [context objectWithID:objectId];
                [objectIdToHashKey setValue:key forKey:objectId.URIRepresentation.description];
                [resultArray addObject:managedObject];
            }

            return resultArray;
        }
        else
        {
            *error = getItemResponse.error;
            return nil;
        }
    }
    @catch (NSException *exception)
    {
        *error = [self errorFromException:exception];
        return nil;
    }
}

- (BOOL)insertObjects:(NSSet *)insertedObjects error:(NSError **)error
{
    AMZLogDebug(@"- (BOOL)insertObjects:(NSManagedObject *)managedObject error:(NSError **)error called.");
    @try
    {
        DynamoDBBatchWriteItemRequest *batchWriteRequest = [DynamoDBBatchWriteItemRequest new];

        int counter = 1;

        for(NSManagedObject *managedObject in insertedObjects)
        {
            NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithCapacity:[managedObject.entity.properties count]];

            for(NSObject *o in managedObject.entity.properties)
            {
                if([o isKindOfClass:[NSAttributeDescription class]])
                {
                    NSAttributeDescription *ad = (NSAttributeDescription *)o;

                    [userDic setValue:[self attributeValueFromObject:[managedObject valueForKey:ad.name]] forKey:ad.name];
                }
                else if([o isKindOfClass:[NSRelationshipDescription class]])
                {
                    NSRelationshipDescription *rd = (NSRelationshipDescription *)o;
                    NSMutableArray *values = [NSMutableArray arrayWithCapacity:rd.maxCount];

                    if([[managedObject valueForKey:rd.name] isKindOfClass:[NSManagedObject class]])
                    {
                        NSManagedObject *innerObject = [managedObject valueForKey:rd.name];
                        [values addObject:[innerObject valueForKey:[self hashKeyForEntityName:innerObject.entity.name]]];
                    }
                    else if([[managedObject valueForKey:rd.name] isKindOfClass:[NSSet class]]
                            || [[managedObject valueForKey:rd.name] isKindOfClass:[NSArray class]])
                    {
                        for (NSManagedObject *innerObject in [managedObject valueForKey:rd.name])
                        {
                            [values addObject:[innerObject valueForKey:[self hashKeyForEntityName:innerObject.entity.name]]];
                        }
                    }

                    if([values count] > 0)
                    {
                        [userDic setValue:[self attributeValueFromObject:values] forKey:rd.name];
                    }
                }
            }

            [userDic setValue:[[DynamoDBAttributeValue alloc] initWithN:@"1"] forKey:[self versionKeyForEntityName:managedObject.entity.name]];

            DynamoDBPutRequest *putRequest = [DynamoDBPutRequest new];
            putRequest.item = userDic;

            DynamoDBWriteRequest *writeRequest = [DynamoDBWriteRequest new];
            writeRequest.putRequest = putRequest;

            NSMutableArray *writes = [batchWriteRequest.requestItems objectForKey:[self tableNameForEntityName:managedObject.entity.name]];
            if(writes == nil)
            {
                writes = [NSMutableArray arrayWithCapacity:25];
                [batchWriteRequest setRequestItemsValue:writes
                                                 forKey:[self tableNameForEntityName:managedObject.entity.name]];
            }

            [writes addObject:writeRequest];

            if(counter % 25 == 0 || [insertedObjects count] == counter)
            {
                DynamoDBBatchWriteItemResponse * batchWriteResponse = nil;

                AmazonDynamoDBClient *dynamoDBClient = [self dynamoDBClient];

                for(int i = 0; i < self.retryCount + 1; i++)
                {
                    batchWriteResponse = [dynamoDBClient batchWriteItem:batchWriteRequest];

                    if(batchWriteResponse.error == nil)
                    {
                        if(batchWriteResponse.unprocessedItems == nil
                           || [batchWriteResponse.unprocessedItems count] == 0
                           || i == self.retryCount)
                        {
                            break;
                        }
                        else
                        {
                            [NSThread sleepForTimeInterval:pow(2, i) * self.initialBackoffTimeInSecond];
                            batchWriteRequest = [DynamoDBBatchWriteItemRequest new];

                            for(NSString *key in batchWriteResponse.unprocessedItems)
                            {
                                [batchWriteRequest setRequestItemsValue:[batchWriteResponse.unprocessedItems objectForKey:key]
                                                                 forKey:key];
                            }
                        }
                    }
                    else
                    {
                        *error = batchWriteResponse.error;
                        return NO;
                    }
                }

                if(batchWriteResponse.unprocessedItems != nil
                   && [batchWriteResponse.unprocessedItems count] > 0)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"BatchWrite failed. Some items were not processed.", @"message", nil];
                    *error = [NSError errorWithDomain:AWSPersistenceDynamoDBClientErrorDomain code:-1 userInfo:userInfo];
                    return NO;
                }

                if([insertedObjects count] != counter)
                {
                    batchWriteRequest = [DynamoDBBatchWriteItemRequest new];
                }
            }

            counter++;
        }

        return YES;
    }
    @catch (NSException *exception)
    {
        *error = [self errorFromException:exception];
        return NO;
    }
}

- (BOOL)updateObject:(NSSet *)updatedObjects withDeletedObjects:(NSSet *)deletedObjects error:(NSError **)error
{
    AMZLogDebug(@"- (BOOL)updateObject:(NSSet *)updatedObjects withDeletedObjects:(NSSet *)deletedObjects error:(NSError **)error called.");
    @try
    {
        for(NSManagedObject *managedObject in updatedObjects)
        {
            NSArray *properties = managedObject.entity.properties;
            NSMutableDictionary *userDic = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
            NSMutableDictionary *userDicForDelete = [NSMutableDictionary dictionaryWithCapacity:[properties count]];
            NSMutableArray *deletedValues = [NSMutableArray arrayWithCapacity:10];

            DynamoDBAttributeValue *attributeValue = nil;
            DynamoDBAttributeValueUpdate *attributeValueUpdate = nil;

            for(NSString *key in [managedObject changedValues])
            {
                // If not a hash key
                if(![[self hashKeyForEntityName:managedObject.entity.name] isEqualToString:key])
                {
                    if([[managedObject.entity relationshipsByName] objectForKey:key] == nil)
                    {
                        if([managedObject valueForKey:key] != nil
                           && ![[[managedObject valueForKey:key] description] isEqualToString:@""])
                        {
                            attributeValue = [self attributeValueFromObject:[[managedObject changedValues] valueForKey:key]];
                            attributeValueUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:attributeValue andAction:@"PUT"];
                            [userDic setValue:attributeValueUpdate forKey:key];
                        }
                        else
                        {
                            attributeValueUpdate = [DynamoDBAttributeValueUpdate new];
                            attributeValueUpdate.action = @"DELETE";
                            [userDic setValue:attributeValueUpdate forKey:key];
                        }
                    }
                }
                else
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%@[%@] has been modified. Hash keys cannot be updated.", key, [[managedObject changedValues] valueForKey:key]], @"message", nil];
                    *error = [NSError errorWithDomain:AWSPersistenceDynamoDBClientErrorDomain code:-1 userInfo:userInfo];
                    return NO;
                }
            }

            for(NSString *key in [managedObject.entity relationshipsByName])
            {
                NSRelationshipDescription *rd = [[managedObject.entity relationshipsByName] valueForKey:key];

                if([[managedObject valueForKey:key] isKindOfClass:[NSManagedObject class]])
                {
                    NSMutableArray *values = [NSMutableArray arrayWithCapacity:rd.maxCount];
                    NSManagedObject *innerObject = [managedObject valueForKey:key];
                    [values addObject:[innerObject valueForKey:[self hashKeyForEntityName:innerObject.entity.name]]];

                    if([values count] > 0)
                    {
                        attributeValue = [self attributeValueFromObject:values];
                        attributeValueUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:attributeValue andAction:@"ADD"];
                        [userDic setValue:attributeValueUpdate forKey:key];
                    }
                }
                else if([[managedObject valueForKey:key] isKindOfClass:[NSSet class]]
                        || [[managedObject valueForKey:key] isKindOfClass:[NSArray class]])
                {
                    NSMutableArray *values = [NSMutableArray array];
                    for (NSManagedObject *innerObject in [managedObject valueForKey:key])
                    {
                        [values addObject:[innerObject valueForKey:[self hashKeyForEntityName:innerObject.entity.name]]];
                    }

                    if([values count] > 0)
                    {
                        attributeValue = [self attributeValueFromObject:values];
                        attributeValueUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:attributeValue andAction:@"ADD"];
                        [userDic setValue:attributeValueUpdate forKey:key];
                    }

                    for (NSManagedObject *deletedObject in deletedObjects)
                    {
                        if([deletedObject.entity.name isEqualToString:rd.destinationEntity.name])
                        {
                            [deletedValues addObject:[deletedObject valueForKey:[self hashKeyForEntityName:deletedObject.entity.name]]];
                        }
                    }

                    if([deletedValues count] > 0)
                    {
                        attributeValue = [self attributeValueFromObject:deletedValues];
                        attributeValueUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:attributeValue andAction:@"DELETE"];
                        [userDicForDelete setValue:attributeValueUpdate forKey:key];
                    }
                }
            }

            attributeValue = [[DynamoDBAttributeValue alloc] initWithN:@"1"];
            attributeValueUpdate = [[DynamoDBAttributeValueUpdate alloc] initWithValue:attributeValue andAction:@"ADD"];
            [userDic setValue:attributeValueUpdate forKey:[self versionKeyForEntityName:managedObject.entity.name]];

            attributeValue = [self attributeValueFromObject:[managedObject valueForKey:[self hashKeyForEntityName:managedObject.entity.name]]];
            DynamoDBKey *hashKey = [[DynamoDBKey alloc] initWithHashKeyElement:attributeValue];
            DynamoDBUpdateItemRequest *updateItemRequest = [[DynamoDBUpdateItemRequest alloc] initWithTableName:[self tableNameForEntityName:managedObject.entity.name]
                                                                                                         andKey:hashKey
                                                                                            andAttributeUpdates:userDic];

            AmazonDynamoDBClient *dynamoDBClient = [self dynamoDBClient];
            DynamoDBUpdateItemResponse *updateItemResponse = [dynamoDBClient updateItem:updateItemRequest];

            if(updateItemResponse.error == nil)
            {
                if([userDicForDelete count] > 0)
                {
                    DynamoDBUpdateItemRequest *updateItemRequest = [[DynamoDBUpdateItemRequest alloc] initWithTableName:[self tableNameForEntityName:managedObject.entity.name]
                                                                                                                 andKey:hashKey
                                                                                                    andAttributeUpdates:userDicForDelete];
                    updateItemResponse = [dynamoDBClient updateItem:updateItemRequest];
                    if(updateItemResponse.error != nil)
                    {
                        *error = updateItemResponse.error;
                        return NO;
                    }
                }
            }
            else
            {
                *error = updateItemResponse.error;
                return NO;
            }
        }

        return YES;
    }
    @catch (NSException *exception)
    {
        *error = [self errorFromException:exception];
        return NO;
    }
}

- (BOOL)deleteObject:(NSSet *)deletedObjects error:(NSError **)error
{
    AMZLogDebug(@"- (BOOL)deleteObject:(NSSet *)deletedObjects error:(NSError **)error called.");
    @try
    {
        DynamoDBBatchWriteItemRequest *batchWriteRequest = [DynamoDBBatchWriteItemRequest new];

        int counter = 1;

        for(NSManagedObject *managedObject in deletedObjects)
        {
            DynamoDBAttributeValue *attributeValue = [self attributeValueFromObject:[managedObject valueForKey:[self hashKeyForEntityName:managedObject.entity.name]]];
            DynamoDBKey *hashKey = [[DynamoDBKey alloc] initWithHashKeyElement:attributeValue];

            DynamoDBDeleteRequest *deleteRequest = [DynamoDBDeleteRequest new];
            deleteRequest.key = hashKey;

            DynamoDBWriteRequest *writeRequest = [DynamoDBWriteRequest new];
            writeRequest.deleteRequest = deleteRequest;

            NSMutableArray *writes = [batchWriteRequest.requestItems objectForKey:[self tableNameForEntityName:managedObject.entity.name]];
            if(writes == nil)
            {
                writes = [NSMutableArray arrayWithCapacity:25];
                [batchWriteRequest setRequestItemsValue:writes
                                                 forKey:[self tableNameForEntityName:managedObject.entity.name]];
            }

            [writes addObject:writeRequest];

            if(counter % 25 == 0 || [deletedObjects count] == counter)
            {
                DynamoDBBatchWriteItemResponse * batchWriteResponse = nil;

                AmazonDynamoDBClient *dynamoDBClient = [self dynamoDBClient];

                for(int i = 0; i < self.retryCount + 1; i++)
                {
                    batchWriteResponse = [dynamoDBClient batchWriteItem:batchWriteRequest];

                    if(batchWriteResponse.error == nil)
                    {
                        if(batchWriteResponse.unprocessedItems == nil
                           || [batchWriteResponse.unprocessedItems count] == 0
                           || i == self.retryCount)
                        {
                            break;
                        }
                        else
                        {
                            [NSThread sleepForTimeInterval:pow(2, i) * self.initialBackoffTimeInSecond];
                            batchWriteRequest = [DynamoDBBatchWriteItemRequest new];

                            for(NSString *key in batchWriteResponse.unprocessedItems)
                            {
                                [batchWriteRequest setRequestItemsValue:[batchWriteResponse.unprocessedItems objectForKey:key]
                                                                 forKey:key];
                            }
                        }
                    }
                    else
                    {
                        *error = batchWriteResponse.error;
                        return NO;
                    }
                }

                if(batchWriteResponse.unprocessedItems != nil
                   && [batchWriteResponse.unprocessedItems count] > 0)
                {
                    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:@"BatchWrite failed. Some items were not processed.", @"message", nil];
                    *error = [NSError errorWithDomain:AWSPersistenceDynamoDBClientErrorDomain code:-1 userInfo:userInfo];
                    return NO;
                }

                if([deletedObjects count] != counter)
                {
                    batchWriteRequest = [DynamoDBBatchWriteItemRequest new];
                }
            }

            [objectIdToHashKey removeObjectForKey:managedObject.objectID.URIRepresentation.description];

            counter++;
        }

        return YES;
    }
    @catch (NSException *exception)
    {
        *error = [self errorFromException:exception];
        return NO;
    }
}

#pragma mark - Helper Methods

- (NSString *)referenceObjectIdForCoreData:(id)hashKeyOrCompositeKey
{
    if([hashKeyOrCompositeKey isKindOfClass:[NSDictionary class]])
    {
        NSDictionary *compositeKey = hashKeyOrCompositeKey;
        NSString *hashKey = [compositeKey objectForKey:@"hashKey"];
        id rangeKey = [compositeKey objectForKey:@"rangeKey"];
        if([rangeKey isKindOfClass:[NSDate class]])
        {
            NSDate  *rangeKeyAsDate = rangeKey;
            rangeKey = [NSNumber numberWithDouble:[rangeKeyAsDate timeIntervalSince1970]];
        }
        else
        {
            
        }

        
        NSString *compositeKeyAsString = [NSString stringWithFormat:@"--HK--%@----RK--%@--", hashKey, rangeKey];
        return compositeKeyAsString;
    }
    else
    {
        NSString *hashKey = hashKeyOrCompositeKey;
        return hashKey;
    }
}

- (DynamoDBAttributeValue *)attributeValueFromObject:(NSObject *)object
{
    DynamoDBAttributeValue *attributeValue;

    if([object isKindOfClass:[NSString class]])
    {
        attributeValue = [[DynamoDBAttributeValue alloc] initWithS:[self convertObjectToString:object]];
    }
    else if([object isKindOfClass:[NSDate class]])
    {
        attributeValue = [[DynamoDBAttributeValue alloc] initWithN:[self convertObjectToString:object]];
    }
    else if([object isKindOfClass:[NSDecimalNumber class]]
            || [object isKindOfClass:[NSNumber class]])
    {
        attributeValue = [[DynamoDBAttributeValue alloc] initWithN:[self convertObjectToString:object]];
    }
    else if([object isKindOfClass:[NSSet class]] && [(NSSet *)object count] > 0)
    {
        id firstObject = [object performSelector:@selector(anyObject) withObject:nil];
        NSMutableArray *attributeArray = [NSMutableArray arrayWithArray:[(NSSet *)object allObjects]];

        if([firstObject isKindOfClass:[NSString class]])
        {
            attributeValue = [[DynamoDBAttributeValue alloc] initWithSS:attributeArray];
        }
        else if([firstObject isKindOfClass:[NSDate class]])
        {
            for(int i = 0; i < [attributeArray count]; i++)
            {
                [attributeArray replaceObjectAtIndex:i
                                          withObject:[self convertObjectToString:[attributeArray objectAtIndex:i]]];
            }
            attributeValue = [[DynamoDBAttributeValue alloc] initWithNS:attributeArray];
        }
        else if([firstObject isKindOfClass:[NSDecimalNumber class]]
                || [firstObject isKindOfClass:[NSNumber class]])
        {
            for(int i = 0; i < [attributeArray count]; i++)
            {
                [attributeArray replaceObjectAtIndex:i
                                          withObject:[self convertObjectToString:[attributeArray objectAtIndex:i]]];
            }
            attributeValue = [[DynamoDBAttributeValue alloc] initWithNS:attributeArray];
        }
        else
        {
            return nil;
        }
    }
    else if([object isKindOfClass:[NSArray class]] && [(NSArray *)object count] > 0)
    {
        id firstObject = [object performSelector:@selector(objectAtIndex:) withObject:0];
        NSMutableArray *attributeArray = [NSMutableArray arrayWithArray:(NSArray *)object];

        if([firstObject isKindOfClass:[NSString class]])
        {
            attributeValue = [[DynamoDBAttributeValue alloc] initWithSS:attributeArray];
        }
        else if([firstObject isKindOfClass:[NSDate class]])
        {
            for(int i = 0; i < [attributeArray count]; i++)
            {
                [attributeArray replaceObjectAtIndex:i
                                          withObject:[self convertObjectToString:[attributeArray objectAtIndex:i]]];
            }
            attributeValue = [[DynamoDBAttributeValue alloc] initWithNS:attributeArray];
        }
        else if([firstObject isKindOfClass:[NSDecimalNumber class]]
                || [firstObject isKindOfClass:[NSNumber class]])
        {
            for(int i = 0; i < [attributeArray count]; i++)
            {
                [attributeArray replaceObjectAtIndex:i
                                          withObject:[self convertObjectToString:[attributeArray objectAtIndex:i]]];
            }
            attributeValue = [[DynamoDBAttributeValue alloc] initWithNS:attributeArray];
        }
        else
        {
            return nil;
        }
    }
    else
    {
        return nil;
    }

    return attributeValue;
}

- (id)convertString:(NSString *)string toClass:(Class)class
{
    if([class isSubclassOfClass:[NSString class]])
    {
        return string;
    }
    else if([class isSubclassOfClass:[NSDate class]])
    {
        return [NSDate dateWithTimeIntervalSince1970:[[nf numberFromString:string] doubleValue]];
    }
    else if([class isSubclassOfClass:[NSDecimalNumber class]]
            || [class isSubclassOfClass:[NSNumber class]])
    {
        return [nf numberFromString:string];
    }
    else
    {
        return nil;
    }
}

- (NSString *)convertObjectToString:(NSObject *)object
{
    if([object isKindOfClass:[NSString class]])
    {
        return (NSString *)object;
    }
    else if([object isKindOfClass:[NSDate class]])
    {
        return [NSString stringWithFormat:@"%@", [NSNumber numberWithDouble:[(NSDate *)object timeIntervalSince1970]]];
    }
    else if([object isKindOfClass:[NSDecimalNumber class]]
            || [object isKindOfClass:[NSNumber class]])
    {
        return [NSString stringWithFormat:@"%@", object];
    }
    else
    {
        return nil;
    }
}

- (NSString *)tableNameForEntityName:(NSString *)entityName
{
    if([[self.options valueForKey:AWSPersistenceDynamoDBTableMapper] valueForKey:entityName] != nil)
    {
        return [[self.options valueForKey:AWSPersistenceDynamoDBTableMapper] valueForKey:entityName];
    }
    else
    {
        return entityName;
    }
}

- (NSString *)hashKeyForEntityName:(NSString *)entityName
{
    return [[self.options valueForKey:AWSPersistenceDynamoDBHashKey] valueForKey:entityName];
}

- (NSString *)rangeKeyForEntityName:(NSString *)entityName
{
    return [[self.options valueForKey:AWSPersistenceDynamoDBRangeKey] valueForKey:entityName];
}

- (NSString *)versionKeyForEntityName:(NSString *)entityName
{
    return [[self.options valueForKey:AWSPersistenceDynamoDBVersionKey] valueForKey:entityName];
}

- (NSDictionary *)attributeClassesForClassName:(NSString *)className
{
    AMZLogDebug(@"- (NSDictionary *)attributeClassesForClassName:(NSString *)className called.");

    id classObject = objc_getClass([className UTF8String]);
    unsigned int outCount, i;

    objc_property_t *properties = class_copyPropertyList(classObject, &outCount);

    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:outCount];

    for (i = 0; i < outCount; i++)
    {
        objc_property_t property = properties[i];
        NSString *attributeName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        NSString *attribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];

        NSArray *attributeComponents = [attribute componentsSeparatedByString: @"\""];

        if([attributeComponents count] >= 2)
        {
            [result setValue:objc_getClass([[attributeComponents objectAtIndex:1] UTF8String]) forKey:attributeName];
        }
    }

    free(properties);

    return [NSDictionary dictionaryWithDictionary:result];
}

- (NSError *)errorFromException:(NSException *)exception
{
    NSError *error = [AmazonErrorHandler errorFromException:exception
                                         serviceErrorDomain:AWSPersistenceDynamoDBServiceErrorDomain
                                          clientErrorDomain:AWSPersistenceDynamoDBClientErrorDomain];

    if(error != nil
       && [exception isKindOfClass:[AmazonServiceException class]])
    {
        [self checkeAuthenticationFailure:((AmazonServiceException *)exception).errorCode];
    }

    return error;
}

- (void)checkeAuthenticationFailure:(NSString *)errorCode
{
    if([delegate respondsToSelector:@selector(handleAuthenticationFailure)])
    {
        if(
           // STS http://docs.amazonwebservices.com/STS/latest/APIReference/CommonErrors.html
           [errorCode isEqualToString:@"IncompleteSignature"]
           || [errorCode isEqualToString:@"InternalFailure"]
           || [errorCode isEqualToString:@"InvalidClientTokenId"]
           || [errorCode isEqualToString:@"OptInRequired"]
           || [errorCode isEqualToString:@"RequestExpired"]
           || [errorCode isEqualToString:@"ServiceUnavailable"]
           
           // DynamoDB http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/ErrorHandling.html#APIErrorTypes
           || [errorCode isEqualToString:@"AccessDeniedException"]
           || [errorCode isEqualToString:@"IncompleteSignatureException"]
           || [errorCode isEqualToString:@"MissingAuthenticationTokenException"]
           || [errorCode isEqualToString:@"ValidationException"]
           || [errorCode isEqualToString:@"InternalFailure"]
           || [errorCode isEqualToString:@"InternalServerError"])
        {
            [delegate handleAuthenticationFailure];
        }
    }
}

@end