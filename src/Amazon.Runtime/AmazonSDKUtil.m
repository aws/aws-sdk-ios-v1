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
 *
 * Portions Copyright (c) 1997-2012 The PHP Group.
 * Please see LICENSE.txt for applicable license terms and NOTICE.txt for applicable notices.
 */

#import "AmazonSDKUtil.h"
#import <CommonCrypto/CommonDigest.h>

static char        base64EncodingTable[] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

static const short base64DecodingTable[] =
{
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -1, -1, -2, -1, -1, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -1, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, 62, -2, -2, -2, 63,
    52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -2, -2, -2, -2, -2, -2,
    -2,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
    15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -2, -2, -2, -2, -2,
    -2, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
    41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2,
    -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2, -2
};

NSString *const AWSDefaultRunLoopMode = @"com.amazonaws.DefaultRunLoopMode";
NSString *const AWSS3TransferManagerUserAgentPrefix = @"Transfer Manager";

static NSTimeInterval _clockskew = 0.0;


@implementation AmazonSDKUtil

+(NSString *)userAgentString
{
    NSString *sn  = [[[UIDevice currentDevice] systemName] stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    NSString *sv  = [[UIDevice currentDevice] systemVersion];
    NSString *loc = [[NSLocale currentLocale] localeIdentifier];
    NSString *ua  = [NSString stringWithFormat:AWS_SDK_USER_AGENT_FORMAT, AWS_SDK_VERSION, sn, sv, loc];

    return ua;
}

+(NSString *)urlEncode:(NSString *)input
{
    NSString *encoded = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)input, NULL, (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", kCFStringEncodingUTF8);

    return [encoded autorelease];
}

+(NSData *)hexDecode:(NSString *)hexString
{
    NSMutableData *stringData = [[[NSMutableData alloc] init] autorelease];
    unsigned char whole_byte;
    char          byte_chars[3] = { '\0', '\0', '\0' };
    NSInteger     i;
    for (i = 0; i < [hexString length] / 2; i++) {
        byte_chars[0] = [hexString characterAtIndex:i * 2];
        byte_chars[1] = [hexString characterAtIndex:i * 2 + 1];
        whole_byte    = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }

    return stringData;
}

+(NSString *)hexEncode:(NSString *)string
{
    NSUInteger len    = [string length];
    unichar    *chars = malloc(len * sizeof(unichar));

    [string getCharacters:chars];

    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        if ((int)chars[i] < 16) {
            [hexString appendString:@"0"];
        }
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }
    free(chars);

    return [hexString autorelease];
}

+(NSString *)hexEncodeData:(NSData *)data
{
    NSUInteger      len    = [data length];
    const unsigned  *chars = [data bytes];

    NSMutableString *hexString = [[NSMutableString alloc] init];
    for (NSUInteger i = 0; i < len; i++) {
        if ((int)chars[i] < 16) {
            [hexString appendString:@"0"];
        }
        [hexString appendString:[NSString stringWithFormat:@"%x", chars[i]]];
    }

    return [hexString autorelease];
}

