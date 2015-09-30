//
//  FormView.m
//  Beacons
//
//  Created by Jeff Ames on 9/22/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FormView.h"
#import "InsetTextField.h"

@interface FormView() <UITextFieldDelegate>

@property (strong, nonatomic) NSArray *textFields;

@end

@implementation FormView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textColor = [UIColor unnormalizedColorWithRed:68 green:68 blue:68 alpha:255];
        self.placeholderTextColor = [UIColor unnormalizedColorWithRed:97 green:97 blue:97 alpha:255];
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame formTitles:(NSArray *)formTitles formPlaceholders:(NSArray *)formPlaceholders
{
    self = [self initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.formTitles = formTitles;
    self.formPlaceholders = formPlaceholders;
    return self;
}

- (void)setFormPlaceholders:(NSArray *)formPlaceholders
{
    _formPlaceholders = formPlaceholders;
    
    [self removeAllTextFields];
    NSMutableArray *textFields = [[NSMutableArray alloc] initWithCapacity:formPlaceholders.count];
    for (NSInteger i=0; i<formPlaceholders.count; i++) {
        NSString *title = formPlaceholders[i];
        CGRect textFieldFrame = CGRectZero;
        textFieldFrame.size.width = self.frame.size.width;
        textFieldFrame.size.height = self.frame.size.height/formPlaceholders.count;
        textFieldFrame.origin.y = i*textFieldFrame.size.height;
        textFieldFrame.origin.x = 85;
        InsetTextField *textField = [[InsetTextField alloc] initWithFrame:textFieldFrame];
        [textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        textField.delegate = self;
        textField.horizontalInset = 10;
        textField.placeholder = title;
        textField.textColor = self.textColor;
        textField.backgroundColor = [UIColor unnormalizedColorWithRed:250 green:250 blue:250 alpha:255];
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: self.placeholderTextColor}];
        [self addSubview:textField];
        [textFields addObject:textField];
        //add divider between text fields
        if (i < formPlaceholders.count - 1) {
            CGRect dividerFrame;
            dividerFrame.size = CGSizeMake(self.frame.size.width, 1);
            dividerFrame.origin.y = CGRectGetMaxY(textField.frame) - dividerFrame.size.height;
            UIView *dividerView = [[UIView alloc] initWithFrame:dividerFrame];
            dividerView.backgroundColor = [UIColor unnormalizedColorWithRed:231 green:231 blue:231 alpha:255];
            [self addSubview:dividerView];
            
            textField.returnKeyType = UIReturnKeyNext;
        }
        else {
            textField.returnKeyType = UIReturnKeyDone;
        }
    }
    self.textFields = [NSArray arrayWithArray:textFields];
}

- (void)setFormTitles:(NSArray *)formTitles
{
    _formTitles = formTitles;
    
    for (NSInteger i=0; i<formTitles.count; i++) {
        NSString *title = formTitles[i];
        CGRect textFieldFrame = CGRectZero;
        textFieldFrame.size.width = self.frame.size.width;
        textFieldFrame.size.height = self.frame.size.height/formTitles.count;
        if ([title isEqualToString:@"PROMO"]) {
            textFieldFrame.origin.y = i*textFieldFrame.size.height - 5;
        } else {
            textFieldFrame.origin.y = i*textFieldFrame.size.height;
        }
        textFieldFrame.origin.x = 25;
//        NSLog(@"frame = %@", NSStringFromCGRect(textFieldFrame));
        UILabel *fieldTitle = [[UILabel alloc] initWithFrame:textFieldFrame];
        fieldTitle.text = title;
        fieldTitle.textColor = self.textColor;
        fieldTitle.font = [ThemeManager mediumFontOfSize:14];
        [self addSubview:fieldTitle];
        //[textFields addObject:fieldTitle];
        //add divider between text fields
        //        if (i < formTitles.count - 1) {
        //            CGRect dividerFrame;
        //            dividerFrame.size = CGSizeMake(self.frame.size.width, 1);
        //            dividerFrame.origin.y = CGRectGetMaxY(textField.frame) - dividerFrame.size.height;
        //            UIView *dividerView = [[UIView alloc] initWithFrame:dividerFrame];
        //            //dividerView.backgroundColor = [UIColor lightGrayColor];
        //            [self addSubview:dividerView];
        //
        //            textField.returnKeyType = UIReturnKeyNext;
        //        }
        //        else {
        //            textField.returnKeyType = UIReturnKeyDone;
        //        }
    }
    
}

- (void)removeAllTextFields
{
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            [view removeFromSuperview];
        }
    }
}
                    
- (UITextField *)textFieldAtIndex:(NSInteger)index
{
    if (index < 0 || index > self.textFields.count - 1) {
        return nil;
    }
    UITextField *textField = self.textFields[index];
    return textField;
}

- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    for (UITextField *textField in self.textFields) {
        textField.textColor = textColor;
    }
}

- (void)setPlaceholderTextColor:(UIColor *)placeholderTextColor
{
    _placeholderTextColor = placeholderTextColor;
    for (UITextField *textField in self.textFields) {
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:textField.placeholder attributes:@{NSForegroundColorAttributeName: placeholderTextColor}];
    }
}

- (void)endEditing
{
    for (UITextField *textField in self.textFields) {
        if ([textField isFirstResponder]) {
            [textField resignFirstResponder];
        }
    }
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger index = [self.textFields indexOfObject:textField];
    if (index == self.textFields.count - 1) {
        return YES;
    }
    UITextField *nextTextField = self.textFields[index + 1];
    [nextTextField becomeFirstResponder];
    return NO;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(formView:textFieldDidChange:)]) {
        [self.delegate formView:self textFieldDidChange:textField];
    }
}


@end
