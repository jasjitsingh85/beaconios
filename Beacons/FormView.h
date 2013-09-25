//
//  FormView.h
//  Beacons
//
//  Created by Jeff Ames on 9/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormView : UIView

@property (strong, nonatomic) NSArray *formTitles;
@property (strong, nonatomic) NSArray *keyboardTypes;
@property (strong, nonatomic) UIColor *placeholderTextColor;
@property (strong, nonatomic) UIColor *textColor;

- (id)initWithFrame:(CGRect)frame formTitles:(NSArray *)formTitles;
- (UITextField *)textFieldAtIndex:(NSInteger)index;
- (void)endEditing;

@end
