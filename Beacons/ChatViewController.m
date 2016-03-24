//
//  ChatViewController.m
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatMessage.h"
#import "ChatTableViewCell.h"
#import "User.h"
#import "Theme.h"
#import "AppDelegate.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import "JAPlaceholderTextView.h"

@interface ChatViewController ()

@end

@implementation ChatViewController

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    return self;
}

- (void)viewDidLoad
{
    
    CGRect textViewContainerFrame;
    textViewContainerFrame.size = CGSizeMake(self.view.frame.size.width, 44);
    textViewContainerFrame.origin = CGPointMake(0, self.view.frame.size.height - textViewContainerFrame.size.height - 140);
    self.textViewContainer = [[UIView alloc] initWithFrame:textViewContainerFrame];
    self.textViewContainer.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.textViewContainer];
    
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect cameraButtonFrame;
    cameraButtonFrame.size = CGSizeMake(44, 44);
    cameraButtonFrame.origin = CGPointMake(0, 0.5*(self.textViewContainer.frame.size.height - cameraButtonFrame.size.height));
    self.cameraButton.frame = cameraButtonFrame;
    [self.cameraButton addTarget:self action:@selector(cameraButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.cameraButton setImage:[UIImage imageNamed:@"cameraSmall"] forState:UIControlStateNormal];
    [self.textViewContainer addSubview:self.cameraButton];
    
    CGRect textViewFrame;
    textViewFrame.size = CGSizeMake(self.view.frame.size.width - cameraButtonFrame.size.width - 10, 32);
    textViewFrame.origin.x = cameraButtonFrame.size.width;
    textViewFrame.origin.y = 0.5*(self.textViewContainer.frame.size.height - textViewFrame.size.height);
    self.textView = [[JAPlaceholderTextView alloc] initWithFrame:textViewFrame];
    self.textView.centerVertically = YES;
    self.textView.minimumSize = textViewFrame.size;
    self.textView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5);
    self.textView.placeholder = @"Send a message";
    self.textView.placeholderColor = [UIColor darkGrayColor];
    self.textView.font = [ThemeManager lightFontOfSize:15];
    self.textView.layer.cornerRadius = 4;
    self.textView.backgroundColor = [UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0];
    self.textView.delegate = self;
    self.textView.returnKeyType = UIReturnKeySend;
    [self.textViewContainer addSubview:self.textView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.textViewContainer];
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height - self.textView.frame.origin.y, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    self.desiredEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0);
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)applicationWillResignActive:(NSNotification *)notification
{
    [self.textView resignFirstResponder];
}


#pragma mark - Table view data source
- (void)reloadMessages
{
    [self.tableView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets contentInsets = self.desiredEdgeInsets;
        contentInsets.bottom = self.view.frame.size.height - self.textViewContainer.frame.origin.y + 10;
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }];
    if (!self.messages || !self.messages.count) {
        return;
    }
    
    [self scrollToBottom];
}

- (void)scrollToBottom
{
    if (!self.messages || !self.messages.count) {
        return;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numRows = 0;
    if (self.messages) {
        numRows = self.messages.count;
    }
    return numRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMessage *chatMessage = self.messages[indexPath.row];
    return [ChatTableViewCell heightForChatMessage:chatMessage];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ChatTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[ChatTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    ChatMessage *chatMessage = self.messages[indexPath.row];
    cell.chatMessage = chatMessage;
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatTableViewCell *chatCell = (ChatTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (!chatCell || !chatCell.chatMessage) {
        return;
    }
    if ([self.chatViewControllerDelegate respondsToSelector:@selector(chatViewController:didSelectChatMessage:)]) {
        [self.chatViewControllerDelegate chatViewController:self didSelectChatMessage:chatCell.chatMessage];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    if ([self.chatViewControllerDelegate respondsToSelector:@selector(chatViewController:willEndDraggingWithVelocity:)]) {
        [self.chatViewControllerDelegate chatViewController:self willEndDraggingWithVelocity:velocity];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.chatViewControllerDelegate respondsToSelector:@selector(chatViewController:didScrollScrollView:)]) {
        [self.chatViewControllerDelegate chatViewController:self didScrollScrollView:scrollView];
    }
}


#pragma mark - Keyboard
- (void)dismissKeyboard
{
    [self.textView resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    
    CGRect textViewFrame = self.textViewContainer.frame;
    textViewFrame.origin.y -= kbSize.height;
    [UIView animateWithDuration:animationDuration animations:^{
        self.textViewContainer.frame = textViewFrame;
        UIEdgeInsets contentInsets = self.desiredEdgeInsets;
        contentInsets.bottom = self.view.frame.size.height - textViewFrame.origin.y;
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }];
    
    [self scrollToBottom];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary* info = [notification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGFloat animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect textViewFrame = self.textViewContainer.frame;
    textViewFrame.origin.y += kbSize.height;
    [UIView animateWithDuration:animationDuration animations:^{
        self.textViewContainer.frame = textViewFrame;
        UIEdgeInsets contentInsets = self.desiredEdgeInsets;
        contentInsets.bottom = self.view.frame.size.height - self.textViewContainer.frame.origin.y;
        self.tableView.contentInset = contentInsets;
        self.tableView.scrollIndicatorInsets = contentInsets;
    }];
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        if (![textView.text isEqualToString:@""]) {
            [self didEnterText:textView.text];
        }
        textView.text = @"";
        return NO;
    }
    NSInteger maxLength = 300;
    if (text.length && textView.text.length > maxLength) {
        [[[UIAlertView alloc] initWithTitle:@"Max character limit reached" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

- (void)placeholderTextView:(JAPlaceholderTextView *)placeholderTextView desiresHeightChange:(CGFloat)desiredHeight
{
    CGRect frame = placeholderTextView.frame;
    CGFloat oldHeight = frame.size.height;
    frame.size.height = desiredHeight;
    frame.origin.y -= desiredHeight - oldHeight;
    placeholderTextView.frame = frame;
}

- (void)didEnterText:(NSString *)text
{
    
}

- (void)cameraButtonTouched:(id)sender
{

}

@end
