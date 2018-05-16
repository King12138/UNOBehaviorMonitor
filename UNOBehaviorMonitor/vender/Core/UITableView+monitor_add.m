//
//  UITableView+monitor_add.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/10.
//

#import "UITableView+monitor_add.h"
#import "UNOMonitorUtil.h"
#import "UNOBehaviorDef.h"

#import "NSObject+UNO_aspect.h"
#import <objc/runtime.h>

@interface _private_AspectForTableView : NSObject

- (void)_private_tableView:(UITableView *)tableview
   didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation UITableView (monitor_add)

+ (void)load{
    MonitorExWithInsSel(self,
                        @selector(setDelegate:),
                        @selector(_monitor_setDelegate:));
}

static const char *UNOTableViewDeleteHasAspectKey = "UNOTableViewDeleteHasAspectKey";
- (void)_monitor_setDelegate:(id<UITableViewDelegate>)delegate{
    [self _monitor_setDelegate:delegate];
    
    //针对hook代理的方案,这里有两种,
    //第一种是永远让tableView变成自己的代理,然后转发给真正的代理者
    //第二种是swizzle真正的代理的方法,让系统直接把消息发给真正的代理,然后让代理转发个monitor服务,
    //这里采用第二种,
    //理由:在monitor代码有问题的时候,保证业务代码的有效,允许monitor服务采集不到信息,
    if (!delegate) return;
    
    _private_AspectForTableView *one = objc_getAssociatedObject(delegate, UNOTableViewDeleteHasAspectKey);
    
    if (one != nil) return;
    
    one = [[_private_AspectForTableView alloc] init];
    [(NSObject *)delegate aspect_fromSelector:@selector(tableView:
                                                        didSelectRowAtIndexPath:)
                                     toTarget:one
                                           to:@selector(_private_tableView:
                                                            didSelectRowAtIndexPath:)];
    objc_setAssociatedObject(delegate, UNOTableViewDeleteHasAspectKey, one, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation _private_AspectForTableView

- (void)_private_tableView:(UITableView *)tableview
   didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSArray *selfXPath = [UNOMonitorUtil XPathWith:tableview];
    NSMutableDictionary *infoMap = nil;
    @try{
        infoMap = [@{UNOBehavior_XPath:selfXPath,
                    UNOBehavior_Action:@"tableViewSelect",
                    UNOBehavior_IndexSection:@(indexPath.section).stringValue,
                    UNOBehavior_IndexRow:@(indexPath.row).stringValue} mutableCopy];
        
    }@catch (NSException *exception){
        infoMap = [@{UNOBehavior_Action:@"tableViewSelect",
                    UNOBehavior_IndexSection:@(indexPath.section).stringValue,
                    UNOBehavior_IndexRow:@(indexPath.row).stringValue}mutableCopy];
    }@finally {
         UITableViewCell *cell = [tableview cellForRowAtIndexPath:indexPath];
        if (cell) {
           NSDictionary *subViewInfo = [UNOMonitorUtil subViewsWith:cell];
             [infoMap setObject:subViewInfo forKey:UNOBehavior_SubViewInfo];
        }
        
        if (cell.textLabel.text!=nil&&
            cell.textLabel.text.length>0) {
            [infoMap setObject:cell.textLabel.text forKey:UNOBehavior_CellTitle];
        }
        
        if (cell.detailTextLabel.text!=nil&&
            cell.detailTextLabel.text.length>0) {
            [infoMap setObject:cell.detailTextLabel.text forKey:UNOBehavior_CellDetailTitle];
        }
        [UNOMonitorUtil monitorDescption:[infoMap copy]];
    }
}

@end

