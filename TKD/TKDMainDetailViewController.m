//
//  TKDMainDetailViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDMainDetailViewController.h"

@interface TKDMainDetailViewController ()<UIAlertViewDelegate>
@property(nonatomic,weak)IBOutlet UILabel *idLabel;
@property(nonatomic,weak)IBOutlet UILabel *expressLabel;
@property(nonatomic,weak)IBOutlet UILabel *dateLabel;
@property(nonatomic,weak)IBOutlet UILabel *localLabel;
@property(nonatomic,weak)IBOutlet UILabel *sheetStatus;
@property(nonatomic,weak)IBOutlet UILabel *addressTextView;

@property(nonatomic,weak)IBOutlet UILabel *noticeLabel;
@property(nonatomic,weak)IBOutlet UITextField *areaCodeT;
@property(nonatomic,weak)IBOutlet UILabel *areaCodeLabel;
@property(nonatomic,weak)IBOutlet UIView *areaCodeView;
@property(nonatomic,weak)IBOutlet UILabel *areaCodeText;

@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)NSString *mobile;
@property(nonatomic,assign)BOOL isNeedPasswordCode;
@end

@implementation TKDMainDetailViewController

-(void)viewWillAppear:(BOOL)animated{
	[ApplicationDelegate hideTabBar];
}

-(void)viewWillDisappear:(BOOL)animated{
	[ApplicationDelegate showTabBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"签收宝贝";

    if ([self.type isEqualToString:@"apns"]) {
        UIBarButtonItem *backBtnItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(onLeftBtn)];
        self.navigationItem.leftBarButtonItem = backBtnItem;
    }
	
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
	
    HUD_Define
	
	[self fetchSheetDetails];
}

- (void)fetchSheetDetails {
	[self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_SHEET_DETAILS];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
	[request addPostValue:[self.dic objectForKey:@"Id"] forKey:@"Id"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
		[self updateSheetInfo:[[request responseString]JSONValue]];
        [self fetchSheetLock];
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

- (void)fetchSheetLock {
	[self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_SHEET_LOCK];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
	[request addPostValue:[self.dic objectForKey:@"Id"] forKey:@"Id"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        if (![dic[@"RegionCodeRequired"] intValue]) {
            QFAlert(@"提示", @"请到达指定的位置,进行取件", @"好的");
        }else{
            self.isNeedPasswordCode = YES;
            self.areaCodeT.hidden = NO;
            self.areaCodeLabel.hidden = NO;
            self.areaCodeView.hidden = NO;
            self.areaCodeText.hidden = NO;
            QFAlert(@"提示", @"输入柜门上印着的区域码,方可取件", @"好的");
        }
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startSynchronous];
}

-(void)updateSheetInfo:(NSDictionary *)dicData{
	self.idLabel.text = [dicData objectForKey:@"SheetNo"];
	
	NSString *ID = [dicData objectForKey:@"VendorId"];

    [[USER_DEFAULTS objectForKey:@"expressList"] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            self.expressLabel.text = [dic objectForKey:@"Name"];
        }
    }];
	
    self.dateLabel.text = [dicData objectForKey:@"ArrivalTime"];

	if (IS_NULL_STRING([dicData objectForKey:@"Position"])) {
		self.localLabel.text = [USER_DEFAULTS objectForKey:[self.dic objectForKey:@"Id"]];
	}else{
		self.localLabel.text = [dicData objectForKey:@"Position"];
		[USER_DEFAULTS setObject:[dicData objectForKey:@"Position"] forKey:[self.dic objectForKey:@"Id"]];
	}
	
    
	if ([[dicData objectForKey:@"Status"] isEqualToString:@"Retrieveable"]) {
		[VIEWWITHTAG(self.view, 3000) setHidden:NO];
		self.noticeLabel.text = [NSString stringWithFormat:@"请您站到柜台<%@>正前方输入口令,否则可能造成丢失!",[dicData objectForKey:@"Position"]];
	}else{
		[VIEWWITHTAG(self.view, 3000) setHidden:YES];
	}
	
    NSArray *addressList = [USER_DEFAULTS objectForKey:@"addressList"];
    NSString *stationID = [dicData objectForKey:@"StationId"];
    [addressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:stationID]) {
            self.addressTextView.text = [dic objectForKey:@"Address"];
        }
    }];
	
	self.sheetStatus.text = [USER_DEFAULTS objectForKey:[dicData objectForKey:@"Status"]];
}

