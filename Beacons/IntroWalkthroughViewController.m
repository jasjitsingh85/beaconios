//
//  RegistrationFlowViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 1/27/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "IntroWalkthroughViewController.h"
#import "UIImageView+AnimationCompletion.h"
#import "Theme.h"
#import "RegisterViewController.h"

int const numberOfPages = 5;

typedef enum ScrollDirection {
    ScrollDirectionNone,
    ScrollDirectionRight,
    ScrollDirectionLeft
} ScrollDirection;

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
@property (strong, nonatomic) UILabel *captionLabel;

@end

@interface PhoneView : UIView <RegistrationPageView>

@property (strong, nonatomic) UIImageView *phoneView;
@property (strong, nonatomic) UIImage *phoneImage;
@property (strong, nonatomic) NSAttributedString *captionString;
@property (strong, nonatomic) UILabel *captionLabel;
- (id)initWithImage:(UIImage *)image captionString:(NSAttributedString *)captionString;

@end

@interface IntroWalkthroughViewController () <UIScrollViewDelegate>

@property (assign, nonatomic) CGPoint lastContentOffset;
@property (strong, nonatomic) id<RegistrationPageView> currentPageView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *backgrounds;
@property (strong, nonatomic) DrinkView *drinkView;
@property (strong, nonatomic) PhoneView *phoneView1;
@property (strong, nonatomic) PhoneView *phoneView2;
@property (strong, nonatomic) PhoneView *phoneView3;
@property (strong, nonatomic) PhoneView *phoneView4;
@property (assign, nonatomic) ScrollDirection scrollDirection;

@end