+(NSString *)MIMETypeForExtension:(NSString *)extension
{
    static NSDictionary *lookupTable = nil;

    if (lookupTable == nil) {
        lookupTable = [[NSDictionary alloc] initWithObjectsAndKeys:
                       @"application/postscript", @"ai",
                       @"audio/x-aiff", @"aif",
                       @"audio/x-aiff", @"aifc",
                       @"audio/x-aiff", @"aiff",
                       @"text/plain", @"asc",
                       @"audio/basic", @"au",
                       @"video/x-msvideo", @"avi",
                       @"application/x-bcpio", @"bcpio",
                       @"application/octet-stream", @"bin",
                       @"text/plain", @"c",
                       @"text/plain", @"cc",
                       @"application/clariscad", @"ccad",
                       @"application/x-netcdf", @"cdf",
                       @"application/octet-stream", @"class",
                       @"application/x-cpio", @"cpio",
                       @"text/plain", @"cpp",
                       @"application/mac-compactpro", @"cpt",
                       @"text/plain", @"cs",
                       @"application/x-csh", @"csh",
                       @"text/css", @"css",
                       @"application/x-director", @"dcr",
                       @"application/x-director", @"dir",
                       @"application/octet-stream", @"dms",
                       @"application/msword", @"doc",
                       @"application/msword", @"docx",
                       @"application/msword", @"dot",
                       @"application/drafting", @"drw",
                       @"application/x-dvi", @"dvi",
                       @"application/acad", @"dwg",
                       @"application/dxf", @"dxf",
                       @"application/x-director", @"dxr",
                       @"application/postscript", @"eps",
                       @"text/x-setext", @"etx",
                       @"application/octet-stream", @"exe",
                       @"application/andrew-inset", @"ez",
                       @"text/plain", @"f",
                       @"text/plain", @"f90",
                       @"video/x-fli", @"fli",
                       @"image/gif", @"gif",
                       @"application/x-gtar", @"gtar",
                       @"application/x-gzip", @"gz",
                       @"text/plain", @"h",
                       @"application/x-hdf", @"hdf",
                       @"text/plain", @"hh",
                       @"application/mac-binhex40", @"hqx",
                       @"text/html", @"htm",
                       @"text/html", @"html",
                       @"x-conference/x-cooltalk", @"ice",
                       @"image/ief", @"ief",
                       @"model/iges", @"iges",
                       @"model/iges", @"igs",
                       @"application/x-ipscript", @"ips",
                       @"application/x-ipix", @"ipx",
                       @"image/jpeg", @"jpe",
                       @"image/jpeg", @"jpeg",
                       @"image/jpeg", @"jpg",
                       @"application/x-javascript", @"js",
                       @"audio/midi", @"kar",
                       @"application/x-latex", @"latex",
                       @"application/octet-stream", @"lha",
                       @"application/x-lisp", @"lsp",
                       @"application/octet-stream", @"lzh",
                       @"text/plain", @"m",
                       @"application/x-troff-man", @"man",
                       @"application/x-troff-me", @"me",
                       @"model/mesh", @"mesh",
                       @"audio/midi", @"mid",
                       @"audio/midi", @"midi",
                       @"www/mime", @"mime",
                       @"video/quicktime", @"mov",
                       @"video/x-sgi-movie", @"movie",
                       @"audio/mpeg", @"mp2",
                       @"audio/mpeg", @"mp3",
                       @"video/mpeg", @"mpe",
                       @"video/mpeg", @"mpeg",
                       @"video/mpeg", @"mpg",
                       @"audio/mpeg", @"mpga",
                       @"application/x-troff-ms", @"ms",
                       @"application/x-ole-storage", @"msi",
                       @"model/mesh", @"msh",
                       @"application/x-netcdf", @"nc",
                       @"application/oda", @"oda",
                       @"image/x-portable-bitmap", @"pbm",
                       @"chemical/x-pdb", @"pdb",
                       @"application/pdf", @"pdf",
                       @"image/x-portable-graymap", @"pgm",
                       @"application/x-chess-pgn", @"pgn",
                       @"image/png", @"png",
                       @"image/x-portable-anymap", @"pnm",
                       @"application/mspowerpoint", @"pot",
                       @"image/x-portable-pixmap", @"ppm",
                       @"application/mspowerpoint", @"pps",
                       @"application/mspowerpoint", @"ppt",
                       @"application/mspowerpoint", @"ppz",
                       @"application/x-freelance", @"pre",
                       @"application/pro_eng", @"prt",
                       @"application/postscript", @"ps",
                       @"video/quicktime", @"qt",
                       @"audio/x-realaudio", @"ra",
                       @"audio/x-pn-realaudio", @"ram",
                       @"image/cmu-raster", @"ras",
                       @"image/x-rgb", @"rgb",
                       @"audio/x-pn-realaudio", @"rm",
                       @"application/x-troff", @"roff",
                       @"audio/x-pn-realaudio-plugin", @"rpm",
                       @"text/rtf", @"rtf",
                       @"text/richtext", @"rtx",
                       @"application/x-lotusscreencam", @"scm",
                       @"application/set", @"set",
                       @"text/sgml", @"sgm",
                       @"text/sgml", @"sgml",
                       @"application/x-sh", @"sh",
                       @"application/x-shar", @"shar",
                       @"model/mesh", @"silo",
                       @"application/x-stuffit", @"sit",
                       @"application/x-koan", @"skd",
                       @"application/x-koan", @"skm",
                       @"application/x-koan", @"skp",
                       @"application/x-koan", @"skt",
                       @"application/smil", @"smi",
                       @"application/smil", @"smil",
                       @"audio/basic", @"snd",
                       @"application/solids", @"sol",
                       @"application/x-futuresplash", @"spl",
                       @"application/x-wais-source", @"src",
                       @"application/STEP", @"step",
                       @"application/SLA", @"stl",
                       @"application/STEP", @"stp",
                       @"application/x-sv4cpio", @"sv4cpio",
                       @"application/x-sv4crc", @"sv4crc",
                       @"application/x-shockwave-flash", @"swf",
                       @"application/x-troff", @"t",
                       @"application/x-tar", @"tar",
                       @"application/x-tcl", @"tcl",
                       @"application/x-tex", @"tex",
                       @"image/tiff", @"tif",
                       @"image/tiff", @"tiff",
                       @"application/x-troff", @"tr",
                       @"audio/TSP-audio", @"tsi",
                       @"application/dsptype", @"tsp",
                       @"text/tab-separated-values", @"tsv",
                       @"text/plain", @"txt",
                       @"application/i-deas", @"unv",
                       @"application/x-ustar", @"ustar",
                       @"application/x-cdlink", @"vcd",
                       @"application/vda", @"vda",
                       @"model/vrml", @"vrml",
                       @"audio/x-wav", @"wav",
                       @"model/vrml", @"wrl",
                       @"image/x-xbitmap", @"xbm",
                       @"application/vnd.ms-excel", @"xlc",
                       @"application/vnd.ms-excel", @"xll",
                       @"application/vnd.ms-excel", @"xlm",
                       @"application/vnd.ms-excel", @"xls",
                       @"application/vnd.ms-excel", @"xlw",
                       @"text/xml", @"xml",
                       @"image/x-xpixmap", @"xpm",
                       @"image/x-xwindowdump", @"xwd",
                       @"chemical/x-pdb", @"xyz",
                       @"application/zip", @"zip",
                       @"video/x-m4v", @"m4v",
                       @"video/webm", @"webm",
                       @"video/ogv", @"ogv",
                       @"audio/mp4a-latm", @"m4a",
                       nil];
    }
    NSString *mimetype = (NSString *)[lookupTable objectForKey:[extension lowercaseString]];
    return mimetype == nil ? @"application/octet-stream" : mimetype;
}

