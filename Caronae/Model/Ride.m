#import "Ride.h"

static NSDateFormatter *dateFormatter;
static NSDateFormatter *otherDateParserFormatter;

@implementation Ride

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"rideID": @"id",
             @"neighborhood": @"neighborhood",
             @"zone": @"myzone",
             @"place": @"place",
             @"route": @"route",
             @"slots": @"slots",
             @"notes": @"description",
             @"hub": @"hub",
             @"going": @"going",
             @"driver": @"driver",
             @"users": @"riders",
             @"date": @[ @"mydate", @"mytime" ],
             @"routineID": @[ @"routine_id", @"week_days" ]
             };
}

+ (NSValueTransformer *)routineIDJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *routineDictionary, BOOL *success, NSError *__autoreleasing *error) {
        NSString *weekDays = routineDictionary[@"week_days"];
        id routineID = routineDictionary[@"routine_id"];
        if ([weekDays isEqual:[NSNull null]] || ([weekDays isKindOfClass:NSString.class] && weekDays.length == 0) || (routineID == nil)) {
            return @(0);
        } else {
            return routineID;
        }
    } reverseBlock:^id(id routineID, BOOL *success, NSError *__autoreleasing *error) {
        return @{ @"routine_id": routineID };
    }];
}

+ (NSValueTransformer *)dateJSONTransformer {
    if (!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *dateDictionary, BOOL *success, NSError *__autoreleasing *error) {
        NSString *dateString = [NSString stringWithFormat:@"%@ %@", dateDictionary[@"mydate"], dateDictionary[@"mytime"]];
        return [dateFormatter dateFromString:dateString];
    } reverseBlock:^id(NSDate *date, BOOL *success, NSError *__autoreleasing *error) {
        NSString *dateTimeString = [dateFormatter stringFromDate:date];
        NSArray *dateComponents = [dateTimeString componentsSeparatedByString:@" "];
        NSString *dateString = dateComponents[0];
        NSString *timeString = dateComponents[1];
        return @{ @"mydate": dateString, @"mytime": timeString };
    }];
}

+ (NSValueTransformer *)driverJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:User.class];
}

+ (NSValueTransformer *)usersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:User.class];
}

- (NSString *)title {
    if (_going) {
        return [NSString stringWithFormat:@"%@ → %@", _neighborhood, _hub];
    }
    else {
        return [NSString stringWithFormat:@"%@ → %@", _hub, _neighborhood];
    }
}

- (BOOL)active {
    return _users.count > 0;
}

- (BOOL)isRoutine {
    return _routineID != 0;
}

@end
