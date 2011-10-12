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

#import "AmazonS3Client.h"


@implementation AmazonS3Client

-(id)init
{
    if ((self = [super init]) != nil) {
        [AmazonS3Client initializeResponseObjects];
        self.endpoint = @"https://s3.amazonaws.com";
    }

    return self;
}

+(NSString *)apiVersion
{
    return @"2006-03-01";
}

#pragma mark Service Requests

-(S3CreateBucketResponse *)createBucket:(S3CreateBucketRequest *)createBucketRequest
{
    return (S3CreateBucketResponse *)[self invoke:createBucketRequest];
}

-(S3CreateBucketResponse *)createBucketWithName:(NSString *)bucketName
{
    S3CreateBucketRequest  *createBucketRequest  = [[S3CreateBucketRequest alloc] initWithName:bucketName];
    S3CreateBucketResponse *createBucketResponse = [self createBucket:createBucketRequest];

    [createBucketRequest release];

    return createBucketResponse;
}

-(S3DeleteBucketResponse *)deleteBucket:(S3DeleteBucketRequest *)deleteBucketRequest
{
    return (S3DeleteBucketResponse *)[self invoke:deleteBucketRequest];
}

-(S3DeleteBucketResponse *)deleteBucketWithName:(NSString *)bucketName
{
    S3DeleteBucketRequest  *deleteBucketRequest  = [[S3DeleteBucketRequest alloc] initWithName:bucketName];
    S3DeleteBucketResponse *deleteBucketResponse = [self deleteBucket:deleteBucketRequest];

    [deleteBucketRequest release];

    return deleteBucketResponse;
}

-(S3Region *)getBucketLocation:(NSString *)bucketName
{
    S3Request *req = [[S3Request alloc] init];

    req.bucket      = bucketName;
    req.subResource = @"location";

    S3Response                       *res = [self invoke:req];

    NSXMLParser                      *parser          = [[NSXMLParser alloc] initWithData:res.body];
    S3LocationConstraintUnmarshaller *locUnmarshaller = [[S3LocationConstraintUnmarshaller alloc] init];
    [parser setDelegate:locUnmarshaller];
    [parser parse];

    NSString *location = locUnmarshaller.location;

    [req release];
    [parser release];
    [locUnmarshaller release];

    return [S3Region regionWithString:location];
}

-(NSArray *)listBuckets
{
    S3ListBucketsRequest  *req      = [[[S3ListBucketsRequest alloc] init] autorelease];
    S3ListBucketsResponse *response = [self listBuckets:req];

    if (response.listBucketsResult != nil && response.listBucketsResult.buckets != nil) {
        return [NSArray arrayWithArray:response.listBucketsResult.buckets];
    }
    return nil;
}

-(S3ListBucketsResponse *)listBuckets:(S3ListBucketsRequest *)listBucketsRequest
{
    return (S3ListBucketsResponse *)[self invoke:listBucketsRequest];
}

-(S3ListObjectsResponse *)listObjects:(S3ListObjectsRequest *)listObjectsRequest
{
    return (S3ListObjectsResponse *)[self invoke:listObjectsRequest];
}

-(NSArray *)listObjectsInBucket:(NSString *)bucketName
{
    S3ListObjectsRequest  *req = [[S3ListObjectsRequest alloc] initWithName:bucketName];
    S3ListObjectsResponse *res = [self listObjects:req];

    [req release];

    if (res.listObjectsResult != nil && res.listObjectsResult.objectSummaries != nil) {
        return [NSArray arrayWithArray:res.listObjectsResult.objectSummaries];
    }
    return nil;
}

-(S3GetObjectMetadataResponse *)getObjectMetadata:(S3GetObjectMetadataRequest *)getObjectMetadataRequest
{
    return (S3GetObjectMetadataResponse *)[self invoke:getObjectMetadataRequest];
}

-(S3Response *)putObject:(S3PutObjectRequest *)putObjectRequest
{
    return [self invoke:putObjectRequest];
}

-(S3GetObjectResponse *)getObject:(S3GetObjectRequest *)getObjectRequest
{
    return (S3GetObjectResponse *)[self invoke:getObjectRequest];
}

-(S3DeleteObjectResponse *)deleteObject:(S3DeleteObjectRequest *)deleteObjectRequest
{
    return (S3DeleteObjectResponse *)[self invoke:deleteObjectRequest];
}

