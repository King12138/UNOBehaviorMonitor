//
//  UIGestureRecognizer+monitor_add.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/15.
//

#import "UIGestureRecognizer+monitor_add.h"
#import "UNOMonitorUtil.h"
#import "UNOBehaviorDef.h"
#import "NSObject+UNO_aspect.h"
#import <objc/runtime.h>

@interface _private_GestureRecognizer_Target : NSObject

@property (nonatomic, assign) NSUInteger target_actionPairsCounts;
@property (nonatomic, assign) BOOL canRespondShouldBegin;

- (void)_private_handlerGes:(UIGestureRecognizer *)ges;
- (void)_private_gestureRecognizerShouldBegin:(UIGestureRecognizer *)ges;

@end

@implementation UIGestureRecognizer (monitor_add)

static const char *UNO_PrivateMonitorToken_Key = "UNO_PrivateMonitorToken_Key";

+ (void)load{
    //hook gesture is a hard work
    //a gesture is so flexible that can support various scenes
    // .1 be added to a view and give some target-action pairs
    // .2 give a delegate and do something wanted in delegate function but not give a target-action pair
    // .3 may both above
    //  #import <UIKit/UIGestureRecognizerSubclass.h>
    // .4 overwritten 'touchesBegan' serial function
    
    // we just hook the specific functions and to do
    // something wanted
    MonitorExWithInsSel(self,
                        @selector(addTarget:action:),
                        @selector(_monitor_addTarget:action:));
    MonitorExWithInsSel(self,
                        @selector(removeTarget:action:),
                        @selector(_monitor_removeTarget:action:));
    MonitorExWithInsSel(self,
                        @selector(setDelegate:),
                        @selector(_monitor_setDelegate:));
}

- (void)_monitor_addTarget:(id)target action:(SEL)action{
    //just in case
    if ([target isKindOfClass:[_private_GestureRecognizer_Target class]]){
        return;
    }
    [self _monitor_addTarget:target action:action];
    
    if (![self validGesClassForMonitor]) return;
    
    _private_GestureRecognizer_Target *privateTarget = objc_getAssociatedObject(self, UNO_PrivateMonitorToken_Key);
    
    if (privateTarget != nil){
        privateTarget.target_actionPairsCounts +=1;
        return;
    }
    
    privateTarget = [[_private_GestureRecognizer_Target alloc] init];
    objc_setAssociatedObject(self, UNO_PrivateMonitorToken_Key, privateTarget, OBJC_ASSOCIATION_RETAIN);
    privateTarget.target_actionPairsCounts = 1;
    [self _monitor_addTarget:privateTarget
                     action:@selector(_private_handlerGes:)];
}

- (void)_monitor_removeTarget:(id)target action:(SEL)action{
    //just in case
    if ([target isKindOfClass:[_private_GestureRecognizer_Target class]]){
        return;
    }
    
    [self _monitor_removeTarget:target action:action];
    
    if (![self validGesClassForMonitor]) return;
    _private_GestureRecognizer_Target *privateTarget = objc_getAssociatedObject(self, UNO_PrivateMonitorToken_Key);
    
    if (privateTarget == nil||
        --privateTarget.target_actionPairsCounts>0 ||
        privateTarget.canRespondShouldBegin == YES) return;
    
    objc_setAssociatedObject(self, UNO_PrivateMonitorToken_Key, nil, OBJC_ASSOCIATION_RETAIN);
    [self _monitor_removeTarget:privateTarget
                         action:@selector(_private_handlerGes:)];
}

- (void)_monitor_setDelegate:(id<UIGestureRecognizerDelegate>)delegate{
    //just in case
    if ([delegate isKindOfClass:[_private_GestureRecognizer_Target class]]){
        return;
    }
    
    [self _monitor_setDelegate:delegate];
    
    if (![self validGesClassForMonitor]) return;
    
    _private_GestureRecognizer_Target *privateTarget = objc_getAssociatedObject(self, UNO_PrivateMonitorToken_Key);

    if (privateTarget != nil){
        if (delegate == nil) {
            if ( privateTarget.target_actionPairsCounts == 0) {
                objc_setAssociatedObject(self, UNO_PrivateMonitorToken_Key, nil, OBJC_ASSOCIATION_RETAIN);
                return;
            }
        }else{
            NSString *delegateClassName = NSStringFromClass([delegate class]);
            if ([delegateClassName hasPrefix:@"_"]) {
                return;
            }
        }        
    }else{
        privateTarget = [[_private_GestureRecognizer_Target alloc] init];
        objc_setAssociatedObject(self, UNO_PrivateMonitorToken_Key, privateTarget, OBJC_ASSOCIATION_RETAIN);
    }

    //here is just to aspect gestureRecognizerShouldBegin
    //may add some later if needed

    if ([delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)]) {
        privateTarget.canRespondShouldBegin = YES;
        [(NSObject *)delegate aspect_fromSelector:@selector(gestureRecognizerShouldBegin:)
                                         toTarget:privateTarget
                                               to:@selector(_private_gestureRecognizerShouldBegin:)];
    }
}

#pragma mark-
#pragma mark- util
//just monitor some specific Ges
- (BOOL)validGesClassForMonitor{
    NSString *className = NSStringFromClass([self class]);
    return ![className hasPrefix:@"_"];
}

@end

@implementation _private_GestureRecognizer_Target

- (void)_private_handlerGes:(UIGestureRecognizer *)ges{
    // if can repsond gestureRecognizerShouldBegin
    // It is enough for collect message
    if (self.canRespondShouldBegin) return;
    
    [self logWithGes:ges];
}

-(void)_private_gestureRecognizerShouldBegin:(UIGestureRecognizer *)ges{
    [self logWithGes:ges];
}

- (void)logWithGes:(UIGestureRecognizer *)ges{
    if (!ges) return;
    NSLog(@"logWithGes ---> %@",ges);
    NSString *gesClassName = NSStringFromClass([ges class]);
    NSMutableDictionary *infoMap = [NSMutableDictionary dictionaryWithObject:gesClassName forKey:UNOBehavior_ClassName];
    @try{
        if (ges.view!=nil) {
            NSArray *gesViewPath = [UNOMonitorUtil XPathWith:ges.view];
            NSDictionary *gesSubViews = [UNOMonitorUtil subViewsWith:ges.view];
            [infoMap setObject:gesSubViews forKey:UNOBehavior_SubViewInfo];
            [infoMap setObject:gesViewPath forKey:UNOBehavior_XPath];
        }
        
        if (ges.delegate!=nil) {
            NSString *gesDelegateName = NSStringFromClass([ges.delegate class]);
            [infoMap setObject:gesDelegateName forKey:UNOBehavior_DelegateClass];
        }

    }@catch(NSException *e){
        infoMap = nil;
    }@finally{
        [UNOMonitorUtil monitorDescption:[infoMap copy]];
    }
}

@end
