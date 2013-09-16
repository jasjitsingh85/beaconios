//
//  PhotoManager.m
//  Beacons
//
//  Created by Jeff Ames on 9/15/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "PhotoManager.h"

typedef void (^PhotoPickerCompletionBlock)(UIImage *image, BOOL cancelled);

@interface PhotoManager()

@property (strong, nonatomic) PhotoPickerCompletionBlock photoPickerCompletionBlock;

@end

@implementation PhotoManager

+ (PhotoManager *)sharedManager
{
    static PhotoManager *_sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[PhotoManager alloc] init];
    });
    return _sharedManager;
}

- (void)presentImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType fromViewController:(UIViewController *)viewController completion:(void (^)(UIImage *image, BOOL cancelled))completion
{
    self.photoPickerCompletionBlock = completion;
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    [viewController presentViewController:imagePickerController animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if (self.photoPickerCompletionBlock) {
        self.photoPickerCompletionBlock(image, NO);
    }
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (self.photoPickerCompletionBlock) {
        self.photoPickerCompletionBlock(nil, YES);
    }
    [picker.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
