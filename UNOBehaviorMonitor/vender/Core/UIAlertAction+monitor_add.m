//
//  UIAlertAction+monitor_add.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/14.
//

#import "UIAlertAction+monitor_add.h"
#import "UNOMonitorUtil.h"
#import "UNOBehaviorDef.h"

@implementation UIAlertAction (monitor_add)

+ (void)load{
    MonitorExWithClassSel(self,
                          @selector(actionWithTitle:style:handler:),
                          @selector(_monitor_actionWithTitle:style:handler:));
}

+(instancetype)_monitor_actionWithTitle:(NSString *)title style:(UIAlertActionStyle)style handler:(void (^)(UIAlertAction * _Nonnull))handler{
    void (^wrapedHanlder)(UIAlertAction * _Nonnull) = ^(UIAlertAction *action){
        if (handler != nil) {
            handler(action);
        }
        
        NSDictionary *infoMap;
        @try{
            infoMap = @{UNOBehavior_AlterTitle:title,
                        UNOBehavior_AlterType:@(style)};
        }@catch (NSException *exception){
            infoMap = nil;
        }@finally {
            [UNOMonitorUtil monitorDescption:infoMap];
        }
    };
    return [self _monitor_actionWithTitle:title style:style handler:wrapedHanlder];
}

@end
