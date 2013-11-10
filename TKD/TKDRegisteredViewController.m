//
//  TKDRegisteredViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDRegisteredViewController.h"

@interface TKDRegisteredViewController ()<UITextFieldDelegate>
@property(nonatomic,weak)IBOutlet UITextField *verifyPhoneT;
@property(nonatomic,weak)IBOutlet UIImageView *checkImg;
@property(nonatomic,strong)MBProgressHUD *HUD;
@end

@implementation TKDRegisteredViewController

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
