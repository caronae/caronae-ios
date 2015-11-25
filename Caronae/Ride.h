#import <Foundation/Foundation.h>

@interface Ride : NSObject
- (instancetype)initWithDictionary:(NSDictionary *)ride;

@property (nonatomic) NSString *driverName;
@property (nonatomic) NSString *driverCourse;
@property (nonatomic) NSString *neighborhood;
@property (nonatomic) NSString *place;
@property (nonatomic) NSString *route;
@property (nonatomic) NSDate *date;
@property (nonatomic) unsigned int slots;
@property (nonatomic) NSString *zone;
@property (nonatomic) NSString *notes;
@property (nonatomic) NSString *hub;
@property (nonatomic) BOOL going;
@property (nonatomic) long rideID;
@property (nonatomic) long driverID;
@end
