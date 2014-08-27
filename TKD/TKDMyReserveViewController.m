//
//  TKDMyReserveViewController.m
//  TKD
//
//  Created by YoungShook on 14-8-24.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDMyReserveViewController.h"
#import "TKDMyReserveCell.h"
#import "ODRefreshControl.h"

@interface TKDMyReserveViewController ()<UITableViewDataSource,UITableViewDelegate,TKDReserveAction>
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *reservationArray;
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
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bgView"]];
	self.reservationArray = [NSMutableArray new];
	self.tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame)-49)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	self.tableView.backgroundColor = [UIColor clearColor];
	[self.tableView setRowHeight:129];
	self.tableView.allowsSelection = NO;
	[self.tableView registerNib:[UINib nibWithNibName:@"TKDMyReserveCell" bundle:nil] forCellReuseIdentifier:@"TKDMyReserveCell"];
    [self.view addSubview:self.tableView];
	self.refreshControl = [[ODRefreshControl alloc]initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

	[self fetchReservations];
}

- (void)fetchReservations {
	[self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_NEWS_RESERVATIONS];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
		[_refreshControl endRefreshing];
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
		self.reservationArray = [[[request responseString]JSONValue] mutableCopy];
		
		if (![self.reservationArray count]) {
			QFAlert(@"提示", @"亲,您还未预订过任何东西!", @"我知道了");
		}
		
		[self.tableView reloadData];
    }];
    [request setFailedBlock:^{
		[_refreshControl endRefreshing];
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

- (void)cancelReservation:(NSString *)reserveID{
	[self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_NEWS_CANCEL_RESERVATION];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
	[request addPostValue:reserveID forKey:@"Id"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
		
		[self.reservationArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
			NSDictionary *dic = obj;
			if ([[dic objectForKey:@"Id"]isEqualToString:reserveID]) {
				[self.reservationArray removeObjectAtIndex:idx];
				*stop = YES;
			}
		}];
		
		[self.tableView reloadData];
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

#pragma mark -
#pragma mark UITableView Delgate

/** 返回一共有几组记录*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.reservationArray count];
}

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

	TKDMyReserveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TKDMyReserveCell" forIndexPath:indexPath];
	cell.backgroundColor = [UIColor clearColor];
	cell.contentView.backgroundColor = [UIColor clearColor];
    cell.delegate = self;
    NSDictionary *dic = [self.reservationArray objectAtIndex:indexPath.row];
    cell.reserveID = [dic objectForKey:@"Id"];
    cell.reserveTitle.text = [dic objectForKey:@"Title"];
    cell.reserveCount.text = [[dic objectForKey:@"Count"] stringValue];
	cell.reserveTime.text = [dic objectForKey:@"ReserveTime"];
	[cell.reserveStatus setTitle:@"取消预订" forState:UIControlStateNormal];
	
    return cell;
}

/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - TKDReserveAction Delegate
#pragma mark -

-(void)selectReserveStatus:(id)sender{
	[self cancelReservation:(NSString *)sender];
}

#pragma mark - ODRefreshControl Delegate
#pragma mark -

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshCon{
    [self.refreshControl beginRefreshing];
    [self fetchReservations];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