-(S3DeleteObjectResponse *)deleteObjectWithKey:(NSString *)theKey withBucket:(NSString *)theBucket
{
    S3DeleteObjectRequest *request = [[S3DeleteObjectRequest alloc] init];

    request.key    = theKey;
    request.bucket = theBucket;

    S3DeleteObjectResponse *response = (S3DeleteObjectResponse *)[self invoke:request];

    [request release];

    return response;
}

-(S3CopyObjectResponse *)copyObject:(S3CopyObjectRequest *)copyObjectRequest
{
    return (S3CopyObjectResponse *)[self invoke:copyObjectRequest];
}

-(S3GetACLResponse *)getACL:(S3GetACLRequest *)getACLRequest
{
    return (S3GetACLResponse *)[self invoke:getACLRequest];
}

-(S3SetACLResponse *)setACL:(S3SetACLRequest *)setACLRequest
{
    return (S3SetACLResponse *)[self invoke:setACLRequest];
}

-(S3GetBucketPolicyResponse *)getBucketPolicy:(S3GetBucketPolicyRequest *)getPolicyRequest
{
    S3GetBucketPolicyResponse *response = nil;

    @try {
        response = (S3GetBucketPolicyResponse *)[self invoke:getPolicyRequest];
    }
    @catch (AmazonServiceException *exception) {
        if ( [exception.errorCode isEqualToString:@"NoSuchBucketPolicy"]) {
            response        = [[[S3GetBucketPolicyResponse alloc] init] autorelease];
            response.policy = [[[S3BucketPolicy alloc] init] autorelease];
        }
    }

    return response;
}

-(S3SetBucketPolicyResponse *)setBucketPolicy:(S3SetBucketPolicyRequest *)setPolicyRequest
{
    return (S3SetBucketPolicyResponse *)[self invoke:setPolicyRequest];
}

-(S3DeleteBucketPolicyResponse *)deleteBucketPolicy:(S3DeleteBucketPolicyRequest *)deletePolicyRequest
{
    return (S3DeleteBucketPolicyResponse *)[self invoke:deletePolicyRequest];
}

-(S3GetBucketVersioningConfigurationResponse *)getBucketVersioningConfiguration:(S3GetBucketVersioningConfigurationRequest *)getBucketVersioningConfigurationRequest
{
    return (S3GetBucketVersioningConfigurationResponse *)[self invoke:getBucketVersioningConfigurationRequest];
}

-(S3SetBucketVersioningConfigurationResponse *)setBucketVersioningConfiguration:(S3SetBucketVersioningConfigurationRequest *)setBucketVersioningConfigurationRequest
{
    return (S3SetBucketVersioningConfigurationResponse *)[self invoke:setBucketVersioningConfigurationRequest];
}

-(S3DeleteVersionResponse *)deleteVersion:(S3DeleteVersionRequest *)deleteVersionRequest
{
    return (S3DeleteVersionResponse *)[self invoke:deleteVersionRequest];
}

-(S3ListVersionsResponse *)listVersions:(S3ListVersionsRequest *)lisVersionsRequest
{
    return (S3ListVersionsResponse *)[self invoke:lisVersionsRequest];
}

-(NSURL *)getPreSignedURL:(S3GetPreSignedURLRequest *)preSignedURLRequest
{
    if (nil == preSignedURLRequest.accessKey) {
        if (nil == preSignedURLRequest.credentials) {
            preSignedURLRequest.accessKey = credentials.accessKey;
        }
        else {
            preSignedURLRequest.accessKey = preSignedURLRequest.credentials.accessKey;
        }
    }

    if (preSignedURLRequest.endpoint == nil) {
        [preSignedURLRequest setEndpoint:self.endpoint];
    }


    AmazonURLRequest *amazonURLRequest = [preSignedURLRequest configureURLRequest];
    amazonURLRequest.endpointHost = [preSignedURLRequest endpointHost];
    NSURLRequest     *urlRequest  = [self signS3Request:preSignedURLRequest];
    NSString         *auth        = [urlRequest valueForHTTPHeaderField:kHttpHdrAuthorization];
    NSString         *signature   = (NSString *)[[auth componentsSeparatedByString:@":"] objectAtIndex:1];
    NSString         *queryString = [[preSignedURLRequest queryString] stringByAppendingFormat:@"&%@=%@", kS3QueryParamSignature, [AmazonSDKUtil urlEncode:signature]];

    [preSignedURLRequest setSubResource:queryString];

    return [AmazonSDKUtil URLWithURL:[preSignedURLRequest url] andProtocol:preSignedURLRequest.protocol];
}

