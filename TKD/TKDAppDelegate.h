//
//  TKDAppDelegate.h
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMFilterView.h"
@class TKDLoginViewController;

@interface TKDAppDelegate : UIResponder <UIApplicationDelegate,DMFilterViewDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) NSMutableArray *listData;
@property (nonatomic, strong) UITabBarController *tabBarVC;
@property (nonatomic,strong) TKDLoginViewController *loginVC;
@property (nonatomic, strong) DMFilterView *filterView;
-(void)resetTabBarVC;
-(void)hideTabBar;
-(void)showTabBar;
@end
