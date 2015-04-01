//
//  FormView.h
//  Beacons
//
//  Created by Jeff Ames on 9/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FormView;
@protocol FormViewDelegate <NSObject>

- (void)formView:(FormView *)formView textFieldDidChange:(UITextField *)textField;

@end

@interface FormView : UIView

@property (weak, nonatomic) id<FormViewDelegate> delegate;
@property (strong, nonatomic) NSArray *formTitles;
@property (strong, nonatomic) NSArray *formPlaceholders;
@property (strong, nonatomic) NSArray *keyboardTypes;
@property (strong, nonatomic) UIColor *placeholderTextColor;
@property (strong, nonatomic) UIColor *textColor;

- (id)initWithFrame:(CGRect)frame formTitles:(NSArray *)formTitles formPlaceholders:(NSArray *)formPlaceholders;
- (UITextField *)textFieldAtIndex:(NSInteger)index;
- (void)endEditing;

@end
