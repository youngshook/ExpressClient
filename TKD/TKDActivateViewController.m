//
//  TKDActivateViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDActivateViewController.h"
#import "TKDAgreementViewController.h"
#import "TKDRegisterViewController.h"
#import "TKDResetPasswordViewController.h"
@interface TKDActivateViewController ()<UITextFieldDelegate>
@property(nonatomic,weak)IBOutlet UITextField *verifyPhoneT;
@property(nonatomic,weak)IBOutlet UIImageView *checkImg;
@property(nonatomic,strong)MBProgressHUD *HUD;
@property(nonatomic,weak)IBOutlet UIButton *verifyBtn;
@end

@implementation TKDActivateViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.verifyPhoneT becomeFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"获取验证";
    HUD_Define
    self.checkImg.tag = 1201;
    UIButton *btn = (UIButton *)VIEWWITHTAG(self.view, 2000);
    [btn setBackgroundImage:[[UIImage imageNamed:@"login_btn"] stretchableImageWithLeftCapWidth:15 topCapHeight:5] forState:UIControlStateNormal];
    if ([self.activateType isEqualToString:@"ResetPassword"]) {
        UIView *tipsView = [self.view viewWithTag:3000];
        tipsView.hidden = YES;
        UIView *checkImg = [self.view viewWithTag:3001];
        checkImg.hidden = YES;
        self.checkImg.tag = 1200;
    }
}

-(IBAction)checkImg:(id)sender{
    if (self.checkImg.tag == 1200) {
        self.checkImg.image = [UIImage imageNamed:@"uncheck"];
        self.checkImg.tag = 1201;
    }else{
        self.checkImg.tag = 1200;
        self.checkImg.image = [UIImage imageNamed:@"check"];
        TKDAgreementViewController *agreementVC = [TKDAgreementViewController new];
        [self.navigationController pushViewController:agreementVC animated:YES];
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

-(IBAction)verifyCode:(id)sender{
    
    if (self.checkImg.tag == 1201) {
        QFAlert(@"提示", @"请先同意会员协议", @"我知道了");
        return;
    }
    
    if (![self VerifyPhoneNum:self.verifyPhoneT.text]) {
        QFAlert(@"提示", @"无效手机号,请重新输入", @"我知道了");
        return;
    }
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_APP_VERIFY_CODE];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:self.verifyPhoneT.text forKey:@"mobile"];
    if ([self.activateType isEqualToString:@"ResetPassword"]) {
        [request addPostValue:@"Recover" forKey:@"purpose"];
    }else{
        [request addPostValue:@"Register" forKey:@"purpose"];
    }
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        if ([dic objectForKey:@"VerificationId"]) {
            [self registerAccount:[dic objectForKey:@"VerificationId"]];
        }else{
            QFAlert(@"提示", @"验证码获取失败,请重新发送验证码", @"我知道了");
        }
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];
}

-(void)registerAccount:(NSString *)verificationId{
    QFAlert(@"提示", @"验证码获取成功,请填写注册信息!", @"我知道了");
    if ([self.activateType isEqualToString:@"ResetPassword"]) {
        TKDResetPasswordViewController *regVC = [TKDResetPasswordViewController new];
        regVC.verCode = verificationId;
		regVC.phoneTel = self.verifyPhoneT.text;
        [self.navigationController pushViewController:regVC animated:YES];
    }else{
        TKDRegisterViewController *regVC = [TKDRegisterViewController new];
        regVC.verifyCode = verificationId;
		regVC.phoneTel = self.verifyPhoneT.text;
        [self.navigationController pushViewController:regVC animated:YES];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	[[UIApplication sharedApplication].keyWindow endEditing:YES];
	
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self verifyCode:nil];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