@implementation IntroWalkthroughViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *backgroundImageNames = @[@"redGradientBackground", @"blueGradientBackground", @"greenGradientBackground", @"redGradientBackground", @"orangeBackground"];
    NSMutableArray *backgrounds = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<backgroundImageNames.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:backgroundImageNames[i]]];
        [backgrounds addObject:imageView];
    }
    self.backgrounds = [NSArray arrayWithArray:backgrounds];
    for (UIView *view in self.backgrounds.reverseObjectEnumerator) {
        [self.view addSubview:view];

    }
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hotspotLogoLarge"]];
    CGRect logoFrame = logoImageView.frame;
    logoFrame.origin.x = 0.5*(self.view.frame.size.width - logoFrame.size.width);
    logoFrame.origin.y = 25;
    logoImageView.frame = logoFrame;
    [self.view addSubview:logoImageView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(numberOfPages*self.view.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    CGRect pageControlFrame = CGRectZero;
    pageControlFrame.size = CGSizeMake(self.view.frame.size.width, 7);
    pageControlFrame.origin.y = self.view.frame.size.height - 90;
    self.pageControl.frame = pageControlFrame;
    self.pageControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.pageControl.numberOfPages = numberOfPages;
    self.pageControl.pageIndicatorTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.currentPage = 0;
    [self.view addSubview:self.pageControl];
    
    self.drinkView = [[DrinkView alloc] init];
    [self.drinkView hideOffScreen];
    [self.view addSubview:self.drinkView];
    
    NSString *line1 = @"Pick a Deal";
    NSString *line2 = @"at a local bar";
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", line1, line2]];
    [attributedString setAttributes:@{NSFontAttributeName : [ThemeManager boldFontOfSize:26]} range:[attributedString.string rangeOfString:line1]];
    [attributedString setAttributes:@{NSFontAttributeName : [ThemeManager mediumFontOfSize:20]} range:[attributedString.string rangeOfString:line2]];
    self.phoneView1 = [[PhoneView alloc] initWithImage:[UIImage imageNamed:@"iphoneWalkthrough1"] captionString:attributedString];
    [self.phoneView1 hideOffScreen];
    [self.view addSubview:self.phoneView1];
    
    NSString *view2Line1 = @"Type a Message";
    NSString *view2Line2 = @"to a few friends";
    NSMutableAttributedString *attributedString2 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", view2Line1, view2Line2]];
    [attributedString2 setAttributes:@{NSFontAttributeName : [ThemeManager boldFontOfSize:26]} range:[attributedString2.string rangeOfString:view2Line1]];
    [attributedString2 setAttributes:@{NSFontAttributeName : [ThemeManager mediumFontOfSize:20]} range:[attributedString2.string rangeOfString:view2Line2]];
    self.phoneView2 = [[PhoneView alloc] initWithImage:[UIImage imageNamed:@"iphoneWalkthrough2"] captionString:attributedString2];
    [self.phoneView2 hideOffScreen];
    [self.view addSubview:self.phoneView2];
    
    NSString *view3Line1 = @"Select Friends to Text";
    NSString *view3Line2 = @"(they don't need the app)";
    NSMutableAttributedString *attributedString3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", view3Line1, view3Line2]];
    [attributedString3 setAttributes:@{NSFontAttributeName : [ThemeManager boldFontOfSize:26]} range:[attributedString3.string rangeOfString:view3Line1]];
    [attributedString3 setAttributes:@{NSFontAttributeName : [ThemeManager mediumFontOfSize:20]} range:[attributedString3.string rangeOfString:view3Line2]];
    self.phoneView3 = [[PhoneView alloc] initWithImage:[UIImage imageNamed:@"iphoneWalkthrough3"] captionString:attributedString3];
    [self.phoneView3 hideOffScreen];
    [self.view addSubview:self.phoneView3];
    
    NSString *view4Line1 = @"Redeem Instantly";
    NSString *view4Line2 = @"(by showing voucher to staff)";
    NSMutableAttributedString *attributedString4 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@", view4Line1, view4Line2]];
    [attributedString4 setAttributes:@{NSFontAttributeName : [ThemeManager boldFontOfSize:26]} range:[attributedString4.string rangeOfString:view4Line1]];
    [attributedString4 setAttributes:@{NSFontAttributeName : [ThemeManager mediumFontOfSize:20]} range:[attributedString4.string rangeOfString:view4Line2]];
    self.phoneView4 = [[PhoneView alloc] initWithImage:[UIImage imageNamed:@"iphoneWalkthrough4"] captionString:attributedString4];
    [self.phoneView4 hideOffScreen];
    [self.view addSubview:self.phoneView4];
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect registerButtonFrame = CGRectZero;
    registerButtonFrame.size = CGSizeMake(279, 53);
    registerButtonFrame.origin.x = 0.5*(self.view.frame.size.width - registerButtonFrame.size.width);
    registerButtonFrame.origin.y = self.view.frame.size.height - registerButtonFrame.size.height - 10;
    self.registerButton.frame = registerButtonFrame;
    self.registerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.registerButton.backgroundColor = [UIColor whiteColor];
    self.registerButton.layer.cornerRadius = 4;
    [self.registerButton setTitle:@"Get Started!" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor colorWithRed:234/255.0 green:129/255.0 blue:91/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = [ThemeManager lightFontOfSize:23];
    [self.view addSubview:self.registerButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    jadispatch_after_delay(0.5, dispatch_get_main_queue(), ^{
        self.currentPageView = self.drinkView;
        [self.drinkView animateInFromRight];
    });
}

- (void)animateRegisterButton
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [UIView animateWithDuration:0.2 animations:^{
            self.registerButton.transform = CGAffineTransformMakeScale(1.1, 1.1);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.2 animations:^{
                self.registerButton.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                onceToken = 0;
            }];
        }];
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    BOOL reachedEnd = (scrollView.contentSize.width - scrollView.contentOffset.x) < scrollView.frame.size.width;
    CGPoint offset = scrollView.contentOffset;
    if (self.lastContentOffset.x > scrollView.contentOffset.x) {
        self.scrollDirection = ScrollDirectionRight;
    }
    else if (self.lastContentOffset.x < scrollView.contentOffset.x) {
        self.scrollDirection = ScrollDirectionLeft;
    }
    self.lastContentOffset = scrollView.contentOffset;
    
    NSInteger page = floor(offset.x/scrollView.frame.size.width);
    self.pageControl.currentPage = round(offset.x/scrollView.frame.size.width);
    for (NSInteger i=0; i<page; i++) {
        UIImageView *background = self.backgrounds[page];
        background.alpha = 0;
    }
    if (page >= 0 && page <= (numberOfPages - 1)) {
        UIImageView *background = self.backgrounds[page];
        if (reachedEnd) {
            background.alpha = 1;
        }
        else {
            background.alpha = 1 - pow((offset.x/scrollView.frame.size.width - page),1);
        }
    }
    
    if (reachedEnd) {
        [self animateRegisterButton];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
    if (self.currentPageView) {
        if(translation.x > 0) {
            [self.currentPageView animateOffFromLeft];
        }
        else if (self.currentPageView != self.phoneView4) {
            [self.currentPageView animateOffFromRight];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = floor(scrollView.contentOffset.x/scrollView.frame.size.width);
    NSArray *pageViews = @[self.drinkView, self.phoneView1, self.phoneView2, self.phoneView3, self.phoneView4];
    self.currentPageView = pageViews[page];
    if (self.scrollDirection == ScrollDirectionLeft) {
        [self.currentPageView animateInFromLeft];
    }
    else {
        if (self.currentPageView != self.phoneView4) {
            [self.currentPageView animateInFromRight];
        }
    }
    //make sure other page views are hidden of screen
    for (id<RegistrationPageView>pageView in pageViews) {
        if (pageView != self.currentPageView) {
            [pageView hideOffScreen];
        }
    }
}

+ (NSAttributedString *)multiLineAttributedStringWithLineTexts:(NSArray *)lines fonts:(NSArray *)fonts
{
    NSString *string = @"";
    for (NSString *l in lines) {
        if (string.length) {
            string = [string stringByAppendingString:@"\n"];
        }
        string = [string stringByAppendingString:l];
    }
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:string];
    for (NSInteger i=0; i<fonts.count; i++) {
        UIFont *font = fonts[i];
        NSString *line = lines[i];
        [attributedString setAttributes:@{NSFontAttributeName : font} range:[attributedString.string rangeOfString:line]];
    }
    return attributedString;
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
    
    self.captionLabel = [[UILabel alloc] init];
    CGRect captionFrame = CGRectZero;
    captionFrame.size = CGSizeMake(290, 150);
    captionFrame.origin.x = 0.5*(self.frame.size.width - captionFrame.size.width);
    captionFrame.origin.y = 275;
    self.captionLabel.frame = captionFrame;
//    self.captionLabel.text = @"Hotspot is the fastest way to get groups of friends together.";
    self.captionLabel.attributedText = [IntroWalkthroughViewController
                                        multiLineAttributedStringWithLineTexts:@[@"Happy Hour", @"is now on-demand"]
                                        fonts:@[[ThemeManager boldFontOfSize:30], [ThemeManager boldFontOfSize:24]]];
    self.captionLabel.numberOfLines = 3;
    self.captionLabel.textColor = [UIColor whiteColor];
    self.captionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.captionLabel];
    
    return self;
}

- (void)hideOffScreen
{
    self.beerView.transform = CGAffineTransformMakeTranslation(-120, 0);
    self.whiskeyView.transform = CGAffineTransformMakeTranslation(-160, 50);
    self.fruitDrinkView.transform = CGAffineTransformMakeTranslation(160, 50);
    self.martiniView.transform = CGAffineTransformMakeTranslation(150, 0);
    self.captionLabel.alpha = 0;
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
    [UIView animateWithDuration:0.3 delay:0.2 options:0 animations:^{
        self.captionLabel.alpha = 1;
    } completion:nil];
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

- (id)initWithImage:(UIImage *)image captionString:(NSAttributedString *)captionString
{
    self = [super init];
    if (!self) {
        return nil;
    }
    self.phoneImage = image;
    self.captionString = captionString;
    self.userInteractionEnabled = NO;
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.phoneView = [[UIImageView alloc] initWithImage:self.phoneImage];
    CGRect phoneFrame = self.phoneView.frame;
    phoneFrame.size.width *= 1.2;
    phoneFrame.size.height *= 1.2;
    phoneFrame.origin.x = (self.width - phoneFrame.size.width)/2.0;
    phoneFrame.origin.y = 199/2.0 - 10;
    self.phoneView.frame = phoneFrame;
    [self addSubview:self.phoneView];
    
    self.captionLabel = [[UILabel alloc] init];
    CGRect captionFrame = CGRectZero;
    captionFrame.size = CGSizeMake(270, 135);
    captionFrame.origin.x = 0.5*(self.frame.size.width - captionFrame.size.width);
    captionFrame.origin.y = 300;
    self.captionLabel.frame = captionFrame;
    self.captionLabel.attributedText = self.captionString;
    self.captionLabel.numberOfLines = 3;
//    self.captionLabel.font = [ThemeManager regularFontOfSize:18];
    self.captionLabel.textColor = [UIColor whiteColor];
    self.captionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.captionLabel];
    
    return self;
}

- (void)hideOffScreen
{
    self.phoneView.transform = CGAffineTransformMakeTranslation(300, 0);
    self.captionLabel.alpha = 0;
}

- (void)animateInFromLeft
{
    [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
        self.captionLabel.alpha = 1;
    } completion:nil];
    self.phoneView.transform = CGAffineTransformMakeTranslation(300, 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.phoneView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];
}

- (void)animateInFromRight
{
    [self animateInFromLeft];
}

- (void)animateOffFromRight
{
    [UIView animateWithDuration:0.5 animations:^{
        self.phoneView.transform = CGAffineTransformMakeTranslation(-300, 0);
        self.captionLabel.alpha = 0;
    }];
}

- (void)animateOffFromLeft
{
    [UIView animateWithDuration:0.4 animations:^{
        [self hideOffScreen];
    }];
}

@end
