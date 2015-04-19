//
//  Payments.m
//  Beacons
//
//  Created by Jasjit Singh on 4/7/15.
//  Copyright (c) 2015 Jeff Ames. All rights reserved.
//

#import "PaymentsViewController.h"
#import "APIClient.h"

@interface PaymentsViewController()

    @property (strong, nonatomic) NSString *clientToken;
    @property (strong, nonatomic) NSString *nonce;

@end

@implementation PaymentsViewController


- (id) initWithClientToken: (NSString *)clientToken  {
    self = [super init];
    NSLog(@"Client Token: %@", clientToken);
    self.clientToken = clientToken;
    if (!self) {
        return nil;
    } else {
        return self;
    }
}

- (void)openPaymentModal {

    // Create and retain a `Braintree` instance with the client token
    self.braintree = [Braintree braintreeWithClientToken:self.clientToken];
    // Create a BTDropInViewController
    BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
    // This is where you might want to customize your Drop in. (See below.)
    
    dropInViewController.summaryTitle = @"Margarita at Oaxaca";
    dropInViewController.summaryDescription = @"To ensure speedy service (and low fees) Oaxaca requires you open a tab through Hotspot";
    dropInViewController.displayAmount = @"$3";
    dropInViewController.callToActionText = @"Open Tab";
    
    // The way you present your BTDropInViewController instance is up to you.
    // In this example, we wrap it in a new, modally presented navigation controller:
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                          target:self
                                                                                                          action:@selector(userDidCancelPayment)];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    self.nonce = paymentMethod.nonce;
    [self postNonceToServer:self.nonce]; // Send payment method nonce to your server
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    [[APIClient sharedClient] postPurchase:paymentMethodNonce forBeaconWithID:self.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Success %@", responseObject[@"payment_authorized"]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Failure");
    }];
}

@end
