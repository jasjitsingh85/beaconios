//
//  Header.h
//  Beacons
//
//  Created by Jasjit Singh on 4/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import <Braintree/Braintree.h>

@interface PaymentsViewController () <BTDropInViewControllerDelegate>

@property (nonatomic, strong) Braintree *braintree;

@end
