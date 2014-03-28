//
//  MapSnapshotImageView.m
//  Beacons
//
//  Created by Jeffrey Ames on 3/11/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "MapSnapshotImageView.h"
#import "UIView+UIImage.h"

@interface MapSnapshotImageView()

@property (strong, nonatomic) UIImageView *placeholderImageView;
@property (strong, nonatomic) MKMapSnapshotOptions *snapshotOptions;
@property (strong, nonatomic) UIImage *mapImage;

@end

@implementation MapSnapshotImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    self.clipsToBounds = YES;
    self.snapshotOptions = [[MKMapSnapshotOptions alloc] init];
    self.snapshotOptions.size = self.frame.size;
    self.snapshotOptions.scale = [[UIScreen mainScreen] scale];
    return self;
}

- (void)setRegion:(MKCoordinateRegion)region
{
    _region = region;
    self.snapshotOptions.region = region;
}

- (void)setPlaceholder:(UIImage *)placeholder
{
    _placeholder = placeholder;
    if (!self.placeholderImageView) {
        self.placeholderImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.placeholderImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.placeholderImageView];
    }
    self.placeholderImageView.image = placeholder;
}

- (void)update
{
    MKMapSnapshotter *snapshotter = [[MKMapSnapshotter alloc] initWithOptions:self.snapshotOptions];
    [snapshotter startWithQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
              completionHandler:^(MKMapSnapshot *snapshot, NSError *error) {
                  if (error) {
                      NSLog(@"[Error] %@", error);
                      return;
                  }
                  
                  MKAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:nil];
                  
                  UIImage *image = snapshot.image;
                  UIGraphicsBeginImageContextWithOptions(image.size, YES, image.scale);
                  [image drawAtPoint:CGPointMake(0.0f, 0.0f)];
                  
                  CGRect rect = CGRectMake(0.0f, 0.0f, image.size.width, image.size.height);
                  for (MKAnnotationView *annotationView in self.annotationViews) {
                      CGPoint point = [snapshot pointForCoordinate:annotationView.annotation.coordinate];
                      if (CGRectContainsPoint(rect, point)) {
                          point.x = point.x + annotationView.centerOffset.x -
                          (pin.bounds.size.width / 2.0f);
                          point.y = point.y + annotationView.centerOffset.y -
                          (annotationView.bounds.size.height / 2.0f);
                          [[annotationView UIImage] drawAtPoint:point];
                      }
                  }
                  UIImage *compositeImage = UIGraphicsGetImageFromCurrentImageContext();
                  UIGraphicsEndImageContext();
                  jadispatch_main_qeue(^{
                      //seems like some ios 7 issue is causing animations to stop randomly
                      //this is said to be a fix
                      [UIView setAnimationsEnabled:YES];
                      self.mapImage = compositeImage;
                      self.image = self.mapImage;
                      [UIView animateWithDuration:0.5 animations:^{
                          self.placeholderImageView.alpha = 0;
                          self.placeholderImageView.transform = CGAffineTransformMakeScale(1.5, 1.5);
                      } completion:nil];
                  });
              }];
}

@end
