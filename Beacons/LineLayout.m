#import "LineLayout.h"


#define CELL_WIDTH 300.0
#define CELL_HEIGHT 100.0

@implementation LineLayout

#define ACTIVE_DISTANCE 300
#define ZOOM_FACTOR 0.3

-(id)init
{
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        self.sectionInset = UIEdgeInsetsMake(0, 10, 0, 10);
        self.minimumLineSpacing = 5;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset withScrollingVelocity:(CGPoint)velocity
{
    CGPoint currentOffset = self.collectionView.contentOffset;
    if (velocity.x > 0) {
        proposedContentOffset.x = currentOffset.x + CELL_WIDTH/2.0;
    }
    else if (velocity.x < 0) {
        proposedContentOffset.x = currentOffset.x - CELL_WIDTH/2.0;
    }
    
    CGFloat offsetAdjustment = MAXFLOAT;
    CGFloat horizontalCenter = proposedContentOffset.x + (CGRectGetWidth(self.collectionView.bounds) / 2.0);
    
    CGRect targetRect = CGRectMake(proposedContentOffset.x, 0.0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    NSArray* array = [super layoutAttributesForElementsInRect:targetRect];
    
    for (UICollectionViewLayoutAttributes* layoutAttributes in array) {
        CGFloat itemHorizontalCenter = layoutAttributes.center.x;
        if (ABS(itemHorizontalCenter - horizontalCenter) < ABS(offsetAdjustment)) {
            offsetAdjustment = itemHorizontalCenter - horizontalCenter;
        }
    }
    return CGPointMake(proposedContentOffset.x + offsetAdjustment, proposedContentOffset.y);
}

@end