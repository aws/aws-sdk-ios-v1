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

#import "CloudFormationStackResourceUnmarshaller.h"
#ifdef AWS_MULTI_FRAMEWORK
#import <AWSRuntime/AmazonServiceExceptionUnmarshaller.h>
#else
#import "../AmazonServiceExceptionUnmarshaller.h"
#endif

@implementation CloudFormationStackResourceUnmarshaller

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    [super parser:parser didStartElement:elementName namespaceURI:namespaceURI qualifiedName:qName attributes:attributeDict];
    
    
    
    if ([elementName isEqualToString:@"Error"]) {
        [parser setDelegate:[[[AmazonServiceExceptionUnmarshaller alloc] initWithCaller:self withParentObject:self.response withSetter:@selector(setException:)] autorelease]];
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    [super parser:parser didEndElement:elementName namespaceURI:namespaceURI qualifiedName:qName];
    
    
	if ([elementName isEqualToString:@"Description"]) {
        self.response.description = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"LogicalResourceId"]) {
        self.response.logicalResourceId = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"PhysicalResourceId"]) {
        self.response.physicalResourceId = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"ResourceStatus"]) {
        self.response.resourceStatus = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"ResourceStatusReason"]) {
        self.response.resourceStatusReason = self.currentText;
        return;
    }
	if ([elementName isEqualToString:@"ResourceType"]) {
        self.response.resourceType = self.currentText;
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
	if ([elementName isEqualToString:@"Timestamp"]) {
        self.response.timestamp = [AmazonSDKUtil convertStringToDate:self.currentText];;
        return;
    }
    
    if ([elementName isEqualToString:@"StackResource"]) {
        if (caller != nil) {
            [parser setDelegate:caller];
        }
        
        if (parentObject != nil && [parentObject respondsToSelector:parentSetter]) {
            [parentObject performSelector:parentSetter withObject:self.response];
        }
        
        return;
    }
}

-(CloudFormationStackResource *)response
{
    if (nil == response) {
        response = [[CloudFormationStackResource alloc] init];
    }
    return response;
}

-(void)dealloc
{
	[response release];
    [super dealloc];
}

@end