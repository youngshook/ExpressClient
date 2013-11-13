//
//  TKDRegisterViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-11.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDRegisterViewController.h"
#import "TKDActivateViewController.h"
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
    if (!IS_NULL_STRING(self.verifyCode)) {
        self.verifyCodeT.text = self.verifyCode;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"会员注册";
    HUD_Define
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
    [request addPostValue:self.phoneT.text forKey:@"mobile"];
    [request addPostValue:self.passwordT.text forKey:@"password"];
    [request addPostValue:self.usernameT.text forKey:@"realname"];
    [request addPostValue:self.verifyCodeT.text forKey:@"verifycode"];
    [request addPostValue:self.passwordT.text forKey:@"verificationId"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
        QFAlert(@"提示", @"注册成功,请使用注册账号登录!", @"我知道了");
        [self.navigationController popToRootViewControllerAnimated:YES];
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
