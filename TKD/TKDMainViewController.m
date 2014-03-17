//
//  TKDMainViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDMainViewController.h"
#import "TKDSetViewController.h"
#import "TKDMainDetailViewController.h"
#import "ODRefreshControl.h"
#import "TKDAppDelegate.h"
@interface TKDMainViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,copy)NSMutableArray *dataArray;
@property(nonatomic,strong)ODRefreshControl *refreshControl;

@end

@implementation TKDMainViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [TKDKit refreshGPS];
    NSString *enabel = [MobClick getConfigParams:@"enabel"];
    if ([enabel isEqualToString:@"NO"]) {
        UIAlertView *av = [UIAlertView alertViewWithTitle:@"警告" message:@"当前应用被锁定,请联系开发者!"];
        [av show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    QFListenEvent(@"fetchDataSource", self, @selector(fetchDataSource));
    self.navigationItem.hidesBackButton = YES;
    self.dataArray = [NSMutableArray new];
    self.title = @"芝麻园";

    self.myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame) - 44 - 49)];
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
    NSURL *url = [NSURL URLWithString:API_SHEET_INDEX];
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
    
	UILabel *expressType = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 56, 30)];
	expressType.textAlignment = NSTextAlignmentCenter;
    expressType.text = @"快递";
	
	
    UILabel *expressID = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 56, 30)];
	expressID.textAlignment = NSTextAlignmentCenter;
	expressID.center = sectionView.center;
    expressID.text = @"运单号";
    
    
    UILabel *Status = [[UILabel alloc]initWithFrame:CGRectMake(254, 0, 56, 30)];
	Status.textAlignment = NSTextAlignmentCenter;
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

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
    
    UILabel *expressType = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 56, 34)];
    [cell.contentView addSubview:expressType];
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [dic objectForKey:@"VendorId"];
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            expressType.text = [dic objectForKey:@"Name"];
        }
    }];
	
	
	UILabel *sheetSN = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 34)];
	sheetSN.center = cell.contentView.center;
	NSString *sheetNoStirng = [dic objectForKey:@"SheetNo"];
	if (sheetNoStirng.length > 6) {
		sheetSN.text = [NSString stringWithFormat:@"...%@",[sheetNoStirng substringFromIndex:sheetNoStirng.length - 6]];
	}else{
		sheetSN.text = sheetNoStirng;
	}
    [cell.contentView addSubview:sheetSN];
    
    UILabel *Status = [[UILabel alloc]initWithFrame:CGRectMake(220, 0, 90, 34)];
    Status.text = [USER_DEFAULTS objectForKey:[dic objectForKey:@"Status"]];
	Status.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:Status];
    
    if ([[dic objectForKey:@"Status"] isEqualToString:@"Retrieveable"]) {
        sheetSN.textColor = RGBACOLOR(64, 128, 0, 1);
        expressType.textColor = RGBACOLOR(64, 128, 0, 1);
        Status.textColor = RGBACOLOR(64, 128, 0, 1);
    }
    
    if ([[dic objectForKey:@"Status"] isEqualToString:@"Retrieved"]) {
        sheetSN.textColor = RGBACOLOR(237, 97, 96, 1);
        expressType.textColor = RGBACOLOR(237, 97, 96, 1);
        Status.textColor = RGBACOLOR(237, 97, 96, 1);
    }
    
    return cell;
}

/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TKDMainDetailViewController *detailVC = [TKDMainDetailViewController new];
    detailVC.dic = [self.dataArray objectAtIndex:indexPath.row];
	detailVC.hidesBottomBarWhenPushed = YES;
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

@end

