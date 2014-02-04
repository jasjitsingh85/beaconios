//
//  RegistrationFlowViewController.m
//  Beacons
//
//  Created by Jeffrey Ames on 1/27/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "RegistrationFlowViewController.h"
#import "UIImageView+AnimationCompletion.h"
#import "Theme.h"
#import "RegisterViewController.h"

int const numberOfPages = 4;

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
@property (strong, nonatomic) UILabel *hotspotDescriptionLabel;
@property (strong, nonatomic) NSString *hotspotDescriptionText;
@property (strong, nonatomic) UILabel *captionLabel;

@end

@interface AnyDeviceView : UIView <RegistrationPageView>

@property (strong, nonatomic) UIImageView *handPhoneView;
@property (strong, nonatomic) UILabel *captionLabel;

@end

@interface InviteMoreView : UIView <RegistrationPageView>

@property (strong, nonatomic) UIImageView *handPhoneView;
@property (weak, nonatomic) AnyDeviceView *anyDeviceView;
@property (strong, nonatomic) UILabel *captionLabel;

@end

@interface RegistrationFlowViewController () <UIScrollViewDelegate>

@property (strong, nonatomic) UIScrollView *scrollView;
@property (assign, nonatomic) CGPoint lastContentOffset;
@property (strong, nonatomic) id<RegistrationPageView> currentPageView;
@property (strong, nonatomic) UIPageControl *pageControl;
@property (strong, nonatomic) NSArray *backgrounds;
@property (strong, nonatomic) DrinkView *drinkView;
@property (strong, nonatomic) PhoneView *phoneView;
@property (strong, nonatomic) AnyDeviceView *anyDeviceView;
@property (strong, nonatomic) InviteMoreView *inviteMoreView;
@property (assign, nonatomic) ScrollDirection scrollDirection;
@property (strong, nonatomic) UIButton *registerButton;
@property (strong, nonatomic) UIButton *loginButton;

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
    self.scrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    self.pageControl = [[UIPageControl alloc] init];
    CGRect pageControlFrame = CGRectZero;
    pageControlFrame.size = CGSizeMake(self.view.frame.size.width, 7);
    pageControlFrame.origin.y = self.view.frame.size.height - 147;
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
    
    self.phoneView = [[PhoneView alloc] init];
    [self.phoneView hideOffScreen];
    [self.view addSubview:self.phoneView];
    
    self.anyDeviceView = [[AnyDeviceView alloc] init];
    [self.anyDeviceView hideOffScreen];
    [self.view addSubview:self.anyDeviceView];
    
    self.inviteMoreView = [[InviteMoreView alloc] init];
    [self.inviteMoreView hideOffScreen];
    [self.view addSubview:self.inviteMoreView];
    self.inviteMoreView.anyDeviceView = self.anyDeviceView;
    
    self.registerButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect registerButtonFrame = CGRectZero;
    registerButtonFrame.size = CGSizeMake(279, 53);
    registerButtonFrame.origin.x = 0.5*(self.view.frame.size.width - registerButtonFrame.size.width);
    registerButtonFrame.origin.y = self.view.frame.size.height - 103;
    self.registerButton.frame = registerButtonFrame;
    self.registerButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.registerButton.backgroundColor = [UIColor whiteColor];
    self.registerButton.layer.cornerRadius = 4;
    [self.registerButton setTitle:@"Get Started!" forState:UIControlStateNormal];
    [self.registerButton setTitleColor:[UIColor colorWithRed:234/255.0 green:129/255.0 blue:91/255.0 alpha:1.0] forState:UIControlStateNormal];
    self.registerButton.titleLabel.font = [ThemeManager lightFontOfSize:23];
    [self.view addSubview:self.registerButton];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    CGRect loginButtonFrame = CGRectZero;
    loginButtonFrame.size = CGSizeMake(self.view.frame.size.width, 14);
    loginButtonFrame.origin.x = 0.5*(self.view.frame.size.width - loginButtonFrame.size.width);
    loginButtonFrame.origin.y = self.view.frame.size.height - 36;
    self.loginButton.frame = loginButtonFrame;
    self.loginButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    self.loginButton.titleLabel.font = [ThemeManager regularFontOfSize:11];
    NSMutableAttributedString *attributedTitle = [[NSMutableAttributedString alloc] initWithString:@"Already have an account? Login!" attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    NSRange range = [attributedTitle.string rangeOfString:@"Login!"];
    [attributedTitle setAttributes:@{NSForegroundColorAttributeName : [UIColor blackColor]} range:range];
    [self.loginButton setAttributedTitle:attributedTitle forState:UIControlStateNormal];
    [self.view addSubview:self.loginButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    jadispatch_after_delay(0.5, dispatch_get_main_queue(), ^{
        self.currentPageView = self.drinkView;
        [self.drinkView animateInFromRight];
    });
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
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
    if (page >= 0 && page < numberOfPages) {
        UIImageView *background = self.backgrounds[page];
        background.alpha = 1 - pow((offset.x/scrollView.frame.size.width - page),1);
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.currentPageView) {
        CGPoint translation = [scrollView.panGestureRecognizer translationInView:scrollView.superview];
        if(translation.x > 0) {
            [self.currentPageView animateOffFromLeft];
        } else {
            [self.currentPageView animateOffFromRight];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = floor(scrollView.contentOffset.x/scrollView.frame.size.width);
    NSArray *pageViews = @[self.drinkView, self.phoneView, self.anyDeviceView, self.inviteMoreView];
    self.currentPageView = pageViews[page];
    if (self.scrollDirection == ScrollDirectionLeft) {
    [self.currentPageView animateInFromLeft];
    }
    else {
        [self.currentPageView animateInFromRight];
    }
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
    captionFrame.size = CGSizeMake(260, 135);
    captionFrame.origin.x = 0.5*(self.frame.size.width - captionFrame.size.width);
    captionFrame.origin.y = self.frame.size.height - captionFrame.size.height - 155;
    self.captionLabel.frame = captionFrame;
    self.captionLabel.text = @"Hotspot is the easiest way to get groups of friends together.";
    self.captionLabel.numberOfLines = 2;
    self.captionLabel.font = [ThemeManager regularFontOfSize:17];
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
    
    self.captionLabel = [[UILabel alloc] init];
    CGRect captionFrame = CGRectZero;
    captionFrame.size = CGSizeMake(270, 135);
    captionFrame.origin.x = 0.5*(self.frame.size.width - captionFrame.size.width);
    captionFrame.origin.y = self.frame.size.height - captionFrame.size.height - 155;
    self.captionLabel.frame = captionFrame;
    self.captionLabel.text = @"Tell your friends what you're up to, where you are, and who you're with - all at once";
    self.captionLabel.numberOfLines = 3;
    self.captionLabel.font = [ThemeManager regularFontOfSize:18];
    self.captionLabel.textColor = [UIColor whiteColor];
    self.captionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.captionLabel];
    
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
    self.phoneView.transform = CGAffineTransformMakeTranslation(300, 0);
    self.captionLabel.alpha = 0;
}

- (void)animateInFromLeft
{
    [UIView animateWithDuration:0.5 delay:0.2 options:0 animations:^{
        self.captionLabel.alpha = 1;
    } completion:nil];
    self.hotspotDescriptionLabel.text = @"";
    self.phoneView.transform = CGAffineTransformMakeTranslation(300, 0);
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.phoneView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(updateText:) userInfo:nil repeats:YES];
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

@implementation AnyDeviceView

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.userInteractionEnabled = NO;
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.handPhoneView = [[UIImageView alloc] init];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<26;i++) {
        NSString *name = [NSString stringWithFormat:@"inviteAnyoneAnimation%04d", i];
        [images addObject:[UIImage imageNamed:name]];
    }
    self.handPhoneView.animationImages = images;
    self.handPhoneView.animationRepeatCount = 1;
    self.handPhoneView.animationDuration = 0.5;
    //preload images
    [self.handPhoneView startAnimating];
    CGRect handPhoneFrame = self.handPhoneView.frame;
    UIImage *firstImage = [self.handPhoneView.animationImages firstObject];
    handPhoneFrame.size = CGSizeMake(firstImage.size.width/2.0, firstImage.size.height/2.0);
    handPhoneFrame.origin.y = 0;
    handPhoneFrame.origin.x = 0;
    self.handPhoneView.frame = handPhoneFrame;
    [self addSubview:self.handPhoneView];
    
    self.captionLabel = [[UILabel alloc] init];
    CGRect captionFrame = CGRectZero;
    captionFrame.size = CGSizeMake(270, 135);
    captionFrame.origin.x = 0.5*(self.frame.size.width - captionFrame.size.width);
    captionFrame.origin.y = self.frame.size.height - captionFrame.size.height - 155;
    self.captionLabel.frame = captionFrame;
    self.captionLabel.text = @"Send them all the info, even if they don't have the app or an iPhone";
    self.captionLabel.numberOfLines = 2;
    self.captionLabel.font = [ThemeManager regularFontOfSize:17];
    self.captionLabel.textColor = [UIColor whiteColor];
    self.captionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.captionLabel];
    return self;
}

