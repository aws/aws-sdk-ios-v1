//
//  ScoreModel.m
//  baviera
//
//  Created by Ricardo Ruiz on 16/08/11.
//  Copyright 2011 Protecmobile. All rights reserved.
//

#import "ScoreModel.h"
#import "AmazonWebServices.h"
#import "constants.h"
#import "NSString+SHA1.h"
#import "Util.h"
#import "Score.h"
#import "PrivateRanking.h"
#import "AmazonSimpleDBClient.h"

@implementation ScoreModel

@synthesize delegate=_delegate;
@synthesize publicHighScores=_publicHighScores;
@synthesize privateHighScores=_privateHighScores;
@synthesize privateRankings=_privateRankings;

#define kGetPublicHighScoresRequest 1
#define kGetPrivateHighScoresRequest 2
#define kSetScoreRequest 3
#define kCreatePrivateRankingRequest 4
#define kGetPrivateRankingsRequest 5

-(id) init {
	self = [super init];
    if(self){	
        _publicHighScores=[[NSMutableArray alloc] init];
        _privateHighScores=[[NSMutableArray alloc] init];
        _privateRankings=[[NSMutableArray alloc] init];
    }
    return self;
}

/*!
 Token will be not take into account, so there is a limit close 100 scores.
 */
-(void) getPublicHighScoresForGameType:(NSUInteger)gameType {
    if (_delegate==nil) {
		NSLog(@"ScoreModel delegate is nil. Request will be not send.");
		return;
	}
	if (_getPublicHighScoresRequest!=nil) {
		NSLog(@"There is already a request ongoing.");
		if ([_delegate respondsToSelector:@selector(getPublicHighScoresRequestFailedWithReason:)]) {
			[_delegate getPublicHighScoresRequestFailedWithReason:@"There is already a request ongoing."];
		}
		return;
	} 

    NSString* gameTypeString=[NSString stringWithFormat:@"%u", gameType];
    NSString* selectExpression=nil;
    if (gameType==4 || gameType==1) {
        selectExpression = [NSString stringWithFormat:@"select * from `%@` where game_type='%@' and time is not null order by time desc limit %d", kSimpleDBDomainScores, gameTypeString, kMaxScoresShownAtOnce];
    
    } else { // gameType 2
        selectExpression = [NSString stringWithFormat:@"select * from `%@` where game_type='%@' and points is not null order by points desc limit %d", kSimpleDBDomainScores, gameTypeString, kMaxScoresShownAtOnce];
    }
    // NSLog(@"%@", selectExpression);
    
    _getPublicHighScoresRequest=[[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpression andConsistentRead:YES];
    [_getPublicHighScoresRequest setDelegate:self];
    _getPublicHighScoresRequest.requestTag=kGetPublicHighScoresRequest;
    [[[AmazonWebServices sharedAmazonWebServices] sdb] select:_getPublicHighScoresRequest];
}

/*!
 Token will be not take into account, so there is a limit close 100 scores.
 */
-(void) getPrivateHighScoresForGameType:(NSUInteger)gameType PrivateRankingName:(NSString*)privateRankingName {
    
    if (_delegate==nil) {
		NSLog(@"ScoreModel delegate is nil. Request will be not send.");
		return;
	}
	if (_getPrivateHighScoresRequest!=nil) {
		NSLog(@"There is already a request ongoing.");
		if ([_delegate respondsToSelector:@selector(getPrivateHighScoresRequestFailedWithReason:)]) {
			[_delegate getPrivateHighScoresRequestFailedWithReason:@"There is already a request ongoing."];
		}
		return;
	} 
    if (privateRankingName==nil || privateRankingName.length==0) {
        NSLog(@"Invalid Private Ranking Id.");
		if ([_delegate respondsToSelector:@selector(getPrivateHighScoresRequestFailedWithReason:)]) {
			[_delegate getPrivateHighScoresRequestFailedWithReason:@"Invalid Private Ranking Id."];
		}
		return;
    }
    
    NSString* gameTypeString=[NSString stringWithFormat:@"%u", gameType];
    NSString* selectExpression=nil;
    if (gameType==4 || gameType==1) {
        selectExpression = [NSString stringWithFormat:@"select * from `%@` where game_type='%@' and private_ranking_name='%@' and time is not null order by time desc limit %d", kSimpleDBDomainScores, gameTypeString, privateRankingName, kMaxScoresShownAtOnce];
        
    } else { // gameType 2
        selectExpression = [NSString stringWithFormat:@"select * from `%@` where game_type='%@' and private_ranking_name='%@' and points is not null order by points desc limit %d", kSimpleDBDomainScores, gameTypeString, privateRankingName, kMaxScoresShownAtOnce];
    }
    // NSLog(@"%@", selectExpression);
    
    _getPrivateHighScoresRequest=[[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpression andConsistentRead:YES];
    [_getPrivateHighScoresRequest setDelegate:self];
    _getPrivateHighScoresRequest.requestTag=kGetPrivateHighScoresRequest;
    [[[AmazonWebServices sharedAmazonWebServices] sdb] select:_getPrivateHighScoresRequest];
}

-(void) setScoreForGameType:(NSUInteger)gameType Points:(NSInteger)points Time:(NSUInteger)time Name:(NSString*)name PrivateRankingName:(NSString*)privateRankingName {
    
    if (_delegate==nil) {
        NSLog(@"delegate is nil. Request will be not send.");
        return;
    }
    if (_setScoreRequest!=nil) {
        NSLog(@"There is already a request ongoing.");
        if ([_delegate respondsToSelector:@selector(setScoreRequestFailedWithReason:)]) {
            [_delegate setScoreRequestFailedWithReason:@"There is already a request ongoing."];
        }
        return;
    } 
    if (name==nil || name.length==0) {
        NSLog(@"Invalid input parameter.");
        if ([_delegate respondsToSelector:@selector(setScoreRequestFailedWithReason:)]) {
            [_delegate setScoreRequestFailedWithReason:@"Invalid input parameters."];
        }
        return;
    }
    if (name.length<kNameMinLenght) {
        NSString* errorString=[NSString stringWithFormat:@"Too short. Min length is %d", kNameMinLenght];
        NSLog(@"%@", errorString);
        if ([_delegate respondsToSelector:@selector(setScoreRequestFailedWithReason:)]) {
            [_delegate setScoreRequestFailedWithReason:errorString];
        }
        return;
    }
    if (name.length>kNameMaxLenght) {
        NSString* errorString=[NSString stringWithFormat:@"Too long. Max length is %d", kNameMaxLenght];
        NSLog(@"%@", errorString);
        if ([_delegate respondsToSelector:@selector(setScoreRequestFailedWithReason:)]) {
            [_delegate setScoreRequestFailedWithReason:errorString];
        }
        return;
    }
    
    // itemName (score_id): hash among ... and random number arc4random()
    NSString* deviceTimestamp=[Util getISO8601StringFromLocalNSDate:[NSDate date]];
    NSString* notProcessedItemName=[NSString stringWithFormat:@"%@%d%u%u%@%@%u", name, points, time, gameType, privateRankingName, deviceTimestamp, arc4random()];
    NSString* itemName=[notProcessedItemName sha1];
    //NSLog(@"%@", itemName);
    
    // create request
    _setScoreRequest = [[SimpleDBPutAttributesRequest alloc] init];
    [_setScoreRequest setDelegate:self];
    _setScoreRequest.requestTag=kSetScoreRequest;
    [_setScoreRequest setDomainName:kSimpleDBDomainScores];
    [_setScoreRequest setItemName:itemName];
    
    // name
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"name" andValue:name andReplace:true];
        [_setScoreRequest addAttribute:attribute];
        [attribute release];
    }
    
    // points
    {
        NSString* simpleDBPoints=[Util convertPointsToSimpleDBPoints:points];
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"points" andValue:simpleDBPoints andReplace:true];
        [_setScoreRequest addAttribute:attribute];
        [attribute release];
    }
    
    // time
    {
        NSString* simpleDBTime=[Util convertTimeToSimpleDBTime:time];
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"time" andValue:simpleDBTime andReplace:true];
        [_setScoreRequest addAttribute:attribute];
        [attribute release];
    }
    
    // game_type
    {
        NSString* gameTypeString=[NSString stringWithFormat:@"%u", gameType];
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"game_type" andValue:gameTypeString andReplace:true];
        [_setScoreRequest addAttribute:attribute];
        [attribute release];
    }
    
    // device timestamp
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"device_timestamp" andValue:deviceTimestamp andReplace:true];
        [_setScoreRequest addAttribute:attribute];
        [attribute release];
    }
    
    // private_ranking_name
    if (privateRankingName!=nil) {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"private_ranking_name" andValue:privateRankingName andReplace:true];
        [_setScoreRequest addAttribute:attribute];
        [attribute release];
    }
    
    // launch request
    [[[AmazonWebServices sharedAmazonWebServices] sdb] putAttributes:_setScoreRequest];
}

