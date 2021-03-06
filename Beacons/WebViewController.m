//
//  WebViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/26/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "WebViewController.h"
#import "NavigationBarTitleLabel.h"
#import "LoadingIndictor.h"

@interface WebViewController ()

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) UIActivityIndicatorView *loadingIndicator;
//@property (nonatomic, strong) NSURL *websiteUrl;
//@property (nonatomic, strong) NSString *title;
@end

@implementation WebViewController

@synthesize webView = _webView;
@synthesize loadingIndicator = _loadingIndicator;
@synthesize websiteUrl = _websiteUrl;

- (UIWebView *)webView
{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.delegate = self;
    }
    return _webView;
}

//- (id)initWithTitle:(NSString *)title andURL:(NSURL *)url
//{
//    self = [super init];
//    if (self) {
////        self.url = url;
//        self.title = title;
////        self.view = self.webView;
////        NSURLRequest *requestObj = [NSURLRequest requestWithURL:self.url];
////        [self.webView loadRequest:requestObj];
//    }
//    return self;
//}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
}

-(void)setWebsiteUrl:(NSURL *)websiteUrl
{
    _websiteUrl = websiteUrl;
    
    //[self.loadingIndicator startAnimating];
    self.view = self.webView;
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:websiteUrl];
    [self.webView loadRequest:requestObj];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(dismissModalViewControllerAnimated:)];
    
    UIButton *dismissButton = [[UIButton alloc] init];
    dismissButton.size = CGSizeMake(25, 25);
    //dismissButton.backgroundColor = [UIColor blackColor];
    //dismissButton.x = -50;
    [dismissButton setImage:[UIImage imageNamed:@"largeCrossout"] forState:UIControlStateNormal];
    [dismissButton addTarget:self action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:dismissButton];
    
    UIButton *shareButton = [[UIButton alloc] init];
    shareButton.size = CGSizeMake(45, 40);
    [shareButton setTitle:@"Share" forState:UIControlStateNormal];
    [shareButton setTitleColor:[[ThemeManager sharedTheme] redColor] forState:UIControlStateNormal];
    shareButton.titleLabel.font = [ThemeManager regularFontOfSize:14];
    [shareButton addTarget:self action:@selector(shareButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    //self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:self.websiteTitle];
}

-(void)shareButtonTouched:(id)sender
{
    
    NSArray *objectsToShare = @[self.websiteUrl];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludeActivities = @[UIActivityTypeAirDrop,
                                   UIActivityTypePrint,
                                   UIActivityTypeAssignToContact,
                                   UIActivityTypeSaveToCameraRoll,
                                   UIActivityTypeAddToReadingList,
                                   UIActivityTypePostToFlickr,
                                   UIActivityTypePostToVimeo];
    
    activityVC.excludedActivityTypes = excludeActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - webview delegate methods
- (void)webViewDidStartLoad:(UIWebView *)webView
{
//    [self.webView addSubview:self.loadingIndicator];
//    self.loadingIndicator.center = self.webView.center;
//    [self.loadingIndicator startAnimating];
    [LoadingIndictor showLoadingIndicatorInView:self.view animated:YES];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
//    [self.loadingIndicator stopAnimating];
//    [self.loadingIndicator removeFromSuperview];
    [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    return YES;
    
}

@end