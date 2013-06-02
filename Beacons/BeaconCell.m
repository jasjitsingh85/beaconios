//
//  BeaconCell.m
//  Beacons
//
//  Created by Jeff Ames on 6/1/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "BeaconCell.h"
#import <QuartzCore/QuartzCore.h>

@interface BeaconCell()

@property (strong, nonatomic) UIImageView *avatarImageView;
@property (strong, nonatomic) UILabel *titleLable;
@property (strong, nonatomic) UILabel *descriptionLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UILabel *timeLabel;

@end

@implementation BeaconCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, frame.size.width, frame.size.height)];
        self.label.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.font = [UIFont boldSystemFontOfSize:50.0];
        self.label.backgroundColor = [UIColor whiteColor];
        self.label.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.label];;
        self.contentView.layer.cornerRadius = 2;
        self.contentView.clipsToBounds = YES;
        
        //add drop shadow. Must be applied to contentView's superview since contentView clips to bounds
        self.layer.cornerRadius = self.contentView.layer.cornerRadius;
        self.layer.shadowColor = [[UIColor blackColor] CGColor];
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 1.0;
        self.layer.shadowOffset = CGSizeMake(0, 1);
        self.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:self.contentView.layer.cornerRadius].CGPath;
    }
    return self;
}


@end
