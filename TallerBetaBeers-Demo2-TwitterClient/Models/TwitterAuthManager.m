//
//  TwitterAuthManager.m
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 11/09/11.
//

#import "TwitterAuthManager.h"

#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"
#import "OAToken.h"

#pragma mark - Configuration Data
#define kTwitterAuthRequestTokenURL @"https://api.twitter.com/oauth/request_token"
#define kTwitterAuthAuthorizeURL @"https://api.twitter.com/oauth/authorize"
#define kTwitterAuthAccessTokenURL @"https://api.twitter.com/oauth/access_token"
#define kTwitterCallbackURL @"http://www.betabeers.com/tallerios/oauth_callback"

#define kTokenStoreName @"BetaBeersTwitterAppTokenKey"
#define kTokenStorePrefix @"BetaBeersTwitterAppTokenPrefixKey"
#pragma mark -

@implementation TwitterAuthManager

+ (TwitterAuthManager *)sharedAuthManager {
    static dispatch_once_t dispatchOncePredicate;
    static TwitterAuthManager *sharedAuthManager = nil;
    
    dispatch_once(&dispatchOncePredicate, ^{
        sharedAuthManager = [[self alloc] init];
    });
    
    return sharedAuthManager;
}

#pragma mark - Public Methods

- (BOOL)isTwitterAuthDataPresent {    
    return ([self storedTwitterAuthToken] != nil);
}

- (OAToken *)storedTwitterAuthToken {
    return [[[OAToken alloc] initWithUserDefaultsUsingServiceProviderName:kTokenStoreName prefix:kTokenStorePrefix] autorelease];
}

- (void)deleteStoredTwitterAuthToken {
    [OAToken removeFromUserDefaultsWithServiceProviderName:kTokenStoreName prefix:kTokenStorePrefix];
}

+ (NSURL *)twitterAuthURLWithRequestToken:(OAToken *)token {
    return [NSURL URLWithString:[[NSString stringWithFormat:@"%@?oauth_token=%@", kTwitterAuthAuthorizeURL, token.key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
}

+ (BOOL)urlIsCallbackURL:(NSURL *)URL {
    return ([URL.absoluteString rangeOfString:kTwitterCallbackURL].location != NSNotFound);
}

#pragma mark - Private

- (void)cleanup {
    self.requestToken = nil;
}

#pragma mark - Request Methods

- (void)fetchTwitterRequestToken {
    NSURL *URL = [NSURL URLWithString:kTwitterAuthRequestTokenURL];
	OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:kTwitterConsumerKey secret:kTwitterConsumerSecret] autorelease];
	
	OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:URL
																	consumer:consumer
																	   token:nil
																	   realm:nil 
														   signatureProvider:nil] autorelease];
	
	[request setHTTPMethod:@"POST"];
	
	OARequestParameter *oauth_callback = [[[OARequestParameter alloc] initWithName:@"oauth_callback" value:kTwitterCallbackURL] autorelease];
	NSArray *params = [NSArray arrayWithObject:oauth_callback];
	[request setParameters:params];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request 
             delegate:self 
             didFinishSelector:@selector(fetchTwitterRequestToken:didFinishWithData:) 
             didFailSelector:@selector(fetchTwitterRequestToken:didFailWithError:)];
    
    [fetcher release];
}

