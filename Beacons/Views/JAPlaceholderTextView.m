//
//  JAPlaceholderTextView.m
//  Beacons
//
//  Created by Jeff Ames on 9/29/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "JAPlaceholderTextView.h"
#import "JAInsetLabel.h"

@interface JAPlaceholderTextView()

@property (nonatomic, retain) JAInsetLabel *placeHolderLabel;

@end

@implementation JAPlaceholderTextView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Use Interface Builder User Defined Runtime Attributes to set
    // placeholder and placeholderColor in Interface Builder.
    if (!self.placeholder) {
        [self setPlaceholder:@""];
    }
    
    if (!self.placeholderColor) {
        [self setPlaceholderColor:[UIColor lightGrayColor]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
    self.textContainerInset = UIEdgeInsetsMake(2, 0, 2, 0);
}

- (id)initWithFrame:(CGRect)frame
{
    if( (self = [super initWithFrame:frame]) )
    {
        [self setPlaceholder:@""];
        [self setPlaceholderColor:[UIColor lightGrayColor]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textChanged:) name:UITextViewTextDidChangeNotification object:nil];
        self.textContainerInset = UIEdgeInsetsMake(2, 0, 2, 0);
    }
    return self;
}

- (void)setPlaceholderColor:(UIColor *)placeholderColor
{
    _placeholderColor = placeholderColor;
    self.placeHolderLabel.textColor = placeholderColor;
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset
{
    [super setTextContainerInset:textContainerInset];
    self.placeHolderLabel.edgeInsets = textContainerInset;
}

- (UILabel *)placeHolderLabel
{
    if (_placeHolderLabel == nil )
    {
        _placeHolderLabel = [[JAInsetLabel alloc] initWithFrame:CGRectMake(4, 0, self.frame.size.width, self.frame.size.height)];
        _placeHolderLabel.textAlignment = NSTextAlignmentLeft;
        _placeHolderLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _placeHolderLabel.numberOfLines = 0;
        _placeHolderLabel.font = self.font;
        _placeHolderLabel.backgroundColor = [UIColor clearColor];
        _placeHolderLabel.textColor = self.placeholderColor;
        _placeHolderLabel.alpha = 0;
        _placeHolderLabel.tag = 999;
        [self addSubview:_placeHolderLabel];
        [self sendSubviewToBack:_placeHolderLabel];
    }
    return _placeHolderLabel;
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder;
    self.placeHolderLabel.text = self.placeholder;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.placeHolderLabel.frame = CGRectMake(4, 0, frame.size.width, frame.size.height);
    [self updateInsets];
}

- (void)setFont:(UIFont *)font
{
    [super setFont:font];
    self.placeHolderLabel.font = font;
    [self updateInsets];
}

- (void)textChanged:(NSNotification *)notification
{
    if([[self placeholder] length] == 0)
    {
        return;
    }
    
    if([[self text] length] == 0)
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    else
    {
        [[self viewWithTag:999] setAlpha:0];
    }
    CGFloat textheight = [self.text boundingRectWithSize:CGSizeMake(self.frame.size.width - 8 - self.textContainerInset.left - self.textContainerInset.right, 10000.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:NULL].size.height;
    CGFloat desiredBuffer = self.textContainerInset.bottom + self.textContainerInset.top;
    CGFloat desiredHeight = textheight + desiredBuffer;
    if (desiredHeight > self.minimumSize.height) {
        if ([self.delegate respondsToSelector:@selector(placeholderTextView:desiresHeightChange:)]) {
            [self.delegate placeholderTextView:self desiresHeightChange:desiredHeight];
        }
    }
    else {
        if ([self.delegate respondsToSelector:@selector(placeholderTextView:desiresHeightChange:)]) {
            [self.delegate placeholderTextView:self desiresHeightChange:self.minimumSize.height];
        }
    }
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self textChanged:nil];
}

- (void)updateInsets
{
    if (!self.font) {
        return;
    }
    NSString *text = self.text && self.text.length ? self.text : @" ";
    CGFloat textheight = [text boundingRectWithSize:CGSizeMake(self.frame.size.width - 8 - self.textContainerInset.left - self.textContainerInset.right, 10000.0) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : self.font} context:NULL].size.height;
    CGFloat buffer = 0.5*(self.frame.size.height - textheight);
    self.textContainerInset = UIEdgeInsetsMake(buffer, self.textContainerInset.left, buffer, self.textContainerInset.right);
}

- (void)drawRect:(CGRect)rect
{
    if( [[self text] length] == 0 && [[self placeholder] length] > 0 )
    {
        [[self viewWithTag:999] setAlpha:1];
    }
    
    [super drawRect:rect];
}

@end
