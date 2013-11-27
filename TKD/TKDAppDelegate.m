//
//  TKDAppDelegate.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDAppDelegate.h"
#import "TKDLoginViewController.h"
#import "TKDRegisterViewController.h"
@implementation TKDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self loadUserlocalString];
    QFListenEvent(@"referRetrieveStatus", self, @selector(referRetrieveStatus));
    if (!isFisrtLaunch) {
        [self getApplicationToken];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"alreadyFirstLaunch"];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    QFListenEvent(@"getApplicationToken", self, @selector(getApplicationToken));
    self.window.backgroundColor = [UIColor whiteColor];
    TKDLoginViewController *loginC = [TKDLoginViewController new];
    UINavigationController *navC = [[UINavigationController alloc]initWithRootViewController:loginC];
    self.window.rootViewController = navC;
    [self.window makeKeyAndVisible];

    return YES;
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


-(void)referRetrieveStatus{
    
    NSURL *url = [NSURL URLWithString:API_SHEET_RETRIEVE_STATUS];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:[USER_DEFAULTS objectForKey:@"RetrieveRequestId"] forKey:@"requestid"];
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        
        int delay = [[dic objectForKey:@"Delay"]intValue];
        NSTimeInterval sed = [[USER_DEFAULTS objectForKey:@"date"] timeIntervalSinceNow];
        if (delay > 0) {
            if (sed < -30) {
                QFAlert(@"提示", @"您的验证申请超时，请到前台与工作人员联系取件", @"我知道了");
            }else{
                [self performSelector:@selector(referRetrieveStatus) withObject:nil afterDelay:delay];
            }
        }else{
            QFAlert(@"提示",[NSString stringWithFormat:@"取件成功，单号%@,柜组号%@,请核对收件人姓名取件，感谢使用祝您愉快",[dic objectForKey:@"SheetNo"],[dic objectForKey:@"GroupChest"]],@"我知道了");
        }
    }];
    [request setFailedBlock:^{
    }];
    [request startAsynchronous];
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
