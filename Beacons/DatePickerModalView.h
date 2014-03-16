//
//  DatePickerModalView.h
//  Beacons
//
//  Created by Jeffrey Ames on 3/16/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DatePickerModalView : UIView

@property (strong, nonatomic) UIDatePicker *datePicker;

- (void)show;

@end
