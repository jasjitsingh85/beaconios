//
//  DatePickerModalView.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/16/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DatePickerModalView.h"
#import "NSDate+FormattedDate.h"

@interface DatePickerModalView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UILabel *datePreviewLabel;
@property (strong, nonatomic) UIView *dateContainerView;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation DatePickerModalView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    [self addSubview:self.backgroundView];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateFormat = @"EdMMM";
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    self.datePreviewLabel = [[UILabel alloc] init];
    self.datePreviewLabel.textColor = [UIColor blueColor];
    self.datePreviewLabel.size = CGSizeMake(300, 20);
    self.datePreviewLabel.x = 20;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    tap.numberOfTapsRequired = 1;
    [self.datePreviewLabel addGestureRecognizer:tap];
    self.datePreviewLabel.userInteractionEnabled = YES;
    self.datePreviewLabel.text = [self.dateFormatter stringFromDate:self.datePicker.date];
    
    self.dateContainerView = [[UIView alloc] init];
    self.dateContainerView.height = self.datePreviewLabel.height + self.datePicker.height;
    self.dateContainerView.width = self.width;
    self.dateContainerView.bottom = self.height;
    self.dateContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.datePicker.bottom = self.dateContainerView.height;
    [self.dateContainerView addSubview:self.datePicker];
    [self.dateContainerView addSubview:self.datePreviewLabel];
    [self addSubview:self.dateContainerView];
    self.dateContainerView.backgroundColor = [UIColor whiteColor];
    
    return self;
}

- (void)show
{
    UIViewController *rootViewController = rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController.view addSubview:self];
    
    self.backgroundView.alpha = 0;
    self.dateContainerView.transform = CGAffineTransformMakeTranslation(0, self.dateContainerView.height);
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 1;
        self.dateContainerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0;
        self.dateContainerView.transform = CGAffineTransformMakeTranslation(0, self.dateContainerView.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dateChanged:(id)sender
{
    self.datePreviewLabel.text = [self.datePicker.date fullFormattedDate];
}

@end
