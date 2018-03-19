//
//  UIViewController+NetworkObserve.m
//  zcsdxc
//
//  Created by yxmac on 17/4/21.
//  Copyright © 2017年 steven. All rights reserved.
//

#import "UIViewController+NetworkObserve.h"

#import "Reachability.h"

#import <objc/runtime.h>

#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

@implementation UIViewController (NetworkObserve)

static NSString *KNoticeLable;



+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        SEL systemSel = @selector(viewWillAppear:);

        SEL swizzSel = @selector(swiz_viewWillAppear:);
        
        Method systemMethod = class_getInstanceMethod([self class], systemSel);
        Method swizzMethod = class_getInstanceMethod([self class], swizzSel);
        
        Method sysDes = class_getInstanceMethod([self class], @selector(viewWillDisappear:));
        
        Method swizzDes = class_getInstanceMethod([self class], @selector(swizz_viewWillDisappear:));
        
        BOOL isAdd = class_addMethod(self, systemSel, method_getImplementation(swizzMethod), method_getTypeEncoding(swizzMethod));
        if (isAdd) {
          
            class_replaceMethod(self, swizzSel, method_getImplementation(systemMethod), method_getTypeEncoding(systemMethod));
        }else{
            method_exchangeImplementations(systemMethod, swizzMethod);
            
            method_exchangeImplementations(sysDes, swizzDes);
        }
        
    });
}

- (void)swiz_viewWillAppear:(BOOL)animated{
 
    if (![self respondsToSelector:@selector(viewWillDisappear:)]) {
        [self swiz_viewWillAppear:animated];
        return;
    }
    
    NSArray *classArray;
    if (IOS_VERSION<8) {
        
        classArray = @[[UINavigationController class],[RootTabBarController class]];
    }
    else {
        classArray = @[[UINavigationController class],[RootTabBarController class],NSClassFromString(@"UIInputWindowController"),NSClassFromString(@"UIAlertController"),NSClassFromString(@"UICompatibilityInputViewController")];
    }
    
    for (id className in classArray) {
        if ([self isKindOfClass:className]) {
            [self swiz_viewWillAppear:YES];
            return;
        }
    }
    
    [kNotificationCenter addObserver:self selector:@selector(netWorkChanged:) name:kNetworkChangedNotification object:nil];
    
    if (![UntitlyFile isConnectionAvailable]) {
        
        UILabel *noticeLable = [self.view viewWithTag:888888];
        
        if (!noticeLable) {
            [self createNetworkLable];
        }

    }
}

- (void)swizz_viewWillDisappear:(BOOL)animated {
  
    [kNotificationCenter removeObserver:self name:kNetworkChangedNotification object:nil];
    
    [self removeNetworkLable];
    
    [self swizz_viewWillDisappear:animated];
    
}

- (void)netWorkChanged:(NSNotification *)notice {
    Reachability *currReach = [notice object];
    if ([currReach.currentReachabilityString isEqualToString:@"No Connection"]) {
        [self createNetworkLable];
    }
    
    else {
        [self removeNetworkLable];
    }
}


- (void)createNetworkLable {
    
    UILabel *noticeLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 66, SCREEN_WIDTH, 30)];
    
//    objc_setAssociatedObject(self, &KNoticeLable, noticeLable, OBJC_ASSOCIATION_ASSIGN);
    
    noticeLable.font = [UIFont systemFontOfSize:15];
    
    noticeLable.text = @"   网络请求失败，请检查您的网络设置";
    
    noticeLable.textColor = [UIColor whiteColor];
    
    noticeLable.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.8];
    
    noticeLable.tag = 888888;
    
    [self.view addSubview:noticeLable];
}

- (void)removeNetworkLable {
    
    UILabel *noticeLable = [self.view viewWithTag:888888];
    
    if (noticeLable) {
        
        [noticeLable removeFromSuperview];
        
    }
}

@end
