//
//  TabViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 1/12/16.
//  Copyright © 2016 Jeff Ames. All rights reserved.
//

#import "TabViewController.h"
#import "TabTableView.h"
#import "APIClient.h"
#import "Venue.h"
#import "PaymentsViewController.h"

@interface TabViewController ()

@property (strong, nonatomic) TabTableView *tabTableView;
@property (strong, nonatomic) UIScrollView *scrollViewContainer;
@property (strong, nonatomic) UIButton *addPayment;
@property (strong, nonatomic) UIView *changePayment;
@property (strong, nonatomic) UIImageView *cardType;
@property (strong, nonatomic) UILabel *cardInfo;
@property (strong, nonatomic) PaymentsViewController *paymentsViewController;

@end

@implementation TabViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.scrollViewContainer = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollViewContainer.scrollEnabled = YES;
    self.scrollViewContainer.backgroundColor = [UIColor whiteColor];
    self.scrollViewContainer.bounds = self.view.bounds;
    self.scrollViewContainer.contentSize = CGSizeMake(self.view.width, self.view.height);
    [self.view addSubview:self.scrollViewContainer];
    
    UIImageView *headerIcon = [[UIImageView alloc] init];
    headerIcon.height = 18;
    headerIcon.width = 18;
    headerIcon.x = 20;
    headerIcon.y = 15;
    [headerIcon setImage:[UIImage imageNamed:@"newPaymentIcon"]];
    [self.scrollViewContainer addSubview:headerIcon];
    
    UILabel *headerTitle = [[UILabel alloc] init];
    headerTitle.height = 20;
    headerTitle.width = self.view.width;
    headerTitle.textAlignment = NSTextAlignmentLeft;
    headerTitle.x = 42;
    headerTitle.font = [ThemeManager boldFontOfSize:11];
    headerTitle.y = 14;
    headerTitle.text = @"FULL TAB";
    [self.scrollViewContainer addSubview:headerTitle];
    
    UILabel *headerExplanationText = [[UILabel alloc] initWithFrame:CGRectMake(0, 18, self.view.width - 45, 50)];
    headerExplanationText.centerX = self.view.width/2;
    headerExplanationText.font = [ThemeManager lightFontOfSize:12];
    headerExplanationText.textAlignment = NSTextAlignmentLeft;
    headerExplanationText.numberOfLines = 1;
    headerExplanationText.text = @"Close out your tab by tapping 'PAY TAB'";
    [self.scrollViewContainer addSubview:headerExplanationText];
    
    self.tabTableView = [[TabTableView alloc] init];
    self.tabTableView.tabSummary = NO;
    self.tabTableView.tab = self.tab;
    self.tabTableView.tableView.y = 55;
    self.tabTableView.tabItems = self.tabItems;
    [self.scrollViewContainer addSubview:self.tabTableView.tableView];
    
    UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(20, ((self.tabItems.count + 4) * 22) + 70, self.view.width - 40, 0.5)];
    topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:161 green:161 blue:161 alpha:255];
    [self.scrollViewContainer addSubview:topBorder];
    
    UIImageView *changePaymentIcon = [[UIImageView alloc] init];
    changePaymentIcon.height = 18;
    changePaymentIcon.width = 18;
    changePaymentIcon.x = 20;
    changePaymentIcon.y = topBorder.y + 15;
    [changePaymentIcon setImage:[UIImage imageNamed:@"newPaymentIcon"]];
    [self.scrollViewContainer addSubview:changePaymentIcon];
    
    UILabel *changePaymentTitle = [[UILabel alloc] init];
    changePaymentTitle.height = 20;
    changePaymentTitle.width = self.view.width;
    changePaymentTitle.textAlignment = NSTextAlignmentLeft;
    changePaymentTitle.x = 42;
    changePaymentTitle.font = [ThemeManager boldFontOfSize:11];
    changePaymentTitle.y = topBorder.y + 14;
    changePaymentTitle.text = @"CHANGE PAYMENT";
    [self.scrollViewContainer addSubview:changePaymentTitle];
    
    self.addPayment = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.addPayment setTitle:@"ADD PAYMENT" forState:UIControlStateNormal];
    self.addPayment.titleLabel.font = [ThemeManager regularFontOfSize:9];
    [self.addPayment setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.addPayment.size = CGSizeMake(self.view.width - 40, 20);
    self.addPayment.x = 20;
    self.addPayment.y = topBorder.y + 45;
    self.addPayment.layer.cornerRadius = 2.0;
    self.addPayment.layer.borderColor = [UIColor blackColor].CGColor;
    self.addPayment.layer.borderWidth = 1;
    self.addPayment.hidden = YES;
    [self.addPayment addTarget:self action:@selector(addPaymentButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollViewContainer addSubview:self.addPayment];
    
    self.changePayment = [[UIView alloc] initWithFrame:CGRectMake(20, topBorder.y + 35, self.view.width - 40, 30)];
    self.changePayment.hidden = YES;
    [self.scrollViewContainer addSubview:self.changePayment];
    
    UIView *sectionDivider = [[UIView alloc] initWithFrame:CGRectMake((self.view.width - 40)/2, 10, .5, 22.5)];
    sectionDivider.backgroundColor = [UIColor unnormalizedColorWithRed:161 green:161 blue:161 alpha:255];
    [self.changePayment addSubview:sectionDivider];
    
    self.cardType = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"master"]];
    self.cardType.y = 0;
    [self.changePayment addSubview:self.cardType];
    
    self.cardInfo = [[UILabel alloc] initWithFrame:CGRectMake(60, 8, 100, 25)];
    self.cardInfo.font = [ThemeManager lightFontOfSize:12];
    [self.changePayment addSubview:self.cardInfo];
    
    UIButton *changePaymentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [changePaymentButton setTitle:@"CHANGE PAYMENT" forState:UIControlStateNormal];
    changePaymentButton.titleLabel.font = [ThemeManager lightFontOfSize:12];
    [changePaymentButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    changePaymentButton.size = CGSizeMake(155, 25);
    changePaymentButton.x = (self.view.width - 40)/2;
    changePaymentButton.y = 8;
    [changePaymentButton addTarget:self action:@selector(changePaymentButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.changePayment addSubview:changePaymentButton];
    
    UIView *buttonContainer = [[UIView alloc] init];
    buttonContainer.backgroundColor = [UIColor whiteColor];
    buttonContainer.width = self.view.width;
    buttonContainer.height = 60;
    buttonContainer.y = self.view.height - 60;
    buttonContainer.userInteractionEnabled = YES;
    [self.view addSubview:buttonContainer];
    
    UIImageView *topDropShadowBorder = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dropShadowTopBorder"]];
    topDropShadowBorder.y = -8;
    [buttonContainer addSubview:topDropShadowBorder];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.size = CGSizeMake(self.view.width - 50, 35);
    button.centerX = self.view.width/2.0;
    button.y = 12.5;
    button.layer.cornerRadius = 4;
    button.backgroundColor = [[ThemeManager sharedTheme] redColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateHighlighted];
    
    [buttonContainer addSubview:button];
    
    button.titleLabel.font = [ThemeManager boldFontOfSize:13];
    [button addTarget:self action:@selector(reviewTabButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [button setTitle:@"PAY TAB" forState:UIControlStateNormal];
    
    [self loadPaymentViewController];
    
    [self updatePaymentInformation];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePaymentInformation) name:kRefreshCustomerPaymentInfo object:nil];
    
}

-(void)loadPaymentViewController
{
    [[APIClient sharedClient] getClientToken:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *clientToken = responseObject[@"client_token"];
        self.paymentsViewController = [[PaymentsViewController alloc] initWithClientToken:clientToken];
        self.paymentsViewController.onlyAddPayment = YES;
        [self addChildViewController:self.paymentsViewController];
        self.paymentsViewController.view.frame = self.view.bounds;
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        [LoadingIndictor hideLoadingIndicatorForView:self.view animated:YES];
    }];
}

