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

#define AWS_SDK_VERSION              @"1.7.1"
#define AWS_SDK_USER_AGENT_FORMAT    @"aws-sdk-iOS/%@ %@/%@ %@"
#define kISO8061DateFormat           @"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
#define kISO8601DateFormat           @"yyyy-MM-dd'T'HH:mm:ss'Z'"
#define kRFC822DateFormat            @"EEE, dd MMM yyyy HH:mm:ss z"
#define kDateStampFormat             @"yyyyMMdd"
#define kDateTimeFormat              @"yyyyMMdd'T'HHmmss'Z'"

extern NSString *const AWSDefaultRunLoopMode;
extern NSString *const AWSS3TransferManagerUserAgentPrefix;

/**
 * Utility class for the AWS SDK for iOS.  Contains many common operations used
 * by all supported services.
 */
@interface AmazonSDKUtil : NSObject
{
}

/**
 * The user agent string for the SDK.
 *
 * @return the user agent string that will be used for service clients
 */
+(NSString *)userAgentString;

/**
 * Return a MIME type for the file based on extension.
 * 
 * @param extension the extension for the file (gif, jpg, etc)
 *
 * @return the expected MIME type to use for this type of file
 */
+(NSString *)MIMETypeForExtension:(NSString *)extension;

/**
 * Encode a string to embed in a URL.
 *
 * @param input string to encode
 * 
 * @return encoded string
 */
+(NSString *)urlEncode:(NSString *)input;

/**
 * Hex decode a string value.
 *
 * @param hexString the string to attempt to decode
 * 
 * @return The decoded data.
 */
+(NSData *)hexDecode:(NSString *)hexString;

/**
 * Hex encode a string value.
 * 
 * @param string the string to encode
 * 
 * @return the hex encoded value as an NSString
 */
+(NSString *)hexEncode:(NSString *)string;

/**
 * Hex encode a data value
 *
 * @param data value to encode
 *
 * @return the hex encoded value as an NSString
 */
+(NSString *)hexEncodeData:(NSData *)data;

/**
 * Parse a number from an NSString value
 *
 * @param string NSString containing a number
 *
 * @return NSNumber parsed from the string
 */
+(NSNumber *)convertStringToNumber:(NSString *)string;

/**
 * Parse a date from an NSString value
 *
 * @param string NSString containing a date in ISO-8061 format
 *
 * @return The NSDate parsed from the string
 */
+(NSDate *)convertStringToDate:(NSString *)string;

/**
 * Parse a date from an NSString value using a given format
 *
 * @param string NSString containing a date
 * @param dateFormat The format of the date
 */
+(NSDate *)convertStringToDate:(NSString *)string usingFormat:(NSString *)dateFormat;

/**
 * Convert a NSDate to a NSString using a given format
 * 
 * @param date the NSDate to convert
 * @param dateFormat the format to use
 * 
 * @return The string representation of the date using the given format
 */
+(NSString *)convertDateToString:(NSDate *)date usingFormat:(NSString *)dateFormat;

/**
 * Construct a date using the number of milliseconds from the epoch (00:00:00 1/1/1970 GMT)
 * 
 * @param millisSinceEpoch number of milliseconds since the epoch
 *
 * @return NSDate for that exact time.
 */
+(NSDate *)millisSinceEpochToDate:(NSNumber *)millisSinceEpoch;

/**
 * Construct a date using the number of seconds from the epoch (00:00:00 1/1/1970 GMT)
 *
 * @param secondsSinceEpoch number of seconds since the epoch
 *
 * @return NSDate for that exact time.
 */
+(NSDate *)secondsSinceEpochToDate:(NSNumber *)secondsSinceEpoch;

/**
 * Construct an NSURL object with a URI and protocol/scheme
 *
 * @param theURL the URL fragment (hostname + path)
 * @param theProtocol scheme to use. Valid schemes are @"http://" and @"https://"
 * 
 * @return NSURL object for this path
 */
+(NSURL *)URLWithURL:(NSURL *)theURL andProtocol:(NSString *)theProtocol;

/**
 * Return the locale for the current device
 * 
 * @return the NSLocale
 */
+(NSLocale *)timestampLocale;

/**
 * Set the clock skew for the current device.  This clock skew will be used for calculating
 * signatures to AWS signatures and for parsing/converting date values from responses.
 *
 * @param clockskew the skew (in seconds) for this device.  If the clock on the device is fast, pass positive skew to correct.  If the clock on the device is slow, pass negative skew to correct.
 */
+(void)setRuntimeClockSkew:(NSTimeInterval)clockskew;

/**
 * Get the clock skew for the current device.
 *
 * @return the skew (in seconds) currently set for this device.  Positive clock skew implies the device is fast, negative implies the device is slow.
 */
+(NSTimeInterval)getRuntimeClockSkew;

@end


/**
 * This category adds some AWS specific date formatting and parsing to the NSDate class
 */
@interface NSDate (AmazonSDKUtil)

/**
 * Return string representation in ISO-8061 format
 *
 * @return NSString representation of this Date in ISO-8061 format
 */
-(NSString *)stringWithISO8061Format;

/**
 * Return string representation in ISO-8601 format
 *
 * @return NSString representation of this Date in ISO-8601 format
 */
-(NSString *)stringWithISO8601Format;

/**
 * Return string representation in RFC822 format
 *
 * @return NSString representation of this Date in RFC822 format
 */
-(NSString *)stringWithRFC822Format;

/**
 * Parse a ISO-8061 date from a string
 * 
 * @param dateString NSString containing ISO-8061 date
 * 
 * @return NSDate parsed from the given string
 */
+(NSDate *)dateWithISO8061Format:(NSString *)dateString;

/**
 * Parse a RFC822 date from a string
 *
 * @param dateString NSString containing RFC822 date
 *
 * @return NSDate parsed from the given string
 */
+(NSDate *)dateWithRFC822Format:(NSString *)dateString;

/**
 * Return string representation of current date in ISO-8061 format
 *
 * @return NSString representation of the current date in ISO-8061 format
 */
+(NSString *)ISO8061FormattedCurrentTimestamp;

/**
 * Return string representation of current date
 *
 * @return NSString representation of just date portion of the current date
 */
-(NSString *)dateStamp;

/**
 * Return string representation of current date
 *
 * @return NSString representation of the current date
 */
-(NSString *)dateTime;

@end

/**
 * This category adds some AWS specific string normalization to the NSString class
 */
@interface NSString (AmazonSDKUtil)

/**
 * Encode '+' for use with S3
 *
 * @return Encoded NSString
 */
-(NSString *)stringByNormalizingPathComponent;

/**
 * Encode an NSString for use in URL
 * 
 * @return Encoded NSString
 */
-(NSString *)stringWithURLEncoding;

@end

/**
 * This category Adds Base64 encoding to the NSData class.
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
 * @param encodedString an base-64 encoded string
 *
 * @return NSData with the data represented by the encoded string.
 */
+(NSData *) dataWithBase64EncodedString:(NSString *)encodedString;
@end

/**
 * This category adds CRC32 calculation to the NSData class.
 */
@interface NSData (CRC32)

/**
 * Calculate the CRC32 value for the NSData object.
 *
 * @return value of CRC32 calculation for this NSData object.
 */
- (uint32_t)crc32;

@end
