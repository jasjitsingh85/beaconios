//
//  PhotoManager.h
//  Beacons
//
//  Created by Jeff Ames on 9/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PhotoManager : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>

+ (instancetype)sharedManager;
- (void)presentImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType fromViewController:(UIViewController *)viewController completion:(void (^)(UIImage *image, BOOL cancelled))completion;

@end
