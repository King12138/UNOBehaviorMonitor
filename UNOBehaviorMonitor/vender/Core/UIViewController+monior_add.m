//
//  UIViewController+monior_add.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/9.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import "UIViewController+monior_add.h"

#import "UNOMonitorUtil.h"
#import "UNOBehaviorDef.h"

@implementation UIViewController (monior_add)

+ (void)load{
    if ([self isKindOfClass:[UINavigationController class]]) {
        return;
    }
    
    MonitorExWithInsSel(self,
                        @selector(viewDidAppear:),
                        @selector(_monitor_viewDidAppear:));
    MonitorExWithInsSel(self,
                        @selector(viewDidDisappear:),
                        @selector(_monitor_viewDidDisappear:));
}

- (void)_monitor_viewDidAppear:(BOOL)animated{
    [self _monitor_viewDidAppear:animated];
    NSString *className = NSStringFromClass(self.class);
    NSString *title = self.title;
    NSString *dateString = [UNODateUtil descriptionWithCurrentDate];
    NSString *action = @"viewDidAppear";
    NSDictionary *infoMap = nil;
    @try {
        infoMap = @{UNOBehavior_ClassName:className,
                    UNOBehavior_VCTitle:title,
                    UNOBehavior_Date:dateString,
                    UNOBehavior_Action:action};
    } @catch (NSException *exception) {
        infoMap = nil;
    } @finally {
        [UNOMonitorUtil monitorDescption:infoMap];
    }
}

- (void)_monitor_viewDidDisappear:(BOOL)animated{
    [self _monitor_viewDidDisappear:animated];
    NSString *className = NSStringFromClass(self.class);
    NSString *title = self.title;
    NSString *dateString = [UNODateUtil descriptionWithCurrentDate];
    NSString *action = @"viewDidDisappear";
    NSDictionary * infoMap = nil;
    @try {
        infoMap = @{UNOBehavior_ClassName:className,
                    UNOBehavior_VCTitle:title,
                    UNOBehavior_Date:dateString,
                    UNOBehavior_Action:action};
    } @catch (NSException *exception) {
        infoMap = nil;
    } @finally {
        [UNOMonitorUtil monitorDescption:infoMap];
    }
}

@end
