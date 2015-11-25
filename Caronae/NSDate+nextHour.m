#import "NSDate+nextHour.h"

@implementation NSDate(nextHour)

+ (NSDate *)nextHour {
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour fromDate:now];
    components.hour++;
    return [calendar dateFromComponents:components];
}

@end
