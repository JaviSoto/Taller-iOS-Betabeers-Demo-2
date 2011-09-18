//
//  TwitterRequestManager.h
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 11/09/11.
//

#import <Foundation/Foundation.h>

@class OAMutableURLRequest;

@protocol TwitterRequestManagerDelegate
@optional
- (void)tweetSendingRequest:(OAMutableURLRequest *)request didFinishWithData:(NSData *)data;
- (void)tweetSendingRequest:(OAMutableURLRequest *)request didFailWithError:(NSError *)error;

- (void)getUserTimeline:(OAMutableURLRequest *)request didFinishWithData:(NSData *)data;
- (void)getUserTimeline:(OAMutableURLRequest *)request didFailWithError:(NSError *)error;
@end

@interface TwitterRequestManager : NSObject {
    id <TwitterRequestManagerDelegate> delegate;  
}

@property (nonatomic, assign) id<TwitterRequestManagerDelegate> delegate;

- (id)initWithDelegate:(id<TwitterRequestManagerDelegate>)delegate;

- (void)sendTweetWithText:(NSString *)text;
- (void)getUserTimeline;

@end
