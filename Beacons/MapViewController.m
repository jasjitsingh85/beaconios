//
//  MapViewController.m
//  Beacons
//
//  Created by Jeff Ames on 5/30/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "MapViewController.h"
#import "BeaconCell.h"
#import "LineLayout.h"

@interface MapViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *beaconCollectionView;

@end

@implementation MapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    //initially hide beacon collection view
    self.beaconCollectionView.alpha = 0;
    self.beaconCollectionView.backgroundColor = [UIColor clearColor];
    self.beaconCollectionView.decelerationRate = UIScrollViewDecelerationRateFast;
    self.beaconCollectionView.pagingEnabled = NO;
    self.beaconCollectionView.delegate = self;
    self.beaconCollectionView.dataSource = self;
    [self.beaconCollectionView.collectionViewLayout invalidateLayout];
    self.beaconCollectionView.collectionViewLayout = [LineLayout new];
    [self.beaconCollectionView registerClass:[BeaconCell class] forCellWithReuseIdentifier:@"MY_CELL"];
    [self.beaconCollectionView reloadData];
    [self showBeaconCollectionViewAnimated:YES];
}

- (void)showBeaconCollectionViewAnimated:(BOOL)animated
{
    if (animated) {
        self.beaconCollectionView.alpha = 0;
        self.beaconCollectionView.transform = CGAffineTransformMakeTranslation(0, -self.beaconCollectionView.frame.size.height);
    }
    NSTimeInterval duration = animated ? 0.5 : 0.0;
    [UIView animateWithDuration:duration
                          delay:2
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.beaconCollectionView.alpha = 1;
                         self.beaconCollectionView.transform = CGAffineTransformIdentity;
                     } completion:^(BOOL finished) {
                         
                     }];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BeaconCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MY_CELL" forIndexPath:indexPath];
    return cell;
}

@end
