//
//  TKDMyReserveViewController.m
//  TKD
//
//  Created by YoungShook on 14-8-24.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDMyReserveViewController.h"
#import "ODRefreshControl.h"
@interface TKDMyReserveViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *contactArray;
@property(nonatomic,strong)ODRefreshControl *refreshControl;
@end

@implementation TKDMyReserveViewController

-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"我的预定";
	self.tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame)-49)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    [self.view addSubview:self.tableView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