+(NSNumber *)convertStringToNumber:(NSString *)string
{
    NSNumberFormatter *formatter = [[[NSNumberFormatter alloc] init] autorelease];

    [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [formatter setLocale:[AmazonSDKUtil timestampLocale]];

    return [formatter numberFromString:string];
}

+(NSDate *)convertStringToDate:(NSString *)string
{
    NSDate *date = [AmazonSDKUtil convertStringToDate:string usingFormat:kISO8061DateFormat];

    if (date != nil) {
        return date;
    }
    else {
        return [AmazonSDKUtil convertStringToDate:string usingFormat:kISO8601DateFormat];
    }
}

+(NSDate *)millisSinceEpochToDate:(NSNumber *)millisSinceEpoch
{
    return [NSDate dateWithTimeIntervalSince1970:([millisSinceEpoch doubleValue] / 1000)-_clockskew];
}

+(NSDate *)secondsSinceEpochToDate:(NSNumber *)secondsSinceEpoch
{
    return [NSDate dateWithTimeIntervalSince1970:[secondsSinceEpoch doubleValue]-_clockskew];
}

+(NSDate *)convertStringToDate:(NSString *)string usingFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];

    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:[AmazonSDKUtil timestampLocale]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];

    NSDate *parsed = [dateFormatter dateFromString:string];

    NSDate *localDate = [parsed dateByAddingTimeInterval:_clockskew];
    
    [dateFormatter release];
    
    return localDate;
}

+(NSString *)convertDateToString:(NSDate *)date usingFormat:(NSString *)dateFormat
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    [dateFormatter setDateFormat:dateFormat];
    [dateFormatter setLocale:[AmazonSDKUtil timestampLocale]];
    
    NSDate *realDate =  [date dateByAddingTimeInterval:-1*_clockskew];
    
    NSString *formatted = [dateFormatter stringFromDate:realDate];
    
    [dateFormatter release];
    
    return formatted;
}

