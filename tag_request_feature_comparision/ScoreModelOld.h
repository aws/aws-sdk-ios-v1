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
@class DummyGetPublicHighScores;
@class DummyGetPrivateHighScores;
@class DummySetScore;
@class DummyCreatePrivateRanking;
@class DummyGetPrivateRankings;

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

@interface ScoreModelOld : NSObject {
    id <ScoreModelProtocol> _delegate;
    DummyGetPublicHighScores* _dummyGetPublicHighScores;
    DummyGetPrivateHighScores* _dummyGetPrivateHighScores;
	DummySetScore* _dummySetScore;
    DummyCreatePrivateRanking* _dummyCreatePrivateRanking;
    DummyGetPrivateRankings* _dummyGetPrivateRankings;
}
@property (nonatomic,assign) id<ScoreModelProtocol> delegate;
@property (nonatomic, readonly) NSMutableArray* publicHighScores;
@property (nonatomic, readonly) NSMutableArray* privateHighScores;
@property (nonatomic, readonly) NSMutableArray* privateRankings;
-(void) getPublicHighScoresForGameType:(NSUInteger)gameType;
-(void) setScoreForGameType:(NSUInteger)gameType Points:(NSInteger)points Time:(NSUInteger)time Name:(NSString*)name PrivateRankingName:(NSString*)privateRankingName;
-(void) getPrivateHighScoresForGameType:(NSUInteger)gameType PrivateRankingName:(NSString*)privateRankingName;
-(void) createPrivateRankingWithName:(NSString*)name Password:(NSString*)password;
-(void) getPrivateRankings;
@end


/*!
 DummyGetPublicHighScores
 */
@interface DummyGetPublicHighScores : NSObject <AmazonServiceRequestDelegate> {
	id <ScoreModelProtocol> _delegate;
    SimpleDBSelectRequest* _selectRequest;
    NSMutableArray* _publicHighScores;
}
@property (nonatomic,assign) id <ScoreModelProtocol> delegate;
@property (nonatomic, readonly) NSMutableArray* publicHighScores;
-(void) getPublicHighScoresForGameType:(NSUInteger)gameType;
@end

/*!
 DummySetScore
 */
@interface DummySetScore : NSObject <AmazonServiceRequestDelegate> {
	id <ScoreModelProtocol> _delegate;
	SimpleDBPutAttributesRequest* _requestPutAttributes;
}
@property (nonatomic,assign) id <ScoreModelProtocol> delegate;
-(void) setScoreForGameType:(NSUInteger)gameType Points:(NSInteger)points Time:(NSUInteger)time Name:(NSString*)name PrivateRankingName:(NSString*)privateRankingName;
@end


/*!
 DummyGetPrivateHighScores
 */
@interface DummyGetPrivateHighScores : NSObject <AmazonServiceRequestDelegate> {
	id <ScoreModelProtocol> _delegate;
    SimpleDBSelectRequest* _selectRequest;
    NSMutableArray* _privateHighScores;
}
@property (nonatomic,assign) id <ScoreModelProtocol> delegate;
@property (nonatomic, readonly) NSMutableArray* privateHighScores;
-(void) getPrivateHighScoresForGameType:(NSUInteger)gameType PrivateRankingName:(NSString*)privateRankingName;
@end


/*!
 DummyGetPrivateRankings
 */
@interface DummyGetPrivateRankings : NSObject <AmazonServiceRequestDelegate> {
	id <ScoreModelProtocol> _delegate;
    SimpleDBSelectRequest* _selectRequest;
    NSMutableArray* _privateRankings;
}
@property (nonatomic,assign) id <ScoreModelProtocol> delegate;
@property (nonatomic, readonly) NSMutableArray* privateRankings;
-(void) getPrivateRankings;
@end

/*!
 DummyCreatePrivateRanking
 */
@interface DummyCreatePrivateRanking : NSObject <AmazonServiceRequestDelegate> {
	id <ScoreModelProtocol> _delegate;
	SimpleDBPutAttributesRequest* _requestPutAttributes;
}
@property (nonatomic,assign) id <ScoreModelProtocol> delegate;
-(void) createPrivateRankingWithName:(NSString*)name Password:(NSString*)password;
@end


