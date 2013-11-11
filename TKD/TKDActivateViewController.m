//
//  TKDActivateViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDActivateViewController.h"

@interface TKDActivateViewController ()<UITextFieldDelegate>
@property(nonatomic,weak)IBOutlet UITextField *verifyPhoneT;
@property(nonatomic,weak)IBOutlet UIImageView *checkImg;
@property(nonatomic,strong)MBProgressHUD *HUD;
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
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:self.HUD];
}

-(IBAction)checkImg:(id)sender{


}

-(IBAction)verifyCode:(id)sender{
    
    NSURL *url = [NSURL URLWithString:API_APP_VERIFY_CODE];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:@"mobile" forKey:self.verifyPhoneT.text];
    [request addPostValue:@"purpose" forKey:@"Register"];
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        if ([dic objectForKey:@"VerificationId"]) {
            [self userRegister:[dic objectForKey:@"VerificationId"]];
        }
    }];
    [request setFailedBlock:^{
        NetworkError
    }];

}

-(void)userRegister:(NSString *)VerifId{
    NSURL *url = [NSURL URLWithString:API_APP_VERIFY_CODE];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:@"mobile" forKey:self.verifyPhoneT.text];
    [request addPostValue:@"purpose" forKey:@"Register"];
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        if ([dic objectForKey:@"VerificationId"]) {
            [self userRegister:[dic objectForKey:@"VerificationId"]];
        }
    }];
    [request setFailedBlock:^{
        NetworkError
    }];
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