-(S3InitiateMultipartUploadResponse *)initiateMultipartUpload:(S3InitiateMultipartUploadRequest *)initiateMultipartUploadRequest
{
    return (S3InitiateMultipartUploadResponse *)[self invoke:initiateMultipartUploadRequest];
}

-(S3CopyPartResponse *)copyPart:(S3CopyPartRequest *)copyPartRequest
{
    return (S3CopyPartResponse *)[self invoke:copyPartRequest];
}

-(S3MultipartUpload *)initiateMultipartUploadWithKey:(NSString *)theKey withBucket:(NSString *)theBucket
{
    S3InitiateMultipartUploadRequest *request = [[[S3InitiateMultipartUploadRequest alloc] init] autorelease];

    request.key    = theKey;
    request.bucket = theBucket;

    S3InitiateMultipartUploadResponse *response = (S3InitiateMultipartUploadResponse *)[self invoke:request];

    return response.multipartUpload;
}

-(S3AbortMultipartUploadResponse *)abortMultipartUpload:(S3AbortMultipartUploadRequest *)abortMultipartUploadRequest
{
    return (S3AbortMultipartUploadResponse *)[self invoke:abortMultipartUploadRequest];
}

// This method is misleading.  It will always fail, because aborting a multipart upload
// requires not just the upload ID but also the key and the bucket, which are used in the URL
// and in signing the request.  If you keep this method, it should take those two values as parameters.
-(void)abortMultipartUploadWithUploadId:(NSString *)theUploadId
{
    S3AbortMultipartUploadRequest *request = [[[S3AbortMultipartUploadRequest alloc] init] autorelease];

    request.uploadId = theUploadId;

    [self abortMultipartUpload:request];
}

-(S3ListMultipartUploadsResponse *)listMultipartUploads:(S3ListMultipartUploadsRequest *)listMultipartUploadsRequest
{
    return (S3ListMultipartUploadsResponse *)[self invoke:listMultipartUploadsRequest];
}

-(S3UploadPartResponse *)uploadPart:(S3UploadPartRequest *)uploadPartRequest
{
    return (S3UploadPartResponse *)[self invoke:uploadPartRequest];
}

-(S3ListPartsResponse *)listParts:(S3ListPartsRequest *)listPartsRequest
{
    return (S3ListPartsResponse *)[self invoke:listPartsRequest];
}

-(S3CompleteMultipartUploadResponse *)completeMultipartUpload:(S3CompleteMultipartUploadRequest *)completeMultipartUploadRequest
{
    return (S3CompleteMultipartUploadResponse *)[self invoke:completeMultipartUploadRequest];
}

#pragma mark Request Utility Code

