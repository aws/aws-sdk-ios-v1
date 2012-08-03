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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AmazonClientException.h"

#define AWS_SDK_VERSION              @"1.3.2"
#define AWS_SDK_USER_AGENT_FORMAT    @"aws-sdk-iOS/%@ %@/%@ %@"
#define kISO8061DateFormat           @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
#define kISO8601DateFormat           @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#define kRFC822DateFormat            @"EEE, dd MMM yyyy HH:mm:ss z"
#define kDateStampFormat             @"yyyyMMdd"
#define kDateTimeFormat              @"yyyyMMdd'T'HHmmss'Z'"

@interface AmazonSDKUtil:NSObject {
}

+(NSString *)userAgentString;
+(NSString *)MIMETypeForExtension:(NSString *)extension;
+(NSString *)urlEncode:(NSString *)input;
+(NSData *)hexDecode:(NSString *)hexString;
+(NSString *)hexEncode:(NSString *)string;
+(NSString *)hexEncodeData:(NSData *)data;
+(NSNumber *)convertStringToNumber:(NSString *)string;
+(NSDate *)convertStringToDate:(NSString *)string;
+(NSDate *)convertStringToDate:(NSString *)string usingFormat:(NSString *)dateFormat;
+(NSDate *)millisSinceEpochToDate:(NSNumber *)millisSinceEpoch;
+(NSDate *)secondsSinceEpochToDate:(NSNumber *)secondsSinceEpoch;
+(NSURL *)URLWithURL:(NSURL *)theURL andProtocol:(NSString *)theProtocol;
+(NSLocale *)timestampLocale;
@end

@interface NSDate (WithISO8061Format)

-(NSString *)stringWithISO8061Format;
-(NSString *)stringWithISO8601Format;
-(NSString *)stringWithRFC822Format;
+(NSDate *)dateWithISO8061Format:(NSString *)dateString;
+(NSString *)ISO8061FormattedCurrentTimestamp;
-(NSString *)dateStamp;
-(NSString *)dateTime;



@end

@interface NSString (AmazonSDKUtil)

-(NSString *)stringByNormalizingPathComponent;
-(NSString *)stringWithURLEncoding;

@end

/*! \category NSData(WithBase64)
 *  \abstract Adds Base64 encoding to the NSData class.
 */
@interface NSData (WithBase64)

/**
 * Return a base64 encoded representation of the data.
 *
 * @return base64 encoded representation of the data.
 */
-(NSString *) base64EncodedString;

/**
 * Decode a base-64 encoded string into a new NSData object.
 *
 * @return NSData with the data represented by the encoded string.
 */
+(NSData *) dataWithBase64EncodedString:(NSString *)encodedString;
@end
