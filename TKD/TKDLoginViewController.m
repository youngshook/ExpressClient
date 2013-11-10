//
//  TKDLoginViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDLoginViewController.h"
#import "TKDRegisteredViewController.h"
@interface TKDLoginViewController ()<UITextFieldDelegate>
@property(nonatomic,weak)IBOutlet UITextField *accountwordT;
@property(nonatomic,weak)IBOutlet UITextField *passwordT;
@property(nonatomic,weak)IBOutlet UIImageView *checkImg;
@property(nonatomic,weak)IBOutlet UIButton *LoginBtn;
@property(nonatomic,strong)MBProgressHUD *HUD;
@end

@implementation TKDLoginViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.accountwordT becomeFirstResponder];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.accountwordT resignFirstResponder];
    [self.passwordT resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"淘快递";
    self.navigationController.navigationBar.tintColor = [UIColor redColor];
    
    UIBarButtonItem *rightBtn = [[UIBarButtonItem alloc]initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(registerAccount)];
    [self.navigationItem setRightBarButtonItem:rightBtn animated:YES];
    
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:self.HUD];
}


-(IBAction)login:(id)sender{
    [self.HUD show:YES];
    [self.accountwordT resignFirstResponder];
    [self.passwordT resignFirstResponder];
    
    [self.accountwordT setEnabled:NO];
    [self.passwordT setEnabled:NO];
    [self.LoginBtn setEnabled:NO];
    
 	if ([self.accountwordT.text length]>2 && ([self.passwordT.text length]>5 && [self.passwordT.text length]<21)) {
        [self login:self.accountwordT.text password:self.passwordT.text];
	} else {
        //红色字提示
        if ([self.accountwordT.text length] < 2 || [self.accountwordT.text length] > 15) {
            QFAlert(@"请输入有效的手机号", nil, @"确定");
            [self.accountwordT becomeFirstResponder];
        } else if([self.passwordT.text length] < 6 || [self.passwordT.text length]>20){
            QFAlert(@"输入的密码长度错误,请输入正确的密码", nil, @"确定");
            [self.passwordT becomeFirstResponder];
        }
        //如果密码错误，则清空密码区
        [self.passwordT setText:@""];
        //可以再次点击
        [self setWaitStop];
    }
}


-(void)setWaitSatr{
    [self.LoginBtn setTitle:@"正在登录..." forState:UIControlStateNormal|UIControlStateDisabled];
    [self.HUD show:YES];
    [self.LoginBtn setEnabled:NO];
    [self.accountwordT setEnabled:NO];
    [self.passwordT setEnabled:NO];
}

-(void)setWaitStop{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.LoginBtn setTitle:@"登录" forState:UIControlStateNormal];
    [self.HUD hide:YES];
    [self.LoginBtn setEnabled:YES];
    [self.accountwordT setEnabled:YES];
    [self.passwordT setEnabled:YES];
}

-(void)login:(NSString*)u password:(NSString*)p{


}

-(IBAction)forgetPassWord:(id)sender{


}

-(IBAction)checkRemPassword:(id)sender{


}

-(void)registerAccount{
    TKDRegisteredViewController *regVC = [TKDRegisteredViewController new];
    [self.navigationController pushViewController:regVC animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if ([textField isEqual:self.passwordT]) {
        [self login:nil];
        return YES;
    }
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if ([textField isEqual:self.accountwordT]) {
        if (range.location > 15) {
            return NO;
        }
        else {
            return YES;
        }
    }
    
    if ([textField isEqual:self.passwordT]) {
        if (range.location > 19) {
            return NO;
        }
        else {
            return YES;
        }
    }
    return NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

-(BOOL)shouldAutorotate
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