- (void)hideOffScreen
{
    self.handPhoneView.transform = CGAffineTransformMakeTranslation(350, 0);
    self.captionLabel.alpha = 0;
}

- (void)animateInFromLeft
{
    self.alpha = 1;
    self.handPhoneView.alpha = 1;
    self.handPhoneView.transform = CGAffineTransformMakeTranslation(350, 0);
    self.handPhoneView.image = [self.handPhoneView.animationImages firstObject];
    jadispatch_after_delay(0.2, dispatch_get_main_queue(), ^{
        self.handPhoneView.image = [self.handPhoneView.animationImages lastObject];
        [self.handPhoneView startAnimating];
    });
    [UIView animateWithDuration:0.3 delay:0.2 options:0 animations:^{
        self.captionLabel.alpha = 1;
    } completion:nil];
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        self.handPhoneView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {

    }];
}

- (void)animateInFromRight
{
    [self animateInFromLeft];
}

- (void)animateOffFromRight
{
    [UIView animateWithDuration:0.3 animations:^{
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

@implementation InviteMoreView

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.userInteractionEnabled = NO;
    self.frame = [UIScreen mainScreen].bounds;
    self.backgroundColor = [UIColor clearColor];
    
    self.handPhoneView = [[UIImageView alloc] init];
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (NSInteger i=0; i<31;i++) {
        NSString *name = [NSString stringWithFormat:@"inviteMoreAnimation%04d", i];
        [images addObject:[UIImage imageNamed:name]];
    }
    self.handPhoneView.animationImages = images;
    self.handPhoneView.animationRepeatCount = 1;
    //preload images
    [self.handPhoneView startAnimating];
    CGRect handPhoneFrame = self.handPhoneView.frame;
    UIImage *firstImage = [self.handPhoneView.animationImages firstObject];
    handPhoneFrame.size = CGSizeMake(firstImage.size.width/2.0, firstImage.size.height/2.0);
    handPhoneFrame.origin.y = 0;
    handPhoneFrame.origin.x = 0;
    self.handPhoneView.frame = handPhoneFrame;
    [self addSubview:self.handPhoneView];
    
    self.captionLabel = [[UILabel alloc] init];
    CGRect captionFrame = CGRectZero;
    captionFrame.size = CGSizeMake(270, 135);
    captionFrame.origin.x = 0.5*(self.frame.size.width - captionFrame.size.width);
    captionFrame.origin.y = self.frame.size.height - captionFrame.size.height - 155;
    self.captionLabel.frame = captionFrame;
    self.captionLabel.text = @"Your friends invite their friends so everyone gets to meet new people and have more fun.";
    self.captionLabel.numberOfLines = 3;
    self.captionLabel.font = [ThemeManager regularFontOfSize:17];
    self.captionLabel.textColor = [UIColor whiteColor];
    self.captionLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.captionLabel];
    
    return self;
}

- (void)hideOffScreen
{
    self.alpha = 0;
}

- (void)animateInFromLeft
{
    self.transform = CGAffineTransformIdentity;
    self.anyDeviceView.alpha = 0;
    self.alpha = 1;
    self.handPhoneView.image = [self.handPhoneView.animationImages firstObject];
    jadispatch_after_delay(0.01, dispatch_get_main_queue(), ^{
        self.handPhoneView.image = [self.handPhoneView.animationImages lastObject];
        [self.handPhoneView startAnimating];
    });

}

- (void)animateInFromRight
{
    [self animateInFromLeft];
}

- (void)animateOffFromRight
{
    [UIView animateWithDuration:0.5 animations:^{
        self.transform = CGAffineTransformMakeTranslation(-350, 0);
    }];
}

- (void)animateOffFromLeft
{
    [UIView animateWithDuration:0.4 animations:^{
        [self hideOffScreen];
    }];
}

@end
