//
//  RegistrationFlowViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 1/27/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "RegistrationFlowViewController.h"
#import "Theme.h"

int const numberOfPages = 4;

@protocol RegistrationPageView <NSObject>

- (void)hideOffScreen;
- (void)animateInFromLeft;
- (void)animateInFromRight;
- (void)animateOffFromLeft;
- (void)animateOffFromRight;

@end

@interface DrinkView : UIView <RegistrationPageView>

@property (strong, nonatomic) UIImageView *beerView;
@property (strong, nonatomic) UIImageView *whiskeyView;
@property (strong, nonatomic) UIImageView *martiniView;
@property (strong, nonatomic) UIImageView *fruitDrinkView;

@end

@interface PhoneView : UIView <RegistrationPageView>

@property (strong, nonatomic) UIImageView *phoneView;
@property (strong, nonatomic) UILabel *hotspotDescriptionLabel;
@property (strong, nonatomic) NSString *hotspotDescriptionText;

@end

@interface RegistrationFlowViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGPoint lastContentOffset;
@property (strong, nonatomic) id<RegistrationPageView> currentPageView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *backgrounds;
@property (strong, nonatomic) DrinkView *drinkView;
@property (strong, nonatomic) PhoneView *phoneView;

@end

@implementation RegistrationFlowViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *backgroundImageNames = @[@"redGradientBackground", @"blueGradientBackground", @"greenGradientBackground", @"orangeGradientBackground"];
    NSMutableArray *backgrounds = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<backgroundImageNames.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImageNames[i]]];
        [backgrounds addObject:imageView];
    }
    self.backgrounds = [NSArray arrayWithArray:backgrounds];
    for (UIView *view in self.backgrounds.reverseObjectEnumerator) {
        [self.view addSubview:view];

    }
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoNav"]];
    CGRect logoFrame = logoImageView.frame;
    logoFrame.origin.x = 0.5*(self.view.frame.size.width - logoFrame.size.width);
    logoFrame.origin.y = 30;
    logoImageView.frame = logoFrame;
    [self.view addSubview:logoImageView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(numberOfPages*self.view.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.pagingEnabled = YES;
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width, 50)];
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    
    self.drinkView = [[DrinkView alloc] init];
    [self.drinkView hideOffScreen];
    [self.view addSubview:self.drinkView];
    
    self.phoneView = [[PhoneView alloc] init];
    [self.phoneView hideOffScreen];
    [self.view addSubview:self.phoneView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGPoint offset = scrollView.contentOffset;
    NSInteger page = floor(offset.x/scrollView.frame.size.width);
    self.pageControl.currentPage = round(offset.x/scrollView.frame.size.width);
    for (NSInteger i=0; i<page; i++) {
        UIImageView *background = self.backgrounds[page];
        background.alpha = 0;
    }
    if (page >= 0 && page < numberOfPages) {
    UIImageView *background = self.backgrounds[page];
    background.alpha = 1 - pow((offset.x/scrollView.frame.size.width - page),1);
        NSLog(@"page %d alpha %f", page, background.alpha);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.currentPageView) {
        [self.currentPageView animateOffFromRight];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = floor(scrollView.contentOffset.x/scrollView.frame.size.width);
    NSArray *pageViews = @[self.drinkView, self.phoneView, self.drinkView, self.phoneView];
    self.currentPageView = pageViews[page];
    [self.currentPageView animateInFromLeft];
}

@end

@implementation DrinkView

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.userInteractionEnabled = NO;
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.beerView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"beer"]];
    CGRect beerFrame = self.beerView.frame;
    beerFrame.origin = CGPointMake(0, 211/2.0);
    self.beerView.frame = beerFrame;
    [self addSubview:self.beerView];
    
    self.whiskeyView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"whisky"]];
    CGRect whiskeyFrame = self.whiskeyView.frame;
    whiskeyFrame.origin = CGPointMake(151/2.0, 360/2.0);
    self.whiskeyView.frame = whiskeyFrame;
    [self addSubview:self.whiskeyView];
    
    self.fruitDrinkView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fruityDrink"]];
    CGRect fruitDrinkView = self.fruitDrinkView.frame;
    fruitDrinkView.origin = CGPointMake(323/2.0, 318/2.0);
    self.fruitDrinkView.frame = fruitDrinkView;
    [self addSubview:self.fruitDrinkView];
    
    self.martiniView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"martini"]];
    CGRect martiniFrame = self.martiniView.frame;
    martiniFrame.origin = CGPointMake(431/2.0, 218/2.0);
    self.martiniView.frame = martiniFrame;
    [self addSubview:self.martiniView];
    
    return self;
}

- (void)hideOffScreen
{
    self.beerView.transform = CGAffineTransformMakeTranslation(-120, 0);
    self.whiskeyView.transform = CGAffineTransformMakeTranslation(-160, 50);
    self.fruitDrinkView.transform = CGAffineTransformMakeTranslation(160, 50);
    self.martiniView.transform = CGAffineTransformMakeTranslation(150, 0);
}

- (void)animateOffFromLeft
{
    [UIView animateWithDuration:0.4 animations:^{
        [self hideOffScreen];
    }];
}

- (void)animateOffFromRight
{
    [self animateOffFromLeft];
}

- (void)animateInFromLeft
{
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.whiskeyView.transform = CGAffineTransformIdentity;
    } completion:nil];
    [UIView animateWithDuration:0.3 delay:0.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.fruitDrinkView.transform = CGAffineTransformIdentity;
    } completion:nil];
    [UIView animateWithDuration:0.3 delay:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.beerView.transform = CGAffineTransformIdentity;
    } completion:nil];
    [UIView animateWithDuration:0.3 delay:0.4 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.martiniView.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)animateInFromRight
{
    [self animateInFromLeft];
}

@end

@implementation PhoneView

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.userInteractionEnabled = NO;
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.phoneView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"iphoneVector"]];
    CGRect phoneFrame = self.phoneView.frame;
    phoneFrame.origin = CGPointMake(167/2.0, 199/2.0);
    self.phoneView.frame = phoneFrame;
    [self addSubview:self.phoneView];
    
    self.hotspotDescriptionLabel = [[UILabel alloc] initWithFrame:CGRectMake(38, 223/2.0, 200, 8)];
    self.hotspotDescriptionLabel.font = [ThemeManager regularFontOfSize:7];
    self.hotspotDescriptionLabel.textColor = [UIColor whiteColor];
    self.hotspotDescriptionLabel.text = @"";
    self.hotspotDescriptionText = @"Drinks with friends!";
    [self.phoneView addSubview:self.hotspotDescriptionLabel];
    
    return self;
}

- (void)updateText:(NSTimer *)timer
{
    NSString *currentText = self.hotspotDescriptionLabel.text;
    if (currentText.length == self.hotspotDescriptionText.length) {
        [timer invalidate];
    }
    else {
        self.hotspotDescriptionLabel.text = [self.hotspotDescriptionText substringToIndex:currentText.length+1];
    }
}

- (void)hideOffScreen
{
    self.transform = CGAffineTransformMakeTranslation(300, 0);
}

- (void)animateInFromLeft
{
    self.hotspotDescriptionLabel.text = @"";
    self.transform = CGAffineTransformMakeTranslation(300, 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateText:) userInfo:nil repeats:YES];
    }];
}

- (void)animateOffFromRight
{
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeTranslation(-300, 0);
    }];
}

@end
