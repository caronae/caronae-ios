#import <Foundation/Foundation.h>
#import "User.h"

@interface Ride : NSObject

- (instancetype)initWithDictionary:(NSDictionary *)ride;

@property (nonatomic, copy) NSString *neighborhood;
@property (nonatomic, copy) NSString *place;
@property (nonatomic, copy) NSString *route;
@property (nonatomic, copy) NSDate *date;
@property (nonatomic, assign) unsigned int slots;
@property (nonatomic, copy) NSString *zone;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, copy) NSString *hub;
@property (nonatomic, assign) BOOL going;
@property (nonatomic, assign) long rideID;
@property (nonatomic, strong) User *driver;
@property (nonatomic, strong) NSArray<User *> *users;

@property (readonly, nonatomic, copy) NSString *title;

@end
