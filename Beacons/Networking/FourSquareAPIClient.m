//
//  FourSquareAPIClient.m
//  Beacons
//
//  Created by Jeffrey Ames on 6/8/13.
//  Copyright (c) 2013 Jeff Ames. All rights reserved.
//

#import "FourSquareAPIClient.h"

static NSString * const kFourSquareClientID = @"W2NADLA3QFZCLRLFIAUXVNUXMZYU02SFOWR3G4DYCT34D0H5";
static NSString * const kFourSquareClientSecret = @"4UQ3LTEBD5S5YXWYSTAIBMODD3K0UZVSTMV0RRRBECIVZ4VN";
static NSString * const kFourSquareCallBackURL = @"http://www.getbeacons.com";

@interface FourSquareAPIClient() <BZFoursquareRequestDelegate>

@property (strong, nonatomic) BZFoursquare *foursquare;
@property (strong, nonatomic) NSMutableArray *requests;
@property (strong, nonatomic) NSMutableArray *completionBlocks;
@end

@implementation FourSquareAPIClient

+ (FourSquareAPIClient *)sharedClient
{
    static FourSquareAPIClient *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedClient = [[FourSquareAPIClient alloc] init];
    });
    return _sharedClient;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.foursquare = [[BZFoursquare alloc] initWithClientID:kFourSquareClientID callbackURL:kFourSquareCallBackURL];
        self.foursquare.clientSecret = kFourSquareClientSecret;
        self.requests = [NSMutableArray new];
        self.completionBlocks = [NSMutableArray new];
    }
    return self;
}

- (void)searchVenuesNearLocation:(CLLocation *)location query:(NSString *)query radius:(NSNumber *)radius limit:(NSNumber *)limit completion:(void (^)(id response, NSError *error))completion
{
    NSDictionary *parameters = @{@"ll": [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude],
                                 @"query" : query,
                                 @"radius" : radius,
                                 @"limit" : limit};
    BZFoursquareRequest *request = [self.foursquare userlessRequestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
    [self.requests addObject:request];
    [self.completionBlocks addObject:completion];
    request.delegate = self;
    [request start];
}


#pragma mark - BZFourSquareRequestDelegate
- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error
{
    [self executeCompletionBlockForRequest:request error:error];
}

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request
{
    [self executeCompletionBlockForRequest:request error:nil];
}

- (void)requestDidStartLoading:(BZFoursquareRequest *)request
{
    
}

- (void)executeCompletionBlockForRequest:(BZFoursquareRequest *)request error:(NSError *)error
{
    NSInteger index = [self.requests indexOfObject:request];
    void (^completion)(id response, NSError *) = [self.completionBlocks objectAtIndex:index];
    completion(request.response, error);
}




@end
