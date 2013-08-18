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

#import "CloudFormationStackUnmarshaller.h"
#ifdef AWS_MULTI_FRAMEWORK
#import <AWSRuntime/AmazonServiceExceptionUnmarshaller.h>
#else
#import "../AmazonServiceExceptionUnmarshaller.h"
#endif

@implementation CloudFormationStackUnmarshaller

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
    
    
	if ([elementName isEqualToString:@"Capabilities"]) {
        AmazonListUnmarshaller *listUnmarshaller = [[[AmazonListUnmarshaller alloc] initWithCaller:self withParentObject:self.response.capabilities withSetter:@selector(addObjectsFromArray:)] autorelease];
        listUnmarshaller.endListElementName = @"Capabilities";
        listUnmarshaller.entryElementName   = @"member";
        listUnmarshaller.delegateClass      = [AmazonValueUnmarshaller class];
        
        [parser setDelegate:listUnmarshaller];
    }
    
	if ([elementName isEqualToString:@"NotificationARNs"]) {
        AmazonListUnmarshaller *listUnmarshaller = [[[AmazonListUnmarshaller alloc] initWithCaller:self withParentObject:self.response.notificationARNs withSetter:@selector(addObjectsFromArray:)] autorelease];
        listUnmarshaller.endListElementName = @"NotificationARNs";
        listUnmarshaller.entryElementName   = @"member";
        listUnmarshaller.delegateClass      = [AmazonValueUnmarshaller class];
        
        [parser setDelegate:listUnmarshaller];
    }
    
	if ([elementName isEqualToString:@"Outputs"]) {
        AmazonListUnmarshaller *listUnmarshaller = [[[AmazonListUnmarshaller alloc] initWithCaller:self withParentObject:self.response.outputs withSetter:@selector(addObjectsFromArray:)] autorelease];
        listUnmarshaller.endListElementName = @"Outputs";
        listUnmarshaller.entryElementName   = @"member";
        listUnmarshaller.delegateClass      = [CloudFormationOutputUnmarshaller class];
        
        [parser setDelegate:listUnmarshaller];
    }
    
	if ([elementName isEqualToString:@"Parameters"]) {
        AmazonListUnmarshaller *listUnmarshaller = [[[AmazonListUnmarshaller alloc] initWithCaller:self withParentObject:self.response.parameters withSetter:@selector(addObjectsFromArray:)] autorelease];
        listUnmarshaller.endListElementName = @"Parameters";
        listUnmarshaller.entryElementName   = @"member";
        listUnmarshaller.delegateClass      = [CloudFormationParameterUnmarshaller class];
        
        [parser setDelegate:listUnmarshaller];
    }
    
	if ([elementName isEqualToString:@"Tags"]) {
        AmazonListUnmarshaller *listUnmarshaller = [[[AmazonListUnmarshaller alloc] initWithCaller:self withParentObject:self.response.tags withSetter:@selector(addObjectsFromArray:)] autorelease];
        listUnmarshaller.endListElementName = @"Tags";
        listUnmarshaller.entryElementName   = @"member";
        listUnmarshaller.delegateClass      = [CloudFormationTagUnmarshaller class];
        
        [parser setDelegate:listUnmarshaller];
    }
    
    
    if ([elementName isEqualToString:@"Error"]) {
        [parser setDelegate:[[[AmazonServiceExceptionUnmarshaller alloc] initWithCaller:self withParentObject:self.response withSetter:@selector(setException:)] autorelease]];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
    
    
	if ([elementName isEqualToString:@"CreationTime"]) {
        self.response.creationTime = [AmazonSDKUtil convertStringToDate:self.currentText];
        return;
    }
	if ([elementName isEqualToString:@"Description"]) {
        self.response.description = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"DisableRollback"]) {
        self.response.disableRollback = [self.currentText boolValue];
        return;
    }
	if ([elementName isEqualToString:@"LastUpdatedTime"]) {
        self.response.lastUpdatedTime = [AmazonSDKUtil convertStringToDate:self.currentText];
        return;
    }
	if ([elementName isEqualToString:@"StackId"]) {
        self.response.stackId = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"StackName"]) {
        self.response.stackName = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"StackStatus"]) {
        self.response.stackStatus = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"StackStatusReason"]) {
        self.response.stackStatusReason = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"TimeoutInMinutes"]) {
        self.response.timeoutInMinutes = [AmazonSDKUtil convertStringToNumber:self.currentText];
        return;
    }
    
    if ([elementName isEqualToString:@"Stacks"]) {
        if (caller != nil) {
            [parser setDelegate:caller];
        }
        
        if (parentObject != nil && [parentObject respondsToSelector:parentSetter]) {
            [parentObject performSelector:parentSetter withObject:self.response];
        }
        
        return;
    }
}

-(CloudFormationStack *)response
{
    if (nil == response) {
        response = [[CloudFormationStack alloc] init];
    }
    return response;
}

-(void)dealloc
{
	[response release];
    [super dealloc];
}

@end