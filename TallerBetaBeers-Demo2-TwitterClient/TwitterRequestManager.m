//
//  TwitterRequestManager.m
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 11/09/11
//

#import "TwitterRequestManager.h"
#import "TwitterAuthManager.h"

#import "JSONKit.h"

#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OAToken.h"

// Docs: https://dev.twitter.com/docs/api
#define kTwitterMethodURLPrefix @"http://api.twitter.com/1/"

@implementation TwitterRequestManager

@synthesize delegate;

// Designated initializor
- (id)initWithDelegate:(id<TwitterRequestManagerDelegate>)_delegate {
    if ((self = [super init])) {
        self.delegate = _delegate;
    }
    
    return self;
}

#pragma mark - Private methods

- (void)startRequestWithURL:(NSString *)methodURL method:(NSString *)method params:(NSDictionary *)params finishSelector:(SEL)successCallback errorSelector:(SEL)errorCallback {
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", kTwitterMethodURLPrefix, methodURL]];
                  
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:kTwitterConsumerKey secret:kTwitterConsumerSecret] autorelease];
	
    OAToken *token = [[TwitterAuthManager sharedAuthManager] storedTwitterAuthToken];
    
    if (!token) {
        [NSException raise:NSInternalInconsistencyException format:@"Tried to send a twitter request without a valid token"];
    }
    
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:URL
																	consumer:consumer
																	   token:token
																	   realm:nil 
														   signatureProvider:nil] autorelease];
	
	[request setHTTPMethod:method];
	
    NSMutableArray *parameters = [[NSMutableArray alloc] init];
    
    for (NSString *key in params) {
        OARequestParameter *param = [[[OARequestParameter alloc] initWithName:key value:[params valueForKey:key]] autorelease];
        [parameters addObject:param];
    }
    
    request.parameters = parameters;
    [parameters release];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request 
                         delegate:delegate 
                didFinishSelector:successCallback 
                  didFailSelector:errorCallback];
    
    [fetcher release];

}

#pragma mark - Public Methods

- (void)sendTweetWithText:(NSString *)text  {
    [self startRequestWithURL:@"statuses/update.json" method:@"POST" params:[NSDictionary dictionaryWithObjectsAndKeys:text, @"status", nil] finishSelector:@selector(tweetSendingRequest:didFinishWithData:) errorSelector:@selector(tweetSendingRequest:didFailWithError:)];
}

- (void)getUserTimeline {
    [self startRequestWithURL:@"statuses/home_timeline.json" method:@"GET" params:nil finishSelector:@selector(getUserTimeline:didFinishWithData:) errorSelector:@selector(getUserTimeline:didFailWithError:)];
}
        
- (void)dealloc {
    delegate = nil;
    
    [super dealloc];
}

@end
