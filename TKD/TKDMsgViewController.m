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
	self.title = @"我的快鸽";
    self.tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame) - 44 - 49)];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
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
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
	
	NSString *URL = [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/%@", [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"SmallImageUrl"]];
	UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, 280, 100)];
	[imageView sd_setImageWithURL:[NSURL URLWithString:URL] placeholderImage:[UIImage imageNamed:@"loading"]];
	[imageView setContentMode:UIViewContentModeScaleAspectFill];
	[imageView setClipsToBounds:YES];
	UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 105, 210, 30)];
	[cell.contentView addSubview:imageView];
	[cell.contentView addSubview:nameLabel];
    nameLabel.text = [[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Title"];
    nameLabel.font = [UIFont systemFontOfSize:14];
    nameLabel.adjustsFontSizeToFitWidth = YES;
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	UILabel *likeNum = [[UILabel alloc]initWithFrame:CGRectMake(235, 105, 10, 30)];
	likeNum.font = [UIFont systemFontOfSize:13];
	likeNum.backgroundColor = [UIColor clearColor];
	likeNum.textColor = [UIColor redColor];
	likeNum.text = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Likes"] stringValue];
	
	UIImageView *likeImage = [[UIImageView alloc]initWithFrame:CGRectMake(247, 105, 10, 30)];
	likeImage.contentMode = UIViewContentModeScaleAspectFit;
	likeImage.image = [UIImage imageNamed:@"heart"];
	
	UILabel *reservationNum = [[UILabel alloc]initWithFrame:CGRectMake(265, 105, 30, 30)];
	reservationNum.font = [UIFont systemFontOfSize:13];
	reservationNum.backgroundColor = [UIColor clearColor];
	reservationNum.textColor = [UIColor redColor];
	reservationNum.text = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Reservations"]stringValue];
	reservationNum.text = [reservationNum.text stringByAppendingString:@" 订"];
	
	[cell.contentView addSubview:likeNum];
	[cell.contentView addSubview:likeImage];
	[cell.contentView addSubview:reservationNum];
	
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
	msgDetailVc.liked = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Liked"] boolValue];
	msgDetailVc.reservationed = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"Reserved"] boolValue];
	msgDetailVc.allowLike = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"AllowLike"] boolValue];
	msgDetailVc.allowReserve = [[[self.dataArray objectAtIndex:indexPath.row]objectForKey:@"AllowReserve"] boolValue];
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
