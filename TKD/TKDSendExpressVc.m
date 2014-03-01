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
#import "TKDExpressListViewController.h"
#import "TKDExpressSiteViewController.h"

typedef void (^ExpressSiteSelectBlock)(NSString *expressSiteStr);

@interface TKDSendExpressVc ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate>

@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,copy)NSMutableArray *dataArray;
@property(nonatomic,strong)ODRefreshControl *refreshControl;
@property(nonatomic,copy)NSString *expressID;
@property(nonatomic,copy)NSString *expressSiteStr;

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
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender) {
		
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加新单号" message:@"请选择添加单号的方式"];
		[alert addButtonWithTitle:@"手动输入单号" handler:^{
			UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"添加新单号" message:@"请输入快递单号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
			[av setAlertViewStyle:UIAlertViewStylePlainTextInput];
			[av show];
		}];
		[alert addButtonWithTitle:@"扫描获得单号" handler:^{
			
		}];
		[alert addButtonWithTitle:@"取消"];
		[alert show];

	}];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"寄快递" style:UIBarButtonItemStylePlain handler:^(id sender) {
		TKDExpressListViewController *expressListVC = [TKDExpressListViewController new];
		[self presentViewController:expressListVC animated:YES completion:nil];
	}];
    
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
            }
        }
    }];
    [request setFailedBlock:^{
        [_refreshControl endRefreshing];
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
	if (buttonIndex == 1) {
		self.expressID = [(UITextField *)[alertView textFieldAtIndex:0] text];
		TKDExpressSiteViewController *expressSite = [TKDExpressSiteViewController new];
		__weak TKDSendExpressVc *weakSelf = self;
		expressSite.expressSiteSelectBlock = (ExpressSiteSelectBlock)^(NSString *expressStr){
			weakSelf.expressSiteStr = expressStr;
			NSLog(@"%@",expressStr);
		};
		UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:expressSite];
		[self presentViewController:nav animated:YES completion:nil];
	}
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

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
    
    UILabel *sheetSN = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 144, 34)];
    sheetSN.text = [dic objectForKey:@"SheetNo"];
    [cell.contentView addSubview:sheetSN];
    
    UILabel *expressType = [[UILabel alloc]initWithFrame:CGRectMake(178, 0, 56, 34)];
    [cell.contentView addSubview:expressType];
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [dic objectForKey:@"VendorId"];
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            expressType.text = [dic objectForKey:@"Name"];
        }
    }];
    
    UILabel *Status = [[UILabel alloc]initWithFrame:CGRectMake(254, 0, 144, 34)];
    Status.text = [USER_DEFAULTS objectForKey:[dic objectForKey:@"Status"]];
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

@end
