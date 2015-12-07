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

@property (strong, nonatomic) UILabel *eventHeader;

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
    _events = events;
    
    Event *event = self.events[0];
    
    self.eventScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 200)];
    self.eventScroll.pagingEnabled = YES;
    self.eventScroll.showsHorizontalScrollIndicator = NO;
    self.eventScroll.contentSize = CGSizeMake(self.contentView.frame.size.width * events.count, self.contentView.frame.size.height);
    self.eventScroll.delegate = self;
    [self.contentView addSubview:self.eventScroll];
    
    [self.eventScroll setUserInteractionEnabled:NO];
    [self.contentView addGestureRecognizer:self.eventScroll.panGestureRecognizer];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = NO;
    self.pageControl.numberOfPages = events.count;
    self.pageControl.centerX = self.contentView.width/2;
    self.pageControl.y = 187;
    //self.pageControl.currentPageIndicatorTintColor = [[ThemeManager sharedTheme] redColor];
    //self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    //[self.pageControl sizeToFit];
    [self.contentView addSubview:self.pageControl];
    
    self.eventHeader = [[UILabel alloc] init];
    self.eventHeader.textColor = [UIColor whiteColor];
    self.eventHeader.font = [ThemeManager boldFontOfSize:13];
//    self.eventHeader.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:204];
    self.eventHeader.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    self.eventHeader.textAlignment = NSTextAlignmentCenter;
    self.eventHeader.width = 140;
    self.eventHeader.height = 24;
    self.eventHeader.x = 0;
    self.eventHeader.y = 25;
    self.eventHeader.text = event.venue.name;
    [self.contentView addSubview:self.eventHeader];
    
    [self updateDate];
    
    for (int i = 0; i < events.count; i++) {
        Event *event = events[i];
        UIView *eventView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width * i, 0, self.contentView.frame.size.width, 200)];
        [self.eventScroll addSubview:eventView];
        
        UIImageView *eventImageView = [[UIImageView alloc] init];
        eventImageView.height = 200;
        eventImageView.width = eventView.size.width;
        //eventImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        eventImageView.contentMode = UIViewContentModeScaleAspectFill;
        eventImageView.clipsToBounds = YES;
        [eventImageView sd_setImageWithURL:event.venue.imageURL];
        [eventView addSubview:eventImageView];
        
        UIView *backgroundViewBlack = [[UIView alloc] initWithFrame:eventImageView.bounds];
        backgroundViewBlack.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
        //UIView *backgroundViewOrange = [[UIView alloc] initWithFrame:eventImageView.bounds];
        //backgroundViewOrange.backgroundColor = [UIColor colorWithRed:(199/255.) green:(88/255.) blue:(13/255.) alpha:.2 ];
        //backgroundViewBlack.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        //backgroundViewOrange.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [eventView addSubview:backgroundViewBlack];
        //[eventView addSubview:backgroundViewOrange];
        
        UILabel *venueTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 122, self.contentView.width, 30)];
        venueTitle.text = [NSString stringWithFormat:@"@ %@", [event.venue.name uppercaseString]];
        venueTitle.font = [ThemeManager lightFontOfSize:20];
        venueTitle.textColor = [UIColor whiteColor];
        //eventTitleLineOne.adjustsFontSizeToFitWidth = YES;
        //        [eventTitle setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
        venueTitle.textAlignment = NSTextAlignmentCenter;
        venueTitle.numberOfLines = 1;
        [eventView addSubview:venueTitle];
        
        UILabel *eventTitleLineOne = [[UILabel alloc] init];
        eventTitleLineOne.width = eventView.size.width - 50;
        eventTitleLineOne.x = 25;
        eventTitleLineOne.height = 60;
        eventTitleLineOne.y = 72;
        eventTitleLineOne.text = [event.title uppercaseString];
        eventTitleLineOne.font = [ThemeManager boldFontOfSize:20];
        eventTitleLineOne.textColor = [UIColor whiteColor];
        //eventTitleLineOne.adjustsFontSizeToFitWidth = YES;
//        [eventTitle setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
        eventTitleLineOne.textAlignment = NSTextAlignmentCenter;
        eventTitleLineOne.numberOfLines = 2;
        [eventView addSubview:eventTitleLineOne];

    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.eventScroll.frame.size.width;
    int page = floor((self.eventScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
    [self updateDate];
}

-(void)updateDate
{
    Event *event = self.events[self.pageControl.currentPage];
    self.eventHeader.text = [event.getDateAsString uppercaseString];
    CGSize stringBoundingBox = [self.eventHeader.text sizeWithAttributes:@{NSFontAttributeName:self.eventHeader.font}];
    self.eventHeader.width = stringBoundingBox.width + 20;
}

@end