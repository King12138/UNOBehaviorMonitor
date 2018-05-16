//
//  UIPickerView+monitor_add.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/16.
//

#import "UIPickerView+monitor_add.h"
#import "UNOMonitorUtil.h"
#import "UNOBehaviorDef.h"

#import <objc/runtime.h>
#import "NSObject+UNO_aspect.h"

@interface _private_AspectForPickView : NSObject

- (void)_private_pickerView:(UIPickerView *)pickView
               didSelectRow:(NSInteger)row
                inComponent:(NSInteger)component;

@end

@implementation UIPickerView (monitor_add)

+ (void)load{
    MonitorExWithInsSel(self,
                        @selector(setDelegate:),
                        @selector(_monitor_setDelegate:));
}

static const char *UNOPickViewDeleteHasAspectKey = "UNOPickViewDeleteHasAspectKey";

- (void)_monitor_setDelegate:(id<UIPickerViewDelegate>)delegate{
    [self _monitor_setDelegate:delegate];
    
    if (!delegate) return;
    
    _private_AspectForPickView *one = objc_getAssociatedObject(delegate, UNOPickViewDeleteHasAspectKey);
    
    if (one != nil) return;

    one = [[_private_AspectForPickView alloc] init];
    objc_setAssociatedObject(delegate, UNOPickViewDeleteHasAspectKey, one, OBJC_ASSOCIATION_RETAIN);
    
    if ([delegate respondsToSelector:@selector(pickerView:didSelectRow:inComponent:)]) {
        [(NSObject *)delegate aspect_fromSelector:@selector(pickerView:didSelectRow:inComponent:)
                                         toTarget:one
                                               to:@selector(_private_pickerView:didSelectRow:inComponent:)];
    }
    
}
@end

@implementation _private_AspectForPickView

- (void)_private_pickerView:(UIPickerView *)pickView
               didSelectRow:(NSInteger)row
                inComponent:(NSInteger)component{
    
    NSString *title = [pickView.delegate pickerView:pickView titleForRow:row forComponent:component];
    
    NSMutableDictionary *infoMap = nil;
    @try{
        infoMap = [@{UNOBehavior_PickViewTitle:title,
                     UNOBehavior_IndexSection:@(component).stringValue,
                     UNOBehavior_IndexRow:@(row).stringValue} mutableCopy];
    }@catch(NSException *e){
        infoMap = [@{UNOBehavior_IndexSection:@(component).stringValue,
                     UNOBehavior_IndexRow:@(row).stringValue} mutableCopy];
    }@finally{
        [UNOMonitorUtil monitorDescption:[infoMap copy]];
    }
}

@end
