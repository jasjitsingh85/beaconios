//
//  Payments.m
//  Beacons
//
//  Created by Jasjit Singh on 4/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "PaymentsViewController.h"
#import "APIClient.h"
#import "Deal.h"
#import "Venue.h"
#import "BeaconProfileViewController.h"

@interface PaymentsViewController()

    @property (strong, nonatomic) NSString *clientToken;
    @property (strong, nonatomic) NSString *nonce;

@end

@implementation PaymentsViewController

@synthesize beaconProfileViewController = _beaconProfileViewController;


- (id) initWithClientToken: (NSString *)clientToken  {
    self = [super init];
    self.clientToken = clientToken;
    if (!self) {
        return nil;
    } else {
        return self;
    }
}

- (void)openPaymentModalWithDeal: (Deal *)deal {
    
    // Create and retain a `Braintree` instance with the client token
    [Braintree setupWithClientToken:self.clientToken completion:^(Braintree *braintree, NSError *error) {
        //self.braintree = [Braintree braintreeWithClientToken:self.clientToken];
        // Create a BTDropInViewController
        self.braintree = braintree;
        BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
        // This is where you might want to customize your Drop in. (See below.)
        //
        dropInViewController.summaryTitle = [NSString stringWithFormat:@"$%@ per %@", deal.itemPrice, deal.itemName];
        dropInViewController.summaryDescription = @"You will only be charged for redeemed drinks";
        //NSLog(@"ITEM PRICE: %@", deal.itemPrice);
        //dropInViewController.displayAmount = [NSString stringWithFormat:@"$%@ per %@", deal.itemPrice, deal.itemName];
        dropInViewController.callToActionText = @"Open Tab";
        dropInViewController.view.tintColor = [[ThemeManager sharedTheme] blueColor];
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally presented navigation controller:
            dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                                  target:self
                                                                                                                  action:@selector(userDidCancelPayment)];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
        navigationController.navigationBar.topItem.title = @"ONE TIME SETUP";
        navigationController.navigationBar.barTintColor = [[ThemeManager sharedTheme] redColor];
        navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor whiteColor], NSFontAttributeName : [ThemeManager lightFontOfSize:18]};
        navigationController.navigationBar.tintColor = [UIColor whiteColor];
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
    }];
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    self.nonce = paymentMethod.nonce;
    NSLog(@"DID SUCCEED WITH PAYMENT METHOD: %@", paymentMethod);
    [self postNonceToServer:self.nonce]; // Send payment method nonce to your server
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    [[APIClient sharedClient] postPurchase:paymentMethodNonce forBeaconWithID:self.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success %@", responseObject[@"dismiss_payment_modal"]);
        NSString *dismiss_payment_modal_string = responseObject[@"dismiss_payment_modal"];
        NSLog(@"DISMISS PAYMENT MODAL: %d", [dismiss_payment_modal_string boolValue]);
        BOOL dismiss_payment_modal = [dismiss_payment_modal_string boolValue];
        if (dismiss_payment_modal) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.beaconProfileViewController refreshDeal];
        } else {
            [self showCardDeclined];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showCardDeclined];
        NSLog(@"Failure");
    }];
}

- (void) showCardDeclined
{
    [[[UIAlertView alloc] initWithTitle:@"Card Declined" message:@"Please try another payment method" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

@end
