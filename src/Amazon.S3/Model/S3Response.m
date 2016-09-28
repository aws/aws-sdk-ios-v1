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

#import "S3Response.h"
#import "S3GetObjectResponse.h"
#import "AmazonLogger.h"
#import "S3ErrorResponseHandler.h"
#import "AmazonErrorHandler.h"

@implementation S3Response

-(id)init
{
    self = [super init];
    if (self != nil) {
        isFinishedLoading = NO;
        _headers = [NSMutableDictionary new];
    }

    return self;
}

-(void)setValue:(id)value forHTTPHeaderField:(NSString *)header
{
    [self.headers setValue:value forKey:header];

    // remove dashes from headers, and camelCase concatenate to get the corresponding
    // property name.
    // i.e., x-amz-version-id => versionId, Content-Length => contentLength.

    NSString *tmp   = [[header lowercaseString] stringByReplacingOccurrencesOfString:@"x-amz-" withString:@""];
    NSArray  *parts = [tmp componentsSeparatedByString:@"-"];

    NSString *keyName = [(NSString *)[parts objectAtIndex:0] lowercaseString];
    for (NSInteger i = 1; i < [parts count]; i++) {
        keyName = [keyName stringByAppendingString:[[(NSString *)[parts objectAtIndex:i] lowercaseString] capitalizedString]];
    }

    //AMZLog( @"Setting response value [%@] from header [%@] with value [%@]", keyName, header, value );

    NSString *typeName = [self getTypeOfPropertyNamed:keyName];

    if ([typeName isEqualToString:@"T@\"NSString\""]) {
        [self setValue:value forKey:keyName];
    }
    else if ([typeName isEqualToString:@"T@\"NSDate\""]) {
        [self setValue:[NSDate dateWithRFC822Format:value] forKey:keyName];
    }
    else if ([typeName isEqualToString:@"Ti"]) {
        NSInteger v = [(NSString *) value integerValue];
        [self setValue:[NSNumber numberWithInteger:v] forKey:keyName];
    }
    else if ([typeName isEqualToString:@"Tq"]) {
        int64_t foo = [value longLongValue];
        [self setValue:[NSNumber numberWithLongLong:foo] forKey:keyName];
    }
}

-(id)valueForHTTPHeaderField:(NSString *)header
{
    return [self.headers valueForKey:header];
}


-(NSString *)getTypeOfPropertyNamed:(NSString *)propertyName
{
    objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);

    if (NULL == property) {
        return nil;
    }

    const char *propertyAttributes = property_getAttributes(property);
    if (NULL == propertyAttributes) {
        return nil;
    }

    NSString *attrString = [NSString stringWithUTF8String:propertyAttributes];

    return [[attrString componentsSeparatedByString:@","] objectAtIndex:0];
}

-(NSData *)body
{
    return [NSData dataWithData:body];
}

// Override this to perform processing on the body.
-(void)processBody
{
    // Subclasses can use this to build object data from the response, for example
    // parsing XML content.
}

-(NSException *)exception
{
    return exception;
}

-(NSString *)description
{
    NSMutableString *buffer = [NSMutableString stringWithCapacity:256];

    [buffer appendString:@"{"];
    [buffer appendString:[NSString stringWithFormat:@"Headers: %@,", self.headers]];
    [buffer appendString:[NSString stringWithFormat:@"Content-Length: %lld,", self.contentLength]];
    [buffer appendString:[NSString stringWithFormat:@"Connection-State: %@,", self.connectionState]];
    [buffer appendString:[NSString stringWithFormat:@"Date:: %@,", self.date]];
    [buffer appendString:[NSString stringWithFormat:@"ETag: %@,", self.etag]];
    [buffer appendString:[NSString stringWithFormat:@"Server: %@,", self.server]];
    [buffer appendString:[NSString stringWithFormat:@"Delete-Marker: %d,", self.deleteMarker]];
    [buffer appendString:[NSString stringWithFormat:@"Id2: %@,", self.id2]];
    [buffer appendString:[NSString stringWithFormat:@"VersionId: %@,", self.versionId]];
    [buffer appendString:[NSString stringWithFormat:@"Server Side Encryption: %@,", self.serverSideEncryption]];
    [buffer appendString:[super description]];
    [buffer appendString:@"}"];

    return buffer;
}

