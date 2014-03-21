//
//  DatePickerModalView.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/16/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "DatePickerModalView.h"
#import "UIView+Shadow.h"
#import "NSDate+FormattedDate.h"

@interface DatePickerModalView()

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *dateContainerView;

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
    self.backgroundView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.1];
    UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    backgroundTap.numberOfTapsRequired = 1;
    [self.backgroundView addGestureRecognizer:backgroundTap];
    [self addSubview:self.backgroundView];
    
    
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.backgroundColor = [UIColor whiteColor];
    [self.datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.dateContainerView = [[UIView alloc] init];
    self.dateContainerView.height = 302;
    self.dateContainerView.width = self.width;
    self.dateContainerView.bottom = self.height;
    self.dateContainerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.datePicker.centerY = self.dateContainerView.height/2.0;
    [self.dateContainerView addSubview:self.datePicker];
    [self addSubview:self.dateContainerView];
    [self.dateContainerView setShadowWithColor:[UIColor blackColor] opacity:0.5 radius:8 offset:CGSizeMake(0, -4) shouldDrawPath:YES];
    self.dateContainerView.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.dateContainerView addGestureRecognizer:tap];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downArrowRed"]];
    arrowImageView.y = 12;
    arrowImageView.centerX = self.dateContainerView.width/2.0;
    [self.dateContainerView addSubview:arrowImageView];
    
    return self;
}

- (void)show
{
    UIViewController *rootViewController = rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    [rootViewController.view addSubview:self];
    
    self.backgroundView.alpha = 0;
    self.dateContainerView.transform = CGAffineTransformMakeTranslation(0, self.dateContainerView.height);
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundView.alpha = 1;
        self.dateContainerView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.2 animations:^{
        self.backgroundView.alpha = 0;
        self.dateContainerView.transform = CGAffineTransformMakeTranslation(0, self.dateContainerView.height);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dateChanged:(id)sender
{
}

@end
