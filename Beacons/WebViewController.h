//
//  WebViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/26/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, strong) NSString *websiteTitle;
@property (nonatomic, strong) NSURL *websiteUrl;
@property (nonatomic, assign) BOOL dismissModal;

//- (id)initWithTitle:(NSString *)title andURL:(NSURL *)url;

@end
