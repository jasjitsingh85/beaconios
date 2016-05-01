//
//  DealTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "AppDelegate.h"
#import "SponsoredEventTableViewCell.h"
#import <MapKit/MapKit.h>
#import <SDWebImage/UIImageView+WebCache.h>
#include <tgmath.h>
#import "Utilities.h"
#import "UIView+Shadow.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "Venue.h"
#import <QuartzCore/QuartzCore.h>
//#import "SetDealViewController.h"
#import "CenterNavigationController.h"
#import "APIClient.h"

@interface SponsoredEventTableViewCell()

@property (strong, nonatomic) UILabel *eventHeader;

@end

@implementation SponsoredEventTableViewCell

@synthesize eventScroll=eventScroll_;
@synthesize pageControl=pageControl_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
    {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)setEvents:(NSArray *)events
{
    _events = events;
    
//    SponsoredEvent *event = self.events[0];
    
    self.eventScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 201)];
    self.eventScroll.pagingEnabled = YES;
    self.eventScroll.showsHorizontalScrollIndicator = NO;
    self.eventScroll.contentSize = CGSizeMake(self.contentView.frame.size.width * events.count, self.contentView.frame.size.height);
    self.eventScroll.delegate = self;
    [self.contentView addSubview:self.eventScroll];
    
    [self.eventScroll setUserInteractionEnabled:YES];
    [self.contentView addGestureRecognizer:self.eventScroll.panGestureRecognizer];
    
