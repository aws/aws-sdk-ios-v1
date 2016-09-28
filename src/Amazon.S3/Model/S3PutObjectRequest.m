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

#import "S3PutObjectRequest.h"
#import "AmazonMD5Util.h"

@implementation S3PutObjectRequest

-(id)init
{
    if (self = [super init])
    {
        _expires = 0;
        _generateMD5 = YES;

        expiresSet  = NO;
    }
    
    return self;
}

-(id)initWithKey:(NSString *)aKey inBucket:(NSString *)aBucket
{
    if(self = [self init])
    {
        self.key    = aKey;
        self.bucket = aBucket;
    }

    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    
    [self setCacheControl:[decoder decodeObjectForKey:@"CacheControl"]];
    [self setContentDisposition:[decoder decodeObjectForKey:@"ContentDisposition"]];
    [self setContentEncoding:[decoder decodeObjectForKey:@"ContentEncoding"]];
    [self setContentMD5:[decoder decodeObjectForKey:@"ContentMD5"]];
    self.generateMD5 = [decoder decodeBoolForKey:@"GenerateMD5"];
    [self setExpect:[decoder decodeObjectForKey:@"Expect"]];
    self.expires = [decoder decodeIntegerForKey:@"Expires"];
    [self setData:[decoder decodeObjectForKey:@"Data"]];
    [self setFilename:[decoder decodeObjectForKey:@"Filename"]];
    [self setRedirectLocation:[decoder decodeObjectForKey:@"RedirectionLocation"]];
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    
    [encoder encodeObject:self.cacheControl forKey:@"CacheControl"];
    [encoder encodeObject:self.contentDisposition forKey:@"ContentDisposition"];
    [encoder encodeObject:self.contentEncoding forKey:@"ContentEncoding"];
    [encoder encodeObject:self.contentMD5 forKey:@"ContentMD5"];
    [encoder encodeBool:self.generateMD5 forKey:@"GenerateMD5"];
    [encoder encodeObject:self.expect forKey:@"Expect"];
    [encoder encodeInteger:self.expires forKey:@"Expires"];
    [encoder encodeObject:self.data forKey:@"Data"];
    [encoder encodeObject:self.filename forKey:@"Filename"];
    [encoder encodeObject:self.redirectLocation forKey:@"RedirectionLocation"];
}

-(void)setExpires:(int32_t)exp
{
    _expires    = exp;
    expiresSet = YES;
}

-(NSMutableURLRequest *)configureURLRequest
{
    [super configureURLRequest];

    if ((nil == self.contentMD5) && (YES == self.generateMD5)) {
        if (self.data != nil) {
            self.contentMD5 = [AmazonMD5Util base64md5FromData:self.data];
        }
        else {
            if (nil != self.filename) {
                NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:self.filename];
                [inputStream open];

                self.contentMD5 = [AmazonMD5Util base64md5FromStream:inputStream];

                [inputStream close];
                [inputStream release];
            }
        }
    }

    [urlRequest setHTTPMethod:kHttpMethodPut];

    if (nil != self.expect) {
        [self.urlRequest setValue:self.expect
               forHTTPHeaderField:kHttpHdrExpect];
    }
    if (nil != self.contentMD5) {
        [self.urlRequest setValue:self.contentMD5
               forHTTPHeaderField:kHttpHdrContentMD5];
    }
    if (nil != self.contentEncoding) {
        [self.urlRequest setValue:self.contentEncoding
               forHTTPHeaderField:kHttpHdrContentEncoding];
    }
    if (nil != self.contentDisposition) {
        [self.urlRequest setValue:self.contentDisposition
               forHTTPHeaderField:kHttpHdrContentDisposition];
    }
    if (nil != self.cacheControl) {
        [self.urlRequest setValue:self.cacheControl
               forHTTPHeaderField:kHttpHdrCacheControl];
    }
    if (nil != self.redirectLocation) {
        [self.urlRequest setValue:self.redirectLocation
               forHTTPHeaderField:kHttpHdrAmzWebsiteRedirectLocation];
    }

    if (expiresSet) {
        [self.urlRequest setValue:[NSString stringWithFormat:@"%d", self.expires]
               forHTTPHeaderField:kHttpHdrExpires];
    }

    if (self.stream != nil) {
        [self.urlRequest setHTTPBodyStream:self.stream];
    }
    else {
        [self.urlRequest setHTTPBody:self.data];
        if (self.contentLength < 1) {
            [self.urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[self.data length]]
                   forHTTPHeaderField:kHttpHdrContentLength];
        }
    }

    return urlRequest;
}

- (AmazonClientException *)validate
{
    AmazonClientException *clientException = [super validate];

    if(clientException == nil)
    {
        if(self.filename != nil)
        {
            if (![[NSFileManager defaultManager] isReadableFileAtPath:self.filename]) {

                clientException = [AmazonClientException exceptionWithMessage:@"The specified file cannot be read."];
            }
            else {
                self.contentLength = [[[[NSFileManager defaultManager] attributesOfItemAtPath:self.filename
                                                                                        error:nil]
                                       valueForKey:NSFileSize] longLongValue];
                self.contentType   = [AmazonSDKUtil MIMETypeForExtension:[self.filename pathExtension]];

                @try {
                    NSInputStream *inputStream = [[NSInputStream alloc] initWithFileAtPath:self.filename];
                    self.stream = inputStream;
                    [inputStream release];
                }
                @catch (NSException *e) {

                    clientException = [AmazonClientException exceptionWithMessage:
                                       [NSString stringWithFormat:@"Could not open file for streaming: %@", e.reason]];
                }
            }
        }
    }

    return clientException;
}

#ifdef DEBUG
-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    AMZLog(@"Wrote %ld bytes to the connection", (long)bytesWritten);
}
#endif

-(void)dealloc
{
    [_cacheControl release];
    [_contentDisposition release];
    [_contentEncoding release];
    [_contentMD5 release];
    [_expect release];
    [_data release];
    if(_stream.streamStatus == NSStreamStatusOpen){
        [_stream close];
    }
    [_stream release];
    [_filename release];
    [_redirectLocation release];
    
    [super dealloc];
}

@end