-(void)addPaymentButtonTouched:(id)sender
{
    [self openPaymentModal];
}

-(void)changePaymentButtonTouched:(id)sender
{
    [self openPaymentModal];
}

-(void)openPaymentModal
{
    [self.paymentsViewController openPaymentModalForOpenTab];
}

-(void)updatePaymentInformation
{
    [[APIClient sharedClient] getPaymentInfo:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSDictionary *paymentInformation = responseObject[@"payment_information"];
        if (paymentInformation) {
            self.cardInfo.text = [NSString stringWithFormat:@"...... %@", paymentInformation[@"last_four"]];
            [self updateCardType:paymentInformation[@"card_type"]];
            NSLog(@"%@", paymentInformation[@"card_type"]);
            self.addPayment.hidden = YES;
            self.changePayment.hidden = NO;
        } else {
            self.addPayment.hidden = NO;
            self.changePayment.hidden = YES;
        }
    } failure:nil];
}

-(void)updateCardType:(NSString *)cardType
{
    if ([cardType isEqualToString:@"Visa"])
    {
        [self.cardType setImage:[UIImage imageNamed:@"visa"]];
    } else if ([cardType isEqualToString:@"MasterCard"])
    {
        [self.cardType setImage:[UIImage imageNamed:@"master"]];
    }
}

-(void)reviewTabButtonTouched:(id)sender
{
    NSNumber *tipAmount = [NSNumber numberWithFloat:[self.tabTableView.tipAmount.text floatValue]];
    [[APIClient sharedClient] closeTab:self.venue.venueID withTip:tipAmount success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [[[UIAlertView alloc] initWithTitle:@"Tab Closed" message:@"Oh my god your tab has been closed" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    } failure:nil];
}

-(void)setTab:(Tab *)tab
{
    _tab = tab;
}

@end