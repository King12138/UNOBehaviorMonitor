//
//  UNODateUtil.h
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/9.
//

#import <Foundation/Foundation.h>

@interface UNODateUtil : NSObject

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

+ (NSString *)descriptionWithCurrentDate;

@end
