//
//  UICollectionView+monitor_add.m
//  UNOBehaviorMonitor
//
//  Created by intebox on 2018/5/14.
//

#import "UICollectionView+monitor_add.h"
#import "UNOMonitorUtil.h"
#import "UNOBehaviorDef.h"

#import "NSObject+UNO_aspect.h"
#import <objc/runtime.h>

@interface _private_AspectForCollectionView : NSObject

- (void)_private_collectionView:(UICollectionView *)collectionView
       didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)_private_collectionView:(UICollectionView *)collectionView
     didDeselectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@implementation UICollectionView (monitor_add)

+ (void)load{
    MonitorExWithInsSel(self,
                        @selector(setDelegate:),
                        @selector(_monitor_setDelegate:));
}

static const char *UNOCollectionViewDeleteHasAspectKey = "UNOCollectionViewDeleteHasAspectKey";
- (void)_monitor_setDelegate:(id<UICollectionViewDelegate>)delegate{
    [self _monitor_setDelegate:delegate];

    if (!delegate) return;
    
    _private_AspectForCollectionView *one = objc_getAssociatedObject(delegate, UNOCollectionViewDeleteHasAspectKey);
    
    if (one != nil) return;
    
    one = [[_private_AspectForCollectionView alloc] init];
    [(NSObject *)delegate
     aspect_fromSelector:@selector(collectionView:
                                   didSelectItemAtIndexPath:)
     toTarget:one
     to:@selector(_private_collectionView:
                  didSelectItemAtIndexPath:)];
    
    [(NSObject *)delegate
     aspect_fromSelector:@selector(collectionView:
                                   didDeselectItemAtIndexPath:)
     toTarget:one
     to:@selector(_private_collectionView:
                  didDeselectItemAtIndexPath:)];
    objc_setAssociatedObject(delegate, UNOCollectionViewDeleteHasAspectKey, one, OBJC_ASSOCIATION_RETAIN);
}

@end

@implementation _private_AspectForCollectionView : NSObject

- (void)_private_collectionView:(UICollectionView *)collectionView
       didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self logForView:collectionView cmd:_cmd indexPath:indexPath];
}
- (void)_private_collectionView:(UICollectionView *)collectionView
     didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
     [self logForView:collectionView cmd:_cmd indexPath:indexPath];
}

- (void)logForView:(UICollectionView *)collectionView
               cmd:(SEL)cmd
         indexPath:(NSIndexPath *)indexPath{
    
    NSArray *selfXPath = [UNOMonitorUtil XPathWith:collectionView];
    NSString *cmdName = NSStringFromSelector(cmd);
    
    NSMutableDictionary *infoMap = nil;
    @try{
        infoMap = [@{UNOBehavior_XPath:selfXPath,
                    UNOBehavior_Action:cmdName,
                    UNOBehavior_IndexSection:@(indexPath.section).stringValue,
                    UNOBehavior_IndexRow:@(indexPath.row).stringValue} mutableCopy];
        
    }@catch(NSException *e){
        infoMap = [@{UNOBehavior_Action:cmdName,
                    UNOBehavior_IndexSection:@(indexPath.section).stringValue,
                    UNOBehavior_IndexRow:@(indexPath.row).stringValue} mutableCopy];
    }@finally{
        UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];

        if (cell) {
            NSDictionary *subViewInfo = [UNOMonitorUtil subViewsWith:cell];
            [infoMap setObject:subViewInfo forKey:UNOBehavior_SubViewInfo];
        }
        [UNOMonitorUtil monitorDescption:[infoMap copy]];
    }
}

@end
