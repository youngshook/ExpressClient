//
//  TKDExpressSiteContactViewController.m
//  TKD
//
//  Created by YoungShook on 14-3-5.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDExpressSiteContactViewController.h"
#import "TKDExpressListViewController.h"
@interface TKDExpressSiteContactViewController ()
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,weak)IBOutlet UILabel *expressSiteName;
@property(nonatomic,weak)IBOutlet UILabel *expressSiteTel;
@property(nonatomic,weak)IBOutlet UILabel *expressSiteAddress;
@property(nonatomic,weak)IBOutlet UILabel *expressSiteInfo;
@end

@implementation TKDExpressSiteContactViewController
-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}
-(void)viewDidAppear:(BOOL)animated{
	[super viewDidAppear:animated];
	if ([USER_DEFAULTS boolForKey:@"isHasDefaultStationId"]) {
		[self showExpressSiteContact];
	}else{
		TKDExpressListViewController *expressListVC = [TKDExpressListViewController new];
		UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:expressListVC];
		[self presentViewController:nav animated:YES completion:nil];
	}
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
}

- (void)showExpressSiteContact{
	[self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_SENT_CONTACT];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
		if ([[[request responseString]JSONValue] isKindOfClass:[NSDictionary class]]) {
			NSDictionary *dic = [[request responseString]JSONValue];
			NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
			NSString *ID = [dic objectForKey:@"VendorId"];
			
			[expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
				NSDictionary *dic = obj;
				if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
					self.expressSiteName.text = [dic objectForKey:@"Name"];
				}
			}];
			
			self.expressSiteTel.text = [dic objectForKey:@"Phone"];
			self.expressSiteAddress.text = [dic objectForKey:@"Address"];
			self.expressSiteInfo.text = [dic objectForKey:@"Description"];
		}else{
			QFAlert(@"提示", @"暂无站点信息", @"确定");
		}
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