//    [self updateDate];
    
    for (int i = 0; i < events.count; i++) {
        SponsoredEvent *event = events[i];
        UIView *eventView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width * i, 0, self.contentView.frame.size.width, 201)];
        [self.eventScroll addSubview:eventView];
        
        UIImageView *eventImageView = [[UIImageView alloc] init];
        eventImageView.height = 201;
        eventImageView.width = eventView.size.width;
        //eventImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        eventImageView.contentMode = UIViewContentModeScaleAspectFill;
        eventImageView.clipsToBounds = YES;
        [eventImageView sd_setImageWithURL:event.venue.imageURL];
        [eventView addSubview:eventImageView];
        
        UIView *colorBackgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 201)];
        colorBackgroundGradient.backgroundColor = [UIColor unnormalizedColorWithRed:27 green:20 blue:100 alpha:255];
        colorBackgroundGradient.alpha = .4;
        [eventView addSubview:colorBackgroundGradient];
        
        UILabel *eventTitleLineOne = [[UILabel alloc] init];
        eventTitleLineOne.x = 15;
        eventTitleLineOne.height = 26;
        eventTitleLineOne.y = 70;
        eventTitleLineOne.font = [ThemeManager boldFontOfSize:14];
        eventTitleLineOne.backgroundColor = [[ThemeManager sharedTheme] redColor];
        eventTitleLineOne.textColor = [UIColor whiteColor];
        
        UIImageView *presaleDiscount = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"presaleDiscount"]];
        presaleDiscount.y = 50;
        presaleDiscount.hidden = YES;
        [eventView addSubview:presaleDiscount];
        
        if (event.presaleActive) {
            
            NSString *eventTitle = [NSString stringWithFormat:@"  %@ FOR $%@ $%@  ", [event.itemName uppercaseString], event.itemPrice, event.presaleItemPrice];
            eventTitleLineOne.text = eventTitle;
            NSRange range = [eventTitle rangeOfString:[NSString stringWithFormat:@"$%@", event.itemPrice]];
            NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:eventTitle];
            [attributedText addAttribute:NSStrikethroughStyleAttributeName value:[NSNumber numberWithInt:NSUnderlineStyleSingle] range:range];
            [attributedText addAttribute:NSFontAttributeName value:[ThemeManager lightFontOfSize:13] range:range];
            eventTitleLineOne.attributedText = attributedText;
            eventTitleLineOne.width = [self widthOfString:eventTitleLineOne.text withFont:eventTitleLineOne.font];
            
            presaleDiscount.hidden = NO;
            presaleDiscount.x = eventTitleLineOne.width + 20;
        } else {
            NSString *eventTitle = [NSString stringWithFormat:@"  %@ FOR $%@  ", [event.itemName uppercaseString], event.itemPrice];
            eventTitleLineOne.text = eventTitle;
            eventTitleLineOne.width = [self widthOfString:eventTitleLineOne.text withFont:eventTitleLineOne.font];
        }
        
        //eventTitleLineOne.adjustsFontSizeToFitWidth = YES;
        //        [eventTitle setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
        eventTitleLineOne.textAlignment = NSTextAlignmentLeft;
        eventTitleLineOne.numberOfLines = 1;
        [eventView addSubview:eventTitleLineOne];
        
        NSMutableDictionary *venueName = [self parseStringIntoTwoLines:[event.venue.name uppercaseString]];
        CGFloat firstStringWidth = [self widthOfString:[[venueName objectForKey:@"firstLine"] uppercaseString] withFont:[ThemeManager boldFontOfSize:14]];
        CGFloat secondStringWidth = [self widthOfString:[[venueName objectForKey:@"secondLine"] uppercaseString] withFont:[ThemeManager boldFontOfSize:14]];
        
        UILabel *venueTitleLineOne = [[UILabel alloc] initWithFrame:CGRectMake(15, 87, MAX(firstStringWidth, secondStringWidth), 50)];
        venueTitleLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
        venueTitleLineOne.font = [ThemeManager boldFontOfSize:14];
        venueTitleLineOne.textColor = [UIColor whiteColor];
        venueTitleLineOne.textAlignment = NSTextAlignmentLeft;
        venueTitleLineOne.numberOfLines = 1;
        [eventView addSubview:venueTitleLineOne];
        
        UILabel *venueTitleLineTwo = [[UILabel alloc] initWithFrame:CGRectMake(15, 103, MAX(firstStringWidth, secondStringWidth), 50)];
        venueTitleLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
        venueTitleLineTwo.font = [ThemeManager boldFontOfSize:14];
        venueTitleLineTwo.textColor = [UIColor whiteColor];
        venueTitleLineTwo.textAlignment = NSTextAlignmentLeft;
        venueTitleLineTwo.numberOfLines = 1;
        [eventView addSubview:venueTitleLineTwo];
        
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(25 + MAX(firstStringWidth, secondStringWidth), 107.5, .5, 25)];
        verticalLine.backgroundColor = [UIColor whiteColor];
        [eventView addSubview:verticalLine];
        
        UILabel *dateString = [[UILabel alloc] init];
        dateString.textColor = [UIColor whiteColor];
        dateString.font = [ThemeManager mediumFontOfSize:13];
        dateString.textAlignment = NSTextAlignmentLeft;
        dateString.width = 250;
        dateString.height = 50;
        dateString.x = verticalLine.x + 10;
        dateString.y = 87;
        dateString.text = [event.getDateAsString uppercaseString];
        [eventView addSubview:dateString];
        
        UILabel *extraString = [[UILabel alloc] initWithFrame:CGRectMake(dateString.x, 117, self.width, 20)];
        extraString.textColor = [UIColor whiteColor];
        extraString.font = [ThemeManager mediumFontOfSize:9];
        extraString.text = [self getExtraEventString:event];
        extraString.textAlignment = NSTextAlignmentLeft;
        [eventView addSubview:extraString];
        
//        UIButton *followButton = [UIButton buttonWithType:UIButtonTypeCustom];
//        followButton.size = CGSizeMake(85, 25);
//        followButton.x = self.contentView.width - 95;
//        followButton.y = 10;
//        [followButton setTitle:@"INTERESTED" forState:UIControlStateNormal];
//        [followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//        followButton.titleLabel.font = [ThemeManager mediumFontOfSize:10];
//        followButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
//        followButton.titleLabel.textColor = [UIColor whiteColor];
//        followButton.layer.cornerRadius = 4;
//        followButton.tag = [event.eventID integerValue];
//        followButton.layer.borderColor = [[UIColor whiteColor] CGColor];
//        followButton.layer.borderWidth = 1.0;
//        [followButton addTarget:self action:@selector(buttonTouched:) forControlEvents:UIControlEventTouchUpInside];
//        [eventView addSubview:followButton];
        
