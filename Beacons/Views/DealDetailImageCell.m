//
//  DealTableViewCell.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "AppDelegate.h"
#import "DealDetailImageCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#include <tgmath.h>
#import "Utilities.h"
#import "UIView+Shadow.h"
#import <BlocksKit/UIActionSheet+BlocksKit.h>
#import "Venue.h"
#import <QuartzCore/QuartzCore.h>
//#import "SetDealViewController.h"
#import "CenterNavigationController.h"

@interface DealDetailImageCell()

@property (strong, nonatomic) UIImageView *imageSourceIcon;

@end

@implementation DealDetailImageCell

@synthesize photoScroll=photoScroll_;
@synthesize pageControl=pageControl_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
    {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)setVenue:(Venue *)venue
{
    _venue = venue;
    
//    NSURL *photo_url = self.venue.photos[0];
    
    self.photoScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 200)];
    self.photoScroll.pagingEnabled = YES;
    self.photoScroll.showsHorizontalScrollIndicator = NO;
    self.photoScroll.contentSize = CGSizeMake(self.contentView.frame.size.width * venue.photos.count, self.contentView.frame.size.height);
    self.photoScroll.backgroundColor = [UIColor blackColor];
    self.photoScroll.delegate = self;
    [self.contentView addSubview:self.photoScroll];
    
    [self.photoScroll setUserInteractionEnabled:NO];
    [self.contentView addGestureRecognizer:self.photoScroll.panGestureRecognizer];
    
    self.pageControl = [[UIPageControl alloc] init];
    self.pageControl.hidesForSinglePage = NO;
    self.pageControl.height = 25;
    self.pageControl.width = self.contentView.size.width;
    self.pageControl.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.pageControl.numberOfPages = venue.photos.count;
    //self.pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    //self.pageControl.pageIndicatorTintColor = [[UIColor blackColor] colorWithAlphaComponent:.2];
    self.pageControl.centerX = self.contentView.width/2;
    self.pageControl.y = 175;
    //self.pageControl.currentPageIndicatorTintColor = [[ThemeManager sharedTheme] redColor];
    //self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:.6];
    //[self.pageControl sizeToFit];
    [self.contentView addSubview:self.pageControl];
    
//    self.eventHeader = [[UILabel alloc] init];
//    self.eventHeader.textColor = [UIColor whiteColor];
//    self.eventHeader.font = [ThemeManager boldFontOfSize:13];
////    self.eventHeader.backgroundColor = [UIColor unnormalizedColorWithRed:31 green:186 blue:98 alpha:204];
//    self.eventHeader.backgroundColor = [[ThemeManager sharedTheme] greenColor];
//    self.eventHeader.textAlignment = NSTextAlignmentCenter;
//    self.eventHeader.width = 140;
//    self.eventHeader.height = 24;
//    self.eventHeader.x = 0;
//    self.eventHeader.y = 25;
//    self.eventHeader.text = event.venue.name;
//    [self.contentView addSubview:self.eventHeader];
    
//    [self updateDate];
    
    for (int i = 0; i < venue.photos.count + 1; i++) {
        if (i == 0) {
            UIImageView *firstPhoto = [self getFirstImageView];
            [self.photoScroll addSubview: firstPhoto];
        } else {
            NSURL *photo_url = venue.photos[i - 1];
            UIView *photoView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width * i, 0, self.contentView.frame.size.width, 200)];
            [self.photoScroll addSubview:photoView];
            
            UIImageView *photoImageView = [[UIImageView alloc] init];
            photoImageView.height = photoView.size.height;
            photoImageView.width = photoView.size.width;
            //photoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            photoImageView.contentMode = UIViewContentModeScaleAspectFit;
//            photoImageView.clipsToBounds = YES;
            [photoImageView sd_setImageWithURL:photo_url];
            [photoView addSubview:photoImageView];
        }
    }
    
    self.imageSourceIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instagramLogo"]];
    self.imageSourceIcon.x = self.contentView.size.width - 30;
    self.imageSourceIcon.y = 170;
    self.imageSourceIcon.alpha = 0;
    [self.contentView addSubview:self.imageSourceIcon];
    
    if (venue.photos.count == 0) {
        self.pageControl.hidden = YES;
    }
    
}

