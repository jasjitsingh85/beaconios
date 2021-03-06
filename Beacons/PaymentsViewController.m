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
#import "RedemptionViewController.h"
#import "SponsoredEvent.h"
#import "EventStatus.h"

@interface PaymentsViewController()

    @property (strong, nonatomic) NSString *clientToken;
    @property (strong, nonatomic) NSString *nonce;
    @property (strong, nonatomic) SponsoredEvent *sponsoredEvent;

@end

@implementation PaymentsViewController

@synthesize redemptionViewController = _redemptionViewController;
@synthesize delegate;

- (id) initWithClientToken: (NSString *)clientToken  {
    self = [super init];
    self.clientToken = clientToken;
    self.inRegFlow = NO;
    if (!self) {
        return nil;
    } else {
        return self;
    }
}

- (void) openPaymentModalForOpenTab
{
    // Create and retain a `Braintree` instance with the client token
    //[Braintree setupWithClientToken:self.clientToken completion:^(Braintree *braintree, NSError *error) {
    self.braintree = [Braintree braintreeWithClientToken:self.clientToken];
    // Create a BTDropInViewController
    //        self.braintree = braintree;
    BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
    // This is where you might want to customize your Drop in. (See below.)
    //
    //    dropInViewController.summaryTitle = ;
    //    dropInViewController.summaryDescription = @"You won't be charged until your voucher is redeemed and you’ve received your drink";
    //    //NSLog(@"ITEM PRICE: %@", deal.itemPrice);
    //    //dropInViewController.displayAmount = [NSString stringWithFormat:@"$%@ per %@", deal.itemPrice, deal.itemName];
    dropInViewController.callToActionText = @"SAVE";
    dropInViewController.summaryTitle = @"Add Payment";
    dropInViewController.summaryDescription = @"Save time by linking payment before you go out. You're only charged when you actually buy drinks or tickets.";
    dropInViewController.view.tintColor = [[ThemeManager sharedTheme] lightBlueColor];
    
    // The way you present your BTDropInViewController instance is up to you.
    // In this example, we wrap it in a new, modally presented navigation controller:
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                          target:self
                                                                                                          action:@selector(userDidCancelPayment)];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
    navigationController.navigationBar.topItem.title = @"One Time Setup";
    navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [ThemeManager lightFontOfSize:17]};
    navigationController.navigationBar.tintColor = [[ThemeManager sharedTheme] redColor];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void) openPaymentModalWithEvent:(SponsoredEvent *)sponsoredEvent
{
    self.sponsoredEvent = sponsoredEvent;
    // Create and retain a `Braintree` instance with the client token
    //[Braintree setupWithClientToken:self.clientToken completion:^(Braintree *braintree, NSError *error) {
    self.braintree = [Braintree braintreeWithClientToken:self.clientToken];
    // Create a BTDropInViewController
    //        self.braintree = braintree;
    BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
    // This is where you might want to customize your Drop in. (See below.)
    //
    dropInViewController.summaryTitle = [NSString stringWithFormat:@"Add Payment"];
    dropInViewController.summaryDescription = [NSString stringWithFormat:@"Save time by linking payment before you go out. You're only charged when you actually buy drinks or tickets."];
    //NSLog(@"ITEM PRICE: %@", deal.itemPrice);
    //dropInViewController.displayAmount = [NSString stringWithFormat:@"$%@ per %@", deal.itemPrice, deal.itemName];
    dropInViewController.callToActionText = @"SAVE";
    dropInViewController.view.tintColor = [[ThemeManager sharedTheme] lightBlueColor];
    
    // The way you present your BTDropInViewController instance is up to you.
    // In this example, we wrap it in a new, modally presented navigation controller:
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                          target:self
                                                                                                          action:@selector(userDidCancelPayment)];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
    navigationController.navigationBar.topItem.title = @"One Time Setup";
    navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [ThemeManager lightFontOfSize:17]};
    navigationController.navigationBar.tintColor = [[ThemeManager sharedTheme] redColor];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
}

- (void)openPaymentModalWithDeal: (Deal *)deal {
    
    // Create and retain a `Braintree` instance with the client token
    //[Braintree setupWithClientToken:self.clientToken completion:^(Braintree *braintree, NSError *error) {
        self.braintree = [Braintree braintreeWithClientToken:self.clientToken];
        // Create a BTDropInViewController
//        self.braintree = braintree;
        BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
        // This is where you might want to customize your Drop in. (See below.)
        //
        dropInViewController.summaryTitle = [NSString stringWithFormat:@"$%@ for %@", deal.itemPrice, deal.itemName];
        dropInViewController.summaryDescription = @"You won't be charged until your voucher is redeemed and you’ve received your drink";
        //NSLog(@"ITEM PRICE: %@", deal.itemPrice);
        //dropInViewController.displayAmount = [NSString stringWithFormat:@"$%@ per %@", deal.itemPrice, deal.itemName];
        dropInViewController.callToActionText = @"SAVE";
        dropInViewController.view.tintColor = [[ThemeManager sharedTheme] lightBlueColor];
        
        // The way you present your BTDropInViewController instance is up to you.
        // In this example, we wrap it in a new, modally presented navigation controller:
            dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                                  target:self
                                                                                                                  action:@selector(userDidCancelPayment)];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
        navigationController.navigationBar.topItem.title = @"One Time Setup";
        navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [ThemeManager lightFontOfSize:17]};
        navigationController.navigationBar.tintColor = [[ThemeManager sharedTheme] redColor];
        [self presentViewController:navigationController
                           animated:YES
                         completion:nil];
   // }];
}

