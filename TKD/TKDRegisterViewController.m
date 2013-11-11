//
//  TKDRegisterViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-11.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDRegisterViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface TKDRegisterViewController ()
@property(nonatomic,weak)IBOutlet UITextField *phoneT;
@property(nonatomic,weak)IBOutlet UITextField *passwordT;
@property(nonatomic,weak)IBOutlet UITextField *rePasswordT;
@property(nonatomic,weak)IBOutlet UITextField *usernameT;
@property(nonatomic,weak)IBOutlet UITextField *verifyCodeT;
@property(nonatomic,weak)IBOutlet UIButton *registerBtn;
@property(nonatomic,strong)MBProgressHUD *HUD;
@end

@implementation TKDRegisterViewController

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	keyBoardController=[[UIKeyboardViewController alloc] initWithControllerDelegate:self];
	[keyBoardController addToolbarToKeyboard];
}

-(void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"会员注册";
    self.HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:self.HUD];
    RACSignal *formValid = [RACSignal
                            combineLatest:@[
                                            self.phoneT.rac_textSignal,
                                            self.passwordT.rac_textSignal,
                                            self.rePasswordT.rac_textSignal,
                                            self.usernameT.rac_textSignal,
                                            self.verifyCodeT.rac_textSignal
                                            ]
                            reduce:^(NSString *phoneNum, NSString *password, NSString *rePassword, NSString *username, NSString *verifyCode) {
                                return @(phoneNum.length > 0
                                && password.length > 0
                                && rePassword.length > 0
                                && username.length > 0
                                && [password isEqualToString:rePassword]
                                && verifyCode.length >0);
                            }];
    
    
    RACCommand *createAccountCommand = [RACCommand commandWithCanExecuteSignal:formValid];
    [[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] executeCommand:createAccountCommand];
    
    RACSignal *buttonEnabled = RACAbleWithStart(createAccountCommand, canExecute);
    RAC(self.registerBtn.enabled) = buttonEnabled;
    
    UIColor *defaultButtonTitleColor = self.registerBtn.titleLabel.textColor;
    RACSignal *buttonTextColor = [buttonEnabled map:^id(NSNumber *x) {
        return x.boolValue ? defaultButtonTitleColor : [UIColor lightGrayColor];
    }];
    
    [self.registerBtn rac_liftSelector:@selector(setTitleColor:forState:)
                            withObjects:buttonTextColor, @(UIControlStateNormal)];
}


-(IBAction)registerBtn:(id)sender{
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_ACCOUNT_REGISTER];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:@"mobile" forKey:self.phoneT.text];
    [request addPostValue:@"password" forKey:self.passwordT.text];
    [request addPostValue:@"realname" forKey:self.usernameT.text];
    [request addPostValue:@"verifycode" forKey:self.verifyCodeT.text];
    [request addPostValue:@"verificationId" forKey:self.passwordT.text];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        QFAlert(@"提示", @"注册成功", @"我知道了");
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];

}

- (void)alttextFieldDidEndEditing:(UITextField *)textField{


}

- (void)alttextViewDidEndEditing:(UITextView *)textView{


}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
