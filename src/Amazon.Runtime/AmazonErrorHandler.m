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

#import "AmazonErrorHandler.h"
#import "AmazonLogger.h"


// Public Constants
NSString *const AWSiOSSDKServiceErrorDomain = @"com.amazonaws.iossdk.ServiceErrorDomain";
NSString *const AWSiOSSDKClientErrorDomain = @"com.amazonaws.iossdk.ClientErrorDomain";

static BOOL throwsExceptions = YES;

@implementation AmazonErrorHandler

#pragma mark - Public Methods

+ (void)shouldThrowExceptions
{
    throwsExceptions = YES;
}

+ (void)shouldNotThrowExceptions
{
    throwsExceptions = NO;
}

+ (BOOL)throwsExceptions
{
    return throwsExceptions;
}

+ (NSError *)errorFromExceptionWithThrowsExceptionOption:(NSException *)exception
{
    if(exception == nil)
    {
        return nil;
    }
    else if(throwsExceptions == YES)
    {
        AMZLogDebug(@"WARNING: An exception was thrown. Please call [AmazonErrorHandler shouldNotThrowExceptions] to change this behavior.");
        @throw exception;
    }
    else if(![exception isKindOfClass:[AmazonClientException class]])
    {
        // Fatal error. This should not happen.
        @throw exception;
    }
    
    return [AmazonErrorHandler errorFromException:exception];
}

+ (NSError *)errorFromException:(NSException *)exception serviceErrorDomain:(NSString *)serviceErrorDomain clientErrorDomain:(NSString *)clientErrorDomain
{
    NSError *error = nil;
    
    if([exception isKindOfClass:[AmazonServiceException class]])
    {
        AmazonServiceException *serviceException = (AmazonServiceException *)exception;
        
        if(serviceException.error != nil)
        {
            error = serviceException.error;
        }
        else
        {
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithDictionary:serviceException.additionalFields];
            [userInfo setValue:serviceException.requestId forKey:@"requestId"];
            [userInfo setValue:serviceException.errorCode forKey:@"errorCode"];
            [userInfo setValue:serviceException.serviceName forKey:@"serviceName"];
            [userInfo setValue:serviceException forKey:@"exception"];
            
            error = [NSError errorWithDomain:serviceErrorDomain code:serviceException.statusCode userInfo:userInfo];
        }
    }
    else if([exception isKindOfClass:[AmazonClientException class]])
    {
        AmazonClientException *clientException = (AmazonClientException *)exception;
        
        if(clientException.error != nil)
        {
            error = clientException.error;
        }
        else
        {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      clientException.message, @"message", 
                                      clientException, @"exception", nil];
            
            error = [NSError errorWithDomain:clientErrorDomain code:-1 userInfo:userInfo];
        }
    }
    
    // Return nil for non Amazon exceptions.
    return error;
}

+ (NSError *)errorFromException:(NSException *)exception
{
    return [AmazonErrorHandler errorFromException:exception
                               serviceErrorDomain:AWSiOSSDKServiceErrorDomain
                                clientErrorDomain:AWSiOSSDKClientErrorDomain];
}

#pragma mark -

@end