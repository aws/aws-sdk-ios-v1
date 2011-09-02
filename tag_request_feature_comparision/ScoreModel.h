//
//  ScoreModel.h
//  baviera
//
//  Created by Ricardo Ruiz on 16/08/11.
//  Copyright 2011 Protecmobile. All rights reserved.
//

#import "AmazonServiceRequest.h"
@class Score;
@class SimpleDBPutAttributesRequest;
@class SimpleDBSelectRequest;

@protocol ScoreModelProtocol <NSObject>
@optional
-(void) getPublicHighScoresSuccess;
-(void) getPublicHighScoresRequestFailedWithReason:(NSString*)reason;

-(void) getPrivateHighScoresSuccess;
-(void) getPrivateHighScoresRequestFailedWithReason:(NSString*)reason;

-(void) setScoreRequestSuccess;
-(void) setScoreRequestFailedWithReason:(NSString*)reason;

-(void) createPrivateRankingRequestSuccess;
-(void) createPrivateRankingRequestFailedWithReason:(NSString*)reason;

-(void) getPrivateRankingsSuccess;
-(void) getPrivateRankingsRequestFailedWithReason:(NSString*)reason;
@end

@interface ScoreModel : NSObject <AmazonServiceRequestDelegate> {
    id <ScoreModelProtocol> _delegate;
    
    SimpleDBSelectRequest* _getPublicHighScoresRequest;
    NSMutableArray* _publicHighScores;
    
    SimpleDBSelectRequest* _getPrivateHighScoresRequest;
    NSMutableArray* _privateHighScores;
    
    SimpleDBPutAttributesRequest* _setScoreRequest;

    SimpleDBPutAttributesRequest* _createPrivateRankingRequest;

    SimpleDBSelectRequest* _getPrivateRankingsRequest;
    NSMutableArray* _privateRankings;
}
@property (nonatomic,assign) id<ScoreModelProtocol> delegate;
@property (nonatomic, readonly) NSMutableArray* publicHighScores;
@property (nonatomic, readonly) NSMutableArray* privateHighScores;
@property (nonatomic, readonly) NSMutableArray* privateRankings;
-(void) getPublicHighScoresForGameType:(NSUInteger)gameType;
-(void) getPrivateHighScoresForGameType:(NSUInteger)gameType PrivateRankingName:(NSString*)privateRankingName;
-(void) setScoreForGameType:(NSUInteger)gameType Points:(NSInteger)points Time:(NSUInteger)time Name:(NSString*)name PrivateRankingName:(NSString*)privateRankingName;
-(void) createPrivateRankingWithName:(NSString*)name Password:(NSString*)password;
-(void) getPrivateRankings;
@end