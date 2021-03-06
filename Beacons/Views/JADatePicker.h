//
//  JADatePicker.h
//  Beacons
//
//  Created by Jeff Ames on 9/28/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TimePeriodAM=0,
    TimePeriodPM,
} TimePeriod;

@class JADatePicker;
@protocol JADatePickerDelegate <NSObject>
@optional
- (void)userDidUpdateDatePicker:(JADatePicker *)datePicker;
@end

@interface JADatePicker : UIPickerView

@property (weak, nonatomic) id<JADatePickerDelegate> datePickerDelegate;
@property (strong, nonatomic) NSDate *date;
@property (assign, nonatomic) NSInteger minuteInterval;
@property (readonly) NSInteger hour;
@property (readonly) NSInteger minute;

- (void)setHour:(NSInteger)hour minute:(NSInteger)minute timePeriod:(TimePeriod)timeperiod animated:(BOOL)animated;

@end
