//
//  ChatViewController.h
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JAPlaceholderTextView.h"

@class ChatViewController, ChatMessage, JAPlaceholderTextView;
@protocol ChatViewControllerDelegate <NSObject>
@optional
- (void)chatViewController:(ChatViewController *)chatViewController didScrollScrollView:(UIScrollView *)scrollView;
- (void)chatViewController:(ChatViewController *)chatViewController willEndDraggingWithVelocity:(CGPoint)velocity;
- (void)chatViewController:(ChatViewController *)chatViewController didSelectChatMessage:(ChatMessage *)chatMessage;
- (void)chatViewController:(ChatViewController *)chatViewController didLoadChatMessages:(NSArray *)chatMessages;

@end


@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, JAPlaceholderTextViewDelegate, UIImagePickerControllerDelegate>

@property (strong, nonatomic) UIView *textViewContainer;
@property (strong, nonatomic) JAPlaceholderTextView *textView;
@property (strong, nonatomic) UIButton *cameraButton;
@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *messages;
@property (assign, nonatomic) UIEdgeInsets desiredEdgeInsets;
@property (weak, nonatomic) id<ChatViewControllerDelegate>  chatViewControllerDelegate;

- (void)cameraButtonTouched:(id)sender;
- (void)didEnterText:(NSString *)text;
- (void)reloadMessages;
- (void)dismissKeyboard;

@end
