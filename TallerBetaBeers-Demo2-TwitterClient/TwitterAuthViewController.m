//
//  TwitterAuthViewController.m
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 11/09/11.
//

#import "TwitterAuthViewController.h"

#import <QuartzCore/QuartzCore.h>

#pragma mark - Private Methods
@interface TwitterAuthViewController ()
- (void)setUpView;
- (void)startTwitterLoginProcess;
- (void)presentTwitterWebLoginWithRequestToken:(OAToken *)requestToken;
- (void)errorDuringTwitterLoginProccess;
@end

@implementation TwitterAuthViewController

- (id)init {
    if ((self = [super init])) {
        self.title = @"Login";
    }
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    spinnerView.layer.cornerRadius = 5.0;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self setUpView];
}

#pragma mark - Aux

- (void)setUpView {
    if (![[TwitterAuthManager sharedAuthManager] isTwitterAuthDataPresent]) {
        spinnerView.hidden = NO;
        loggedView.hidden = YES;
        [TwitterAuthManager sharedAuthManager].delegate = self;
        [self startTwitterLoginProcess];
    } else {
        spinnerView.hidden = YES;
        loggedView.hidden = NO;
    }
}

- (void)startTwitterLoginProcess {
    [[TwitterAuthManager sharedAuthManager] fetchTwitterRequestToken];   
}

- (void)fetchTwitterRequestTokenFinishedWithToken:(OAToken *)token {
    if (token) {
        [self presentTwitterWebLoginWithRequestToken:token];
    } else {
        [self errorDuringTwitterLoginProccess];
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (void)presentTwitterWebLoginWithRequestToken:(OAToken *)requestToken {
    UIViewController *webViewController = [[UIViewController alloc] init];
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.frame];
    webView.delegate = self;    
    [webView loadRequest:[NSURLRequest requestWithURL:[TwitterAuthManager twitterAuthURLWithRequestToken:requestToken]]];
    
    webViewController.view = webView;
    [webView release];
    
    [self presentModalViewController:webViewController animated:NO];
    
    [webViewController release];
}

- (void)twitterAuthFinishedWithSuccess:(BOOL)success {
    if (success) {
        spinnerView.hidden = YES;
    } else {
        [self errorDuringTwitterLoginProccess];
    }
    
    [self dismissModalViewControllerAnimated:YES];
}

- (void)errorDuringTwitterLoginProccess {
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ha ocurrido un error durante el proceso de inicio de sesión. Inténtalo de nuevo" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [errorAlertView show];
    [errorAlertView release];    
}

#pragma mark - Twitter Web Login Delegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code != -999) { // Ugly fix for weird error happening while trying to load the twitter login page!
        [self dismissModalViewControllerAnimated:YES];
        [self errorDuringTwitterLoginProccess];   
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {    
    if ([TwitterAuthManager urlIsCallbackURL:request.URL]) {
        [webView stopLoading];
        
        [[TwitterAuthManager sharedAuthManager] exchangeTwitterRequestTokenWithCallbackURL:request.URL];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Actions

- (IBAction)deleteLoginInfo {
    [[TwitterAuthManager sharedAuthManager] deleteStoredTwitterAuthToken];
    
    [self setUpView];
}

#pragma mark - Memory Management

- (void)viewDidUnload {    
    [spinnerView release];
    spinnerView = nil;
    [loggedView release];
    loggedView = nil;
    
    [super viewDidUnload];    
}

- (void)dealloc {
    [TwitterAuthManager sharedAuthManager].delegate = nil;    
    [spinnerView release];
    [loggedView release];
    
    [super dealloc];
}

@end