//
//  TwitterAuthViewController.h
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 11/09/11.
//

#import <UIKit/UIKit.h>

#import "TwitterAuthManager.h"

@interface TwitterAuthViewController : UIViewController <TwitterAuthManagerDelegate, UIWebViewDelegate> {
    
    IBOutlet UIView *spinnerView;
    IBOutlet UIView *loggedView;
}

- (IBAction)deleteLoginInfo;

@end
