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
#import "SetDealViewController.h"
#import "CenterNavigationController.h"

@interface DealTableViewEventCell()

@property (strong, nonatomic) UIView *backgroundView;

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
    self.eventScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 196)];
    self.eventScroll.pagingEnabled = YES;
    self.eventScroll.showsHorizontalScrollIndicator = NO;
    self.eventScroll.contentSize = CGSizeMake(self.contentView.frame.size.width * events.count, self.contentView.frame.size.height);
    self.eventScroll.delegate = self;
    [self.contentView addSubview:self.eventScroll];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.numberOfPages = events.count;
    self.pageControl.centerX = self.contentView.width/2;
    self.pageControl.y = 175;
    //self.pageControl.currentPageIndicatorTintColor = [[ThemeManager sharedTheme] redColor];
    self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    //[self.pageControl sizeToFit];
    [self.contentView addSubview:self.pageControl];
    
    for (int i = 0; i < events.count; i++) {
        Deal *deal = events[i];
        UIView *eventView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width * i, 0, self.contentView.frame.size.width, 196)];
        [self.eventScroll addSubview:eventView];
        
        UIImageView *eventImageView = [[UIImageView alloc] init];
        eventImageView.height = 196;
        eventImageView.width = eventView.size.width;
        eventImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        eventImageView.contentMode = UIViewContentModeScaleAspectFill;
        eventImageView.clipsToBounds = YES;
        [eventImageView sd_setImageWithURL:deal.venue.imageURL];
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:eventImageView.bounds];
        backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
//        backgroundView.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.2];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [eventImageView addSubview:backgroundView];
        [eventView addSubview:eventImageView];
        
        UILabel *timePlaceTitle =[[UILabel alloc] init];
        timePlaceTitle.text = [@"Tonight @ " stringByAppendingString:deal.venue.name];
        timePlaceTitle.font = [ThemeManager boldFontOfSize:14];
        //NSDictionary *attributes = @{NSFontAttributeName: [timePlaceTitle.font]};
        timePlaceTitle.width = 140;
        timePlaceTitle.centerX = eventView.size.width/2;
        timePlaceTitle.height = 20;
        timePlaceTitle.y = 30;
        timePlaceTitle.textColor = [[UIColor blackColor] colorWithAlphaComponent:1];
        timePlaceTitle.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:1];
        timePlaceTitle.layer.cornerRadius = 10;
        timePlaceTitle.clipsToBounds = YES;
        timePlaceTitle.adjustsFontSizeToFitWidth = YES;
        timePlaceTitle.textAlignment = NSTextAlignmentCenter;
        timePlaceTitle.numberOfLines = 0;
        [eventView addSubview:timePlaceTitle];
        
        UILabel *eventTitle = [[UILabel alloc] init];
        eventTitle .width = eventView.size.width - 40;
        eventTitle.centerX = eventView.size.width/2;
        eventTitle.height = 40;
        eventTitle.y = 70;
        eventTitle.text = deal.dealDescriptionShort;
        eventTitle.font = [ThemeManager boldFontOfSize:19*1.3];
        eventTitle.textColor = [UIColor whiteColor];
        eventTitle.adjustsFontSizeToFitWidth = YES;
        [eventTitle setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
        eventTitle.textAlignment = NSTextAlignmentCenter;
        eventTitle.numberOfLines = 0;
        [eventView addSubview:eventTitle];
        
        UILabel *dealInfo = [[UILabel alloc] init];
        dealInfo.width = 200;
        dealInfo.centerX = eventView.width/2;
        dealInfo.height = 20;
        dealInfo.y = 110;
        dealInfo.text = deal.dealDescription;
        dealInfo.font = [ThemeManager regularFontOfSize:12];
        dealInfo.backgroundColor = [[[ThemeManager sharedTheme] lightBlueColor] colorWithAlphaComponent:0.85];
        dealInfo.textColor = [UIColor whiteColor];
        dealInfo.adjustsFontSizeToFitWidth = YES;
        dealInfo.textAlignment = NSTextAlignmentCenter;
        dealInfo.numberOfLines = 0;
        [eventView addSubview:dealInfo];
    }
    
}

- (NSString *)stringForDistance:(CLLocationDistance)distance
{
    CGFloat distanceMiles = METERS_TO_MILES*distance;
    NSString *distanceString;
    if (distanceMiles < 0.25) {
        distanceString = [NSString stringWithFormat:@"%0.0fft", (floor((METERS_TO_FEET*distance)/10))*10];
    }
    else {
        distanceString = [NSString stringWithFormat:@"%0.1fmi", METERS_TO_MILES*distance];
    }
    return distanceString;
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.eventScroll.frame.size.width;
    int page = floor((self.eventScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

@end