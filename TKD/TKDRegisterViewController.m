//
//  TKDRegisterViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-11.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//
#import "APService.h"
#import "TKDRegisterViewController.h"
#import "TKDActivateViewController.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
@interface TKDRegisterViewController ()
@property(nonatomic,strong) NSString *gender;
@property (nonatomic, strong) MBProgressHUD *HUD;
@property(nonatomic,weak)IBOutlet UITextField *passwordT;
@property(nonatomic,weak)IBOutlet UITextField *rePasswordT;
@property(nonatomic,weak)IBOutlet UITextField *usernameT;
@property(nonatomic,weak)IBOutlet UITextField *verifyCodeT;
@property(nonatomic,weak)IBOutlet UIButton *registerBtn;
@property (nonatomic, weak) IBOutlet UIImageView *radioSelectedImageView;
@property (nonatomic, weak) IBOutlet UIImageView *radioUnSelectedImageView;
@end

@implementation TKDRegisterViewController

-(void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	keyBoardController=[[UIKeyboardViewController alloc] initWithControllerDelegate:self];
	[keyBoardController addToolbarToKeyboard];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"会员注册";
    HUD_Define
    RACSignal *formValid = [RACSignal
                            combineLatest:@[
                                            self.passwordT.rac_textSignal,
                                            self.rePasswordT.rac_textSignal,
                                            self.usernameT.rac_textSignal,
                                            self.verifyCodeT.rac_textSignal
                                            ]
                            reduce:^(NSString *password, NSString *rePassword, NSString *username, NSString *verifyCode) {
                                return @(password.length > 0
                                && rePassword.length > 0
                                && username.length > 0
                                && [password isEqualToString:rePassword]
                                && verifyCode.length >0);
                            }];
    
    
    RACCommand *createAccountCommand = [RACCommand commandWithCanExecuteSignal:formValid];
	
    [[self.registerBtn rac_signalForControlEvents:UIControlEventTouchUpInside] executeCommand:createAccountCommand];
    UIButton *btn = (UIButton *)VIEWWITHTAG(self.view, 2000);
    [btn setBackgroundImage:[[UIImage imageNamed:@"login_btn"] stretchableImageWithLeftCapWidth:15 topCapHeight:5] forState:UIControlStateNormal];
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.backBarButtonItem.tintColor = [UIColor clearColor];
	self.gender = @"Male";
	[self.radioSelectedImageView bk_whenTapped:^{
		self.gender = @"Male";
		self.radioSelectedImageView.image = [UIImage imageNamed:@"radioSelected.png"];
		self.radioUnSelectedImageView.image = [UIImage imageNamed:@"radioUnselected.png"];
	}];
	
	[self.radioUnSelectedImageView bk_whenTapped:^{
		self.gender = @"Female";
		self.radioUnSelectedImageView.image = [UIImage imageNamed:@"radioSelected.png"];
		self.radioSelectedImageView.image = [UIImage imageNamed:@"radioUnselected.png"];
	}];
	
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

-(IBAction)registerBtn:(id)sender{
    
    if (IS_NULL_STRING(self.phoneTel ) || IS_NULL_STRING(self.passwordT.text) || IS_NULL_STRING(self.usernameT.text)|| IS_NULL_STRING(self.verifyCodeT.text) || IS_NULL_STRING(self.rePasswordT.text)) {
        QFAlert(@"提示", @"请把信息填写完整", @"确定");
        return;
    }
    
    if (![self VerifyPhoneNum:self.phoneTel]) {
        QFAlert(@"提示", @"无效手机号,请重新输入", @"我知道了");
        return;
    }
    
    [self.HUD show:YES];
    NSURL *url = [NSURL URLWithString:API_ACCOUNT_REGISTER];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:self.phoneTel forKey:@"mobile"];
    [request addPostValue:self.passwordT.text forKey:@"password"];
    [request addPostValue:self.usernameT.text forKey:@"realname"];
	[request addPostValue:self.gender forKey:@"gender"];
    [request addPostValue:self.verifyCodeT.text forKey:@"verifycode"];
    [request addPostValue:self.verifyCode forKey:@"verificationId"];
    [request setCompletionBlock:^{
        [self.HUD hide:YES];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        [APService setTags:[NSSet setWithArray:[dic objectForKey:@"Tags"]] alias:[dic objectForKey:@"Id"] callbackSelector:nil object:nil];
        WarningAlert
        QFAlert(@"提示", @"注册成功,请使用注册账号登录!", @"我知道了");
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
    [request setFailedBlock:^{
        NetworkError_HUD
    }];
    [request startAsynchronous];

}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	[[UIApplication sharedApplication].keyWindow endEditing:YES];
	
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
