//
//  TKDExpressSiteContactVC.m
//  TKD
//
//  Created by YoungShook on 14-5-13.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDExpressSiteContactVC.h"
#import "TKDExpressListViewController.h"
#import "ODRefreshControl.h"
#import "TKDSendExpressVc.h"
#import "TKDContactCellCell.h"
@interface TKDExpressSiteContactVC ()<UITableViewDataSource,UITableViewDelegate,TKDExpressTel>
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *contactArray;
@property(nonatomic,strong)ODRefreshControl *refreshControl;
@end

@implementation TKDExpressSiteContactVC

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
    self.title = @"快易购";
    self.tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame)-49)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
    [self.tableView setRowHeight:207];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    [self.view addSubview:self.tableView];
    
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
    
    self.refreshControl = [[ODRefreshControl alloc]initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)showExpressSiteContact{
	[self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_SENT_CONTACT];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        [_refreshControl endRefreshing];
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
		if ([[[request responseString]JSONValue] isKindOfClass:[NSArray class]]) {
			self.contactArray = [[[request responseString]JSONValue] mutableCopy];
            [self.tableView reloadData];
		}else{
			QFAlert(@"提示", @"暂无站点信息", @"确定");
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

/** 返回一共有几组记录*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.contactArray count];
}

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TKDContactCellCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    cell.delegate = self;
    NSDictionary *dic = [self.contactArray objectAtIndex:indexPath.row];
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [dic objectForKey:@"VendorId"];
    
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            cell.expressSiteName.text = [dic objectForKey:@"Name"];
        }
    }];
    
    [cell.expressSiteTel setTitle:[dic objectForKey:@"Phone"] forState:UIControlStateNormal];
    cell.expressSiteAddress.text = [dic objectForKey:@"Address"];
    cell.expressSiteInfo.text = [dic objectForKey:@"Description"];
    cell.expressSiteContact.text = [dic objectForKey:@"Contact"];
    
    return cell;
}

-(void)expressSiteCallTel:(id)sender{
    NSIndexPath *indexPath = [self indexPathForCell:sender];
    NSString *tel = [[self.contactArray objectAtIndex:indexPath.row] objectForKey:@"Phone"];
    UIAlertView *av = [UIAlertView bk_alertViewWithTitle:@"提示" message:[NSString stringWithFormat:@"是否联系%@",tel]];
    [av bk_addButtonWithTitle:@"取消" handler:nil];
    [av bk_addButtonWithTitle:@"拨打" handler:^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",tel]]];
    }];
    [av show];
}

-(NSIndexPath *)indexPathForCell:(id)sender{
    
    return [self.tableView indexPathForCell:(UITableViewCell *)[[[[sender superview] superview]superview]superview]];
    
}

/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ODRefreshControl Delegate
#pragma mark -

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshCon{
    [self.refreshControl beginRefreshing];
    [self showExpressSiteContact];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