+(NSURL *)URLWithURL:(NSURL *)theURL andProtocol:(NSString *)theProtocol
{
    if (!([theProtocol isEqualToString:@"http"] || [theProtocol isEqualToString:@"https"]))
    {
        // Fatal error. This should not happen.
        @throw [AmazonClientException exceptionWithMessage : @"protocol must be 'http' or 'https'."];
    }

    NSString *currentURL = [theURL absoluteString];
    if (![currentURL hasPrefix:[NSString stringWithFormat:@"%@:", theProtocol]]) {
        NSString *pattern;
        if ([theProtocol isEqualToString:@"http"]) {
            pattern = @"https://";
        }
        else {
            pattern = @"http://";
        }

        return [NSURL URLWithString:[currentURL stringByReplacingOccurrencesOfString:pattern
                                     withString:[NSString stringWithFormat:@"%@://", theProtocol]
                                     options:0
                                     range:NSMakeRange(0, 8)]];
    }

    return [NSURL URLWithString:[theURL absoluteString]];
}

+(NSLocale *)timestampLocale
{
    static NSLocale *_tsLoc = nil;

    if (nil == _tsLoc) {
        _tsLoc = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
    }
    return _tsLoc;
}

+(void)setRuntimeClockSkew:(NSTimeInterval)clockskew
{
    _clockskew = clockskew;
}

+(NSTimeInterval)getRuntimeClockSkew
{
    return _clockskew;
}

@end

@implementation NSDate (AmazonSDKUtil)

-(NSString *)stringWithISO8061Format
{
    return [AmazonSDKUtil convertDateToString:self usingFormat:kISO8061DateFormat];
}

-(NSString *)stringWithISO8601Format
{
    return [AmazonSDKUtil convertDateToString:self usingFormat:kISO8601DateFormat];
}

-(NSString *)stringWithRFC822Format
{
    return [AmazonSDKUtil convertDateToString:self usingFormat:kRFC822DateFormat];
}

+(NSDate *)dateWithISO8061Format:(NSString *)dateString
{
    return [AmazonSDKUtil convertStringToDate:dateString usingFormat:kISO8061DateFormat];
}

+(NSDate *)dateWithRFC822Format:(NSString *)dateString
{
    return [AmazonSDKUtil convertStringToDate:dateString usingFormat:kRFC822DateFormat];
}

+(NSString *)ISO8061FormattedCurrentTimestamp
{
    return [[NSDate date] stringWithISO8061Format];
}

-(NSString *)dateStamp
{
    return [AmazonSDKUtil convertDateToString:self usingFormat:kDateStampFormat];
}

-(NSString *)dateTime
{
    return [AmazonSDKUtil convertDateToString:self usingFormat:kDateTimeFormat];
}

@end

@implementation NSString (AmazonSDKUtil)

-(NSString *)stringByNormalizingPathComponent
{
    return [self stringByReplacingOccurrencesOfString:@"+" withString:@"\%2B"];
}

-(NSString *)stringWithURLEncoding
{
    NSString *encoded = (NSString *)CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL, (CFStringRef)@"!*'\"();:@&=$,/?%#[]% ", kCFStringEncodingUTF8);

    [encoded autorelease];
    return [encoded stringByNormalizingPathComponent];
}

@end


@implementation NSData (WithBase64)

