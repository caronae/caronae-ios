#import "Message.h"

@implementation Message

- (instancetype)initWithIncoming:(BOOL)incoming text:(NSString *)text sentDate:(NSDate *)sentDate {
    self = [super init];
    if (self) {
        _incoming = incoming;
        _text = text;
        _sentDate = sentDate;
    }
    return self;
}

@end