//        [self setButtonState:followButton forEvent:event];
    }
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = NO;
    self.pageControl.numberOfPages = events.count;
    self.pageControl.centerX = self.contentView.width/2;
    self.pageControl.y = 182;
    self.pageControl.x = 0;
    self.pageControl.height = 20;
    self.pageControl.width = self.contentView.width;
    self.pageControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.8];
    self.pageControl.hidesForSinglePage = YES;
    //self.pageControl.currentPageIndicatorTintColor = [[ThemeManager sharedTheme] redColor];
    //self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    //[self.pageControl sizeToFit];
    [self.contentView addSubview:self.pageControl];
    
}

//-(void)setButtonState:(UIButton *)button forEvent:(SponsoredEvent *)event
//{
//    if (event.eventStatusOption == EventStatusNoSelection) {
//        [button setTitle:@"INTERESTED" forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//        [button setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//        button.titleLabel.font = [ThemeManager mediumFontOfSize:10];
//        button.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
//        button.layer.borderColor = [[UIColor whiteColor] CGColor];
//        button.titleLabel.textColor = [UIColor whiteColor];
//    } else if (event.eventStatusOption == EventStatusInterested) {
//        [button setTitle:@"INTERESTED" forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [button setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//        button.titleLabel.font = [ThemeManager mediumFontOfSize:10];
//        button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.75];
//        button.layer.borderColor = [[UIColor clearColor] CGColor];
//        button.titleLabel.textColor = [UIColor blackColor];
//    } else if (event.eventStatusOption == EventStatusGoing) {
//        [button setTitle:@"GOING" forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [button setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//        button.titleLabel.font = [ThemeManager mediumFontOfSize:10];
//        button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.75];
//        button.titleLabel.textColor = [UIColor blackColor];
//        button.layer.borderColor = [[UIColor clearColor] CGColor];
//    } else if (event.eventStatusOption == EventStatusRedeemed) {
//        [button setTitle:@"GOING" forState:UIControlStateNormal];
//        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [button setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//        button.titleLabel.font = [ThemeManager mediumFontOfSize:10];
//        button.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.75];
//        button.titleLabel.textColor = [UIColor blackColor];
//        button.layer.borderColor = [[UIColor clearColor] CGColor];
//    }
//}

-(NSString *)getExtraEventString:(SponsoredEvent *)sponsoredEvent
{
    if (![sponsoredEvent.socialMessage isEqualToString:@""]) {
        if (![sponsoredEvent.statusMessage isEqualToString:@""]) {
            return [NSString stringWithFormat:@"%@ | %@", [sponsoredEvent.socialMessage uppercaseString], [sponsoredEvent.statusMessage uppercaseString]];
        } else {
            return [NSString stringWithFormat:@"%@", [sponsoredEvent.socialMessage uppercaseString]];
        }
    } else {
        if (![sponsoredEvent.statusMessage isEqualToString:@""]) {
            return [NSString stringWithFormat:@"%@", [sponsoredEvent.statusMessage uppercaseString]];
        } else {
            return @"";
        }
    }
}

//- (void)buttonTouched:(id)sender
//{
//    UIButton *button = (UIButton *)sender;
//    
////    if ([button.titleLabel.text isEqualToString:@"GOING"]) {
////        [[[UIAlertView alloc] initWithTitle:@"Already Going" message:@"You've already reserved a spot at this event" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
////    }
//
//    if ([button.titleLabel.text isEqualToString:@"INTERESTED"]) {
//        [[APIClient sharedClient] toggleInterested:[NSNumber numberWithInteger:button.tag] success:^(AFHTTPRequestOperation *operation, id responseObject) {
//            SponsoredEvent *event = [[SponsoredEvent alloc] initWithDictionary:responseObject[@"sponsored_event"]];
//            [self setButtonState:button forEvent:event];
//        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"FAILURE");
//        }];
//    }
////    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshAfterToggleFavoriteNotification object:self];
////    self.isFollowed = !self.isFollowed;
////    [self updateFavoriteButton];
////    
////    [[APIClient sharedClient] toggleFavorite:self.venue.venueID success:^(AFHTTPRequestOperation *operation, id responseObject) {
////        self.isFollowed = [responseObject[@"is_favorited"] boolValue];
////        [self updateFavoriteButton];
////    } failure:nil];
//}

