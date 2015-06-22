//
//  DealDetailViewController.m
//  Beacons
//
//  Created by Jasjit Singh on 6/21/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DealDetailViewController.h"
#import "Deal.h"
#import "Venue.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DealDetailViewController ()

@property (strong, nonatomic) UIButton *getDealButton;
@property (strong, nonatomic) UIImageView *venueImageView;
@property (strong, nonatomic) UIImageView *backgroundGradient;
@property (strong, nonatomic) UILabel *venueLabelLineOne;
@property (strong, nonatomic) UILabel *venueLabelLineTwo;
@property (strong, nonatomic) UILabel *distanceLabel;
@property (strong, nonatomic) UILabel *dealTime;

@end

@implementation DealDetailViewController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    UIScrollView *mainScroll = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    
    mainScroll.scrollEnabled = YES;
    mainScroll.userInteractionEnabled = YES;
    
    mainScroll.showsVerticalScrollIndicator = NO;
    
    mainScroll.contentSize = CGSizeMake(self.view.width, 1000);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.venueImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 166)];
    self.venueImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.venueImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.venueImageView.clipsToBounds = YES;
    [mainScroll addSubview:self.venueImageView];
    
    self.backgroundGradient = [[UIImageView alloc] initWithFrame:CGRectMake(0, 105, self.venueImageView.size.width, 60)];
    UIImage *gradientImage = [UIImage imageNamed:@"backgroundGradient@2x.png"];
    [self.backgroundGradient setImage:gradientImage];
    [self.venueImageView addSubview:self.backgroundGradient];
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:self.venueImageView.bounds];
    backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    backgroundView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.venueImageView addSubview:backgroundView];
    
    self.venueLabelLineOne = [[UILabel alloc] init];
    self.venueLabelLineOne.font = [ThemeManager boldFontOfSize:28];
    self.venueLabelLineOne.textColor = [UIColor whiteColor];
    self.venueLabelLineOne.width = self.view.width - 20;
    self.venueLabelLineOne.x = 10;
    self.venueLabelLineOne.height = 30;
    self.venueLabelLineOne.y = 50;
    //self.venueLabelLineOne.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineOne.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineOne.numberOfLines = 1;
    [self.venueImageView addSubview:self.venueLabelLineOne];
    
    self.venueLabelLineTwo = [[UILabel alloc] init];
    self.venueLabelLineTwo.font = [ThemeManager boldFontOfSize:36];
    self.venueLabelLineTwo.textColor = [UIColor whiteColor];
    self.venueLabelLineTwo.width = self.view.width - 20;
    self.venueLabelLineTwo.x = 10;
    self.venueLabelLineTwo.height = 46;
    self.venueLabelLineTwo.y = 79;
    //self.venueLabelLineTwo.adjustsFontSizeToFitWidth = YES;
    //[self.venueLabel setShadowWithColor:[UIColor blackColor] opacity:0.8 radius:2 offset:CGSizeMake(0, 1) shouldDrawPath:NO];
    self.venueLabelLineTwo.textAlignment = NSTextAlignmentLeft;
    self.venueLabelLineTwo.numberOfLines = 1;
    [self.venueImageView addSubview:self.venueLabelLineTwo];
    
    self.getDealButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.getDealButton.size = CGSizeMake(self.view.width, 35);
    self.getDealButton.centerX = self.view.width/2.0;
    self.getDealButton.y = self.view.height - 35;
    self.getDealButton.backgroundColor = [[ThemeManager sharedTheme] lightBlueColor];
    [self.getDealButton setTitle:@"GET THIS DEAL" forState:UIControlStateNormal];
    self.getDealButton.titleLabel.font = [ThemeManager mediumFontOfSize:17];
    [self.getDealButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.getDealButton setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateSelected];
    [self.getDealButton addTarget:self action:@selector(inviteButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.dealTime = [[UILabel alloc] init];
    self.dealTime.font = [ThemeManager lightFontOfSize:16];
    self.dealTime.textColor = [UIColor whiteColor];
    //self.dealTime.adjustsFontSizeToFitWidth = YES;
    self.dealTime.width = 200;
    self.dealTime.height = 20;
    self.dealTime.x = 13;
    self.dealTime.y=135;
    self.dealTime.textAlignment = NSTextAlignmentLeft;
    self.dealTime.numberOfLines = 0;
    [self.venueImageView addSubview:self.dealTime];
    
    self.distanceLabel = [[UILabel alloc] init];
    self.distanceLabel.font = [ThemeManager lightFontOfSize:16];
    self.distanceLabel.size = CGSizeMake(67, 20);
    //self.distanceLabel.layer.cornerRadius = self.distanceLabel.width/2.0;
    //self.distanceLabel.clipsToBounds = YES;
    self.distanceLabel.textAlignment = NSTextAlignmentRight;
    self.distanceLabel.y = 135;
    self.distanceLabel.x = self.view.width - 80;
    self.distanceLabel.textColor = [UIColor whiteColor];
    [self.venueImageView addSubview:self.distanceLabel];
    
    UIImageView *dealIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dollarSign"]];
    dealIcon.centerX = self.view.width/2;
    dealIcon.y = 180;
    [mainScroll addSubview:dealIcon];
    
    UILabel *dealHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 200, self.view.width, 30)];
    dealHeadingLabel.centerX = self.view.width/2;
    dealHeadingLabel.text = @"THE DEAL";
    dealHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    dealHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroll addSubview:dealHeadingLabel];
    
    UILabel *dealTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 220, self.view.width, 30)];
    dealTextLabel.centerX = self.view.width/2;
    dealTextLabel.font = [ThemeManager lightFontOfSize:13];
    dealTextLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroll addSubview:dealTextLabel];
    
    UIImageView *venueIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"venueIcon"]];
    venueIcon.centerX = self.view.width/2;
    venueIcon.y = 260;
    [mainScroll addSubview:venueIcon];
    
    UILabel *venueHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 280, self.view.width, 30)];
    venueHeadingLabel.centerX = self.view.width/2;
    venueHeadingLabel.text = @"THE VENUE";
    venueHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    venueHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroll addSubview:venueHeadingLabel];
    
    UILabel *venueTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 300, self.view.width, 60)];
    venueTextLabel.centerX = self.view.width/2;
    venueTextLabel.font = [ThemeManager lightFontOfSize:13];
    venueTextLabel.width = self.view.width - 50;
    venueTextLabel.centerX = self.view.width/2;
    venueTextLabel.numberOfLines = 0;
    venueTextLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroll addSubview:venueTextLabel];
    
    UIImageView *docIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"documentIcon"]];
    docIcon.centerX = self.view.width/2;
    docIcon.y = venueTextLabel.y + venueTextLabel.size.height + 10;
    [mainScroll addSubview:docIcon];
    
    UILabel *docHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, venueTextLabel.y + venueTextLabel.size.height + 30, self.view.width, 30)];
    docHeadingLabel.centerX = self.view.width/2;
    docHeadingLabel.text = @"HOW THIS WORKS";
    docHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    docHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroll addSubview:docHeadingLabel];
    
    UILabel *docTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, venueTextLabel.y + venueTextLabel.size.height + 50, self.view.width, 60)];
    docTextLabel.centerX = self.view.width/2;
    docTextLabel.font = [ThemeManager lightFontOfSize:13];
    docTextLabel.width = self.view.width - 50;
    docTextLabel.centerX = self.view.width/2;
    docTextLabel.numberOfLines = 0;
    docTextLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroll addSubview:docTextLabel];
    
    UIImageView *directionsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"directionsIcon"]];
    directionsIcon.centerX = self.view.width/2;
    directionsIcon.y = docTextLabel.y + docTextLabel.size.height + 10;
    [mainScroll addSubview:directionsIcon];
    
    UILabel *directionHeadingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, docTextLabel.y + docTextLabel.size.height + 30, self.view.width, 30)];
    directionHeadingLabel.centerX = self.view.width/2;
    directionHeadingLabel.text = @"DIRECTIONS";
    directionHeadingLabel.font = [ThemeManager boldFontOfSize:12];
    directionHeadingLabel.textAlignment = NSTextAlignmentCenter;
    [mainScroll addSubview:directionHeadingLabel];
    
    [self.view addSubview:mainScroll];
   
    NSMutableDictionary *venueName = [self parseStringIntoTwoLines:self.deal.venue.name];
    self.venueLabelLineOne.text = [[venueName objectForKey:@"firstLine"] uppercaseString];
    self.venueLabelLineTwo.text = [[venueName objectForKey:@"secondLine"] uppercaseString];
    [self.venueImageView sd_setImageWithURL:self.deal.venue.imageURL];
    self.distanceLabel.text = [self stringForDistance:self.deal.venue.distance];
    self.dealTime.text = [self.deal.dealStartString uppercaseString];
    dealTextLabel.text = [NSString stringWithFormat:@"You get a %@ for $%@", [self.deal.itemName lowercaseString], self.deal.itemPrice];
    venueTextLabel.text = self.deal.venue.placeDescription;
    docTextLabel.text = @"Just tap 'Get This Deal', pay for your drink, and present the voucher to your server. You will only be charged once the voucher is redeemed";
    
    [self.view addSubview:self.getDealButton];
    
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

- (NSString *)stringForDistance:(CLLocationDistance)distance
{
    //   CGFloat distanceMiles = METERS_TO_MILES*distance;
    NSString *distanceString;
    //    if (distanceMiles < 0.25) {
    //        distanceString = [NSString stringWithFormat:@"%0.0fft", (floor((METERS_TO_FEET*distance)/10))*10];
    //    }
    //    else {
    //distanceString = [NSString stringWithFormat:@"%0.1fmi", METERS_TO_MILES*distance];
    //    }
    distanceString = [NSString stringWithFormat:@"%0.1f mi", METERS_TO_MILES*distance];
    return distanceString;
}

@end