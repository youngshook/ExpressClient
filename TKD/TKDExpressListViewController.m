//
//  TKDExpressListViewController.m
//  TKD
//
//  Created by YoungShook on 14-3-1.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDExpressListViewController.h"

@interface TKDExpressListViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,copy)NSString *stationId;
@property(nonatomic,copy)NSArray *dataArray;
@property(nonatomic,strong)UITableView *myTableView;
@end

@implementation TKDExpressListViewController
-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	HUD_Define
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:^(id sender) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	self.myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 548 - 44)];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.myTableView];
	
	if ([USER_DEFAULTS objectForKey:@"addressList"]) {
		self.dataArray = [USER_DEFAULTS objectForKey:@"addressList"];
		[self.myTableView reloadData];
	}else{
		[self getAddressList];
	}
	
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
	
}

- (void)choiceDefaultExpressSite {
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_ACCOUNT_SET_DEFAULT_STATION];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
	[request setPostValue:self.stationId forKey:@"stationId"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
		[USER_DEFAULTS setBool:YES forKey:@"isHasDefaultStationId"];
		[self dismissViewControllerAnimated:YES completion:nil];
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

-(void)getAddressList{
    
    NSURL *url = [NSURL URLWithString:API_INFO_STATION];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSArray *array = [[request responseString]JSONValue];
        [USER_DEFAULTS setObject:array forKey:@"addressList"];
        [USER_DEFAULTS synchronize];
		self.dataArray = array;
		[self.myTableView reloadData];
    }];
    [request setFailedBlock:^{
        NetworkError
    }];
    [request startAsynchronous];
    
}


#pragma mark -
#pragma mark UITableView Delgate

/** 返回一共有几组记录*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

/** 行高*/
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
	cell.textLabel.text = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"Name"];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;
	
    return cell;
}

/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	self.stationId = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"Id"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self choiceDefaultExpressSite];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
