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
}

-(IBAction)checkImg:(id)sender{
    if (self.checkImg.tag == 1200) {
        self.checkImg.image = [UIImage imageNamed:@"uncheck"];
        self.checkImg.tag = 1201;
        self.verifyBtn.enabled = NO;
    }else{
        self.checkImg.tag = 1200;
        self.checkImg.image = [UIImage imageNamed:@"check"];
        TKDAgreementViewController *agreementVC = [TKDAgreementViewController new];
        [self.navigationController pushViewController:agreementVC animated:YES];
        self.verifyBtn.enabled = YES;
    }
}

-(IBAction)verifyCode:(id)sender{
    
    NSURL *url = [NSURL URLWithString:API_APP_VERIFY_CODE];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:self.verifyPhoneT.text forKey:@"mobile"];
    [request addPostValue:@"Register" forKey:@"purpose"];
    [request setCompletionBlock:^{
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
    TKDRegisterViewController *regVC = [TKDRegisterViewController new];
    regVC.verifyCode = verificationId;
    [self.navigationController pushViewController:regVC animated:YES];
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
