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

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"取消" style:UIBarButtonItemStylePlain handler:^(id sender) {
		[self dismissViewControllerAnimated:YES completion:nil];
	}];
	
	self.dataArray = @[@"EMS",@"天天快递",@"顺丰快递",@"韵达快递",@"圆通快递",@"中通快递",@"申通快递",@"宅急送"];
	self.myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, 548 - 44)];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.myTableView];
	
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
	cell.textLabel.text = [self.dataArray objectAtIndex:indexPath.row];
	cell.textLabel.textAlignment = NSTextAlignmentCenter;

	UIImageView *expressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[self.dataArray objectAtIndex:indexPath.row]]];
	expressImageView.frame = CGRectMake(10, 2, 40, 40);

	[cell.contentView addSubview:expressImageView];
	
    return cell;
}

/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	NSString *expressSiteStr = [self.dataArray objectAtIndex:indexPath.row];
	if (self.expressSiteSelectBlock) {
		self.expressSiteSelectBlock(expressSiteStr);
	}
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
