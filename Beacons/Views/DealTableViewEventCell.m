//
//  DealTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "AppDelegate.h"
#import "DealTableViewEventCell.h"
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

@interface DealTableViewEventCell()

//@property (strong, nonatomic) UIView *backgroundView;

@end

@implementation DealTableViewEventCell

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
    self.eventScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 246)];
    self.eventScroll.pagingEnabled = YES;
    self.eventScroll.showsHorizontalScrollIndicator = NO;
    self.eventScroll.contentSize = CGSizeMake(self.contentView.frame.size.width * events.count, self.contentView.frame.size.height);
    self.eventScroll.delegate = self;
    [self.contentView addSubview:self.eventScroll];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = NO;
    self.pageControl.numberOfPages = events.count;
    self.pageControl.centerX = self.contentView.width/2;
    self.pageControl.y = 233;
    //self.pageControl.currentPageIndicatorTintColor = [[ThemeManager sharedTheme] redColor];
    //self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    //[self.pageControl sizeToFit];
    [self.contentView addSubview:self.pageControl];
    
    for (int i = 0; i < events.count; i++) {
        Deal *deal = events[i];
        UIView *eventView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width * i, 0, self.contentView.frame.size.width, 246)];
        [self.eventScroll addSubview:eventView];
        
        UIImageView *eventImageView = [[UIImageView alloc] init];
        eventImageView.height = 246;
        eventImageView.width = eventView.size.width;
        eventImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        eventImageView.contentMode = UIViewContentModeScaleAspectFill;
        eventImageView.clipsToBounds = YES;
        [eventImageView sd_setImageWithURL:deal.venue.imageURL];
        [eventView addSubview:eventImageView];
        
        UIView *backgroundViewBlack = [[UIView alloc] initWithFrame:eventImageView.bounds];
        backgroundViewBlack.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
        UIView *backgroundViewOrange = [[UIView alloc] initWithFrame:eventImageView.bounds];
        backgroundViewOrange.backgroundColor = [UIColor colorWithRed:(199/255.) green:(88/255.) blue:(13/255.) alpha:.2 ];
        backgroundViewBlack.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        backgroundViewOrange.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [eventView addSubview:backgroundViewBlack];
        [eventView addSubview:backgroundViewOrange];
        
        UIView *pageControlBackground = [[UIView alloc] init];
        pageControlBackground.width = eventView.size.width;
        pageControlBackground.height = 55;
        pageControlBackground.x = 0;
        pageControlBackground.y = 196;
        pageControlBackground.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.5];
        [eventView addSubview:pageControlBackground];
        
        UILabel *eventHeader = [[UILabel alloc] init];
        eventHeader.text = @"DAILY SPECIALS";
        eventHeader.textColor = [UIColor whiteColor];
        eventHeader.font = [ThemeManager boldFontOfSize:13];
        eventHeader.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
        eventHeader.textAlignment = NSTextAlignmentCenter;
        eventHeader.width = 140;
        eventHeader.height = 24;
        eventHeader.x = 0;
        eventHeader.y = 25;
        [self.contentView addSubview:eventHeader];
        
        UILabel *dealInfo = [[UILabel alloc] init];
        dealInfo.width = eventView.size.width;
        //        dealInfo.centerX = eventView.width/2;
        dealInfo.height = 18;
        dealInfo.y = 201;
        dealInfo.text = deal.dealDescription;
        dealInfo.font = [ThemeManager boldFontOfSize:14];
        //dealInfo.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.9];
        //dealInfo.size = CGSizeMake(221, 24);
        dealInfo.centerX = eventView.size.width/2.0;
        dealInfo.textColor = [UIColor whiteColor];
        //dealInfo.adjustsFontSizeToFitWidth = YES;
        dealInfo.textAlignment = NSTextAlignmentCenter;
        dealInfo.numberOfLines = 1;
        [eventView addSubview:dealInfo];
        
//        UIView *whiteStrip = [[UIView alloc]init];
//        whiteStrip.width = eventView.size.width;
//        whiteStrip.height = 30;
//        whiteStrip.y = 0;
//        whiteStrip.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
//        [eventView addSubview:whiteStrip];
        
