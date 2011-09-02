//
//  ScoreModel.m
//  baviera
//
//  Created by Ricardo Ruiz on 16/08/11.
//  Copyright 2011 Protecmobile. All rights reserved.
//

#import "ScoreModelOld.h"
#import "AmazonWebServices.h"
#import "constants.h"
#import "NSString+SHA1.h"
#import "Util.h"
#import "Score.h"
#import "PrivateRanking.h"
#import "AmazonSimpleDBClient.h"

@implementation ScoreModelOld

@synthesize delegate=_delegate;
@synthesize publicHighScores=_publicHighScores;
@synthesize privateHighScores=_privateHighScores;

-(id) init {
	self = [super init];
    if(self){	
		_dummyGetPublicHighScores=[[DummyGetPublicHighScores alloc] init];
		_dummySetScore=[[DummySetScore alloc] init];
        _dummyGetPrivateHighScores=[[DummyGetPrivateHighScores alloc] init];
        _dummyCreatePrivateRanking=[[DummyCreatePrivateRanking alloc] init];
        _dummyGetPrivateRankings=[[DummyGetPrivateRankings alloc] init];
    }
    return self;
}

-(void) setDelegate:(id<ScoreModelProtocol>)delegate {
	_dummyGetPublicHighScores.delegate=delegate;
    _dummyGetPrivateHighScores.delegate=delegate;
	_dummySetScore.delegate=delegate;
    _dummyCreatePrivateRanking.delegate=delegate;
    _dummyGetPrivateRankings.delegate=delegate;
}

-(NSMutableArray*) publicHighScores {
	return _dummyGetPublicHighScores.publicHighScores;
}

-(NSMutableArray*) privateHighScores {
	return _dummyGetPrivateHighScores.privateHighScores;
}

-(NSMutableArray*) privateRankings {
	return _dummyGetPrivateRankings.privateRankings;
}

- (void)dealloc {
	[_dummyGetPublicHighScores release];
    [_dummyGetPrivateHighScores release];
	[_dummySetScore release];
    [_dummyCreatePrivateRanking release];
    [_dummyGetPrivateRankings release];
    [super dealloc];
}

-(void) getPublicHighScoresForGameType:(NSUInteger)gameType {
    [_dummyGetPublicHighScores getPublicHighScoresForGameType:gameType];
}

-(void) setScoreForGameType:(NSUInteger)gameType Points:(NSInteger)points Time:(NSUInteger)time Name:(NSString*)name PrivateRankingName:(NSString*)privateRankingName {
    [_dummySetScore setScoreForGameType:gameType Points:points Time:time Name:name PrivateRankingName:privateRankingName];
}

-(void) getPrivateHighScoresForGameType:(NSUInteger)gameType PrivateRankingName:(NSString*)privateRankingName {
    [_dummyGetPrivateHighScores getPrivateHighScoresForGameType:gameType PrivateRankingName:privateRankingName];
}

-(void) createPrivateRankingWithName:(NSString*)name Password:(NSString*)password {    
    [_dummyCreatePrivateRanking createPrivateRankingWithName:name Password:password];
}

-(void) getPrivateRankings {
    [_dummyGetPrivateRankings getPrivateRankings];
}

@end


#pragma mark DummyGetPublicHighScores
@implementation DummyGetPublicHighScores

@synthesize delegate=_delegate;
@synthesize publicHighScores=_publicHighScores;

