#import <CocoaLumberjack/DDLog.h>

//logging
#ifdef DEBUG
static const int ddLogLevel = LOG_LEVEL_VERBOSE;
#else
static const int ddLogLevel = LOG_LEVEL_INFO;
#endif

//user defaults keys
#define kDefaultsKeyFirstName @"defaultsKeyFirstName"
#define kDefaultsKeyLastName @"defaultsKeyLastName"
#define kDefaultsKeyEmail   @"defaultsKeyEmail"
#define kDefaultsKeyPhone   @"defaultsKeyPhone"
#define kDefaultsKeyUserID @"defaultsKeyUserID"
#define kDefaultsAvatarURLKey @"defaultsAvatarURL"
#define kDefaultsKeyFacebookID @"defaultsKeyFacebookID"
#define kDefaultsKeyIsLoggedIn @"defaultsKeyIsLoggedIn"
#define kDefaultsKeyAccountActivated @"defaultsKeyAccountActivated"
#define kDefaultsKeyLastAuthorizationToken @"lastAuthorizationToken"
#define kDefaultsKeyArchivedBeacons @"archivedBeacons"
#define kDefaultsKeyHasFinishedPermissions @"hasFinishedPermissions"
#define kDefaultsKeyCheckinPromptHotspots @"checkinPromptHotspots"
#define kDefaultsKeyHasSeenHotspotTile @"hasSeenHotspotTile"
#define kDefaultsKeyHasSeenHappyHourTile @"hasSeenHappyHourTile"
//#define kDefaultsKeyHasShownHotspotExplanation @"hasShownHotspotExplanation"
//#define kDefaultsKeyHasShownPaymentExplanation @"hasShownPaymentExplanation"
#define kDefaultsKeyHasShownDealExplanation @"hasShownDealExplanation"
#define kDefaultsKeyHasShownDealsIntroduction @"hasShownDealsIntroduction"
#define kDefaultsKeyHasSkippedVenmo @"hasSkippedVenmo"
#define kDefaultsKeyLastFeedUpdate @"lastFeedUpdate"

//notifications
#define kPushNotificationTypeMessage @"Message"
#define kPushNotificationTypeBeaconUpdate @"Hotspot Update"
#define kPushNotificationTypeGeneral @"General"
#define kPushNotificationTypeRecommendation @"Recommendation"

//local notifications
#define kLocalNotificationTypeKey @"localNotificationTypeKey"
#define kLocalNotificationTypeCheckinPrompt @"localNotificationTypeCheckinPrompt"
#define kLocalNotificationTypeEnteredRegion @"localNotificationTypeEnteredRegion"

//location notifications
#define kNotificationBeaconUpdated @"notificationBeaconUpdated"
#define kNotificationRewardsUpdated @"notificationRewardsUpdated"
#define kPushNotificationMessageReceived @"pushNotificationMessageReceived"
#define kDealsUpdatedNotification @"dealsUpdatedNotification"
#define kFeedUpdateNotification @"feedUpdateNotification"
#define kRefreshAfterToggleFavoriteNotification @"refreshAfterToggleFavoriteNotification"
#define kFeedBackgroundUpdateNotification @"feedBackgroundUpdateNotification"
#define kRemoveNewsfeedNotification @"removeNewsfeedNotification"
#define kFeedStartRefreshNotification @"feedStartRefreshNotification"
#define kFeedFinishRefreshNotification @"feedFinishRefreshNotification"
#define kDidFinishNewsfeedPermissions @"didFinishNewsfeedPermissions"
#define kApplyFilterNotification @"applyFilterNotification"

//random string notifications
#define kRandomStringsUpdated @"randomStringsUpdated"

//analytics
extern NSString * const MIXPANEL_TOKEN;

//conversions
#define METERS_TO_MILES 0.000621371
#define METERS_TO_FEET 3.28084

//messages
#define kMessageTypeUserMessage @"UM"
#define kMessageTypeSystemMessage @"HM"

//deals
extern NSString * const kDealStatusLocked;
extern NSString * const kDealStatusUnlocked;
extern NSString * const kDealStatusRedeemed;

extern NSString * const kHotspotViewType;
extern NSString * const kHappyHourViewType;
extern NSString * const kDealPlaceViewType;


//email
#define kFeedbackEmailAddress @"info@gethotspotapp.com"

//app linking
extern NSString * const kHappyHoursAppURLIdentifier;
extern NSString * const kVenmoAppURLIdentifier;

extern NSString * const kAppID;

//urls
extern NSString * const kTermsURL;
extern NSString * const kPrivacyURL;

//server paths
extern NSString * const  kBaseURLStringDevelopment;
extern NSString * const kBaseURLStringLAN;
extern NSString * const kBaseURLStringProduction;
extern NSString * const  kBaseURLStringStaging;
