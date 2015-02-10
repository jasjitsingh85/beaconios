//
//  Constants.m
//  Beacons
//
//  Created by Jeffrey Ames on 5/18/14.
//  Copyright (c) 2014 Jeff Ames. All rights reserved.
//

#import "Constants.h"

NSString * const kBaseURLStringDevelopment = @"http://localhost:8000/api/";
NSString * const kBaseURLStringLAN = @"http://0.0.0.0:8000/api/";
#ifdef DEBUG
NSString * const kBaseURLStringProduction = @"http://www.getbeacons.com/api/";
#else
NSString * const kBaseURLStringProduction = @"https://www.getbeacons.com/api/";
#endif
NSString * const kBaseURLStringStaging = @"http://hotspotapp-staging.herokuapp.com/api/";

NSString * const kDealStatusLocked = @"L";
NSString * const kDealStatusUnlocked = @"U";
NSString * const kDealStatusRedeemed = @"R";

NSString * const kAppID = @"741683799178892";


NSString * const MIXPANEL_TOKEN = @"5ef90c03d9e72b7e1f460600d47de6ab";

NSString * const kTermsURL = @"http://www.getbeacons.com/terms";
NSString * const kPrivacyURL = @"http://www.getbeacons.com/privacy";

NSString * const kHappyHoursAppURLIdentifier = @"com.hotspot.happyhours";

