//
//  JAPlaceholderTextView.h
//  Beacons
//
//  Created by Jeff Ames on 9/29/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@class JAPlaceholderTextView;
@protocol JAPlaceholderTextViewDelegate<NSObject, UITextViewDelegate>
@optional
- (void)placeholderTextView:(JAPlaceholderTextView *)placeholderTextView desiresHeightChange:(CGFloat)desiredHeight;

@end

@interface JAPlaceholderTextView : UITextView

@property (nonatomic, weak) id<JAPlaceholderTextViewDelegate> delegate;
@property (nonatomic, retain) NSString *placeholder;
@property (nonatomic, retain) UIColor *placeholderColor;
@property (nonatomic, assign) CGSize minimumSize;
@property (nonatomic, assign) BOOL centerVertically;

-(void)textChanged:(NSNotification*)notification;

@end
