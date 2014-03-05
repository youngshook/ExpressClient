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
#import "TKDExpressSiteContactViewController.h"
#import "ZBarSDK.h"
typedef void (^ExpressSiteSelectBlock)(NSString *expressSiteStr);

@interface TKDSendExpressVc ()<UITableViewDelegate,UITableViewDataSource,UIAlertViewDelegate,ZBarReaderDelegate>

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
    
    self.myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame) - 44 - 49)];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.myTableView];
	
	__weak TKDSendExpressVc *weakself = self;
	
	self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd handler:^(id sender) {
		
		UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"添加新单号" message:@"请选择添加单号的方式"];
		[alert addButtonWithTitle:@"手动输入单号" handler:^{
			UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"添加新单号" message:@"请输入快递单号" delegate:weakself cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
			[av setAlertViewStyle:UIAlertViewStylePlainTextInput];
			[av show];
		}];
		[alert addButtonWithTitle:@"扫描获得单号" handler:^{
			ZBarReaderViewController *reader = [ZBarReaderViewController new];
			reader.readerDelegate = weakself;
			reader.supportedOrientationsMask = ZBarOrientationMaskAll;
			ZBarImageScanner *scanner = reader.scanner;
			[scanner setSymbology: ZBAR_I25
						   config: ZBAR_CFG_ENABLE
							   to: 0];
			[weakself presentViewController:reader animated:YES completion:nil];
		}];
		[alert addButtonWithTitle:@"取消"];
		[alert show];

	}];
	
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"寄快递" style:UIBarButtonItemStylePlain handler:^(id sender) {
		TKDExpressSiteContactViewController *expressSiteContactVC = [TKDExpressSiteContactViewController new];
		expressSiteContactVC.hidesBottomBarWhenPushed = YES;
		[self.navigationController pushViewController:expressSiteContactVC animated:YES];
	}];
    
    HUD_Define
    self.refreshControl = [[ODRefreshControl alloc]initInScrollView:self.myTableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	[self fetchDataSource];
}

- (void)createExpress{
	
	if (IS_NULL_STRING(self.expressID) || IS_NULL_STRING(self.expressSiteStr)) {
		QFAlert(@"提示", @"请选择快递公司", @"确定");
		return;
	}
	
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_SENT_CREATE];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
	[request setPostValue:self.expressID forKey:@"sheetNo"];
	[request setPostValue:self.expressSiteStr forKey:@"vendorId"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
		[self fetchDataSource];
    }];
    [request setFailedBlock:^{
        [_refreshControl endRefreshing];
        NetworkError_HUD
    }];
    [request startAsynchronous];
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
			NSArray *data = [dic objectForKey:@"Items"];
			if ([data count] > 0) {
                self.dataArray = [data mutableCopy];
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
	__weak TKDSendExpressVc *weakSelf = self;
	if (buttonIndex == 1) {
		self.expressID = [(UITextField *)[alertView textFieldAtIndex:0] text];
		TKDExpressSiteViewController *expressSite = [TKDExpressSiteViewController new];

		expressSite.expressSiteSelectBlock = (ExpressSiteSelectBlock)^(NSString *expressStr){
			weakSelf.expressSiteStr = expressStr;
			[weakSelf createExpress];
		};
		UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:expressSite];
		[self presentViewController:nav animated:YES completion:nil];
	}
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =   [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
	self.expressID = symbol.data;
	__weak TKDSendExpressVc *weakSelf = self;
	[reader dismissViewControllerAnimated:YES completion:^{
		QFAlert(@"提示",[NSString stringWithFormat:@"识别成功,运单号[%@]",symbol.data], @"我知道了");
		TKDExpressSiteViewController *expressSite = [TKDExpressSiteViewController new];
		expressSite.expressSiteSelectBlock = (ExpressSiteSelectBlock)^(NSString *expressStr){
			weakSelf.expressSiteStr = expressStr;
			[weakSelf createExpress];
		};
		UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:expressSite];
		[self presentViewController:nav animated:YES completion:nil];
	}];
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
    
    UILabel *expressType = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 56, 30)];
	expressType.textAlignment = NSTextAlignmentCenter;
    expressType.text = @"快递";
    
	UILabel *expressID = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 56, 30)];
	expressID.textAlignment = NSTextAlignmentCenter;
	expressID.center = sectionView.center;
    expressID.text = @"运单号";
	
    UILabel *Status = [[UILabel alloc]initWithFrame:CGRectMake(254, 0, 56, 30)];
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

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
	
	UILabel *expressType = [[UILabel alloc]initWithFrame:CGRectMake(10, 0, 56, 34)];
	expressType.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:expressType];
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [dic objectForKey:@"VendorId"];
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            expressType.text = [dic objectForKey:@"Name"];
        }
    }];
	
	
    UILabel *sheetSN = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 70, 34)];
	sheetSN.center = cell.contentView.center;
	NSString *sheetNoStirng = [dic objectForKey:@"SheetNo"];
	sheetSN.textAlignment = NSTextAlignmentCenter;
	if (sheetNoStirng.length > 6) {
		sheetSN.text = [sheetNoStirng substringFromIndex:sheetNoStirng.length - 6];
	}else{
		sheetSN.text = sheetNoStirng;
	}

    [cell.contentView addSubview:sheetSN];

    
    UILabel *Status = [[UILabel alloc]initWithFrame:CGRectMake(220, 0, 90, 34)];
	Status.font = [UIFont systemFontOfSize:12];
    Status.text = [dic objectForKey:@"Status"];
	Status.numberOfLines = 0;
	Status.lineBreakMode = NSLineBreakByWordWrapping;
	Status.textAlignment = NSTextAlignmentCenter;
    [cell.contentView addSubview:Status];
    
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