-(UIImageView *)getFirstImageView
{
    UIImageView *venueImageView = [[UIImageView alloc] init];
    venueImageView.height = 196;
    venueImageView.width = self.contentView.width;
    venueImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    venueImageView.contentMode = UIViewContentModeScaleAspectFill;
    venueImageView.clipsToBounds = YES;
    
    UIView *venuePreviewView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.contentView.frame.size.width, 146)];
    UIImageView *backgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 70, venueImageView.size.width, 196)];
    UIImage *gradientImage = [UIImage imageNamed:@"updatedBackgroundGradient@2x.png"];
    [backgroundGradient setImage:gradientImage];
    [venueImageView addSubview:backgroundGradient];
    
    UILabel *venueLabelLineOne = [[UILabel alloc] init];
    venueLabelLineOne.font = [ThemeManager lightFontOfSize:25];
    venueLabelLineOne.textColor = [UIColor whiteColor];
    venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
    venueLabelLineOne.numberOfLines = 1;
    venueLabelLineOne.width = self.contentView.width - 20;
    venueLabelLineOne.x = 5;
    venueLabelLineOne.y = 122;
    venueLabelLineOne.height = 30;
    [venuePreviewView addSubview:venueLabelLineOne];
    
    UILabel *venueLabelLineTwo = [[UILabel alloc] init];
    venueLabelLineTwo.font = [ThemeManager boldFontOfSize:25];
    venueLabelLineTwo.textColor = [UIColor whiteColor];
    venueLabelLineTwo.textAlignment = NSTextAlignmentLeft;
    venueLabelLineTwo.numberOfLines = 1;
    venueLabelLineTwo.width = self.contentView.width - 20;
    venueLabelLineTwo.x = 5;
    venueLabelLineTwo.y = 136;
    venueLabelLineTwo.height = 46;
    [venuePreviewView addSubview:venueLabelLineTwo];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.height = 26;
    descriptionLabel.x = 0;
    descriptionLabel.y = 90;
    descriptionLabel.font = [ThemeManager boldFontOfSize:14];
    descriptionLabel.textColor = [UIColor whiteColor];
    descriptionLabel.textAlignment = NSTextAlignmentLeft;
    [venuePreviewView addSubview:descriptionLabel];

    
    NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.venue.name];
    venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
    venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];

    [venueImageView addSubview:venuePreviewView];
    
    [venueImageView sd_setImageWithURL:self.venue.imageURL];
    
    return venueImageView;
}


- (void)scrollViewDidScroll:(UIScrollView *)sender {
    CGFloat pageWidth = self.photoScroll.frame.size.width;
    int page = floor((self.photoScroll.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if (page > 0) {
        [self fadeInImage];
    } else {
        [self fadeOutImage];
    }
    self.pageControl.currentPage = page;
}

- (void)setView:(UIImageView *)view hidden:(BOOL)hidden {
    [UIView transitionWithView:view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void){
        [view setHidden:hidden];
    } completion:nil];
}

- (void)fadeInImage
{
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:0.5];
    self.imageSourceIcon.alpha = 1;
    [UIView commitAnimations];
    
}

- (void)fadeOutImage
{
    [UIView beginAnimations:@"fade out" context:nil];
    [UIView setAnimationDuration:0.5];
    self.imageSourceIcon.alpha = 0;
    [UIView commitAnimations];
    
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

//-(void)updateDate
//{
//    Event *event = self.events[self.pageControl.currentPage];
//    self.eventHeader.text = [event.getDateAsString uppercaseString];
//    CGSize stringBoundingBox = [self.eventHeader.text sizeWithAttributes:@{NSFontAttributeName:self.eventHeader.font}];
//    self.eventHeader.width = stringBoundingBox.width + 20;
//}

@end