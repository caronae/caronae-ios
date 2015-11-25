#import "Ride.h"

static NSDateFormatter *dateParserFormatter;

@implementation Ride

- (instancetype)initWithDictionary:(NSDictionary *)ride {
    self = [super init];
    if (self) {
        if (!dateParserFormatter) {
            dateParserFormatter = [[NSDateFormatter alloc] init];
            dateParserFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        }
        NSString *dateTimeString = [NSString stringWithFormat:@"%@ %@", ride[@"date"], ride[@"time"]];
        _date = [dateParserFormatter dateFromString:dateTimeString];
        _driverName = ride[@"driverName"];
        _driverCourse = ride[@"course"];
        _neighborhood = ride[@"neighborhood"];
        _place = ride[@"place"];
        _route = ride[@"route"];
        _zone = ride[@"zone"];
        _slots = [ride[@"slots"] unsignedIntValue];
        _notes = ride[@"description"];
        _hub = ride[@"hub"];
        _going = [ride[@"going"] boolValue];
        _rideID = [ride[@"rideId"] longValue];
        _driverID = [ride[@"driverId"] longValue];        
    }
    return self;
}

@end