//- (void)makeButtonActive:(UIButton *)button
//{
//    [self.followButton setTitle:@"FOLLOWING" forState:UIControlStateNormal];
//    self.followButton.size = CGSizeMake(80, 25);
//    self.followButton.x = self.contentView.width - 90;
//    //[self.followButton setTitleColor:[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] forState:UIControlStateNormal];
//    //[self.followButton setTitleColor:[[UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:255] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//    [self.followButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [self.followButton setTitleColor:[[UIColor blackColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//    self.followButton.layer.borderColor = [UIColor clearColor].CGColor;
//    //    self.followButton.backgroundColor = [[ThemeManager sharedTheme] greenColor];
//    self.followButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.75];
//}

//- (void)makeButtonInactive:(UIButton *)button
//{
//    [self.followButton setTitle:@"FOLLOW" forState:UIControlStateNormal];
//    self.followButton.size = CGSizeMake(60, 25);
//    self.followButton.x = self.contentView.width - 70;
//    [self.followButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.followButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
//    self.followButton.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
//    self.followButton.layer.borderColor = [UIColor whiteColor].CGColor;
//}

//- (void) updateFavoriteButton
//{
//    if (self.isFollowed) {
//        [self makeFollowButtonActive];
//    } else {
//        [self makeFollowButtonInactive];
//    }
//}

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.eventScroll.frame.size.width;
    int page = floor((self.eventScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
//    [self updateDate];
}

//-(void)updateDate
//{
//    SponsoredEvent *event = self.events[self.pageControl.currentPage];
//    self.eventHeader.text = [event.getDateAsString uppercaseString];
//    CGSize stringBoundingBox = [self.eventHeader.text sizeWithAttributes:@{NSFontAttributeName:self.eventHeader.font}];
//    self.eventHeader.width = stringBoundingBox.width + 20;
//}

-(NSMutableDictionary *)parseStringIntoTwoLines:(NSString *)originalString
{
    NSMutableDictionary *firstAndSecondLine = [[NSMutableDictionary alloc] init];
    NSArray *arrayOfStrings = [originalString componentsSeparatedByString:@" "];
    if ([arrayOfStrings count] == 1) {
        [firstAndSecondLine setObject:originalString forKey:@"firstLine"];
        [firstAndSecondLine setObject:@"" forKey:@"secondLine"];
    } else {
        NSMutableString *firstLine = [[NSMutableString alloc] init];
        NSMutableString *secondLine = [[NSMutableString alloc] init];
        NSInteger firstLineCharCount = 0;
        for (int i = 0; i < [arrayOfStrings count]; i++) {
            if ((firstLineCharCount + [arrayOfStrings[i] length] < 12 && i + 1 != [arrayOfStrings count]) || i == 0) {
                if ([firstLine  length] == 0) {
                    [firstLine appendString:arrayOfStrings[i]];
                } else {
                    [firstLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
                }
                firstLineCharCount = firstLineCharCount + [arrayOfStrings[i] length];
            } else {
                if ([secondLine length] == 0) {
                    [secondLine appendString:arrayOfStrings[i]];
                } else {
                    [secondLine appendString:[NSString stringWithFormat:@" %@", arrayOfStrings[i]]];
                }
            }
        }
        [firstAndSecondLine setObject:firstLine forKey:@"firstLine"];
        [firstAndSecondLine setObject:secondLine forKey:@"secondLine"];
    }
    
    return firstAndSecondLine;
}

@end