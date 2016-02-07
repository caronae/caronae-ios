#import "NSDictionary+dictionaryWithoutNulls.h"

@implementation NSDictionary(dictionaryWithoutNulls)

- (NSDictionary *)dictionaryWithoutNulls {
    NSMutableDictionary *new = [[NSMutableDictionary alloc] initWithDictionary:self];
    for (id key in new.allKeys) {
        if ([new[key] isKindOfClass:[NSNull class]]) {
            new[key] = @"";
        }
    }
    return new;
}

@end
