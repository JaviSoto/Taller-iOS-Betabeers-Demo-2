//
//  TweetCell.m
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 9/18/11.
//

#import "TweetCell.h"

@implementation TweetCell
@synthesize userAvatar;
@synthesize userScreenName;
@synthesize tweetText;

- (void)dealloc {
    [userAvatar release];
    [userScreenName release];
    [tweetText release];
    [super dealloc];
}
@end
