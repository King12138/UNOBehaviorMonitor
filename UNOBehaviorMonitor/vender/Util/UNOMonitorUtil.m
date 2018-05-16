//
//  UNOMonitorUtil.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/9.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import "UNOMonitorUtil.h"
#import <objc/runtime.h>

@interface UNOMonitorUtil ()

@property (nonatomic, strong) NSFileHandle *writeFileHandler;
@property (nonatomic, strong) NSFileHandle *readFileHandler;

@end

@implementation UNOMonitorUtil

+(instancetype)shared{
    static UNOMonitorUtil *one = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        one = [[UNOMonitorUtil alloc] init];
    });
    return one;
}

+ (BOOL)makeFileAtPath:(NSString *)path{
    if (!path) {
        return NO;
    }
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        if ([[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return YES;
    }
}

- (NSFileHandle *)writeFileHandler{
    if (!_writeFileHandler) {
        NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *fullPath = [documentPath stringByAppendingPathComponent:@"behavior.txt"];
        NSLog(@"fullPath --> %@",fullPath);
        if (![UNOMonitorUtil makeFileAtPath:fullPath]) {
            return nil;
        }
        _writeFileHandler = [NSFileHandle fileHandleForWritingAtPath:fullPath];
    }
    return _writeFileHandler;
}

#pragma mark-
#pragma mark- private

- (void)monitorDescption:(NSDictionary *)result{
    if (!result || result.count<=0) return;
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:result options:NSJSONWritingPrettyPrinted error:nil];
    NSString *info = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self.writeFileHandler writeData:[[info stringByAppendingString:@"\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    NSLog(@"%@",info);
}

- (NSArray *)XPathWith:(UIView *)element{
    if (!element) return nil;
    
    NSArray *viewChain = nil;
    if (element.superview != nil && [element.nextResponder isKindOfClass:[UIViewController class]]) {
        NSString *nextResponderClass = NSStringFromClass(element.nextResponder.class);
        NSDictionary *selfInfo = [self mapInfoForView:element];
        if ([element.nextResponder isKindOfClass:[UINavigationController class]]) {
            NSString *topVCClass = NSStringFromClass([[(UINavigationController *)element.nextResponder topViewController] class]);
            viewChain = @[nextResponderClass,topVCClass,selfInfo];
        }else if ([element.nextResponder isKindOfClass:[UITabBarController class]]){
            NSString *currenVCClass = NSStringFromClass([[(UITabBarController *)element.nextResponder selectedViewController] class]);
            viewChain = @[nextResponderClass,currenVCClass,selfInfo];
        }else{
            viewChain = @[nextResponderClass,selfInfo];
        }
    }else{
        viewChain = [self viewChainWithView:element];
    }
    return viewChain;
}


#pragma mark-
#pragma mark- util

- (NSArray *)viewChainWithView:(UIView *)view{
    NSDictionary *selfInfo = [self mapInfoForView:view];
    if (view.superview != nil) {
        //指检测到ViewController,可以定位到是哪一个VC就足够了
        if ([view.nextResponder isKindOfClass:[UIViewController class]]) {
            NSString *nextResponderClass = NSStringFromClass(view.nextResponder.class);
            if ([view.nextResponder isKindOfClass:[UINavigationController class]]) {
                NSString *topVCClass = NSStringFromClass([[(UINavigationController *)view.nextResponder topViewController] class]);
                return @[nextResponderClass,topVCClass];
            }else if ([view.nextResponder isKindOfClass:[UITabBarController class]]){
                NSString *currenVCClass = NSStringFromClass([[(UITabBarController *)view.nextResponder selectedViewController] class]);
                return @[nextResponderClass,currenVCClass];
            }
            return @[nextResponderClass];
        }else{
            NSMutableArray *superViewChain = [[self viewChainWithView:view.superview] mutableCopy];
            if (selfInfo != nil) {
                [superViewChain addObject:selfInfo];
            }
            return [superViewChain copy];
        }
    }else{
        NSString *nextResponderClass = NSStringFromClass(view.nextResponder.class);
        NSMutableArray *viewChain = [NSMutableArray arrayWithObject:nextResponderClass];
        [viewChain addObject:selfInfo];
        return [viewChain copy];
    }
}

- (NSDictionary *)mapInfoForView:(UIView *)view{
    if (!view) return @{};
    
    NSString *className = NSStringFromClass(view.class);
    NSString *frame = NSStringFromCGRect(view.frame);
    NSString *textLabel = nil;
    if ([view isKindOfClass:[UIButton class]]) {
        textLabel = [(UIButton *)view titleLabel].text;
    }else if ([view isKindOfClass:[UILabel class]]){
        textLabel = [(UILabel *)view text];
    }else if ([view isKindOfClass:[UITextField class]]){
        textLabel = [(UITextField *)view placeholder];
    }else if ([self respondsToSelector:@selector(text)]){
        textLabel = [self performSelector:@selector(text)];
    }
    
    NSDictionary *dictionary = nil;
    if (textLabel.length>0) {
        dictionary = @{@"Class":className,
                       @"frame":frame,
                       @"text":textLabel};
    }else{
        dictionary = @{@"Class":className,
                       @"frame":frame};
    }
    
    return dictionary == nil ?@{}:dictionary;
}

- (NSDictionary *)subViewsWith:(UIView *)element{
    if (!element) return nil;
    NSMutableDictionary *topChain = [[self mapInfoForView:element] mutableCopy];
    
    if ([element isKindOfClass:[UITableViewCell class]]) {
        [topChain setObject:[self subViewsWith:[(UITableViewCell *)element contentView]]
                     forKey:@"subViews"];
        return [topChain copy];
    }else if ([element isKindOfClass:[UICollectionViewCell class]]) {
        [topChain setObject:[self subViewsWith:[(UICollectionViewCell *)element contentView]]
                     forKey:@"subViews"];
        return [topChain copy];
    }
    
    if (element.subviews.count>0) {
        NSMutableArray *subViews = [NSMutableArray array];
        for (UIView *view in element.subviews) {
            id subViewInfor = [self subViewsWith:view];
            if (!subViews) continue;
            [subViews addObject:subViewInfor];
        }
        [topChain setObject:subViews
                     forKey:@"subViews"];
        return [topChain copy];
    }else{
        return [self mapInfoForView:element];
    }
}

#pragma mark-
#pragma mark- api
+ (void)monitorDescption:(NSDictionary *)result{
    [[UNOMonitorUtil shared] monitorDescption:result];
}

+ (NSArray *)XPathWith:(UIView *)element{
    return [[UNOMonitorUtil shared] XPathWith:element];
}

+ (NSDictionary *)subViewsWith:(UIView *)element{
    return [[UNOMonitorUtil shared] subViewsWith:element];
}

+ (BOOL)MonitorExClsSelWithClass:(Class)class origin:(SEL)origin swizzle:(SEL)swizzle{
    if (!(NSStringFromSelector(origin)&&NSStringFromSelector(swizzle)))  return false;
    
    Method originM = class_getClassMethod(class, origin);
    Method swizzleM = class_getClassMethod(class, swizzle);
    if (!originM || !swizzleM) return false;
    
    method_exchangeImplementations(originM, swizzleM);
    return YES;
}
+ (BOOL)MonitorExInsSelWithClass:(Class)class origin:(SEL)origin swizzle:(SEL)swizzle{
    if (!(NSStringFromSelector(origin)&&NSStringFromSelector(swizzle)))  return false;
    
    Method originM = class_getInstanceMethod(class, origin);
    Method swizzleM = class_getInstanceMethod(class, swizzle);
    if (!originM || !swizzleM) return false;
    
    method_exchangeImplementations(originM, swizzleM);
    return YES;
}

@end
