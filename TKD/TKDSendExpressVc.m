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
#import "TKDSentDetailsViewController.h"
#import "TKDExpressListViewController.h"
#import "TKDExpressSiteViewController.h"
#import "TKDExpressSiteContactVC.h"
#import "TKDSendExpressCell.h"
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

-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataArray = [NSMutableArray new];
    self.title = @"查询";
    self.myTableView  = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, CGRectGetHeight(self.view.frame) - 44)];
    self.myTableView.backgroundColor = [UIColor whiteColor];
    self.myTableView.delegate = self;
    self.myTableView.dataSource = self;
    [self.myTableView registerNib:[UINib nibWithNibName:@"TKDSendExpressCell" bundle:nil] forCellReuseIdentifier:@"TKDSendExpressCell"];
    [self.view addSubview:self.myTableView];
    
    WEAKSELF
    UIView *tableHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    tableHeader.backgroundColor = [UIColor whiteColor];
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [UIColor greenColor];
    [btn setTitle:@"添加查询" forState:UIControlStateNormal];
    [tableHeader addSubview:btn];
    btn.frame = CGRectMake(0, 0, 280, 40);
    btn.center = tableHeader.center;
    [self.myTableView setTableHeaderView:tableHeader];
    [btn bk_addEventHandler:^(id sender) {
        STRONGSELF
        UIAlertView *alert = [[UIAlertView alloc]bk_initWithTitle:@"添加新单号" message:@"请选择添加单号的方式"];
		[alert bk_addButtonWithTitle:@"手动输入单号" handler:^{
			UIAlertView *av = [[UIAlertView alloc]initWithTitle:@"添加新单号" message:@"请输入快递单号" delegate:strongSelf cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
			[av setAlertViewStyle:UIAlertViewStylePlainTextInput];
			[av show];
		}];
		
		[alert bk_addButtonWithTitle:@"扫描获得单号" handler:^{
			ZBarReaderViewController *reader = [ZBarReaderViewController new];
			reader.readerDelegate = strongSelf;
			reader.supportedOrientationsMask = ZBarOrientationMaskAll;
			ZBarImageScanner *scanner = reader.scanner;
			[scanner setSymbology: ZBAR_I25
						   config: ZBAR_CFG_ENABLE
							   to: 0];
			[strongSelf presentViewController:reader animated:YES completion:nil];
		}];
		[alert addButtonWithTitle:@"取消"];
		[alert show];
    } forControlEvents:UIControlEventTouchUpInside];
    
    HUD_Define
    self.refreshControl = [[ODRefreshControl alloc]initInScrollView:self.myTableView];
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
	
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
            }else{
                QFAlert(@"提示", @"“您还没有查询追踪记录，请添加查询单号或呼唤附近邮寄小哥！", @"确定");
            }
        }
    }];
    [request setFailedBlock:^{
        [_refreshControl endRefreshing];
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    id<NSFastEnumeration> results =   [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        break;
	self.expressID = symbol.data;
    WEAKSELF
	[reader dismissViewControllerAnimated:YES completion:^{
        STRONGSELF
		QFAlert(@"提示",[NSString stringWithFormat:@"识别成功,运单号[%@]",symbol.data], @"我知道了");
		TKDExpressSiteViewController *expressSite = [TKDExpressSiteViewController new];
		expressSite.expressSiteSelectBlock = (ExpressSiteSelectBlock)^(NSString *expressStr){
			strongSelf.expressSiteStr = expressStr;
			[strongSelf createExpress];
		};
		UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:expressSite];
		[self presentViewController:nav animated:YES completion:nil];
	}];
}

#pragma mark -
#pragma mark UITableView Delgate

/** 创建TableViewCell*/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TKDSendExpressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TKDSendExpressCell" forIndexPath:indexPath];
    
    NSDictionary *dic = [self.dataArray objectAtIndex:indexPath.row];
	
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [dic objectForKey:@"VendorId"];
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            cell.expressType.text = [dic objectForKey:@"Name"];
        }
    }];
	
	NSString *sheetNoStirng = [dic objectForKey:@"SheetNo"];

	if (sheetNoStirng.length > 6) {
		cell.expressID.text = [sheetNoStirng substringFromIndex:sheetNoStirng.length - 6];
	}else{
		cell.expressID.text = sheetNoStirng;
	}
    cell.expressStatus.text = [dic objectForKey:@"Status"];
    
    return cell;
}

/** 返回一共有几组记录*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataArray count];
}

/** 行高*/
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

/** 处理Cell点击*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	TKDSentDetailsViewController *expressDetailVC = [TKDSentDetailsViewController new];
	expressDetailVC.dic = [self.dataArray objectAtIndex:indexPath.row];
	expressDetailVC.hidesBottomBarWhenPushed = YES;
	[self.navigationController pushViewController:expressDetailVC animated:YES];
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