-(S3Response *)invoke:(S3Request *)request
{
    if (nil == request) {
        @throw [AmazonClientException exceptionWithMessage : @"Request cannot be nil."];
    }

    [request setUserAgent:self.userAgent];
    if (request.endpoint == nil) {
        [request setEndpoint:self.endpoint];
    }
    
    if (request.securityToken == nil && credentials != nil && credentials.securityToken != nil) {
        request.securityToken = credentials.securityToken;
    }
    

    AMZLogDebug(@"Begin Request: %@", NSStringFromClass([request class]));

    S3Response *response = nil;
    int        retries   = 0;
    while (retries < self.maxRetries) {
        if ( retries > 0 ) {
            request.date = [NSDate date];
        }
        
        NSURLRequest *urlRequest = [self signS3Request:request];
        
        AMZLogDebug(@"%@ %@", [urlRequest HTTPMethod], [urlRequest URL]);
        AMZLogDebug(@"Request headers: ");
        for (id hKey in [[urlRequest allHTTPHeaderFields] allKeys])
        {
            AMZLogDebug(@"  %@: %@", [hKey description], [[urlRequest allHTTPHeaderFields] valueForKey:hKey]);
        }
        
        response = [AmazonS3Client constructResponseFromRequest:request];
        [response setRequest:request];

        NSURLConnection *urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:response];
        NSTimer         *timeoutTimer  = [NSTimer scheduledTimerWithTimeInterval:self.timeout target:response selector:@selector(timeout) userInfo:nil repeats:NO];

        request.urlConnection = urlConnection;

        if ([request delegate] == nil) {
            while (!response.isFinishedLoading && !response.exception && !response.didTimeout) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }

            if (response.didTimeout) {
                [urlConnection cancel];
            }
            else {
                [timeoutTimer invalidate];      //  invalidate also releases the object.
            }

            AMZLogDebug(@"Response Status Code : %d", response.httpStatusCode);
            if ( [self shouldRetry:response]) {
                AMZLogDebug(@"Retring Request: %d", retries);

                [self pauseExponentially:retries];
                retries++;
            }
            else {
                if (response.exception) {
                    AMZLogDebug(@"Request threw exception: %@", [response.exception description]);
                    if ([response.exception isMemberOfClass:[AmazonServiceException class]]) {
                        AMZLogDebug(@"HTTP: %d, S3 Error Code: %@", ((AmazonServiceException *)response.exception).statusCode, ((AmazonServiceException *)response.exception).errorCode);
                    }
                    AMZLogDebug(@"Reason: ", [response.exception reason]);
                    @throw response.exception;
                }

                break;
            }
        }
        else {
            return nil;
        }
    }

    if (response.exception) {
        AMZLogDebug(@"Request threw exception: %@", [response.exception description]);
        if ([response.exception isMemberOfClass:[AmazonServiceException class]]) {
            AMZLogDebug(@"HTTP: %d, S3 Error Code: %@", ((AmazonServiceException *)response.exception).statusCode, ((AmazonServiceException *)response.exception).errorCode);
        }
        AMZLogDebug(@"Reason: ", [response.exception reason]);
        @throw response.exception;
    }

    AMZLogDebug(@"Received response from server. RequestId: %@. HTTP: %d. Id2: %@.", response.requestId, response.httpStatusCode, response.id2);
    AMZLogDebug(@"Response [%@]", response);
    
    return response;
}

+(id)constructResponseFromRequest:(S3Request *)request
{
    NSString *requestClassName  = NSStringFromClass([request class]);
    NSString *responseClassName = [[requestClassName substringToIndex:[requestClassName length] - 7] stringByAppendingFormat:@"Response"];

    id       response = [[NSClassFromString(responseClassName) alloc] init];

    if (nil == response) {
        response = [[S3Response alloc] init];
    }

    if ([request isMemberOfClass:[S3GetObjectRequest class]] &&
        [response isMemberOfClass:[S3GetObjectResponse class]] &&
        ((S3GetObjectRequest *)request).outputStream != nil) {
        [(S3GetObjectResponse *) response setOutputStream:((S3GetObjectRequest *)request).outputStream];
    }

    return [response autorelease];
}

