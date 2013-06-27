//
//  WebViewController.h
//  Beacons
//
//  Created by Jeffrey Ames on 6/26/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate>

- (id)initWithTitle:(NSString *)title andURL:(NSURL *)url;

@end
