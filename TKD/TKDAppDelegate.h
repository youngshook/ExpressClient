//
//  TKDAppDelegate.h
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TKDLoginViewController;

@interface TKDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) NSMutableArray *listData;
@property (nonatomic, strong) UITabBarController *tabBarVC;
@property (nonatomic,strong) TKDLoginViewController *loginVC;

-(void)resetTabBarVC;

@end
