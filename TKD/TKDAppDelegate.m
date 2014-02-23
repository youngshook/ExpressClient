//
//  TKDAppDelegate.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

static NSString * const UMENG_APPKEY = @"52977b3d56240b0cf8030d2c";

@implementation TKDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self umengTrack];
    [self loadUserlocalString];
    if (!isFisrtLaunch) {
        [self getApplicationToken];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"alreadyFirstLaunch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    QFListenEvent(@"getApplicationToken", self, @selector(getApplicationToken));
    QFListenEvent(@"clearApnsList", self, @selector(clearApnsList));
    self.window.backgroundColor = [UIColor whiteColor];
    
    TKDMainViewController *mainVC = [TKDMainViewController new];
    TKDSendExpressVc *sendExpressVC = [TKDSendExpressVc new];
    TKDMsgViewController *msgVC = [TKDMsgViewController new];
    
    UINavigationController *navMainVc = [[UINavigationController alloc]initWithRootViewController:mainVC];
    UINavigationController *navSendExpressVC = [[UINavigationController alloc]initWithRootViewController:sendExpressVC];
    UINavigationController *navMsgVC = [[UINavigationController alloc]initWithRootViewController:msgVC];
    
    navMainVc.tabBarItem.title = @"取快递";
    navSendExpressVC.tabBarItem.title = @"寄快递";
    navMsgVC.tabBarItem.title = @"校园";
    
    self.tabBarVC = [UITabBarController new];
    [self.tabBarVC setViewControllers:@[navMainVc,navSendExpressVC,navMsgVC]];
    
    
    self.window.rootViewController = self.tabBarVC;
    [self.window makeKeyAndVisible];
    
    [APService registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge |
                                         UIRemoteNotificationTypeSound |
                                         UIRemoteNotificationTypeAlert)];
    [APService setupWithOption:launchOptions];
    
    return YES;
}

-(void)umengTrack{

    [MobClick setAppVersion:AppVersionShort]; //参数为NSString * 类型,自定义app版本信息，如果不设置，默认从CFBundleVersion里取
                                              //
    [MobClick startWithAppkey:UMENG_APPKEY reportPolicy:(ReportPolicy) REALTIME channelId:nil];
    
    [MobClick updateOnlineConfig];
}

-(void)getApplicationToken{
    NSURL *url = [NSURL URLWithString:API_APP_INIT];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine
    [request addPostValue:APP_ID forKey:@"id"];
    [request addPostValue:APP_SECRET forKey:@"secret"];
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        if ([dic objectForKey:@"ApplicationToken"]) {
            [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"ApplicationToken"] forKey:@"ApplicationToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }];
    [request setFailedBlock:^{
        NetworkError
    }];
    [request startAsynchronous];
}



-(void)loadUserlocalString{
    [USER_DEFAULTS setObject:@"可取" forKey:@"Retrieveable"];
    [USER_DEFAULTS setObject:@"已取件" forKey:@"Retrieved"];
    [USER_DEFAULTS setObject:@"其他" forKey:@"Other"];
    [USER_DEFAULTS  synchronize];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [APService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    if (application.applicationState == UIApplicationStateActive || UIApplicationStateInactive == application.applicationState) {
        QFEvent(@"fetchDataSource", nil);
        if ([[userInfo objectForKey:@"type"] isEqualToString:@"1"] && self.listData) {
            NSString *listId = [userInfo objectForKey:@"data"];
            [self notificationCounter:listId];
            [self.listData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if ([[obj objectForKey:@"Id"] isEqualToString:listId]) {
                    TKDMainDetailViewController *mainDetailVC = [TKDMainDetailViewController new];
                    mainDetailVC.dic = obj;
                    mainDetailVC.type = @"apns";
                    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:mainDetailVC];
                    [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
                    return;
                }
            }];
        }
    }
    [APService handleRemoteNotification:userInfo];
}

-(void)notificationCounter:(NSString *)ids{
    NSURL *url = [NSURL URLWithString:API_SHEET_NOTIFIED];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:ids forKey:@"ids"];
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
    }];
    [request setFailedBlock:^{
        NSLog(@"notificationCounter fail");
    }];
    [request startAsynchronous];
}

- (void)clearApnsList {
    if ([self.listData count]) {
        self.listData = nil;
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     [application setApplicationIconBadgeNumber:0];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