#pragma mark NSURLConnection delegate methods

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [super connection:connection didReceiveResponse:response];

    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSDictionary *allHeaders = [httpResponse allHeaderFields];
    
    for (id key in allHeaders)
    {
        [self setValue:[allHeaders valueForKey:key] forHTTPHeaderField:key];
    }
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (nil == body) {
        body = [[NSMutableData data] retain];
    }

    [body appendData:data];

    if ([self.request.delegate respondsToSelector:@selector(request:didReceiveData:)]) {
        [self.request.delegate request:self.request didReceiveData:data];
    }
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.request.responseTimer invalidate];

    NSDate   *startDate = [NSDate date];
    
    if (![self isMemberOfClass:[S3GetObjectResponse class]]) {
        NSString *tmp       = [[NSString alloc] initWithData:self.body encoding:NSUTF8StringEncoding];
        
        AMZLogDebug(@"Response:\n%@", tmp);
        [tmp release];
    }

    // S3 treats 301's as an error and passes back an Error Response, so parse it
    if ((self.httpStatusCode == 301) || (self.httpStatusCode >= 400)) {
        NSXMLParser            *parser       = [[NSXMLParser alloc] initWithData:self.body];
        S3ErrorResponseHandler *errorHandler = [[S3ErrorResponseHandler alloc] initWithStatusCode:self.httpStatusCode];
        [parser setDelegate:errorHandler];
        [parser parse];

        exception = [[errorHandler exception] copy];
        BOOL throwsExceptions = [AmazonErrorHandler throwsExceptions];

        if (throwsExceptions == YES
            && [self.request.delegate respondsToSelector:@selector(request:didFailWithServiceException:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [self.request.delegate request:self.request didFailWithServiceException:(AmazonServiceException *)exception];
#pragma clang diagnostic pop
        }
        else if (throwsExceptions == NO
                 && [self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
            [self.request.delegate request:self.request didFailWithError:[AmazonErrorHandler errorFromException:exception]];
        }

        [parser release];
        [errorHandler release];
    }
    else {
        [self processBody];
        processingTime    = fabs([startDate timeIntervalSinceNow]);
        isFinishedLoading = YES;
    }

    if ([self.request.delegate respondsToSelector:@selector(request:didCompleteWithResponse:)]) {
        [self.request.delegate request:self.request didCompleteWithResponse:self];
    }


}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)theError
{
    [self.request.responseTimer invalidate];
    
    NSDictionary *info = [theError userInfo];
    for (id key in info)
    {
        AMZLog(@"UserInfo.%@ = %@", [key description], [[info valueForKey:key] description]);
    }
    exception = [[AmazonServiceException exceptionWithMessage:[theError description] andError:theError] retain];
    AMZLog(@"An error occured in the request: %@", [theError description]);

    if ([self.request.delegate respondsToSelector:@selector(request:didFailWithError:)]) {
        [self.request.delegate request:self.request didFailWithError:theError];
    }
}

-(void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    if ([self.request.delegate respondsToSelector:@selector(request:didSendData:totalBytesWritten:totalBytesExpectedToWrite:)]) {
        [self.request.delegate request:self.request
                           didSendData:(long long)bytesWritten
                     totalBytesWritten:(long long)totalBytesWritten
             totalBytesExpectedToWrite:(long long)totalBytesExpectedToWrite];
    }
}

// When a request gets a redirect due to the bucket being in a different region,
// The request gets re-written with a GET http method. This is to set the method back to
// the appropriate method if necessary
-(NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)proposedRequest redirectResponse:(NSURLResponse *)redirectResponse
{
    if (![[proposedRequest URL] isEqual:self.request.urlRequest.URL]) {
        AMZLog(@"Redirect:");
        AMZLog(@"  New  URL: %@", [[proposedRequest URL] description]);
        AMZLog(@"  Orig URL: %@", self.request.urlRequest.URL);

        NSMutableURLRequest *newRequest = [self.request.urlRequest mutableCopy];
        [newRequest setURL:[proposedRequest URL]];
        return [newRequest autorelease];
    }

    return proposedRequest;
}

-(NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

#pragma mark memory managament

-(void)dealloc
{
    [_connectionState release];
    [_etag release];
    [_server release];
    [_id2 release];
    [_versionId release];
    [_serverSideEncryption release];
    [_date release];
    [_headers release];

    [super dealloc];
}

@end