-(void)onLeftBtn{

    [self dismissViewControllerAnimated:YES completion:nil];

}

-(IBAction)substitutionBtn{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入手机号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.delegate = self;
    [alertView show];
}

-(IBAction)verifyBtn{
    
    if (self.isNeedPasswordCode) {
       	if (self.areaCodeT.text.length == 0) {
            QFAlert(@"提示", @"请输入口令", @"我知道了");
            return;
        }
    }

	[self.HUD show:YES];
	NSURL *url = [NSURL URLWithString:API_SHEET_RETRIEVE];
	__weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	ASIFormDataRequestDefine_ToKen
	NSNumber *longitude = [NSNumber numberWithDouble:[[USER_DEFAULTS objectForKey:@"gpslon"] doubleValue]];
	NSNumber *latitude = [NSNumber numberWithDouble:[[USER_DEFAULTS objectForKey:@"gpslat"] doubleValue]];
        // NSNumber *longitude = [NSNumber numberWithDouble:[@"116.3087" doubleValue]];
        //NSNumber *latitude = [NSNumber numberWithDouble:[@"39.96578" doubleValue]];
	[request addPostValue:longitude?:@0.00 forKey:@"longitude"];
	[request addPostValue:latitude?:@0.00 forKey:@"latitude"];
	[request addPostValue:[self.dic objectForKey:@"Id"] forKey:@"id"];
	[request addPostValue:@1 forKey:@"version"];
    if (self.isNeedPasswordCode) {
     	[request addPostValue:self.areaCodeT.text forKey:@"regionCode"];
    }
	[request setCompletionBlock:^{
		[self.HUD hide:YES];
		NSLog(@"%@:%@",[url path],[request responseString]);
		NSDictionary *dic = [[request responseString]JSONValue];
		WarningAlert
		self.localLabel.text = [dic objectForKey:@"Position"];
		[USER_DEFAULTS setObject:[dic objectForKey:@"Position"] forKey:[self.dic objectForKey:@"Id"]];
		QFAlert(@"提示", @"验证成功,请取件", @"我知道了");
		self.sheetStatus.text = @"已取件";
		[VIEWWITHTAG(self.view, 3000) setHidden:YES];
	}];
	[request setFailedBlock:^{
		NetworkError_HUD
	}];
	[request startAsynchronous];

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 1) {
        UITextField *tf=[alertView textFieldAtIndex:0];
        
        if (![self VerifyPhoneNum:tf.text]) {
            QFAlert(@"提示", @"无效手机号,请重新输入", @"我知道了");
            return;
        }
        
        [self.HUD show:YES];
        NSURL *url = [NSURL URLWithString:API_SHEET_AUTHORIZE];
        __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
        ASIFormDataRequestDefine_ToKen
        [request addPostValue:[self.dic objectForKey:@"Id"] forKey:@"id"];
        [request addPostValue:tf.text forKey:@"mobile"];
        [request setCompletionBlock:^{
            [self.HUD hide:YES];
            NSLog(@"%@:%@",[url path],[request responseString]);
            NSDictionary *dic = [[request responseString]JSONValue];
            if ([dic objectForKey:@"error"]) {
                QFAlert(@"提示", [dic objectForKey:@"error"], @"确定");
            }else{
                QFAlert(@"提示", @"设置代取成功", @"我知道了");
            }
        }];
        [request setFailedBlock:^{
            NetworkError_HUD
        }];
        [request startAsynchronous];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

	[[UIApplication sharedApplication].keyWindow endEditing:YES];

}

//手机号校验
-(BOOL)VerifyPhoneNum:(NSString *)phoneString{
    if (phoneString.length == 11) {
        //手机号以13， 15，18开头，八个 \d 数字字符
        NSString *phoneRegex = @"^((13[0-9])|(15[^4,\\D])|(18[0,0-9])|(14[0-9]))\\d{8}$";
        NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
        return [phoneTest evaluateWithObject:phoneString];
    }
    return NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
