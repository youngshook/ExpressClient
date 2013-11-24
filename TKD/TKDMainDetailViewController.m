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
@property(nonatomic,weak)IBOutlet UITextView *addressTextView;
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,strong)NSString *mobile;
@end

@implementation TKDMainDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"运单快递";
    self.idLabel.text = [self.dic objectForKey:@"SheetNo"];
    self.dateLabel.text = [self.dic objectForKey:@"ArrivalTime"];
    
    
    NSArray *expressList = [USER_DEFAULTS objectForKey:@"expressList"];
    NSString *ID = [self.dic objectForKey:@"VendorId"];
    [expressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:ID]) {
            self.expressLabel.text = [dic objectForKey:@"Name"];
        }
    }];
    
    NSArray *addressList = [USER_DEFAULTS objectForKey:@"addressList"];
    NSString *stationID = [self.dic objectForKey:@"StationId"];
    [addressList enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = obj;
        if ([[dic objectForKey:@"Id"] isEqualToString:stationID]) {
            self.addressTextView.text = [dic objectForKey:@"Address"];
        }
    }];
    HUD_Define
    
    // Do any additional setup after loading the view from its nib.
}

-(IBAction)substitutionBtn{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"提示" message:@"请输入手机号" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    alertView.delegate = self;
    [alertView show];
}

-(IBAction)verifyBtn{
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_SHEET_RETRIEVE_STATUS];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:[self.dic objectForKey:@"Id"] forKey:@"requestid"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        QFAlert(@"提示", @"当前取件正常", @"确定");
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
