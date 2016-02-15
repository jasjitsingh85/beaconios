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
    
    self.eventScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 151)];
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
    self.pageControl.y = 135;
    //self.pageControl.currentPageIndicatorTintColor = [[ThemeManager sharedTheme] redColor];
    //self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    //[self.pageControl sizeToFit];
    [self.contentView addSubview:self.pageControl];
    
//    self.eventHeader = [[UILabel alloc] init];
//    self.eventHeader.textColor = [UIColor whiteColor];
//    self.eventHeader.font = [ThemeManager boldFontOfSize:13];
////    self.eventHeader.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:204];
//    self.eventHeader.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
//    self.eventHeader.textAlignment = NSTextAlignmentCenter;
//    self.eventHeader.width = 140;
//    self.eventHeader.height = 24;
//    self.eventHeader.x = 0;
//    self.eventHeader.y = 25;
//    self.eventHeader.text = event.venue.name;
//    [self.contentView addSubview:self.eventHeader];
    
//    [self updateDate];
    
    for (int i = 0; i < events.count; i++) {
        Event *event = events[i];
        UIView *eventView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width * i, 0, self.contentView.frame.size.width, 200)];
        [self.eventScroll addSubview:eventView];
        
        UIImageView *eventImageView = [[UIImageView alloc] init];
        eventImageView.height = 151;
        eventImageView.width = eventView.size.width;
        //eventImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        eventImageView.contentMode = UIViewContentModeScaleAspectFill;
        eventImageView.clipsToBounds = YES;
        [eventImageView sd_setImageWithURL:event.venue.imageURL];
        [eventView addSubview:eventImageView];
        
        UIView *colorBackgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, 151)];
        colorBackgroundGradient.backgroundColor = [UIColor unnormalizedColorWithRed:27 green:20 blue:100 alpha:255];
        colorBackgroundGradient.alpha = .4;
        [eventView addSubview:colorBackgroundGradient];
        
        UILabel *eventTitleLineOne = [[UILabel alloc] init];
        eventTitleLineOne.x = 15;
        eventTitleLineOne.height = 26;
        eventTitleLineOne.y = 45;
        eventTitleLineOne.text = [NSString stringWithFormat:@"  %@  ", [event.title uppercaseString]];
        eventTitleLineOne.font = [ThemeManager boldFontOfSize:14];
        eventTitleLineOne.backgroundColor = [[ThemeManager sharedTheme] redColor];
        eventTitleLineOne.textColor = [UIColor whiteColor];
        CGFloat widthOfString = [self widthOfString:eventTitleLineOne.text withFont:eventTitleLineOne.font];
        if (widthOfString > self.width - 30) {
            eventTitleLineOne.width = self.width - 30;
        } else {
            eventTitleLineOne.width = widthOfString;
        }
        //eventTitleLineOne.adjustsFontSizeToFitWidth = YES;
        //        [eventTitle setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
        eventTitleLineOne.textAlignment = NSTextAlignmentLeft;
        eventTitleLineOne.numberOfLines = 1;
        [eventView addSubview:eventTitleLineOne];
        
        CGFloat stringWidth = [self widthOfString:[event.venue.name uppercaseString] withFont:[ThemeManager boldFontOfSize:14]];
        
//        NSMutableDictionary *venueName = [self parseStringIntoTwoLines:[event.venue.name uppercaseString]];
//        CGFloat firstStringWidth = [self widthOfString:[[venueName objectForKey:@"firstLine"] uppercaseString] withFont:[ThemeManager boldFontOfSize:14]];
//        CGFloat secondStringWidth = [self widthOfString:[[venueName objectForKey:@"secondLine"] uppercaseString] withFont:[ThemeManager boldFontOfSize:14]];
        
        UILabel *venueTitleLineOne = [[UILabel alloc] initWithFrame:CGRectMake(15, 57, stringWidth, 50)];
        venueTitleLineOne.text = [event.venue.name uppercaseString];
        venueTitleLineOne.font = [ThemeManager boldFontOfSize:14];
        venueTitleLineOne.textColor = [UIColor whiteColor];
        venueTitleLineOne.textAlignment = NSTextAlignmentLeft;
        venueTitleLineOne.numberOfLines = 1;
        [eventView addSubview:venueTitleLineOne];
        
//        UILabel *venueTitleLineTwo = [[UILabel alloc] initWithFrame:CGRectMake(15, 73, MAX(firstStringWidth, secondStringWidth), 50)];
//        venueTitleLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
//        venueTitleLineTwo.font = [ThemeManager boldFontOfSize:14];
//        venueTitleLineTwo.textColor = [UIColor whiteColor];
//        venueTitleLineTwo.textAlignment = NSTextAlignmentLeft;
//        venueTitleLineTwo.numberOfLines = 1;
//        [eventView addSubview:venueTitleLineTwo];
        
        UIView *verticalLine = [[UIView alloc] initWithFrame:CGRectMake(25 + stringWidth, 76, .5, 12.5)];
        verticalLine.backgroundColor = [UIColor whiteColor];
        [eventView addSubview:verticalLine];
        
        UILabel *dateString = [[UILabel alloc] init];
        dateString.textColor = [UIColor whiteColor];
        dateString.font = [ThemeManager mediumFontOfSize:13];
        dateString.textAlignment = NSTextAlignmentLeft;
        dateString.width = 250;
        dateString.height = 50;
        dateString.x = verticalLine.x + 10;
        dateString.y = 57;
        dateString.text = [event.getDateAsString uppercaseString];
        [eventView addSubview:dateString];
        
//        UILabel *extraString = [[UILabel alloc] initWithFrame:CGRectMake(dateString.x, 87, self.width, 20)];
//        extraString.textColor = [UIColor whiteColor];
//        extraString.font = [ThemeManager mediumFontOfSize:9];
//        extraString.text = [self getExtraEventString:event];
//        extraString.textAlignment = NSTextAlignmentLeft;
//        [eventView addSubview:extraString];
    }
    
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.eventScroll.frame.size.width;
    int page = floor((self.eventScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
//    [self updateDate];
}

//-(void)updateDate
//{
//    Event *event = self.events[self.pageControl.currentPage];
//    self.eventHeader.text = [event.getDateAsString uppercaseString];
//    CGSize stringBoundingBox = [self.eventHeader.text sizeWithAttributes:@{NSFontAttributeName:self.eventHeader.font}];
//    self.eventHeader.width = stringBoundingBox.width + 20;
//}

- (CGFloat)widthOfString:(NSString *)string withFont:(NSFont *)font {
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
    return [[[NSAttributedString alloc] initWithString:string attributes:attributes] size].width;
}

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