#import <Foundation/Foundation.h>

@interface Message : NSObject

- (instancetype)initWithIncoming:(BOOL)incoming text:(NSString *)text sentDate:(NSDate *)sentDate;

@property (nonatomic) BOOL incoming;
@property (nonatomic) NSString *text;
@property (nonatomic) NSDate *sentDate;

@end
