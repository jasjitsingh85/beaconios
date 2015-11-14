//
//  NavigationBarTitleLabel.m
//  Beacons
//
//  Created by Jeff Ames on 10/26/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "NavigationBarTitleLabel.h"
#import "Theme.h"

@implementation NavigationBarTitleLabel

- (id)initWithTitle:(NSString *)title
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.frame = CGRectMake(0, 0, 200, 64);
    self.text = title;
    self.font = [ThemeManager mediumFontOfSize:15];
    self.textColor = [[ThemeManager sharedTheme] navigationBarTitleAndTextAttributes][NSForegroundColorAttributeName];
    self.textAlignment = NSTextAlignmentCenter;
    return self;
}

@end
