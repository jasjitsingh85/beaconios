//
//  JADatePicker.m
//  Beacons
//
//  Created by Jeff Ames on 9/28/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "JADatePicker.h"
#import "Theme.h"

@interface JADatePicker() <UIPickerViewDelegate, UIPickerViewDataSource>

@property (assign, nonatomic) NSInteger lastSelectedHourRow;

@end

@implementation JADatePicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.delegate = self;
    self.dataSource = self;
    self.minuteInterval = 15;
    [self setHour:12 minute:0 timePeriod:TimePeriodAM animated:NO];
    return self;
}

- (NSDateComponents *)componentsForDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:date];
    return components;
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    NSDateComponents *dateComponents = [self componentsForDate:date];
    TimePeriod timePeriod = dateComponents.hour < 12 ? TimePeriodAM : TimePeriodPM;
    [self setHour:dateComponents.hour minute:dateComponents.minute timePeriod:timePeriod animated:NO];
}

- (void)setHour:(NSInteger)hour minute:(NSInteger)minute timePeriod:(TimePeriod)timeperiod animated:(BOOL)animated
{
    hour = hour % 12;
    minute = minute % 60;
    NSInteger minuteRow = ceilf((CGFloat)minute/(self.minuteInterval));
    if (minuteRow == (60/self.minuteInterval)) {
        hour++;
    }
    if (hour == 12) {
        timeperiod = timeperiod == TimePeriodAM ? TimePeriodPM : TimePeriodAM;
    }
    timeperiod = timeperiod % 2;
    NSInteger hourOffset = INT16_MAX/(2*12)*12;
    NSInteger minuteOffset = INT16_MAX/(2*(60/self.minuteInterval))*(60/self.minuteInterval);
    NSInteger hourRow = hourOffset + hour;
    self.lastSelectedHourRow = hourRow;
    [self selectRow:(hourRow) inComponent:0 animated:animated];
    [self selectRow:(minuteOffset + minuteRow) inComponent:1 animated:animated];
    [self selectRow:timeperiod inComponent:2 animated:animated];
}

- (NSInteger)hour
{
    NSString *hourString = [self pickerView:self titleForRow:[self selectedRowInComponent:0] forComponent:0];
    NSInteger hour = hourString.integerValue;
    NSString *periodString = [self pickerView:self titleForRow:[self selectedRowInComponent:2] forComponent:2];
    hour += [periodString isEqualToString:@"PM"]*12;
    return hour;
}

- (NSInteger)minute
{
    NSString *minuteString = [self pickerView:self titleForRow:[self selectedRowInComponent:1] forComponent:1];
    return minuteString.integerValue;
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSInteger numberOfRows;
    if (component == 0) {
        numberOfRows = INT16_MAX;
    }
    else if (component == 1) {
        numberOfRows = INT16_MAX;
    }
    else {
        numberOfRows = 2;
    }
    return numberOfRows;
}
#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = @"";
    if (component == 0) {
        NSInteger hour = row % 12;
        if (!hour) {
            hour = 12;
        }
        title = @(hour).stringValue;
        CGFloat width = [self viewForRow:row forComponent:component].frame.size.width;
        if (width && hour == 12 && row > self.lastSelectedHourRow) {
            NSInteger timeperiod = [pickerView selectedRowInComponent:2];
            [pickerView selectRow:(timeperiod == TimePeriodAM ? TimePeriodPM : TimePeriodAM) inComponent:2 animated:YES];
            self.lastSelectedHourRow = row;
        }
    }
    else if (component == 1) {
        NSInteger minute = (row % (60/self.minuteInterval))*self.minuteInterval;
        title = [NSString stringWithFormat:@"%02d", minute];
    }
    else {
        title = row == 1 ? @"PM" : @"AM";
    }
    return title;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    UIFont *font = [ThemeManager regularFontOfSize:5];
    NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObject:font
                                                                forKey:NSFontAttributeName];
    NSString *string = [self pickerView:pickerView titleForRow:row forComponent:component];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attrsDictionary];
    return attrString;
}

- (UIView *)pickerView:(UIPickerView *)pickerView
            viewForRow:(NSInteger)row
          forComponent:(NSInteger)component
           reusingView:(UIView *)view {
    
    UILabel *pickerLabel = (UILabel *)view;
    
    if (pickerLabel == nil) {
        CGRect frame = CGRectMake(0.0, 0.0, 35, 30);
        pickerLabel = [[UILabel alloc] initWithFrame:frame];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentRight;
//        [pickerLabel setBackgroundColor:[UIColor clearColor]];
//        [pickerLabel setFont:[UIFont boldSystemFontOfSize:8]];
    }
    pickerLabel.textColor = [UIColor whiteColor];
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    return pickerLabel;
    
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 30;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    CGFloat width;
    if (component == 0) {
        width = 35;
    }
    else if (component == 1) {
        width = 35;
    }
    else {
        width = 45;
    }
    return width;
}

@end
