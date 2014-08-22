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
#import "UIImageView+WebCache.h"
#import "TKDHeaderView.h"
#import "TKDExpressSiteContactVC.h"
#import "TKDSendExpressVc.h"
#import <QuartzCore/QuartzCore.h>
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
        UIAlertView *av = [UIAlertView bk_alertViewWithTitle:@"警告" message:@"当前应用被锁定,请联系开发者!"];
        [av show];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	QFListenEvent(@"sendExpress", self, @selector(sendExpress));
	QFListenEvent(@"checkExpress", self, @selector(checkExpress));
	self.title = @"快易取";
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgView.png"]];
    QFListenEvent(@"fetchDataSource", self, @selector(fetchDataSource));
    self.navigationItem.hidesBackButton = YES;
    self.dataArray = [NSMutableArray new];
	
	TKDHeaderView *headerView =  [[[NSBundle mainBundle] loadNibNamed:@"TKDHeaderView" owner:nil options:nil] objectAtIndex:0];
	headerView.frame = CGRectMake(0, 0, headerView.frame.size.width, headerView.frame.size.height);
	[self.view addSubview:headerView];
    self.myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, headerView.frame.size.height, 320, CGRectGetHeight(self.view.frame) - 64 - 49 - headerView.frame.size.height)];
    self.myTableView.backgroundColor = [UIColor clearColor];
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
            }else{
                QFAlert(@"提示", @"小主,您的快件可能即将到达快鸽服务点,请耐心等候哦", @"我知道了");
            }
        }
    }];
    [request setFailedBlock:^{
        [_refreshControl endRefreshing];
        NetworkError_HUD
    }];
	[ApplicationDelegate.filterView setSelectedIndex:0];
    [request startAsynchronous];
}

#pragma mark -
#pragma mark UITableView Delgate
/*
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
    
	UILabel *expressType = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 80, 30)];
	expressType.textAlignment = NSTextAlignmentCenter;
    expressType.text = @"快递公司";
	
	
    UILabel *expressID = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 56, 30)];
	expressID.textAlignment = NSTextAlignmentCenter;
	expressID.center = sectionView.center;
    expressID.text = @"运单号";
    
    
    UILabel *Status = [[UILabel alloc]initWithFrame:CGRectMake(237, 0, 56, 30)];
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
*/
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
	cell.backgroundColor = [UIColor clearColor];
	cell.contentView.backgroundColor = [UIColor clearColor];
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
	
	UIImageView *expressImg = [[UIImageView alloc]initWithFrame:CGRectMake(10, 2, 60, 30)];
	[cell.contentView addSubview:expressImg];
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [dic objectForKey:@"VendorId"];
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
			NSString *url = [dic objectForKey:@"LogoUrl"];
			NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/%@",url]];
			[expressImg sd_setImageWithURL:URL];
        }
    }];
	
	UILabel *sheetSN = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 80, 34)];
	sheetSN.center = cell.contentView.center;
	sheetSN.backgroundColor = [UIColor clearColor];
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
	Status.backgroundColor = [UIColor clearColor];
	if ([[dic objectForKey:@"Status"] isEqualToString:@"Retrieveable"]) {
		UIView *redPoint = [[UIView alloc]initWithFrame:CGRectMake(80,14, 8, 8)];
		redPoint.backgroundColor = [UIColor redColor];
		redPoint.layer.cornerRadius = 3.5;
		redPoint.clipsToBounds = YES;
		[cell.contentView addSubview:redPoint];
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

- (void)sendExpress{
	TKDSendExpressVc *sendExpressVC = [TKDSendExpressVc new];
	sendExpressVC.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:sendExpressVC animated:YES];
}

- (void)checkExpress{
	TKDExpressSiteContactVC *expressSiteVC = [TKDExpressSiteContactVC new];
	expressSiteVC.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:expressSiteVC animated:YES];
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

