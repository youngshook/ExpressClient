//
//  TKDSetViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//
#import "TKDAppDelegate.h"
#import "TKDSetViewController.h"
#import "TKDMsgViewController.h"
#import "TKDAboutViewController.h"
#import "TKDAgreementViewController.h"
#import "TKDLoginViewController.h"
@interface TKDSetViewController ()
@property(nonatomic,strong)MBProgressHUD *HUD;
@end

@implementation TKDSetViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    for (int i = 0; i < 5; i++) {
        UIButton *btn = (UIButton *)VIEWWITHTAG(self.view, 2000+i);
        [btn setBackgroundImage:[[UIImage imageNamed:@"login_btn"] stretchableImageWithLeftCapWidth:15 topCapHeight:5] forState:UIControlStateNormal];
    }
    
    HUD_Define
}

-(IBAction)versionUpdate:(id)sender{
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_APP_UPGRADE];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        if ([dic objectForKey:@"Version"]) {
            QFAlert([NSString stringWithFormat:@"%@版本发布了!",[dic objectForKey:@"Version"]],[NSString stringWithFormat:@"%@",[dic objectForKey:@"Description"]] , @"我知道了");
        }else{
            QFAlert(@"提示", @"您当前软件版本是最新的!", @"我知道了");
        }
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

-(IBAction)aboutUs:(id)sender{
    TKDAboutViewController *aboutC = [TKDAboutViewController new];
    [self.navigationController pushViewController:aboutC animated:YES];
}

-(IBAction)agreement:(id)sender{
    TKDAgreementViewController *agreementC = [TKDAgreementViewController new];
    [self.navigationController pushViewController:agreementC animated:YES];
}

-(IBAction)logout:(id)sender{
	[UIView transitionWithView:ApplicationDelegate.window
					  duration:0.65
					   options:UIViewAnimationOptionTransitionFlipFromLeft
					animations:^{
						UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:ApplicationDelegate.loginVC];
						ApplicationDelegate.window.rootViewController = nav;
					}
					completion:^(BOOL finished){
						[CHKeychain delete:@"userAccount"];
						QFEvent(@"clearApnsList", nil);
						[ApplicationDelegate resetTabBarVC];
					}];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
