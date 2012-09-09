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

#import "S3Grantee.h"

@implementation S3Grantee

@synthesize emailAddress;
@synthesize URI;

+(id)granteeWithID:(NSString *)theID withDisplayName:(NSString *)theDisplayName
{
    S3Grantee *canonicalUser = [[S3Grantee alloc] init];

    [canonicalUser setID:theID];
    [canonicalUser setDisplayName:theDisplayName];
    return [canonicalUser autorelease];
}

+(id)granteeWithURI:(NSString *)theURI
{
    S3Grantee *group = [[S3Grantee alloc] init];

    [group setURI:theURI];
    return [group autorelease];
}

+(id)granteeWithEmailAddress:(NSString *)theEmailAddress
{
    S3Grantee *user = [[S3Grantee alloc] init];

    [user setEmailAddress:theEmailAddress];
    return [user autorelease];
}

+(id)allUsers
{
    static S3Grantee *allUsers = nil;

    if (allUsers == nil) {
        @synchronized(self) {
            if (allUsers == nil) {
                allUsers = [[S3Grantee granteeWithURI:kS3GroupURIAllUsers] retain];
            }
        }
    }
    return allUsers;
}

+(id)authenticatedUsers
{
    static S3Grantee *authUsers = nil;

    if (authUsers == nil) {
        @synchronized(self) {
            if (authUsers == nil) {
                authUsers = [[S3Grantee granteeWithURI:kS3GroupURIAuthUsers] retain];
            }
        }
    }
    return authUsers;
}

-(NSString *)toXml
{
    if (self.URI != nil) {
        return [NSString stringWithFormat:@"<Grantee %@><URI>%@</URI></Grantee>",
                [NSString stringWithFormat:kXsiNamespaceSpec, kXsiTypeGroup], self.URI];
    }
    if (self.emailAddress != nil) {
        return [NSString stringWithFormat:@"<Grantee %@><EmailAddress>%@</EmailAddress></Grantee>",
                [NSString stringWithFormat:kXsiNamespaceSpec, kXsiTypeAmazonCustomerByEmail], self.emailAddress];
    }
    return [NSString stringWithFormat:@"<Grantee %@><ID>%@</ID><DisplayName>%@</DisplayName></Grantee>",
            [NSString stringWithFormat:kXsiNamespaceSpec, kXsiTypeCanonicalUser], self.ID, self.displayName];
}

-(BOOL)isEqual:(id)object
{
    if (self.URI != nil) {
        if (![object respondsToSelector:@selector(URI)]) {
            return NO;
        }
        return [self.URI isEqual:[object URI]];
    }
    if (self.emailAddress != nil) {
        if (![object respondsToSelector:@selector(emailAddress)]) {
            return NO;
        }
        return [self.emailAddress isEqual:[object emailAddress]];
    }
    if (![object respondsToSelector:@selector(ID)]) {
        return NO;
    }
    if (![object respondsToSelector:@selector(displayName)]) {
        return NO;
    }
    return [self.ID isEqual:[object ID]] && [self.displayName isEqual:[object displayName]];
}

-(NSUInteger)hash
{
    if (self.URI != nil) {
        return [self.URI hash];
    }
    if (self.emailAddress != nil) {
        return [self.emailAddress hash];
    }
    return [self.ID hash] ^ [self.displayName hash];
}

-(void)dealloc
{
    [emailAddress release];
    [URI release];

    [super dealloc];
}

@end
