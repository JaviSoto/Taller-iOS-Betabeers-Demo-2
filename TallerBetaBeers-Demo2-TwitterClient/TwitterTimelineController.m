//
//  TwitterTimelineController.m
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 9/16/11.
//

#import "TwitterTimelineController.h"
#import "TweetCell.h"
#import "JSONKit.h"

@interface TwitterTimelineController ()
- (void)startLoadingTimeline;
@end

@implementation TwitterTimelineController
@synthesize tableView;
@synthesize timelineData;

- (id)init {
    if ((self = [super init])) {
        self.title = @"Timeline";
        requestManager = [[TwitterRequestManager alloc] initWithDelegate:self];
    }
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];    
    
    [self startLoadingTimeline];
}

#pragma mark - Table Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.timelineData isKindOfClass:[NSArray class]]) { // If twitter returns a JSON with an error, it comes in the form of a NSDictionary
        return [self.timelineData count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"TweetCell";
    
    TweetCell *cell = [tv dequeueReusableCellWithIdentifier:cellId];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:cellId owner:self options:nil] objectAtIndex:0];
    }
    
    NSDictionary *tweetData = [self.timelineData objectAtIndex:indexPath.row];
    
    cell.userAvatar.imageURL = [NSURL URLWithString:[[tweetData valueForKeyPath:@"user.profile_image_url"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    cell.tweetText.text = [tweetData valueForKey:@"text"];
    cell.userScreenName.text = [NSString stringWithFormat:@"@%@", [tweetData valueForKeyPath:@"user.screen_name"]];
    
    return cell;
}

#pragma mark -

- (void)setTimelineData:(NSArray *)newTimelineData {
    if (timelineData != newTimelineData) {
        [timelineData release];
        timelineData = [newTimelineData retain];
        
        [self.tableView reloadData];
    }
}

#pragma mak - Twitter request methods

- (void)startLoadingTimeline {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [requestManager getUserTimeline];
}

- (void)getUserTimeline:(OAMutableURLRequest *)request didFinishWithData:(NSData *)data {
    NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    self.timelineData = [responseString objectFromJSONString];
    
    [responseString release];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)getUserTimeline:(OAMutableURLRequest *)request didFailWithError:(NSError *)error {
    // Something went wrong
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ha ocurrido un error al cargar el timeline" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [errorAlertView show];
    [errorAlertView release];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

#pragma mark - Memory Management

- (void)viewDidUnload {
    [self setTableView:nil];
    
    [super viewDidUnload];    
}

- (void)dealloc {    
    [tableView release];
    [requestManager release];
    [timelineData release];
    
    [super dealloc];
}

@end