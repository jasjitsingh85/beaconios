//
//  SettingsViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/25/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FaqViewController.h"
#import <BlocksKit/MFMailComposeViewController+BlocksKit.h>
#import "AppDelegate.h"
#import "Theme.h"
#import "WebViewController.h"
#import "NavigationBarTitleLabel.h"
#import "SecretSettingsViewController.h"
#import "User.h"
#import "GroupsViewController.h"

@interface FaqViewController ()

@end

@implementation FaqViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.titleView = [[NavigationBarTitleLabel alloc] initWithTitle:@"FAQ"];
    self.tableView.backgroundView = [[UIView alloc] initWithFrame:self.tableView.bounds];
    self.tableView.backgroundView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.allowsSelection = NO;
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *question;
    NSString *answer;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            question = @"What is Hotspot?";
            answer = @"An app to help you find great bars and buy drink specials through your phone.";
        }
        else if (indexPath.row == 1) {
            question = @"How does this work?";
            answer = @"We buy drinks wholesale to save you money. When you go to one of our partner venues, you can use Hotspot to buy a discounted first drink and invite friends.";
        }
        else if (indexPath.row == 2) {
            question = @"How do I actually get my drink?";
            answer = @"Tap “Check in and get voucher.” Show the voucher to your bartender or server when you first arrive. They’ll tap it twice to confirm the purchase, and give your drink. You won’t be charged by the venue.";
        } else if (indexPath.row == 3) {
            question = @"When do I get charged?";
            answer = @"You are charged only after your server taps your voucher, and taps again to confirm the purchase.";
        } else if (indexPath.row == 4) {
            question = @"How many can I buy?";
            answer = @"You can purchase one drink special per venue per night.";
        } else if (indexPath.row == 5) {
            question = @"How do I tip?";
            answer = @"Either add tip to the rest of the bill, or use cash. Please do tip your server!";
        } else if (indexPath.row == 6) {
            question = @"I have a free drink credit. Where can I use it?";
            answer = @"Anywhere with a drink special $5 or less. The drink special will say “free” if you can use your credit at that venue.";
        } else if (indexPath.row == 7) {
            question = @"I accidently opened a voucher that I don’t want. Will I be charged?";
            answer = @"No. You’re only charged when the server taps twice to confirm the purchase. If opened a voucher with a free credit but didn’t use it, the credit will be returned to you tomorrow.";
        } else if (indexPath.row == 8) {
            question = @"What about security?";
            answer = @"Your raw payment information is never stored on our servers; it’s tokenized and encrypted by a Level 1 PCI DSS Compliant service provider to ensure complete security.";
        }
    }
    
    return [self getFaqCellWithQuestion:question andAnswer:answer];
}

-(UITableViewCell *) getFaqCellWithQuestion:(NSString *)question andAnswer:(NSString *)answer
{
    NSString *CellIdentifier = question;
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
        UILabel *headerPrompt = [[UILabel alloc] initWithFrame:CGRectMake(25, 10, 20, 20)];
        headerPrompt.textColor = [[ThemeManager sharedTheme] redColor];
        headerPrompt.text = @"Q.";
        headerPrompt.font = [ThemeManager boldFontOfSize:12];
        [cell.contentView addSubview:headerPrompt];
        
        NSStringDrawingContext *context = [[NSStringDrawingContext alloc] init];
        CGSize labelSize = (CGSize){self.view.width - 65, FLT_MAX};
        CGRect labelSizeRect = [question boundingRectWithSize:labelSize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager boldFontOfSize:12]} context:context];
        
        UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(40, 13, self.view.width - 65, labelSizeRect.size.height)];
        header.textColor = [UIColor blackColor];
        header.text = question;
        header.numberOfLines = 0;
        header.font = [ThemeManager boldFontOfSize:12];
        [cell.contentView addSubview:header];
        
        CGSize bodySize = (CGSize){self.view.width - 50, FLT_MAX};
        CGRect bodySizeRect = [answer boundingRectWithSize:bodySize options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[ThemeManager lightFontOfSize:12]} context:context];
        
        UILabel *body = [[UILabel alloc] initWithFrame:CGRectMake(25, 20 + labelSizeRect.size.height, self.view.width - 50, bodySizeRect.size.height + 5)];
        body.numberOfLines = 0;
        body.textColor = [UIColor blackColor];
        body.text = answer;
        body.font = [ThemeManager lightFontOfSize:12];
        [cell.contentView addSubview:body];
        
        if (![question isEqualToString:@"What is Hotspot?"]) {
            UIView *topBorder = [[UIView alloc] initWithFrame:CGRectMake(25, 0, self.view.width - 50, 0.5)];
            topBorder.backgroundColor = [UIColor unnormalizedColorWithRed:161 green:161 blue:161 alpha:255];
            [cell.contentView addSubview:topBorder];
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    if (indexPath.row == 0) {
        height = 80;
    }
    else if (indexPath.row == 1) {
        height = 110;
    }
    else if (indexPath.row == 2) {
        height = 110;
    } else if (indexPath.row == 3) {
        height = 80;
    } else if (indexPath.row == 4) {
        height = 80;
    } else if (indexPath.row == 5) {
        height = 80;
    } else if (indexPath.row == 6) {
        height = 95;
    } else if (indexPath.row == 7) {
        height = 125;
    } else {
        height = 125;
    }
    return height;
}

#pragma mark - Table view delegate



@end