-(void) createPrivateRankingWithName:(NSString*)name Password:(NSString*)password {
    if (_delegate==nil) {
        NSLog(@"DummyCreatePrivateRanking delegate is nil. Request will be not send.");
        return;
    }
    if (_createPrivateRankingRequest!=nil) {
        NSLog(@"There is already a request ongoing.");
        if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestFailedWithReason:)]) {
            [_delegate createPrivateRankingRequestFailedWithReason:@"There is already a request ongoing."];
        }
        return;
    } 
    if (name==nil || name.length==0 || password==nil || password.length==0) {
        NSLog(@"Invalid input parameter.");
        if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestFailedWithReason:)]) {
            [_delegate createPrivateRankingRequestFailedWithReason:@"Invalid input parameters."];
        }
        return;
    }
    if (name.length<kNameMinLenght) {
        NSString* errorString=[NSString stringWithFormat:@"Too short. Min length is %d", kNameMinLenght];
        NSLog(@"%@", errorString);
        if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestFailedWithReason:)]) {
            [_delegate createPrivateRankingRequestFailedWithReason:errorString];
        }
        return;
    }
    if (name.length>kNameMaxLenght) {
        NSString* errorString=[NSString stringWithFormat:@"Too long. Max length is %d", kNameMaxLenght];
        NSLog(@"%@", errorString);
        if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestFailedWithReason:)]) {
            [_delegate createPrivateRankingRequestFailedWithReason:errorString];
        }
        return;
    }
    
    NSString* deviceTimestamp=[Util getISO8601StringFromLocalNSDate:[NSDate date]];
    
    // create request
    _createPrivateRankingRequest = [[SimpleDBPutAttributesRequest alloc] init];
    [_createPrivateRankingRequest setDelegate:self];
    _createPrivateRankingRequest.requestTag=kCreatePrivateRankingRequest;
    [_createPrivateRankingRequest setDomainName:kSimpleDBDomainPrivateRankings];
    [_createPrivateRankingRequest setItemName:name];
    SimpleDBUpdateCondition* condition=[[SimpleDBUpdateCondition alloc] initWithName:@"name" andValue:nil andExists:false];
    [_createPrivateRankingRequest setExpected:condition];
    [condition release];
    
    // password sha1
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"password_sha1" andValue:[password sha1] andReplace:true];
        [_createPrivateRankingRequest addAttribute:attribute];
        [attribute release];
    }
    
    // name
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"name" andValue:name andReplace:true];
        [_createPrivateRankingRequest addAttribute:attribute];
        [attribute release];
    }
    
    // device timestamp
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"device_timestamp" andValue:deviceTimestamp andReplace:true];
        [_createPrivateRankingRequest addAttribute:attribute];
        [attribute release];
    }
    
    // launch request
    [[[AmazonWebServices sharedAmazonWebServices] sdb] putAttributes:_createPrivateRankingRequest];
}

