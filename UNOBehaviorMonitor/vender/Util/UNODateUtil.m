//
//  UNODateUtil.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/9.
//

#import "UNODateUtil.h"

@implementation UNODateUtil

+(instancetype)shared{
    static UNODateUtil *one = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        one = [[UNODateUtil alloc] init];
    });
    return one;
}

- (NSDateFormatter *)dateFormatter{
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];
    }
    return _dateFormatter;
}

+ (NSString *)descriptionWithCurrentDate{
    return [[UNODateUtil shared] descriptionWithCurrentDate];
}

- (NSString *)descriptionWithCurrentDate{
    return [self.dateFormatter stringFromDate:[NSDate date]];
}

@end
