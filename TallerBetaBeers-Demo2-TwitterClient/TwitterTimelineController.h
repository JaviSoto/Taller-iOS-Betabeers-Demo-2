//
//  TwitterTimelineController.h
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 9/16/11.
//

#import <UIKit/UIKit.h>
#import "TwitterRequestManager.h"

@interface TwitterTimelineController : UIViewController <UITableViewDelegate, UITableViewDataSource, TwitterRequestManagerDelegate> {
    TwitterRequestManager *requestManager;
    
    NSArray *timelineData;
}

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (retain, nonatomic) NSArray *timelineData;

@end
