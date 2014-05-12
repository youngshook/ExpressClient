//
//  TKDExpressSiteContactVC.m
//  TKD
//
//  Created by YoungShook on 14-5-13.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDExpressSiteContactVC.h"
#import "TKDExpressListViewController.h"
#import "TKDContactCellCell.h"
@interface TKDExpressSiteContactVC ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *contactArray;
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
    self.tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame) - 44)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
    [self.tableView setRowHeight:172];
    [self.tableView registerNib:[UINib nibWithNibName:@"ContactCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    [self.view addSubview:self.tableView];
    
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
		if ([[[request responseString]JSONValue] isKindOfClass:[NSArray class]]) {
			self.contactArray = [[[request responseString]JSONValue] mutableCopy];
            [self.tableView reloadData];
		}else{
			QFAlert(@"提示", @"暂无站点信息", @"确定");
		}
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
    return [self.contactArray count];
}

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TKDContactCellCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
    NSDictionary *dic = [self.contactArray objectAtIndex:indexPath.row];
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [dic objectForKey:@"VendorId"];
    
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            cell.expressSiteName.text = [dic objectForKey:@"Name"];
        }
    }];
    
    cell.expressSiteTel.text = [dic objectForKey:@"Phone"];
    cell.expressSiteAddress.text = [dic objectForKey:@"Address"];
    cell.expressSiteInfo.text = [dic objectForKey:@"Description"];
    
    return cell;
}

/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
