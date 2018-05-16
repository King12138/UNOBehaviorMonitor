//
//  UNOBehaviorMonitor.h
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/9.
//  Copyright © 2018年 unovo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UNOBehaviorMonitor : NSObject

//the clientId is a number that can indicate a user
//if the clientId is never registed, then will create
//a folder for the clentId in the folder named "Document"
//if the clientId is nil, then will do nothing for you 
+ (void)startWithClientId:(NSString *)clientId;
+ (void)stop;

//will show log in the console default is false
+ (void)setDebug:(BOOL)debug;

@end
