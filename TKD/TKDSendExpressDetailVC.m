//
//  TKDSendExpressDetailVC.m
//  TKD
//
//  Created by YoungShook on 14-3-18.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDSendExpressDetailVC.h"

@interface TKDSendExpressDetailVC ()
@property(nonatomic,weak)IBOutlet UILabel *expressID;
@property(nonatomic,weak)IBOutlet UILabel *expressSite;
@property(nonatomic,weak)IBOutlet UILabel *expressStatus;
@end

@implementation TKDSendExpressDetailVC

-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [self.dic objectForKey:@"VendorId"];
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            self.expressSite.text = [dic objectForKey:@"Name"];
        }
    }];
	self.expressID.text = [self.dic objectForKey:@"SheetNo"];
	if ([[self.dic objectForKey:@"Status"] isEqualToString:@"无法跟踪此运单状态。"]) {
		self.expressStatus.text = @"运单信息还未更新,请耐心等待...";
	}else{
		self.expressStatus.text = [self.dic objectForKey:@"Status"];
	}
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
