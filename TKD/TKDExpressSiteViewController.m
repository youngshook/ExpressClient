//
//  TKDExpressSiteViewController.m
//  TKD
//
//  Created by YoungShook on 14-3-2.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDExpressSiteViewController.h"

@interface TKDExpressSiteViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic,strong)UITableView *myTableView;
@property(nonatomic,copy)NSArray *dataArray;
@end

@implementation TKDExpressSiteViewController
-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain handler:^(id sender) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	NSArray *expressSite = [USER_DEFAULTS objectForKey:@"expressList"];
	
	NSMutableArray *expreeSiteAllowSend = [NSMutableArray new];
	
	[expressSite enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
		NSDictionary *dic = (NSDictionary *)obj;
		if ([[dic objectForKey:@"AllowSend"] boolValue ]) {
			[expreeSiteAllowSend addObject:dic];
		}
	}];
	
	self.dataArray = [expreeSiteAllowSend mutableCopy];
	self.myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 548 - 44)];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.myTableView];
	
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
	
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
	NSString *expressSiteStr = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"Id"];
	if (self.expressSiteSelectBlock) {
		self.expressSiteSelectBlock(expressSiteStr);
	}
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
	[self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
