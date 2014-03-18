//
//  TKDAboutViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDAboutViewController.h"

@interface TKDAboutViewController ()

@end

@implementation TKDAboutViewController
-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"关于我们";
    UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"about" ofType:@"html"];
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