- (void)exchangeTwitterRequestTokenWithCallbackURL:(NSURL *)callbackURL {
    NSString *urlString = callbackURL.absoluteString;
    
    NSArray *split = [urlString componentsSeparatedByString:@"&oauth_verifier="];
    if ([split count] > 1) {
        NSString *verifierString = [split objectAtIndex:1];
        
        
        NSURL *URL = [NSURL URLWithString:kTwitterAuthAccessTokenURL];
        OAConsumer *consumer = [[[OAConsumer alloc] initWithKey:kTwitterConsumerKey secret:kTwitterConsumerSecret] autorelease];
        
        OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:URL
                                                                        consumer:consumer
                                                                           token:self.requestToken
                                                                           realm:nil
                                                               signatureProvider:nil] autorelease];
        
        [request setHTTPMethod:@"POST"];
        
        OARequestParameter *oauth_verifier = [[[OARequestParameter alloc] initWithName:@"oauth_verifier" value:verifierString] autorelease];
        OARequestParameter *oauth_consumer_key = [[[OARequestParameter alloc] initWithName:@"oauth_consumer_key" value:kTwitterConsumerKey] autorelease];
        NSArray *params = [NSArray arrayWithObjects:oauth_verifier, oauth_consumer_key, nil];
        [request setParameters:params];
        
        OADataFetcher *fetcher = [[OADataFetcher alloc] init];

        [fetcher fetchDataWithRequest:request 
                 delegate:self 
                 didFinishSelector:@selector(exchangeTwitterRequestToken:didFinishWithData:) 
                 didFailSelector:@selector(exchangeTwitterRequestToken:didFailWithError:)];
        
        [fetcher release];
    } else { // Something went very wrong!
        if ([self.delegate respondsToSelector:@selector(twitterAuthFinishedWithSuccess:)]) {
            [self.delegate twitterAuthFinishedWithSuccess:NO];
        }
    }

}

#pragma mark - Request Callbacks

- (void)fetchTwitterRequestToken:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (!ticket.didSucceed) {
        if ([self.delegate respondsToSelector:@selector(fetchTwitterRequestTokenFinishedWithToken:)]) {
            [self.delegate fetchTwitterRequestTokenFinishedWithToken:nil];
        }
        return;
	}
    
	NSString *responseBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	OAToken *token = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];    
    
    self.requestToken = token;
    
    if ([self.delegate respondsToSelector:@selector(fetchTwitterRequestTokenFinishedWithToken:)]) {
        [self.delegate fetchTwitterRequestTokenFinishedWithToken:token];
    }
}

- (void)fetchTwitterRequestToken:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(fetchTwitterRequestTokenFinishedWithToken:)]) {
        [self.delegate fetchTwitterRequestTokenFinishedWithToken:nil];
    }
}

- (void)exchangeTwitterRequestToken:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
    [self cleanup];
    
	if (!ticket.didSucceed) {
        if ([self.delegate respondsToSelector:@selector(twitterAuthFinishedWithSuccess:)]) {
            [self.delegate twitterAuthFinishedWithSuccess:NO];
        }
        return;
	}
	
	NSString *responseBody = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
	OAToken *access_token = [[[OAToken alloc] initWithHTTPResponseBody:responseBody] autorelease];
    
	if (!access_token.key) {
        if ([self.delegate respondsToSelector:@selector(twitterAuthFinishedWithSuccess:)]) {
            [self.delegate twitterAuthFinishedWithSuccess:NO];
        }
	}
	else {
        if ([self.delegate respondsToSelector:@selector(twitterAuthFinishedWithSuccess:)]) {
            [self.delegate twitterAuthFinishedWithSuccess:YES];
        }
        
        [access_token storeInUserDefaultsWithServiceProviderName:kTokenStoreName prefix:kTokenStorePrefix];
	}
}

- (void)exchangeTwitterRequestToken:(OAServiceTicket *)ticket didFailWithError:(NSError *)error {
	if ([self.delegate respondsToSelector:@selector(twitterAuthFinishedWithSuccess:)]) {
        [self.delegate twitterAuthFinishedWithSuccess:NO];
    }
    
    [self cleanup];
}

#pragma mark - Synthesize

@synthesize delegate, requestToken;

#pragma mark - Singleton "hacks"
- (oneway void)release { }
- (id)autorelease { return self; }
- (id)retain { return self; }
- (NSUInteger)retainCount { return NSUIntegerMax; }
- (void)dealloc { }

@end