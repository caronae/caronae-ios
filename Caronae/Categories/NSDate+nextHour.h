#import <Foundation/Foundation.h>

@interface NSDate(nextHour)

/**
 *  Gets the next full hour from current date. For example, if now is 16:16:45, returns 17:00:00.
 *
 *  @return NSDate with next full hour (current hour + 1), 0 minutes and 0 seconds.
 */
+ (NSDate *)nextHour;

/**
 *  Gets the current full hour from current date. For example, if now is 16:16:45, returns 16:00:00.
 *
 *  @return NSDate with current full hour (current hour), 0 minutes and 0 seconds.
 */
+ (NSDate *)currentHour;

/**
 *  Gets the current full hour:minutes from current date plus the argument in minutes.
 *
 *  @return NSDate with currente full hour:minutes + minutes.
 */
+ (NSDate *)currentTimePlus:(NSInteger)minutes;

@end
