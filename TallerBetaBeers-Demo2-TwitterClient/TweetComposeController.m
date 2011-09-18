//
//  TweetComposeController.m
//  TallerBetaBeers-Demo2-TwitterClient
//
//  Created by Javier Soto on 11/09/11.
//

#import "TweetComposeController.h"
#import "TwitterAuthManager.h"

@interface TweetComposeController ()
@property (nonatomic, assign) TwitterRequestManager *requestManager;
@end

@implementation TweetComposeController

@synthesize requestManager;

- (id)init {
    if ((self = [super init])) {
        self.title = @"Twitear";
        requestManager = [[TwitterRequestManager alloc] initWithDelegate:self];;
    }
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    sendTweetButton.enabled = [[TwitterAuthManager sharedAuthManager] isTwitterAuthDataPresent];
}

#pragma mark - TextViewDelegate Methods

- (void)textViewDidChange:(UITextView *)textView {
    NSInteger totalCharacters = textView.text.length;
    NSInteger remainingCharacters = 140 - totalCharacters;
    
    tweetRemainingCharsLabel.text = [NSString stringWithFormat:@"%d", remainingCharacters];
    
    tweetRemainingCharsLabel.textColor = remainingCharacters >= 0 ? [UIColor blackColor] : [UIColor redColor];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [textView resignFirstResponder];
}

#pragma mark - Actions

- (void)setInterfaceForEditingEnabled:(BOOL)editingEnabled {
    tweetTextField.userInteractionEnabled = editingEnabled;
    [UIApplication sharedApplication].networkActivityIndicatorVisible = !editingEnabled;   
}

- (IBAction)sendTweet {
    [requestManager sendTweetWithText:tweetTextField.text];    
    
    [self setInterfaceForEditingEnabled:NO];
}

#pragma mark - Callbacks

- (void)tweetSendingRequest:(OAMutableURLRequest *)request didFinishWithData:(NSData *)data {
    tweetTextField.text = @"";
    [self textViewDidChange:tweetTextField];
    [self setInterfaceForEditingEnabled:YES];
}

- (void)tweetSendingRequest:(OAMutableURLRequest *)request didFailWithError:(NSError *)error {
    // Something went wrong
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Ha ocurrido un error al enviar el tweet" delegate:nil cancelButtonTitle:@"Aceptar" otherButtonTitles: nil];
    [errorAlertView show];
    [errorAlertView release];
    
    [self setInterfaceForEditingEnabled:YES];
}

#pragma mark - Memory Management

- (void)viewDidUnload {    
    [tweetTextField release];
    tweetTextField = nil;
    [tweetRemainingCharsLabel release];
    tweetRemainingCharsLabel = nil;
    [sendTweetButton release];
    sendTweetButton = nil;
    
    [super viewDidUnload];    
}

- (void)dealloc {    
    requestManager.delegate = nil;
    [requestManager release];
    [tweetTextField release];
    [tweetRemainingCharsLabel release];
    [sendTweetButton release];
    
    [super dealloc];
}

@end