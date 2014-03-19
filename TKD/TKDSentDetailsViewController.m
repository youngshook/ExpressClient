//
//  TKDSentDetailsViewController.m
//  TKD
//
//  Created by YoungShook on 14-3-20.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDSentDetailsViewController.h"

@interface TKDSentDetailsViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,copy)NSMutableArray *dataArray;
@property(nonatomic,strong)UITableView *tableView;
@property(nonatomic,assign)BOOL isHaveNewStatus;
@end

@implementation TKDSentDetailsViewController

-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	HUD_Define
	self.tableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame) - 44)];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
	[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
	
	UIView *viewBg = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
	viewBg.backgroundColor = [UIColor grayColor];
	
	UILabel *idL = [[UILabel alloc]initWithFrame:CGRectMake(10, 5, 90, 21)];
	UILabel *expressL = [[UILabel alloc]initWithFrame:CGRectMake(10, 29, 90, 21)];
	idL.text = @"快递单号:";
	expressL.text = @"快递公司:";
	
	UILabel *idLT = [[UILabel alloc]initWithFrame:CGRectMake(110, 5, 200, 21)];
	UILabel *expressLT = [[UILabel alloc]initWithFrame:CGRectMake(110, 29, 200, 21)];
	
	idLT.text = [self.dic objectForKey:@"SheetNo"];
	NSString *ID = [self.dic objectForKey:@"VendorId"];
    [[USER_DEFAULTS objectForKey:@"expressList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            expressLT.text = [dic objectForKey:@"Name"];
        }
    }];

	idL.backgroundColor = [UIColor clearColor];
	expressL.backgroundColor = [UIColor clearColor];
	idLT.backgroundColor = [UIColor clearColor];
	expressLT.backgroundColor = [UIColor clearColor];
	
	[viewBg addSubview:idL];
	[viewBg addSubview:expressL];
	[viewBg addSubview:idLT];
	[viewBg addSubview:expressLT];
	
	self.tableView.tableHeaderView = viewBg;
	[self.view addSubview:self.tableView];
	
	if ([[self.dic objectForKey:@"Status"] isEqualToString:@"无法跟踪此运单状态。"]) {
		self.isHaveNewStatus = NO;
	}else{
		self.isHaveNewStatus = YES;
		[self fetchDataSource];
	}
}

-(void)fetchDataSource{
    
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_SENT_DETAILS];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
	[request setPostValue:[self.dic objectForKey:@"Id"] forKey:@"Id"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        if ([[[request responseString]JSONValue] isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = [[request responseString]JSONValue];
			NSArray *data = [dic objectForKey:@"Logs"];
			if ([data count] > 0) {
                self.dataArray = [data mutableCopy];
				[self.tableView reloadData];
            }else{
				
			}
        }
    }];
    [request setFailedBlock:^{
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (self.isHaveNewStatus) {
		return [self.dataArray count];
	}else{
		return 1;
	}
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (self.isHaveNewStatus) {
		return 65;
	}else{
		return 500;
	}
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
	cell.selectionStyle = UITableViewCellSelectionStyleNone;
	
	if (!self.isHaveNewStatus) {
		UILabel *alertView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 40)];
		alertView.text = @"运单信息还未更新,请耐心等待...";
		alertView.textAlignment = NSTextAlignmentCenter;
		alertView.center = cell.contentView.center;
		[cell.contentView addSubview:alertView];
		return cell;
	}
	
	UILabel *timeL = [[UILabel alloc]initWithFrame:CGRectMake(20, 7, 42, 21)];
	UILabel *siteL = [[UILabel alloc]initWithFrame:CGRectMake(20, 31, 42, 21)];
	timeL.text = @"时间:";
	siteL.text = @"站点:";
	UILabel *timeLT = [[UILabel alloc]initWithFrame:CGRectMake(70, 7, 230, 21)];
	UILabel *siteLT = [[UILabel alloc]initWithFrame:CGRectMake(70, 31, 230, 30)];
	timeLT.font = [UIFont systemFontOfSize:13];
	siteLT.font = [UIFont systemFontOfSize:12];
		
	[cell.contentView addSubview:timeL];
	[cell.contentView addSubview:siteL];
	
	[cell.contentView addSubview:timeLT];
	[cell.contentView addSubview:siteLT];
	timeLT.text = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"Time"];
	siteLT.text = [[self.dataArray objectAtIndex:indexPath.row] objectForKey:@"Status"];
	siteLT.numberOfLines = 0;
	siteLT.lineBreakMode = NSLineBreakByWordWrapping;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
