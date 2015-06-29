//
//  FindFriendsViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@class FindFriendsViewController, Deal;
@protocol FindFriendsViewControllerDelegate <NSObject>

- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts andMessage:(NSString *)message andDate:(NSDate *)date;

@end

@interface FindFriendsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) id<FindFriendsViewControllerDelegate>delegate;
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) BOOL autoCheckSuggested;
@property (strong, nonatomic) NSArray *selectedContacts;
@property (strong, nonatomic) NSArray *inactiveContacts;
@property (strong, nonatomic) Deal *deal;

@end
