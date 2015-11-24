#import "CaronaeConstants.h"

#pragma mark - API settings

//const NSString *CaronaeAPIBaseURL = @"http://45.55.46.90:8080";
//const NSString *CaronaeAPIBaseURL = @"http://192.168.1.19:8000";
const NSString *CaronaeAPIBaseURL = @"http://localhost:8000";


#pragma mark - Error types

NSString *CaronaeErrorDomain = @"CaronaeError";
const NSInteger CaronaeErrorInvalidResponse = 1;
const NSInteger CaronaeErrorNoRidesCreated = 2;