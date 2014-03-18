//
//  TKDAgreementViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDAgreementViewController.h"

@interface TKDAgreementViewController ()

@end

@implementation TKDAgreementViewController
-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"用户协议";
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"xieyi" ofType:@"html"];
    NSURL *htmlUrl = [NSURL fileURLWithPath:htmlPath];
    [webView loadRequest:[NSURLRequest requestWithURL:htmlUrl]];
    [self.view addSubview:webView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
