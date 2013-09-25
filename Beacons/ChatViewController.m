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
#import "ChatTest.h"
#import "User.h"
#import "Theme.h"
#import "AppDelegate.h"

@interface ChatViewController ()

@property (strong, nonatomic) UIView *textViewContainer;
@property (strong, nonatomic) UITextView *textView;

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
    [super viewDidLoad];
    
    CGRect textViewContainerFrame;
    textViewContainerFrame.size = CGSizeMake(self.view.frame.size.width, 44);
    textViewContainerFrame.origin = CGPointMake(0, self.view.frame.size.height - textViewContainerFrame.size.height);
    self.textViewContainer = [[UIView alloc] initWithFrame:textViewContainerFrame];
    self.textViewContainer.backgroundColor = [UIColor colorWithRed:247/255.0 green:247/255.0 blue:247/255.0 alpha:1.0];
    self.textViewContainer.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.textViewContainer];
    
    self.cameraButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect cameraButtonFrame;
    cameraButtonFrame.size = CGSizeMake(44, 44);
    cameraButtonFrame.origin = CGPointMake(0, 0.5*(self.textViewContainer.frame.size.height - cameraButtonFrame.size.height));
    self.cameraButton.frame = cameraButtonFrame;
    [self.cameraButton setImage:[UIImage imageNamed:@"cameraSmall"] forState:UIControlStateNormal];
    [self.textViewContainer addSubview:self.cameraButton];
    
    CGRect textViewFrame;
    textViewFrame.size = CGSizeMake(self.view.frame.size.width - cameraButtonFrame.size.width - 10, 28);
    textViewFrame.origin.x = cameraButtonFrame.size.width;
    textViewFrame.origin.y = 0.5*(self.textViewContainer.frame.size.height - textViewFrame.size.height);
    self.textView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.textView.layer.cornerRadius = 4;
    self.textView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.textView.layer.borderWidth = 0.5;
    self.textView.delegate = self;
    [self.textViewContainer addSubview:self.textView];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.textViewContainer];
    self.tableView.backgroundColor = [[ThemeManager sharedTheme] darkColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, self.view.frame.size.height - self.textView.frame.origin.y, 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    self.desiredEdgeInsets = UIEdgeInsetsZero;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:) name:@"UIKeyboardWillShowNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:) name:@"UIKeyboardWillHideNotification" object:nil];
}


#pragma mark - Table view data source
- (void)reloadMessages
{
    [self.tableView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets contentInsets = self.desiredEdgeInsets;
        contentInsets.bottom = self.view.frame.size.height - self.textViewContainer.frame.origin.y;
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
    NSInteger maxLength = 200;
    if (text.length && textView.text.length > maxLength) {
        [[[UIAlertView alloc] initWithTitle:@"Max character limit reached" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return NO;
    }
    return YES;
}

- (void)didEnterText:(NSString *)text
{
    
}


@end