-(NSString *) base64EncodedString
{
    NSMutableString *result;
    unsigned char   *raw;
    unsigned long   length;
    short           i, nCharsToWrite;
    long            cursor;
    unsigned char   inbytes[3], outbytes[4];

    length = [self length];

    if (length < 1) {
        return @"";
    }

    result = [NSMutableString stringWithCapacity:length];
    raw    = (unsigned char *)[self bytes];
    // Take 3 chars at a time, and encode to 4
    for (cursor = 0; cursor < length; cursor += 3) {
        for (i = 0; i < 3; i++) {
            if (cursor + i < length) {
                inbytes[i] = raw[cursor + i];
            }
            else{
                inbytes[i] = 0;
            }
        }

        outbytes[0] = (inbytes[0] & 0xFC) >> 2;
        outbytes[1] = ((inbytes[0] & 0x03) << 4) | ((inbytes[1] & 0xF0) >> 4);
        outbytes[2] = ((inbytes[1] & 0x0F) << 2) | ((inbytes[2] & 0xC0) >> 6);
        outbytes[3] = inbytes[2] & 0x3F;

        nCharsToWrite = 4;

        switch (length - cursor) {
        case 1:
            nCharsToWrite = 2;
            break;

        case 2:
            nCharsToWrite = 3;
            break;
        }
        for (i = 0; i < nCharsToWrite; i++) {
            [result appendFormat:@"%c", base64EncodingTable[outbytes[i]]];
        }
        for (i = nCharsToWrite; i < 4; i++) {
            [result appendString:@"="];
        }
    }

    return [NSString stringWithString:result]; // convert to immutable string
}

+(NSData *) dataWithBase64EncodedString:(NSString *)encodedString
{
    if (nil == encodedString || [encodedString length] < 1) {
        return [NSData data];
    }

    const char    *inputPtr;
    unsigned char *buffer;

    NSInteger     length;

    inputPtr = [encodedString cStringUsingEncoding:NSASCIIStringEncoding];
    length   = strlen(inputPtr);
    char ch;
    NSInteger inputIdx = 0, outputIdx = 0, padIdx;

    buffer = calloc(length, sizeof(unsigned char));

    while (((ch = *inputPtr++) != '\0') && (length-- > 0)) {
        if (ch == '=') {
            if (*inputPtr != '=' && ((inputIdx % 4) == 1)) {
                free(buffer);
                return nil;
            }
            continue;
        }

        ch = base64DecodingTable[ch];

        if (ch < 0) { // whitespace or other invalid character
            continue;
        }

        switch (inputIdx % 4) {
        case 0:
            buffer[outputIdx] = ch << 2;
            break;

        case 1:
            buffer[outputIdx++] |= ch >> 4;
            buffer[outputIdx]    = (ch & 0x0f) << 4;
            break;

        case 2:
            buffer[outputIdx++] |= ch >> 2;
            buffer[outputIdx]    = (ch & 0x03) << 6;
            break;

        case 3:
            buffer[outputIdx++] |= ch;
            break;
        }

        inputIdx++;
    }

    padIdx = outputIdx;

    if (ch == '=') {
        switch (inputIdx % 4) {
        case 1:
            free(buffer);
            return nil;

        case 2:
            padIdx++;

        case 3:
            buffer[padIdx] = 0;
        }
    }

    NSData *objData = [[[NSData alloc] initWithBytes:buffer length:outputIdx] autorelease];
    free(buffer);
    return objData;
}

@end

@implementation NSData (CRC32)

/*
 * Based on PHP crc32.c and crc32.h
 * ===== START =====
*/

static const uint32_t crc32table[256] = {
	0x00000000, 0x77073096, 0xee0e612c, 0x990951ba,
	0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
	0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
	0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
	0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de,
	0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
	0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,
	0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
	0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
	0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
	0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940,
	0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
	0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116,
	0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
	0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
	0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
	0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a,
	0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
	0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818,
	0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
	0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
	0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
	0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c,
	0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
	0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2,
	0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
	0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
	0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
	0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086,
	0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
	0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4,
	0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
	0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
	0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
	0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8,
	0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
	0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe,
	0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
	0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
	0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
	0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252,
	0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
	0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60,
	0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
	0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
	0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
	0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04,
	0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
	0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a,
	0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
	0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
	0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
	0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e,
	0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
	0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c,
	0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
	0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
	0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
	0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0,
	0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
	0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6,
	0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
	0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
	0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d,
};

- (uint32_t)crc32
{
    uint32_t len = [self length];
    uint8_t *p = (uint8_t *)[self bytes];
    uint32_t crcinit = 0;
	uint32_t crc = 0;

	crc = crcinit ^ 0xFFFFFFFF;
	while (len--) {
		crc = ((crc >> 8) & 0x00FFFFFF) ^ crc32table[(crc ^ (*p++)) & 0xFF];
	}
    
	return crc ^ 0xFFFFFFFF;
}

/*
 * ===== END =====
 * Based on PHP crc32.c and crc32.h
 */

@end
