//
//  TweetCell.h
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 9/18/11.
//

#import <UIKit/UIKit.h>
#import "EGOImageView.h"

@interface TweetCell : UITableViewCell {
    EGOImageView *userAvatar;
    UILabel *userScreenName;
    UILabel *tweetText;        
}

@property (retain, nonatomic) IBOutlet EGOImageView *userAvatar;
@property (retain, nonatomic) IBOutlet UILabel *userScreenName;
@property (retain, nonatomic) IBOutlet UILabel *tweetText;

@end