- (void)openPaymentModalToAddPayment
{
    
    // Create and retain a `Braintree` instance with the client token
    //[Braintree setupWithClientToken:self.clientToken completion:^(Braintree *braintree, NSError *error) {
    self.braintree = [Braintree braintreeWithClientToken:self.clientToken];
    // Create a BTDropInViewController
    //        self.braintree = braintree;
    BTDropInViewController *dropInViewController = [self.braintree dropInViewControllerWithDelegate:self];
    // This is where you might want to customize your Drop in. (See below.)
    //
//    dropInViewController.summaryTitle = ;
//    dropInViewController.summaryDescription = @"You won't be charged until your voucher is redeemed and you’ve received your drink";
//    //NSLog(@"ITEM PRICE: %@", deal.itemPrice);
//    //dropInViewController.displayAmount = [NSString stringWithFormat:@"$%@ per %@", deal.itemPrice, deal.itemName];
    dropInViewController.callToActionText = @"SAVE";
    dropInViewController.summaryTitle = @"Add Payment";
    dropInViewController.summaryDescription = @"Save time by linking payment before you go out. You're only charged when you actually buy drinks or tickets.";
    dropInViewController.view.tintColor = [[ThemeManager sharedTheme] lightBlueColor];
    
    // The way you present your BTDropInViewController instance is up to you.
    // In this example, we wrap it in a new, modally presented navigation controller:
    dropInViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                                          target:self
                                                                                                          action:@selector(userDidCancelPayment)];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:dropInViewController];
    navigationController.navigationBar.topItem.title = @"One Time Setup";
    navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName : [UIColor blackColor], NSFontAttributeName : [ThemeManager lightFontOfSize:17]};
    navigationController.navigationBar.tintColor = [[ThemeManager sharedTheme] redColor];
    [self presentViewController:navigationController
                       animated:YES
                     completion:nil];
    // }];
}

- (void)userDidCancelPayment {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)dropInViewController:(__unused BTDropInViewController *)viewController didSucceedWithPaymentMethod:(BTPaymentMethod *)paymentMethod {
    self.nonce = paymentMethod.nonce;
    [self postNonceToServer:self.nonce]; // Send payment method nonce to your server
}

- (void)dropInViewControllerDidCancel:(__unused BTDropInViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)postNonceToServer:(NSString *)paymentMethodNonce {
    if (self.onlyAddPayment) {
        [[APIClient sharedClient] postPaymentNonce:paymentMethodNonce success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *dismiss_payment_modal_string = responseObject[@"dismiss_payment_modal"];
            BOOL dismiss_payment_modal = [dismiss_payment_modal_string boolValue];
            if (dismiss_payment_modal) {
//                    if (self.inRegFlow) {
//                        [self.delegate finishPermissions];
//                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:kRefreshCustomerPaymentInfo object:self];
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.inRegFlow) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishPermissionsAfterPayment object:self];
                    }
                }];
            } else {
                [self showCardDeclined];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [self showCardDeclined];
            NSLog(@"Failure");
        }];
    } else {
        if (self.sponsoredEvent) {
            [self postPurchaseForEvent:paymentMethodNonce];
        } else {
            [self postPurchaseForBeacon:paymentMethodNonce];
        }
    }
    
}

-(void)postPurchaseForEvent:(NSString *)paymentMethodNonce
{
    [[APIClient sharedClient] postPurchaseForEventWithPaymentNonce:paymentMethodNonce success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *dismiss_payment_modal_string = responseObject[@"dismiss_payment_modal"];
        BOOL dismiss_payment_modal = [dismiss_payment_modal_string boolValue];
        if (dismiss_payment_modal) {
            [self dismissViewControllerAnimated:YES completion:^ {
                [[NSNotificationCenter defaultCenter] postNotificationName:kConfirmEventReservation object:self];
            }];
        } else {
            [self showCardDeclined];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self showCardDeclined];
        NSLog(@"Failure");
    }];
}

-(void)postPurchaseForBeacon:(NSString *)paymentMethodNonce
{
    [[APIClient sharedClient] postPurchase:paymentMethodNonce forBeaconWithID:self.beaconID success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *dismiss_payment_modal_string = responseObject[@"dismiss_payment_modal"];
        BOOL dismiss_payment_modal = [dismiss_payment_modal_string boolValue];
        if (dismiss_payment_modal) {
            [self dismissViewControllerAnimated:YES completion:nil];
            [self.redemptionViewController refreshDeal];
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
