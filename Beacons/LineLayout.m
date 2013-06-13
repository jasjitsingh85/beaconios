#import "LineLayout.h"


#define CELL_WIDTH 256
#define CELL_HEIGHT 185

@implementation LineLayout

#define ACTIVE_DISTANCE 256

-(id)init
{
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat horizontalInset = 0.5*(320 - CELL_WIDTH);
        self.sectionInset = UIEdgeInsetsMake(15, horizontalInset, 15, horizontalInset);
        self.minimumLineSpacing = 5;
    }
    return self;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)oldBounds
{
    return YES;
}

-(NSArray*)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSArray* array = [super layoutAttributesForElementsInRect:rect];
    CGRect visibleRect;
    visibleRect.origin = self.collectionView.contentOffset;
    visibleRect.size = self.collectionView.bounds.size;
    
    for (UICollectionViewLayoutAttributes* attributes in array) {
        if (CGRectIntersectsRect(attributes.frame, rect)) {
            CGFloat distance = CGRectGetMidX(visibleRect) - attributes.center.x;
            CGFloat normalizedDistance = distance / ACTIVE_DISTANCE;
            CGFloat alpha = 0.8 + 0.2*(1-ABS(normalizedDistance));
            attributes.alpha = alpha;
            attributes.transform3D = CATransform3DMakeScale(1, alpha, 1);
        }
    }
    return array;
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