-(NSURLRequest *)signS3Request:(S3Request *)request
{
    AmazonURLRequest *urlRequest = [request configureURLRequest];

    if ( [urlRequest valueForHTTPHeaderField:@"Content-Type"] == nil && [request class] != [S3GetPreSignedURLRequest class]) {
        // Setting this here and not the AmazonServiceRequest because S3 extends that class and sets its own Content-Type Header.
        [urlRequest addValue:@"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    }

    NSString *contentMd5  = [urlRequest valueForHTTPHeaderField:@"Content-MD5"];
    NSString *contentType = [urlRequest valueForHTTPHeaderField:@"Content-Type"];
    NSString *timestamp   = [urlRequest valueForHTTPHeaderField:@"Date"];

    if (nil == contentMd5) {
        contentMd5 = @"";
    }
    if (nil == contentType) {
        contentType = @"";
    }

    NSMutableString *canonicalizedAmzHeaders = [NSMutableString stringWithFormat:@""];

    NSArray         *sortedHeaders = [[[urlRequest allHTTPHeaderFields] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    for (id key in sortedHeaders)
    {
        NSString *keyName = [(NSString *) key lowercaseString];
        if ([keyName hasPrefix:@"x-amz-"]) {
            [canonicalizedAmzHeaders appendFormat:@"%@:%@\n", keyName, [urlRequest valueForHTTPHeaderField:(NSString *)key]];
        }
    }

    NSString *canonicalizedResource;
    if (nil == [request key] || [[request key] length] < 1) {
        if (nil == [request bucket] || [[request bucket] length] < 1) {
            canonicalizedResource = @"/";
        }
        else {
            canonicalizedResource = [NSString stringWithFormat:@"/%@/", [request bucket]];
        }
    }
    else {
        canonicalizedResource = [NSString stringWithFormat:@"/%@/%@", [request bucket], [[request key] stringWithURLEncoding]];
    }

    NSString *query = urlRequest.URL.query;

    bool     isListObjects          = [request class] == [S3ListObjectsRequest class];
    bool     isListVersions         = [request class] == [S3ListVersionsRequest class];
    bool     isListMultipartUploads = [request class] == [S3ListMultipartUploadsRequest class];
    bool     isListParts            = [request class] == [S3ListPartsRequest class];
    if (query != nil && [query length] > 0 && !isListObjects && !isListVersions && !isListMultipartUploads && !isListParts) {
        canonicalizedResource = [canonicalizedResource stringByAppendingFormat:@"?%@", [query stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    if (isListVersions) {
        canonicalizedResource = [canonicalizedResource stringByAppendingFormat:@"?%@", kS3SubResourceVersions];
    }
    if (isListMultipartUploads) {
        canonicalizedResource = [canonicalizedResource stringByAppendingFormat:@"?%@", kS3SubResourceUploads];
    }
    if (isListParts) {
        canonicalizedResource = [canonicalizedResource stringByAppendingFormat:@"?%@=%@", kS3QueryParamUploadId, ((S3ListPartsRequest *)request).uploadId];
    }

    NSString *stringToSign = [NSString stringWithFormat:@"%@\n%@\n%@\n%@\n%@%@", [urlRequest HTTPMethod], contentMd5, contentType, timestamp, canonicalizedAmzHeaders, canonicalizedResource];

    AMZLogDebug(@"In SignURLRequest: String to Sign = [%@]", stringToSign);

    NSString *signature = nil;
    if (request.credentials != nil) {
        signature = [AmazonAuthUtils HMACSign:[stringToSign dataUsingEncoding:NSASCIIStringEncoding] withKey:request.credentials.secretKey usingAlgorithm:kCCHmacAlgSHA1];
        [urlRequest setValue:[NSString stringWithFormat:@"AWS %@:%@", request.credentials.accessKey, signature] forHTTPHeaderField:@"Authorization"];
    }
    else {
        signature = [AmazonAuthUtils HMACSign:[stringToSign dataUsingEncoding:NSASCIIStringEncoding] withKey:credentials.secretKey usingAlgorithm:kCCHmacAlgSHA1];
        [urlRequest setValue:[NSString stringWithFormat:@"AWS %@:%@", credentials.accessKey, signature] forHTTPHeaderField:@"Authorization"];
    }

    return urlRequest;
}

-(NSString *)serviceEndpoint
{
    return kS3ServiceEndpoint;
}

#pragma mark memory management

-(void)dealloc
{
    [super dealloc];
}

+(void)initializeResponseObjects
{
    // Since we will be creating instances of these classes using NSClassFromString,
    // make certain they have been loaded by the runtime.
    [S3AbortMultipartUploadResponse class];
    [S3CreateBucketResponse class];
    [S3CompleteMultipartUploadResponse class];
    [S3CopyObjectResponse class];
    [S3CopyPartResponse class];
    [S3DeleteBucketPolicyResponse class];
    [S3DeleteBucketResponse class];
    [S3DeleteObjectResponse class];
    [S3DeleteVersionResponse class];
    [S3GetACLResponse class];
    [S3GetBucketPolicyResponse class];    
    [S3GetBucketVersioningConfigurationResponse class];
    [S3GetObjectMetadataResponse class];
    [S3GetObjectResponse class];
    [S3InitiateMultipartUploadResponse class];
    [S3ListBucketsResponse class];
    [S3ListMultipartUploadsResponse class];
    [S3ListObjectsResponse class];
    [S3ListPartsResponse class];
    [S3ListVersionsResponse class];
    [S3PutObjectResponse class];
    [S3SetACLResponse class];
    [S3SetBucketPolicyResponse class];
    [S3SetBucketVersioningConfigurationResponse class];    
    [S3UploadPartResponse class];
}



@end
