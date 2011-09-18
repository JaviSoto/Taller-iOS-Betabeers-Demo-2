//
//  TweetComposeController.h
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 11/09/11.
//

#import <UIKit/UIKit.h>
#import "TwitterRequestManager.h"

@interface TweetComposeController : UIViewController <TwitterRequestManagerDelegate, UITextViewDelegate> {
    
    IBOutlet UITextView *tweetTextField;
    IBOutlet UILabel *tweetRemainingCharsLabel;
    IBOutlet UIButton *sendTweetButton;
}

- (IBAction)sendTweet;

@end
