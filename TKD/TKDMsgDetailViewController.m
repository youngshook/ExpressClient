//
//  TKDMsgDetailViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDMsgDetailViewController.h"

@interface TKDMsgDetailViewController ()
@property(nonatomic,strong)UIWebView *webview;
@property(nonatomic,strong)UILabel *titleView;
@property(nonatomic,strong)MBProgressHUD *HUD;
@end

@implementation TKDMsgDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"详情";
    self.titleView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 320, 35)];
    self.titleView.font = [UIFont boldSystemFontOfSize:15];
    self.titleView.backgroundColor = [UIColor colorWithWhite:0.831 alpha:1.000];
    self.titleView.textAlignment = NSTextAlignmentCenter;
    self.titleView.adjustsFontSizeToFitWidth = YES;
    self.titleView.text = self.messageTitle;
    [self.view addSubview:self.titleView];
	
    self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 35, 320, self.view.bounds.size.height)];
    [self.webview setUserInteractionEnabled:NO];
    [self.view addSubview:self.webview];
	
    if (IS_NULL_STRING(self.messageTitle)) {
        UIBarButtonItem *backBtn = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftBtn)];
        [self.navigationItem setRightBarButtonItem:backBtn animated:YES];
    }
    HUD_Define
    
	[self.webview loadHTMLString:self.messageContent baseURL:nil];
		//[self refreshMessageDetail];
}

-(void)onLeftBtn{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)refreshMessageDetail{
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_NEWS_DETAILS];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:self.messageId forKey:@"Id"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        NSString *messageBody = [dic objectForKey:@"Content"];
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
