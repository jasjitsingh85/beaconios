//
//  WebViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/26/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "WebViewController.h"
#import "NavigationBarTitleLabel.h"

@interface WebViewController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSString *title;
@end

@implementation WebViewController

@synthesize webView = _webView;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize url = _url;

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    return _webView;
}

- (id)initWithTitle:(NSString *)title andURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
        self.title = title;
        self.view = self.webView;
        NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
        [self.webView loadRequest:requestObj];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //self.view = self.webView;
    //NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
    //[self.webView loadRequest:requestObj];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:self.title];
    if ([self.title isEqualToString:@"Venmo"])
    {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [self.webView addSubview:self.loadingIndicator];
    self.loadingIndicator.center = self.webView.center;
    [self.loadingIndicator startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.loadingIndicator stopAnimating];
    [self.loadingIndicator removeFromSuperview];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if ([self.title isEqualToString:@"Venmo"]) {
        NSString *URLString = [[request URL] absoluteString];
        if (![[self.url absoluteString] containsString:URLString]) {
            [self dismissViewControllerAnimated:YES completion:^{
                NSLog(@"%d",[URLString hasPrefix:@"https://www.getbeacons.com/api/venmo_oauth"]);
                if ([URLString hasPrefix:@"https://www.getbeacons.com/api/venmo_oauth"]) {
                    NSLog(@"HAS PREFIX");
                    if ([URLString containsString:@"User+denied+your+application"]) {
                        NSLog(@"USER DENIED ACCES");
                    } else {
                        NSLog(@"USER ACCEPTED ACCESS");
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDefaultsKeyHasSkippedVenmo];
                        NSLog(@"Hide Venmo %d", [[NSUserDefaults standardUserDefaults] boolForKey:kDefaultsKeyHasSkippedVenmo]);
                    }
                    NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
                    [self.webView loadRequest:requestObj];
                    //return YES;
                } else if ([URLString hasPrefix:@"https://venmo.com/w/signup"]) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://venmo.com/w/signup?from=oauth&client_id=2565"]];
                }
            }];
            return YES;
        }
    }
    return YES;
}

@end