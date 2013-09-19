#import "LineLayout.h"


#define CELL_WIDTH 271.5
#define CELL_HEIGHT 225

@implementation LineLayout

#define ACTIVE_DISTANCE 256

-(id)init
{
    self = [super init];
    if (self) {
        self.itemSize = CGSizeMake(CELL_WIDTH, CELL_HEIGHT);
        self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        CGFloat horizontalInset = 0.5*(320 - CELL_WIDTH);
        CGFloat verticalInset = 0.5*(240 - CELL_HEIGHT);
        self.sectionInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
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
    NSInteger idx = round(proposedContentOffset.x/CELL_WIDTH);
    return CGPointMake(idx*CELL_WIDTH, proposedContentOffset.y);
}

@end