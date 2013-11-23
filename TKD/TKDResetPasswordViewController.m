//
//  TKDResetPasswordViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDResetPasswordViewController.h"

@interface TKDResetPasswordViewController ()
@property(nonatomic,weak)IBOutlet UITextField *phoneNumT;
@property(nonatomic,weak)IBOutlet UITextField *passwordT;
@property(nonatomic,weak)IBOutlet UITextField *reNewPasswordT;
@property(nonatomic,weak)IBOutlet UITextField *verifyCode;
@property(nonatomic,strong)MBProgressHUD *HUD;
@end

@implementation TKDResetPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"重置密码";
    HUD_Define
}

-(IBAction)modifyPassword:(id)sender{

    if (IS_NULL_STRING(self.phoneNumT.text ) || IS_NULL_STRING(self.passwordT.text) || IS_NULL_STRING(self.reNewPasswordT.text)|| IS_NULL_STRING(self.verifyCode.text)) {
        QFAlert(@"提示", @"请把信息填写完整", @"确定");
        return;
    }
    
    if (![self VerifyPhoneNum:self.phoneNumT.text]) {
        QFAlert(@"提示", @"无效手机号,请重新输入", @"我知道了");
        return;
    }
    
    if (![self.passwordT.text isEqualToString:self.reNewPasswordT.text]) {
        QFAlert(@"提示", @"请确认输入的密码与确认不一致,请重新输入", @"我知道了");
        return;
    }
    
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_ACCOUNT_RECOVER];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:self.phoneNumT.text forKey:@"mobile"];
    [request addPostValue:self.passwordT.text forKey:@"password"];
    [request addPostValue:self.verifyCode.text forKey:@"verifycode"];
    [request addPostValue:self.verCode forKey:@"verificationId"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        QFAlert(@"提示", @"密码修改成功,请使用新密码登录", @"我知道了");
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];
    
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
