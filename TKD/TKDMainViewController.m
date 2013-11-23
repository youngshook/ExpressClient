//
//  TKDMainViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDMainViewController.h"

@interface TKDMainViewController ()
@property(nonatomic,strong)MBProgressHUD *HUD;
@end

@implementation TKDMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"淘快递";
    HUD_Define
}

-(void)fetchDataSource{

    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_NEWS_DETAILS];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