-(id) init {
	self = [super init];
    if(self){	
        _publicHighScores=[[NSMutableArray alloc] init];
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
	
	if (_selectRequest!=nil) {
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
    
    _selectRequest=[[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpression andConsistentRead:YES];
    [_selectRequest setDelegate:self];
    [[[AmazonWebServices sharedAmazonWebServices] sdb] select:_selectRequest];
}

- (void)dealloc {
    if (_selectRequest!=nil) {
        [_selectRequest setDelegate:nil];
        [_selectRequest.urlConnection cancel];
        [_selectRequest release];
    }
    [_publicHighScores release];
    [super dealloc];
}

# pragma mark AmazonServiceRequestDelegate
-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)aResponse
{
    @synchronized(self) {
        NSLog(@"didCompleteWithResponse");
        [_selectRequest release];
        _selectRequest=nil;
        
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
    }	
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
{
    @synchronized(self) {
        //NSLog(@"request:didFailWithError: %@", [theError localizedDescription]);
        
        [_selectRequest release];
        _selectRequest=nil;

        if ([_delegate respondsToSelector:@selector(getPublicHighScoresRequestFailedWithReason:)]) {
            [_delegate getPublicHighScoresRequestFailedWithReason:[theError localizedDescription]];
        }
    }
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)theException
{
    @synchronized(self) {
        NSString* error=[NSString stringWithFormat:@"There was an error in the Amazon Web Services. %@", theException];
        //NSLog(@"%@", error);
        
        [_selectRequest release];
        _selectRequest=nil;

        if ([_delegate respondsToSelector:@selector(getPublicHighScoresRequestFailedWithReason:)]) {
            [_delegate getPublicHighScoresRequestFailedWithReason:error];
        }
	}
}

@end


#pragma mark DummySetScore
@implementation DummySetScore

@synthesize delegate=_delegate;
 
-(void) setScoreForGameType:(NSUInteger)gameType Points:(NSInteger)points Time:(NSUInteger)time Name:(NSString*)name PrivateRankingName:(NSString*)privateRankingName {

    if (_delegate==nil) {
        NSLog(@"DummySetScore delegate is nil. Request will be not send.");
        return;
    }
    
    if (_requestPutAttributes!=nil) {
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
    _requestPutAttributes = [[SimpleDBPutAttributesRequest alloc] init];
    [_requestPutAttributes setDelegate:self];
    [_requestPutAttributes setDomainName:kSimpleDBDomainScores];
    [_requestPutAttributes setItemName:itemName];
    
    // name
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"name" andValue:name andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
    
    // points
    {
        NSString* simpleDBPoints=[Util convertPointsToSimpleDBPoints:points];
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"points" andValue:simpleDBPoints andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
        
    // time
    {
        NSString* simpleDBTime=[Util convertTimeToSimpleDBTime:time];
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"time" andValue:simpleDBTime andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
    
    // game_type
    {
        NSString* gameTypeString=[NSString stringWithFormat:@"%u", gameType];
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"game_type" andValue:gameTypeString andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
    
    // device timestamp
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"device_timestamp" andValue:deviceTimestamp andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
    
    // private_ranking_name
    if (privateRankingName!=nil) {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"private_ranking_name" andValue:privateRankingName andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
    
    // launch request
    [[[AmazonWebServices sharedAmazonWebServices] sdb] putAttributes:_requestPutAttributes];
}

- (void)dealloc {
	if (_requestPutAttributes!=nil) {
        [_requestPutAttributes setDelegate:nil];
		[_requestPutAttributes.urlConnection cancel];
		[_requestPutAttributes release];
	}
    [super dealloc];
}

# pragma mark AmazonServiceRequestDelegate
-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)aResponse
{
	@synchronized(self) {
        NSLog(@"didCompleteWithResponse");
        
        [_requestPutAttributes release];
        _requestPutAttributes=nil;
        
        if ([_delegate respondsToSelector:@selector(setScoreRequestSuccess)]) {
            [_delegate setScoreRequestSuccess];
        }
	}
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
{
	@synchronized(self) {
        //NSLog(@"request:didFailWithError: %@", [theError localizedDescription]);
        
        [_requestPutAttributes release];
        _requestPutAttributes=nil;
        
        if ([_delegate respondsToSelector:@selector(setScoreRequestFailedWithReason:)]) {
            [_delegate setScoreRequestFailedWithReason:[theError localizedDescription]];
        }
	}
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)theException
{
	@synchronized(self) {
        NSString* error=[NSString stringWithFormat:@"There was an error in the Amazon Web Services. %@", theException];
        //NSLog(@"%@", error);
        
        [_requestPutAttributes release];
        _requestPutAttributes=nil;

        if ([_delegate respondsToSelector:@selector(setScoreRequestFailedWithReason:)]) {
            [_delegate setScoreRequestFailedWithReason:error];
        }
	}
}

@end

#pragma mark DummyGetPrivateHighScores
@implementation DummyGetPrivateHighScores

@synthesize delegate=_delegate;
@synthesize privateHighScores=_privateHighScores;

-(id) init {
	self = [super init];
    if(self){	
        _privateHighScores=[[NSMutableArray alloc] init];
    }
    return self;
}

/*!
 Token will be not take into account, so there is a limit close 100 scores.
 */
-(void) getPrivateHighScoresForGameType:(NSUInteger)gameType PrivateRankingName:(NSString*)privateRankingName {

    if (_delegate==nil) {
		NSLog(@"ScoreModel delegate is nil. Request will be not send.");
		return;
	}
	
	if (_selectRequest!=nil) {
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
    
    _selectRequest=[[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpression andConsistentRead:YES];
    [_selectRequest setDelegate:self];
    [[[AmazonWebServices sharedAmazonWebServices] sdb] select:_selectRequest];
}

- (void)dealloc {
    if (_selectRequest!=nil) {
        [_selectRequest setDelegate:nil];
        [_selectRequest.urlConnection cancel];
        [_selectRequest release];
    }
    [_privateHighScores release];
    [super dealloc];
}

# pragma mark AmazonServiceRequestDelegate
-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)aResponse
{
    @synchronized(self) {
        NSLog(@"didCompleteWithResponse");
        [_selectRequest release];
        _selectRequest=nil;
        
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
    }	
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
{
    @synchronized(self) {
        //NSLog(@"request:didFailWithError: %@", [theError localizedDescription]);
        
        [_selectRequest release];
        _selectRequest=nil;
        
        if ([_delegate respondsToSelector:@selector(getPrivateHighScoresRequestFailedWithReason:)]) {
            [_delegate getPrivateHighScoresRequestFailedWithReason:[theError localizedDescription]];
        }
    }
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)theException
{
    @synchronized(self) {
        NSString* error=[NSString stringWithFormat:@"There was an error in the Amazon Web Services. %@", theException];
        //NSLog(@"%@", error);
        
        [_selectRequest release];
        _selectRequest=nil;

        if ([_delegate respondsToSelector:@selector(getPrivateHighScoresRequestFailedWithReason:)]) {
            [_delegate getPrivateHighScoresRequestFailedWithReason:error];
        }
	}
}

@end


#pragma mark DummyCreatePrivateRanking
@implementation DummyCreatePrivateRanking

@synthesize delegate=_delegate;

-(void) createPrivateRankingWithName:(NSString*)name Password:(NSString*)password {
    if (_delegate==nil) {
        NSLog(@"DummyCreatePrivateRanking delegate is nil. Request will be not send.");
        return;
    }
    
    if (_requestPutAttributes!=nil) {
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
    _requestPutAttributes = [[SimpleDBPutAttributesRequest alloc] init];
    [_requestPutAttributes setDelegate:self];
    [_requestPutAttributes setDomainName:kSimpleDBDomainPrivateRankings];
    [_requestPutAttributes setItemName:name];
    SimpleDBUpdateCondition* condition=[[SimpleDBUpdateCondition alloc] initWithName:@"name" andValue:nil andExists:false];
    [_requestPutAttributes setExpected:condition];
    [condition release];
    
    // password sha1
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"password_sha1" andValue:[password sha1] andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
    
    // name
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"name" andValue:name andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
    
    // device timestamp
    {
        SimpleDBReplaceableAttribute* attribute=[[SimpleDBReplaceableAttribute alloc] initWithName:@"device_timestamp" andValue:deviceTimestamp andReplace:true];
        [_requestPutAttributes addAttribute:attribute];
        [attribute release];
    }
    
    // launch request
    [[[AmazonWebServices sharedAmazonWebServices] sdb] putAttributes:_requestPutAttributes];
}

- (void)dealloc {
	if (_requestPutAttributes!=nil) {
        [_requestPutAttributes setDelegate:nil];
		[_requestPutAttributes.urlConnection cancel];
		[_requestPutAttributes release];
	}
    [super dealloc];
}

# pragma mark AmazonServiceRequestDelegate
-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)aResponse
{
	@synchronized(self) {
        NSLog(@"didCompleteWithResponse");
        [_requestPutAttributes release];
        _requestPutAttributes=nil;
        
        if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestSuccess)]) {
            [_delegate createPrivateRankingRequestSuccess];
        }
	}
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
{
	@synchronized(self) {
        //NSLog(@"request:didFailWithError: %@", [theError localizedDescription]);
        [_requestPutAttributes release];
        _requestPutAttributes=nil;
        
        if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestFailedWithReason:)]) {
            [_delegate createPrivateRankingRequestFailedWithReason:[theError localizedDescription]];
        }
	}
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)theException
{
	@synchronized(self) {
        NSString* error=nil;
        AmazonServiceException* amazonServiceException=(AmazonServiceException*)theException;
        if ([amazonServiceException.errorCode isEqualToString:@"ConditionalCheckFailed"]) {
            error=@"ConditionalCheckFailed";            
        } else {
            error=[NSString stringWithFormat:@"There was an error in the Amazon Web Services. %@", theException];
        }
        //NSLog(@"%@", error);
        
        [_requestPutAttributes release];
        _requestPutAttributes=nil;
        
        if ([_delegate respondsToSelector:@selector(createPrivateRankingRequestFailedWithReason:)]) {
            [_delegate createPrivateRankingRequestFailedWithReason:error];
        }
	}
}

@end


#pragma mark DummyGetPrivateRankings
@implementation DummyGetPrivateRankings

@synthesize delegate=_delegate;
@synthesize privateRankings=_privateRankings;

-(id) init {
	self = [super init];
    if(self){	
        _privateRankings=[[NSMutableArray alloc] init];
    }
    return self;
}

/*!
 Token will be not take into account, so there is a limit close 100 scores.
 */
-(void) getPrivateRankings {
    
    if (_delegate==nil) {
		NSLog(@"DummyGetPrivateRankings delegate is nil. Request will be not send.");
		return;
	}
	
	if (_selectRequest!=nil) {
		NSLog(@"There is already a request ongoing.");
		if ([_delegate respondsToSelector:@selector(getPrivateRankingsRequestFailedWithReason:)]) {
			[_delegate getPrivateRankingsRequestFailedWithReason:@"There is already a request ongoing."];
		}
		return;
	} 

    NSString* selectExpression=[NSString stringWithFormat:@"select * from `%@` where itemName() is not null order by itemName() desc", kSimpleDBDomainPrivateRankings, kMaxScoresShownAtOnce];

    // NSLog(@"%@", selectExpression);
    
    _selectRequest=[[SimpleDBSelectRequest alloc] initWithSelectExpression:selectExpression andConsistentRead:YES];
    [_selectRequest setDelegate:self];
    [[[AmazonWebServices sharedAmazonWebServices] sdb] select:_selectRequest];
}

- (void)dealloc {
    if (_selectRequest!=nil) {
        [_selectRequest setDelegate:nil];
        [_selectRequest.urlConnection cancel];
        [_selectRequest release];
    }
    [_privateRankings release];
    [super dealloc];
}

# pragma mark AmazonServiceRequestDelegate
-(void)request:(AmazonServiceRequest *)request didCompleteWithResponse:(AmazonServiceResponse *)aResponse
{
    @synchronized(self) {
        NSLog(@"didCompleteWithResponse", request);
        
        [_selectRequest release];
        _selectRequest=nil;

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
    }	
}

-(void)request:(AmazonServiceRequest *)request didFailWithError:(NSError *)theError
{
    @synchronized(self) {
        //NSLog(@"request:didFailWithError: %@", [theError localizedDescription]);
        [_selectRequest release];
        _selectRequest=nil;
        if ([_delegate respondsToSelector:@selector(getPrivateRankingsRequestFailedWithReason:)]) {
            [_delegate getPrivateRankingsRequestFailedWithReason:[theError localizedDescription]];
        }
    }
}

-(void)request:(AmazonServiceRequest *)request didFailWithServiceException:(NSException *)theException
{
    @synchronized(self) {
        NSString* error=[NSString stringWithFormat:@"There was an error in the Amazon Web Services. %@", theException];
        //NSLog(@"%@", error);
        [_selectRequest release];
        _selectRequest=nil;
        if ([_delegate respondsToSelector:@selector(getPrivateRankingsRequestFailedWithReason:)]) {
            [_delegate getPrivateRankingsRequestFailedWithReason:error];
        }
	}
}

@end

