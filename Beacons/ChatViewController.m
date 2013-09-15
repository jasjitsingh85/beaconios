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

@property (strong, nonatomic) UITextView *textView;

@end

@implementation ChatViewController

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    CGRect textViewFrame;
    textViewFrame.size = CGSizeMake(self.view.frame.size.width, 35);
    textViewFrame.origin.x = 0.5*(self.view.frame.size.width - textViewFrame.size.width);
    textViewFrame.origin.y = self.view.frame.size.height - textViewFrame.size.height;
    self.textView = [[UITextView alloc] initWithFrame:textViewFrame];
    self.textView.delegate = self;
    self.textView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:self.textView];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view insertSubview:self.tableView belowSubview:self.textView];
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
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}


#pragma mark - Table view data source
- (void)reloadMessages
{
    [self.tableView reloadData];
    [UIView animateWithDuration:0.5 animations:^{
        UIEdgeInsets contentInsets = self.desiredEdgeInsets;
        contentInsets.bottom = self.view.frame.size.height - self.textView.frame.origin.y;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
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
    
    
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.origin.y -= kbSize.height;
    [UIView animateWithDuration:animationDuration animations:^{
        self.textView.frame = textViewFrame;
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
    CGRect textViewFrame = self.textView.frame;
    textViewFrame.origin.y += kbSize.height;
    [UIView animateWithDuration:animationDuration animations:^{
        self.textView.frame = textViewFrame;
        UIEdgeInsets contentInsets = self.desiredEdgeInsets;
        contentInsets.bottom = self.view.frame.size.height - self.textView.frame.origin.y;
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
