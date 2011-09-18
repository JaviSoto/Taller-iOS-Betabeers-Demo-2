//
//  TwitterAuthManager.h
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 11/09/11.
//

#import <Foundation/Foundation.h>

#define kTwitterConsumerKey @"bWXaruQb17QFTHmg6SERA"
#define kTwitterConsumerSecret @"wgUfpSAbREEq3wbXm4qL4jun6WsnXbRXPisNZ1Za4"

@class OAToken;

@protocol TwitterAuthManagerDelegate
@optional
- (void)fetchTwitterRequestTokenFinishedWithToken:(OAToken *)token;
- (void)twitterAuthFinishedWithSuccess:(BOOL)success;
@end

@interface TwitterAuthManager : NSObject {
    id delegate;
    
    OAToken *requestToken;
}

@property (nonatomic, assign) id delegate;

@property (nonatomic, retain) OAToken *requestToken;

#pragma mark - Singleton
+ (TwitterAuthManager *)sharedAuthManager;

- (BOOL)isTwitterAuthDataPresent;
- (OAToken *)storedTwitterAuthToken;
- (void)deleteStoredTwitterAuthToken;

#pragma mark - Request Methods
- (void)fetchTwitterRequestToken;
- (void)exchangeTwitterRequestTokenWithCallbackURL:(NSURL *)callbackURL;

#pragma mark - Aux
+ (NSURL *)twitterAuthURLWithRequestToken:(OAToken *)token;
+ (BOOL)urlIsCallbackURL:(NSURL *)url;

@end
