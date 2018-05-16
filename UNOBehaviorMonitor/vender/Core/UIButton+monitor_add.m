//
//  UIButton+monitor_add.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/9.
//

#import "UIButton+monitor_add.h"
#import "UNOMonitorUtil.h"
#import "UNOBehaviorDef.h"

@implementation UIControl (monitor_add)

+(void)load{
    MonitorExWithInsSel(self,
                        @selector(sendAction:to:forEvent:),
                        @selector(_monitor_sendAction:to:forEvent:));
}

- (void)_monitor_sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event{
    
    NSArray *selfXPath = [UNOMonitorUtil XPathWith:self];
    [self _monitor_sendAction:action to:target forEvent:event];
    
    NSDictionary *selfInfor = [UNOMonitorUtil subViewsWith:(UIView *)self];
    NSString *actionName = NSStringFromSelector(action);
    NSString *targetClassName = NSStringFromClass([(NSObject *)target class]);
    
    NSDictionary * infoMap = nil;
    @try {
        infoMap = @{UNOBehavior_Action:actionName,
                    UNOBehavior_ClassName:targetClassName,
                    UNOBehavior_XPath:selfXPath,
                    UNOBehavior_SubViewInfo:selfInfor};
    } @catch (NSException *exception) {
        infoMap = nil;
    } @finally {
        [UNOMonitorUtil monitorDescption:infoMap];
    }
}

@end