/*!
 Token will be not take into account, so there is a limit close 100 scores.
 */
-(void) getPrivateRankings {
    
    if (_delegate==nil) {
		NSLog(@"DummyGetPrivateRankings delegate is nil. Request will be not send.");
		return;
	}
	if (_getPrivateRankingsRequest!=nil) {
		NSLog(@"There is already a request ongoing.");
		if ([_delegate respondsToSelector:@selector(getPrivateRankingsRequestFailedWithReason:)]) {
			[_delegate getPrivateRankingsRequestFailedWithReason:@"There is already a request ongoing."];
		}
		return;
	} 
    
    NSString* selectExpression=[NSString stringWithFormat:@"select * from `%@` where itemName() is not null order by itemName() desc", kSimpleDBDomainPrivateRankings, kMaxScoresShownAtOnce];
    // NSLog(@"%@", selectExpression);
    
    _getPrivateRankingsRequest=[[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpression andConsistentRead:YES];
    [_getPrivateRankingsRequest setDelegate:self];
    _getPrivateRankingsRequest.requestTag=kGetPrivateRankingsRequest;
    [[[AmazonWebServices sharedAmazonWebServices] sdb] select:_getPrivateRankingsRequest];
}

- (void)dealloc {
    if (_getPublicHighScoresRequest!=nil) {
        [_getPublicHighScoresRequest setDelegate:nil];
		[_getPublicHighScoresRequest.urlConnection cancel];
		[_getPublicHighScoresRequest release];
	}
    [_publicHighScores release];
    
    if (_getPrivateHighScoresRequest!=nil) {
        [_getPrivateHighScoresRequest setDelegate:nil];
        [_getPrivateHighScoresRequest.urlConnection cancel];
        [_getPrivateHighScoresRequest release];
    }
    [_privateHighScores release];
    
    if (_setScoreRequest!=nil) {
        [_setScoreRequest setDelegate:nil];
		[_setScoreRequest.urlConnection cancel];
		[_setScoreRequest release];
	}
    
    if (_createPrivateRankingRequest!=nil) {
        [_createPrivateRankingRequest setDelegate:nil];
		[_createPrivateRankingRequest.urlConnection cancel];
		[_createPrivateRankingRequest release];
	}
    
    
    if (_getPrivateRankingsRequest!=nil) {
        [_getPrivateRankingsRequest setDelegate:nil];
        [_getPrivateRankingsRequest.urlConnection cancel];
        [_getPrivateRankingsRequest release];
    }
    [_privateRankings release];

    [super dealloc];
}

# pragma mark AmazonServiceRequestDelegate
-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)aResponse
{
    @synchronized(self) {
    
        NSLog(@"didCompleteWithResponse tag=%d", request.requestTag);
        
        if (request.requestTag==kGetPublicHighScoresRequest) {
            [_getPublicHighScoresRequest release];
            _getPublicHighScoresRequest=nil;
            
            [_publicHighScores removeAllObjects];
            
            // process items
            SimpleDBSelectResponse* selectResponse=(SimpleDBSelectResponse*)aResponse;
            for (SimpleDBItem *item in selectResponse.items) {
                
                // extract item attributes
                NSString* itemName=item.name; // scoreId
                NSString* name=nil; 
                NSUInteger points=0;
                NSInteger time=0;
                NSUInteger gameType=0; 
                NSString* deviceTimestamp=nil; 
                NSString* privateRankingName=nil; 
                
                for (SimpleDBAttribute *attribute in item.attributes) {
                    if ([attribute.name isEqualToString:@"name"]) {
                        name=attribute.value;
                    } else if ([attribute.name isEqualToString:@"points"]) {
                        points=[Util convertSimpleDBPointsToPoints:attribute.value];
                    } else if ([attribute.name isEqualToString:@"time"]) {
                        time=[Util convertSimpleDBTimeToTime:attribute.value];
                    } else if ([attribute.name isEqualToString:@"game_type"]) {
                        gameType=[Util convertStringToUnsignedInteger:attribute.value];
                    } else if ([attribute.name isEqualToString:@"device_timestamp"]) {
                        deviceTimestamp=attribute.value;
                    } else if ([attribute.name isEqualToString:@"private_ranking_name"]) {
                        privateRankingName=attribute.value;
                    }
                }
                
                // test if all required attributtes were taken, otherwise ignore this picture (go to next) and write a log
                // privateRankingName can be nil
                if (name==nil || deviceTimestamp==nil) {
                    NSLog(@"An attribute is nil. Ignoring it.");
                    continue;
                }
                
                // add comment to comments
                Score* scoreInstance=[[Score alloc] initWithScoreId:itemName Name:name Points:points Time:time GameType:gameType DeviceTimestamp:deviceTimestamp PrivateRankingName:privateRankingName];
                [_publicHighScores addObject:scoreInstance];
                [scoreInstance release];
                
            }
            
            // inform delegator        
            if ([_delegate respondsToSelector:@selector(getPublicHighScoresSuccess)]) {
                [_delegate getPublicHighScoresSuccess];
            }

        } else if (request.requestTag==kGetPrivateHighScoresRequest) {
            [_getPrivateHighScoresRequest release];
            _getPrivateHighScoresRequest=nil;
            
            [_privateHighScores removeAllObjects];
            
            // process items
            SimpleDBSelectResponse* selectResponse=(SimpleDBSelectResponse*)aResponse;
            for (SimpleDBItem *item in selectResponse.items) {
                
                // extract item attributes
                NSString* itemName=item.name; // scoreId
                NSString* name=nil; 
                NSUInteger points=0;
                NSInteger time=0;
                NSUInteger gameType=0; 
                NSString* deviceTimestamp=nil; 
                NSString* privateRankingName=nil; 
                
                for (SimpleDBAttribute *attribute in item.attributes) {
                    if ([attribute.name isEqualToString:@"name"]) {
                        name=attribute.value;
                    } else if ([attribute.name isEqualToString:@"points"]) {
                        points=[Util convertSimpleDBPointsToPoints:attribute.value];
                    } else if ([attribute.name isEqualToString:@"time"]) {
                        time=[Util convertSimpleDBTimeToTime:attribute.value];
                    } else if ([attribute.name isEqualToString:@"game_type"]) {
                        gameType=[Util convertStringToUnsignedInteger:attribute.value];
                    } else if ([attribute.name isEqualToString:@"device_timestamp"]) {
                        deviceTimestamp=attribute.value;
                    } else if ([attribute.name isEqualToString:@"private_ranking_name"]) {
                        privateRankingName=attribute.value;
                    }
                }
                
                // test if all required attributtes were taken, otherwise ignore this picture (go to next) and write a log
                // privateRankingName can be nil
                if (name==nil || deviceTimestamp==nil) {
                    NSLog(@"An attribute is nil. Ignoring it.");
                    continue;
                }
                
                // add it
                Score* scoreInstance=[[Score alloc] initWithScoreId:itemName Name:name Points:points Time:time GameType:gameType DeviceTimestamp:deviceTimestamp PrivateRankingName:privateRankingName];
                [_privateHighScores addObject:scoreInstance];
                [scoreInstance release];
            }
            
            // inform delegator        
            if ([_delegate respondsToSelector:@selector(getPrivateHighScoresSuccess)]) {
                [_delegate getPrivateHighScoresSuccess];
            }

        } else if (request.requestTag==kSetScoreRequest) {
            [_createPrivateRankingRequest release];
            _createPrivateRankingRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(setScoreRequestSuccess)]) {
                [_delegate setScoreRequestSuccess];
            }
            
        } else if (request.requestTag==kCreatePrivateRankingRequest) {
            [_createPrivateRankingRequest release];
            _createPrivateRankingRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestSuccess)]) {
                [_delegate createPrivateRankingRequestSuccess];
            }
            
        } else if (request.requestTag==kGetPrivateRankingsRequest) {
            [_getPrivateRankingsRequest release];
            _getPrivateRankingsRequest=nil;
            
            [_privateRankings removeAllObjects];
            
            // process items
            SimpleDBSelectResponse* selectResponse=(SimpleDBSelectResponse*)aResponse;
            for (SimpleDBItem *item in selectResponse.items) {
                
                // extract item attributes
                NSString* privateRankingName=item.name; 
                NSString* passwordSha1=nil; 
                NSString* deviceTimestamp=nil; 
                
                for (SimpleDBAttribute *attribute in item.attributes) {
                    if ([attribute.name isEqualToString:@"password_sha1"]) {
                        passwordSha1=attribute.value;
                    } else if ([attribute.name isEqualToString:@"device_timestamp"]) {
                        deviceTimestamp=attribute.value;
                    }
                }
                
                // test if all required attributtes were taken, otherwise ignore this picture (go to next) and write a log
                // privateRankingName can be nil
                if (passwordSha1==nil || deviceTimestamp==nil) {
                    NSLog(@"An attribute is nil. Ignoring it.");
                    continue;
                }
                
                // add it
                PrivateRanking* privateRanking=[[PrivateRanking alloc] initWithName:privateRankingName PasswordSha1:passwordSha1 DeviceTimestamp:deviceTimestamp];
                [_privateRankings addObject:privateRanking];
                [privateRanking release];
            }
            
            // inform delegator        
            if ([_delegate respondsToSelector:@selector(getPrivateRankingsSuccess)]) {
                [_delegate getPrivateRankingsSuccess];
            }
                        
        } else {
            NSLog(@"Unknown request.");
        }
    }	
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
{
    @synchronized(self) {
        NSLog(@"request:didFailWithError: %@. tag=%d", [theError localizedDescription], request.requestTag);
        
        if (request.requestTag==kGetPublicHighScoresRequest) {
            [_getPublicHighScoresRequest release];
            _getPublicHighScoresRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(getPublicHighScoresRequestFailedWithReason:)]) {
                [_delegate getPublicHighScoresRequestFailedWithReason:[theError localizedDescription]];
            }
            
        } else if (request.requestTag==kGetPrivateHighScoresRequest) {
            [_getPrivateHighScoresRequest release];
            _getPrivateHighScoresRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(getPrivateHighScoresRequestFailedWithReason:)]) {
                [_delegate getPrivateHighScoresRequestFailedWithReason:[theError localizedDescription]];
            }
            
        } else if (request.requestTag==kSetScoreRequest) {
            [_setScoreRequest release];
            _setScoreRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(setScoreRequestFailedWithReason:)]) {
                [_delegate setScoreRequestFailedWithReason:[theError localizedDescription]];
            }
            
        } else if (request.requestTag==kCreatePrivateRankingRequest) {
            [_createPrivateRankingRequest release];
            _createPrivateRankingRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestFailedWithReason:)]) {
                [_delegate createPrivateRankingRequestFailedWithReason:[theError localizedDescription]];
            }
            
        } else if (request.requestTag==kGetPrivateRankingsRequest) {
            [_getPrivateRankingsRequest release];
            _getPrivateRankingsRequest=nil;
            if ([_delegate respondsToSelector:@selector(getPrivateRankingsRequestFailedWithReason:)]) {
                [_delegate getPrivateRankingsRequestFailedWithReason:[theError localizedDescription]];
            }
            
        } else {
            NSLog(@"Unknown request.");
        }
    }
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)theException
{
    @synchronized(self) {
        
        NSString* error=[NSString stringWithFormat:@"There was an error in the Amazon Web Services. %@", theException];
        NSLog(@"didFailWithServiceException %@. tag=%d", error, request.requestTag);
        
        if (request.requestTag==kGetPublicHighScoresRequest) {
            [_getPublicHighScoresRequest release];
            _getPublicHighScoresRequest=nil;

            if ([_delegate respondsToSelector:@selector(getPublicHighScoresRequestFailedWithReason:)]) {
                [_delegate getPublicHighScoresRequestFailedWithReason:error];
            }
            
        } else if (request.requestTag==kGetPrivateHighScoresRequest) {
            [_getPrivateHighScoresRequest release];
            _getPrivateHighScoresRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(getPrivateHighScoresRequestFailedWithReason:)]) {
                [_delegate getPrivateHighScoresRequestFailedWithReason:error];
            }
            
        } else if (request.requestTag==kSetScoreRequest) {
            [_setScoreRequest release];
            _setScoreRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(setScoreRequestFailedWithReason:)]) {
                [_delegate setScoreRequestFailedWithReason:error];
            }
            
        } else if (request.requestTag==kCreatePrivateRankingRequest) {
            NSString* error=nil;
            AmazonServiceException* amazonServiceException=(AmazonServiceException*)theException;
            if ([amazonServiceException.errorCode isEqualToString:@"ConditionalCheckFailed"]) {
                error=@"ConditionalCheckFailed";            
            } else {
                error=[NSString stringWithFormat:@"There was an error in the Amazon Web Services. %@", theException];
            }
            //NSLog(@"%@", error);
            
            [_createPrivateRankingRequest release];
            _createPrivateRankingRequest=nil;
            
            if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestFailedWithReason:)]) {
                [_delegate createPrivateRankingRequestFailedWithReason:error];
            }
            
        } else if (request.requestTag==kGetPrivateRankingsRequest) {
            [_getPrivateRankingsRequest release];
            _getPrivateRankingsRequest=nil;
            if ([_delegate respondsToSelector:@selector(getPrivateRankingsRequestFailedWithReason:)]) {
                [_delegate getPrivateRankingsRequestFailedWithReason:error];
            }
            
        } else {
            NSLog(@"Unknown request.");
        }
    }
}

@end

