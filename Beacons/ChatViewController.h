//
//  ChatViewController.h
//  Beacons
//
//  Created by Jeff Ames on 9/4/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ChatViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) UITableView *tableView;
@property (strong, nonatomic) NSArray *messages;
@property (assign, nonatomic) UIEdgeInsets desiredEdgeInsets;

- (void)didEnterText:(NSString *)text;
- (void)reloadMessages;
- (void)dismissKeyboard;

@end
