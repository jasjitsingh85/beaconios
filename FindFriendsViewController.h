//
//  FindFriendsViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/9/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@class FindFriendsViewController;
@protocol FindFriendsViewControllerDelegate <NSObject>

- (void)findFriendViewController:(FindFriendsViewController *)findFriendsViewController didPickContacts:(NSArray *)contacts;

@end

@interface FindFriendsViewController : UITableViewController

@property (weak, nonatomic) id<FindFriendsViewControllerDelegate>delegate;
@property (assign, nonatomic) BOOL autoCheckSuggested;
@property (strong, nonatomic) NSArray *selectedContacts;
@property (strong, nonatomic) NSArray *inactiveContacts;

@end
