//
//  TKDSendExpressVc.m
//  TKD
//
//  Created by YoungShook on 14-2-23.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDSendExpressVc.h"
#import "ODRefreshControl.h"
#import "TKDSendDetailViewController.h"
@interface TKDSendExpressVc ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,copy)NSMutableArray *dataArray;
@property(nonatomic,strong)ODRefreshControl *refreshControl;

@end

@implementation TKDSendExpressVc

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"寄快递";
    self.dataArray = [NSMutableArray new];
    
    self.myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 548 - 44)];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.myTableView];
    
    HUD_Define
    self.refreshControl = [[ODRefreshControl alloc]initInScrollView:self.myTableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

	
}

-(void)fetchDataSource{
    
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_SENT_INDEX];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        [_refreshControl endRefreshing];
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        if ([[[request responseString]JSONValue] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = [[request responseString]JSONValue];
            WarningAlert
        }else{
            NSArray *data = [[request responseString]JSONValue];
            if ([data count] > 0) {
                self.dataArray = [data mutableCopy];
                ApplicationDelegate.listData = [data mutableCopy];
                [self.myTableView reloadData];
                [self fetchSiteList];
            }
        }
    }];
    [request setFailedBlock:^{
        [_refreshControl endRefreshing];
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

#pragma mark -
#pragma mark UITableView Delgate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *sectionView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 30)];
    
    UILabel *expressID = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 144, 30)];
    expressID.text = @"运单号";
    
    UILabel *expressType = [[UILabel alloc]initWithFrame:CGRectMake(178, 0, 56, 30)];
    expressType.text = @"快递";
    
    UILabel *Status = [[UILabel alloc]initWithFrame:CGRectMake(254, 0, 56, 30)];
    Status.text = @"状态";
    expressType.backgroundColor = [UIColor clearColor];
    expressID.backgroundColor = [UIColor clearColor];
    Status.backgroundColor = [UIColor clearColor];
    sectionView.backgroundColor = [UIColor grayColor];
    
    expressID.font = [UIFont boldSystemFontOfSize:18];
    expressType.font = [UIFont boldSystemFontOfSize:18];
    Status.font = [UIFont boldSystemFontOfSize:18];
    
    [sectionView addSubview:expressID];
    [sectionView addSubview:expressType];
    [sectionView addSubview:Status];
    
    return sectionView;
}

/** 返回一共有几组记录*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

/** 行高*/
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 35;
}




/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TKDSendDetailViewController *detailVC = [TKDSendDetailViewController new];
    [self.navigationController pushViewController:detailVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ODRefreshControl Delegate
#pragma mark -

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshCon{
    [self.refreshControl beginRefreshing];
    [self fetchDataSource];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchSiteList{
    NSURL *url = [NSURL URLWithString:API_INFO_STATION];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
        return ;
        if ([[[request responseString]JSONValue] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = [[request responseString]JSONValue];
            WarningAlert
        }else{
            NSArray *data = [[request responseString]JSONValue];
            if ([data count] > 0) {
                self.dataArray = [data mutableCopy];
                [self.myTableView reloadData];
            }
        }
    }];
    [request setFailedBlock:^{
    }];
    [request startAsynchronous];
}


@end
