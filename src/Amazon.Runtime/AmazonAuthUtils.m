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

#import "AmazonAuthUtils.h"
#import "AmazonLogger.h"

@implementation AmazonAuthUtils

+(void)signRequest:(AmazonServiceRequest *)serviceRequest endpoint:(NSString *)theEndpoint credentials:(AmazonCredentials *)credentials
{
    NSData   *dataToSign = [[AmazonAuthUtils getV2StringToSign:[NSURL URLWithString:theEndpoint] request:serviceRequest] dataUsingEncoding:NSUTF8StringEncoding];
    NSString *signature  = [AmazonAuthUtils HMACSign:dataToSign withKey:credentials.secretKey usingAlgorithm:kCCHmacAlgSHA256];

    [serviceRequest setParameterValue:signature forKey:@"Signature"];
}

+(NSString *)signRequestV3:(AmazonServiceRequest *)serviceRequest sts:(NSString *)theSts credentials:(AmazonCredentials *)credentials
{
    return [AmazonAuthUtils HMACSign:[theSts dataUsingEncoding:NSUTF8StringEncoding] withKey:credentials.secretKey usingAlgorithm:kCCHmacAlgSHA256];
}

+(NSString *)getV2StringToSign:(NSURL *)theEndpoint request:(AmazonServiceRequest *)serviceRequest
{
    NSString *host = [theEndpoint host];
    NSString *path = [theEndpoint path];

    if (nil == path || [path length] < 1) {
        path = @"/";
    }
    NSString *sts = [NSString stringWithFormat:@"POST\n%@\n%@\n%@", host, path, [serviceRequest queryString]];
    AMZLogDebug(@"String To Sign:\n%@", sts);
    return sts;
}

+(NSString *)getV3StringToSign:(NSString *)rfc822Date nonce:(NSString *)theNonce
{
    return [NSString stringWithFormat:@"%@%@", rfc822Date, theNonce];
}

+(NSString *)nonce
{
    CFUUIDRef uuid   = CFUUIDCreate(kCFAllocatorDefault);
    NSString  *nonce = [(NSString *)CFUUIDCreateString(kCFAllocatorDefault, uuid) autorelease];

    CFRelease(uuid);

    return nonce;
}

+(NSString *)amznAuthorization:(NSString *)accessKey algorithm:(NSString *)theAlgorithm signature:(NSString *)theSignature
{
    return [NSString stringWithFormat:@"AWS3-HTTPS AWSAccessKeyId=%@,Algorithm=%@,Signature=%@", accessKey, theAlgorithm, theSignature];
}

+(NSString *) HMACSign:(NSData *)data withKey:(NSString *)key usingAlgorithm:(CCHmacAlgorithm)algorithm
{
    CCHmacContext context;
    const char    *keyCString = [key cStringUsingEncoding:NSASCIIStringEncoding];

    CCHmacInit(&context, algorithm, keyCString, strlen(keyCString));
    CCHmacUpdate(&context, [data bytes], [data length]);

    // Both SHA1 and SHA256 will fit in here
    unsigned char digestRaw[CC_SHA256_DIGEST_LENGTH];

    int           digestLength;

    switch (algorithm) {
    case kCCHmacAlgSHA1:
        digestLength = CC_SHA1_DIGEST_LENGTH;
        break;

    case kCCHmacAlgSHA256:
        digestLength = CC_SHA256_DIGEST_LENGTH;
        break;

    default:
        digestLength = -1;
        break;
    }

    if (digestLength < 0) {
        @throw [AmazonSignatureException exceptionWithName : kError_Invalid_Hash_Alg
                reason : kReason_Invalid_Hash_Alg
                userInfo : nil];
    }

    CCHmacFinal(&context, digestRaw);

    NSData *digestData = [NSData dataWithBytes:digestRaw length:digestLength];

    return [digestData base64EncodedString];
}

@end

