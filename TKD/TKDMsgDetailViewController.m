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
-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}
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
	
    self.webview = [[UIWebView alloc]initWithFrame:CGRectMake(0, 35, 320, self.view.bounds.size.height-70)];
    [self.webview setUserInteractionEnabled:YES];
    [self.view addSubview:self.webview];
	
    if (IS_NULL_STRING(self.messageTitle)) {
		
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(popViewController)];
    }
    HUD_Define
	
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
    self.messageContent = [NSString stringWithFormat:@"<p> <img src=\"%@\" width=\"305\" height=\"200\" /> </p> %@<br><br><br><br><br><br><br><br><br>",self.messageImgUrl,self.messageContent];
	[self.webview loadHTMLString:self.messageContent baseURL:nil];
    
    
    if (IS_NULL_STRING(self.linkURL)) {
        return;
    }
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.tag = 1200;
    [btn setTitle:self.linkTitle forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, self.view.frame.size.height - 70, 200, 40);
    btn.center = self.view.center;
    btn.frame = CGRectMake(btn.frame.origin.x, self.view.bounds.size.height-90, 200, 40);
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(jumpGoodPage) forControlEvents:UIControlEventTouchUpInside];
    [btn setUserInteractionEnabled:YES];
    [self.view addSubview:btn];
    
    self.linkURL = [NSString stringWithFormat:@"http://%@",self.linkURL];
    
}

-(void)jumpGoodPage{
    [VIEWWITHTAG(self.view, 1200) removeFromSuperview];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.linkURL]]];;
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
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

- (void)popViewController{
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
