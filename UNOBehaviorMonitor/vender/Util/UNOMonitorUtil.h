//
//  UNOMonitorUtil.h
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/9.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UNODateUtil.h"

#define MonitorExWithInsSel(class,seletor1,seletor2)\
do {\
[UNOMonitorUtil MonitorExInsSelWithClass:class origin:seletor1 swizzle:seletor2];\
} while (0)

#define MonitorExWithClassSel(class,seletor1,seletor2)\
do {\
[UNOMonitorUtil MonitorExClsSelWithClass:class origin:seletor1 swizzle:seletor2];\
} while (0)

@interface UNOMonitorUtil : NSObject

+ (void)monitorDescption:(NSDictionary *)result;

+ (NSArray *)XPathWith:(UIView *)element;
+ (NSDictionary *)subViewsWith:(UIView *)element;

+ (BOOL)MonitorExClsSelWithClass:(Class)class origin:(SEL)origin swizzle:(SEL)swizzle;
+ (BOOL)MonitorExInsSelWithClass:(Class)class origin:(SEL)origin swizzle:(SEL)swizzle;

@end
