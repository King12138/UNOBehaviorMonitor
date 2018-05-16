//
//  UNOBehaviorMonitor.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/9.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import "UNOBehaviorMonitor.h"

@implementation UNOBehaviorMonitor

#pragma mark-
#pragma mark-

+ (instancetype)shared{
    static UNOBehaviorMonitor *one = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        one = [[UNOBehaviorMonitor alloc] init];
    });
    return one;
}

#pragma mark-
#pragma mark- private

- (void)startWithClientId:(NSString *)clientId{
    
    
    
}
- (void)stop{
    
}

- (void)setDebug:(BOOL)debug{
    
}


#pragma mark-
#pragma mark- api
+ (void)startWithClientId:(NSString *)clientId{
    [[UNOBehaviorMonitor shared] startWithClientId:clientId];
}
+ (void)stop{
    [[UNOBehaviorMonitor shared] stop];
}

+ (void)setDebug:(BOOL)debug{
    [[UNOBehaviorMonitor shared] setDebug:debug];
}

@end
