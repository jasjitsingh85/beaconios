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
#define kPushNotificationMessageReceived @"pushNotificationMessageReceived"

//random string notifications
#define kRandomStringsUpdated @"randomStringsUpdated"

//analytics
#define MIXPANEL_TOKEN @"5ef90c03d9e72b7e1f460600d47de6ab"
#define APPSEE_TOKEN @"a7b17f911dfd4d57a2b53abc502baaef"

//conversions
#define METERS_TO_MILES 0.000621371
#define METERS_TO_FEET 3.28084

//messages
#define kMessageTypeUserMessage @"UM"
#define kMessageTypeSystemMessage @"HM"

//email
#define kFeedbackEmailAddress @"info@gethotspotapp.com"

//urls
#define kTermsURL @"http://www.getbeacons.com/terms"
#define kPrivacyURL @"http://www.getbeacons.com/privacy"

//server paths
static NSString * const kBaseURLStringDevelopment = @"http://localhost:8000/api/";
static NSString * const kBaseURLStringLAN = @"http://0.0.0.0:8000/api/";
#ifdef DEBUG
static NSString * const kBaseURLStringProduction = @"http://www.getbeacons.com/api/";
#else
static NSString * const kBaseURLStringProduction = @"https://www.getbeacons.com/api/";
#endif
static NSString * const kBaseURLStringStaging = @"http://hotspotapp-staging.herokuapp.com/api/";