//        UILabel *timePlaceTitle =[[UILabel alloc] init];
//        timePlaceTitle.text = @"Tonight";
//        timePlaceTitle.font = [ThemeManager boldFontOfSize:16];
//        //NSDictionary *attributes = @{NSFontAttributeName: [timePlaceTitle.font]};
//        timePlaceTitle.width = eventView.size.width - 100;
//        timePlaceTitle.centerX = eventView.size.width/2;
//        timePlaceTitle.height = 30;
//        timePlaceTitle.y = 0;
//        timePlaceTitle.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
//        //timePlaceTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
//        //timePlaceTitle.layer.cornerRadius = 10;
//        //timePlaceTitle.clipsToBounds = YES;
//        timePlaceTitle.adjustsFontSizeToFitWidth = YES;
//        timePlaceTitle.textAlignment = NSTextAlignmentCenter;
//        timePlaceTitle.numberOfLines = 0;
//        [eventView addSubview:timePlaceTitle];
        
        UILabel *timeTitle =[[UILabel alloc] init];
        timeTitle.text = deal.hoursAvailableString;
        timeTitle.font = [ThemeManager boldFontOfSize:22];
        //NSDictionary *attributes = @{NSFontAttributeName: [timePlaceTitle.font]};
        timeTitle.width = eventView.size.width - 20;
        //timePlaceTitle.width = 110;
        //timePlaceTitle.width = eventView.size.width;
        timeTitle.x = 5;
        timeTitle.height = 22;
        timeTitle.y = 160;
        //timePlaceTitle.y = 20;
        timeTitle.textColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        //timePlaceTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        //timePlaceTitle.layer.cornerRadius = 10;
        //timePlaceTitle.clipsToBounds = YES;
        //timeTitle.adjustsFontSizeToFitWidth = YES;
        timeTitle.textAlignment = NSTextAlignmentLeft;
        timeTitle.numberOfLines = 1;
        [eventView addSubview:timeTitle];
        
        NSMutableDictionary *eventTitle = [self parseStringIntoTwoLines:deal.dealDescriptionShort];
        
        UILabel *eventTitleLineOne = [[UILabel alloc] init];
        eventTitleLineOne.width = eventView.size.width - 20;
        eventTitleLineOne.x = 5;
        eventTitleLineOne.height = 30;
        eventTitleLineOne.y = 72;
        eventTitleLineOne.text = [[eventTitle objectForKey:@"firstLine"] uppercaseString];
        //eventTitleLineOne.text =@"KARAOKE HAPPY";
        eventTitleLineOne.font = [ThemeManager boldFontOfSize:30];
        eventTitleLineOne.textColor = [UIColor whiteColor];
        //eventTitleLineOne.adjustsFontSizeToFitWidth = YES;
//        [eventTitle setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
        eventTitleLineOne.textAlignment = NSTextAlignmentLeft;
        eventTitleLineOne.numberOfLines = 1;
        [eventView addSubview:eventTitleLineOne];
        
        UILabel *eventTitleLineTwo = [[UILabel alloc] init];
        eventTitleLineTwo.width = eventView.size.width-20;
        eventTitleLineTwo.x = 4;
        eventTitleLineTwo.height = 46;
        eventTitleLineTwo.y = 95;
        //eventTitleLineTwo.text = [@"HOUR" uppercaseString];
        eventTitleLineTwo.text = [[eventTitle objectForKey:@"secondLine"] uppercaseString];
        //eventTitle.text =[deal.dealDescriptionShort stringByAppendingString:deal.venue.name];
        eventTitleLineTwo.font = [ThemeManager boldFontOfSize:46];
        eventTitleLineTwo.textColor = [UIColor whiteColor];
        //eventTitleLineTwo.adjustsFontSizeToFitWidth = YES;
        //        [eventTitle setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
        eventTitleLineTwo.textAlignment = NSTextAlignmentLeft;
        eventTitleLineTwo.numberOfLines = 1;
        //[eventTitleLineTwo sizeToFit];
        [eventView addSubview:eventTitleLineTwo];
        
        UILabel *venueLine = [[UILabel alloc] init];
        venueLine.width = eventView.size.width-20;
        venueLine.x = 5;
        venueLine.height = 30;
        venueLine.y = 130;
        venueLine.text = [NSString stringWithFormat:@"@ %@", [deal.venue.name uppercaseString]];
        //eventTitleLineTwo.text = [[eventTitle objectForKey:@"secondLine"] uppercaseString];
        //eventTitle.text =[deal.dealDescriptionShort stringByAppendingString:deal.venue.name];
        venueLine.font = [ThemeManager boldFontOfSize:30];
        venueLine.textColor = [UIColor whiteColor];
        //venueLine.adjustsFontSizeToFitWidth = YES;
        //        [eventTitle setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
        venueLine.textAlignment = NSTextAlignmentLeft;
        venueLine.numberOfLines = 1;
        [venueLine sizeToFit];
        [eventView addSubview:venueLine];
    }
    
}

//- (NSString *)stringForDistance:(CLLocationDistance)distance
//{
//    CGFloat distanceMiles = METERS_TO_MILES*distance;
//    NSString *distanceString;
//    if (distanceMiles < 0.25) {
//        distanceString = [NSString stringWithFormat:@"%0.0fft", (floor((METERS_TO_FEET*distance)/10))*10];
//    }
//    else {
//        distanceString = [NSString stringWithFormat:@"%0.1fmi", METERS_TO_MILES*distance];
//    }
//    return distanceString;
//}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.eventScroll.frame.size.width;
    int page = floor((self.eventScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

-(NSMutableDictionary *)parseStringIntoTwoLines:(NSString *)originalString
{
    NSMutableDictionary *firstAndSecondLine = [[NSMutableDictionary alloc] init];
    NSArray *arrayOfStrings = [originalString componentsSeparatedByString:@" "];
    if ([arrayOfStrings count] == 1) {
        [firstAndSecondLine setObject:@"" forKey:@"firstLine"];
        [firstAndSecondLine setObject:originalString forKey:@"secondLine"];
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