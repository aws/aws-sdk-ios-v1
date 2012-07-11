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


#import "S3UploadInputStream.h"
#import "S3Constants.h"
#import "AmazonLogger.h"

@implementation S3UploadInputStream

@synthesize stream, packetSize, delay;

-(id)init 
{
    if ((self = [super init]) != nil) {
        delay = 0.0;
        packetSize = 32;
    }
    
    return self;    
}

+(id)inputStreamWithData:(NSData *)data
{
	S3UploadInputStream *uploadStream = [[[S3UploadInputStream alloc] init] autorelease];
	if (data) {
		[uploadStream setStream:[NSInputStream inputStreamWithData:data]];
	}
	return uploadStream;
}

+(id)inputStreamWithFileAtPath:(NSString *)path
{
	S3UploadInputStream *uploadStream = [[[S3UploadInputStream alloc] init] autorelease];
	[uploadStream setStream:[NSInputStream inputStreamWithFileAtPath:path]];
	return uploadStream;
}

+(id)inputStreamWithStream:(NSInputStream *)aStream
{
	S3UploadInputStream *uploadStream = [[[S3UploadInputStream alloc] init] autorelease];
	[uploadStream setStream:aStream];
	return uploadStream;
}

-(NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
	NSInteger nBytesRead = [stream read:buffer maxLength:(kS3UploadInputStreamChunkSize * packetSize)];
	AMZLogDebug(@"S3UploadInputStream: read %d bytes (%d max)", nBytesRead, len);
	[NSThread sleepForTimeInterval:delay];
	return nBytesRead;
}

-(BOOL)hasBytesAvailable
{
	return [stream hasBytesAvailable];
}

- (BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
	return NO;
}

/*
 * Implement NSInputStream mandatory methods to make sure they are implemented
 * (necessary for MacRuby for example) and avoid the overhead of method
 * forwarding for these common methods.
 */
- (void)open
{
	[stream open];
}

- (void)close
{
	[stream close];
}

- (id)delegate
{
	return [stream delegate];
}

- (void)setDelegate:(id)delegate
{
	[stream setDelegate:delegate];
}

- (void)scheduleInRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
	[stream scheduleInRunLoop:aRunLoop forMode:mode];
}

- (void)removeFromRunLoop:(NSRunLoop *)aRunLoop forMode:(NSString *)mode
{
	[stream removeFromRunLoop:aRunLoop forMode:mode];
}

- (id)propertyForKey:(NSString *)key
{
	return [stream propertyForKey:key];
}

- (BOOL)setProperty:(id)property forKey:(NSString *)key
{
	return [stream setProperty:property forKey:key];
}

- (NSStreamStatus)streamStatus
{
	return [stream streamStatus];
}

- (NSError *)streamError
{
	return [stream streamError];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
	return [stream methodSignatureForSelector:aSelector];
}

- (void)forwardInvocation:(NSInvocation *)anInvocation
{
	[anInvocation invokeWithTarget:stream];
}

-(void)dealloc
{
	[stream release];
	
	[super dealloc];
}

@end
