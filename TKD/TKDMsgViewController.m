//
//  TKDMsgViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-13.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDMsgViewController.h"
#import "TKDMsgDetailViewController.h"
#import "UIImageView+WebCache.h"
#import "ODRefreshControl.h"
@interface TKDMsgViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,strong)NSMutableArray *dataArray;
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)ODRefreshControl *refreshControl;
@end

@implementation TKDMsgViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self refreshMessage];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.title = @"芝麻园";
    self.tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame) - 44 - 49)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"设置" style:UIBarButtonItemStylePlain target:self action:@selector(setting)];
    
    [self.view addSubview:self.tableView];
	
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
    HUD_Define
	self.refreshControl = [[ODRefreshControl alloc]initInScrollView:self.tableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

-(void)refreshMessage{
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_NEWS_INDEX];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
		[_refreshControl endRefreshing];
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        if ([[dic objectForKey:@"TotalCount"]intValue] > 0) {
            self.dataArray = [dic objectForKey:@"Items"];
            [self.tableView reloadData];
        }else{
        }
    }];
    [request setFailedBlock:^{
		[_refreshControl endRefreshing];
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

-(void)setting{
    TKDSetViewController *setVC = [TKDSetViewController new];
	setVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:setVC animated:YES];
}

#pragma mark -
#pragma mark UITableView Delgate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

/** 返回一共有几组记录*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

/** 行高*/
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 130;
}

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	NSString *URL = [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/%@", [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"SmallImageUrl"]];
	UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 280, 100)];
	[imageView sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:@"loading"]];
	[imageView setContentMode:UIViewContentModeScaleAspectFill];
	[imageView setClipsToBounds:YES];
	UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 105, 280, 30)];
	[cell.contentView addSubview:imageView];
	[cell.contentView addSubview:nameLabel];
    nameLabel.text = [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Title"];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.adjustsFontSizeToFitWidth = YES;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *msgId = [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Id"];
    NSString *msgTitle = [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Title"];
	NSString *msgContent = [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Content"];
    TKDMsgDetailViewController *msgDetailVc = [TKDMsgDetailViewController new];
    msgDetailVc.messageId = msgId;
    msgDetailVc.messageTitle = msgTitle;
	msgDetailVc.messageContent = msgContent;
    msgDetailVc.linkTitle = [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"LinkText"];
    msgDetailVc.linkURL = [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"LinkUrl"];
	msgDetailVc.messageImgUrl = [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/%@", [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"LargeImageUrl"]];
	msgDetailVc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:msgDetailVc animated:YES];
}

#pragma mark - ODRefreshControl Delegate
#pragma mark -

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshCon{
    [self.refreshControl beginRefreshing];
    [self refreshMessage];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
