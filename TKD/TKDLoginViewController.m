//
//  TKDLoginViewController.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//
#import "APService.h"
#import "TKDLoginViewController.h"
#import "TKDResetPasswordViewController.h"
#import "TKDActivateViewController.h"
#import "TKDMainViewController.h"
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
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.accountwordT resignFirstResponder];
    [self.passwordT resignFirstResponder];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"快鸽欢迎您";

    HUD_Define
    
    if ([USER_DEFAULTS boolForKey:@"remPassword"]) {
        self.checkImg.image = [UIImage imageNamed:@"check"];
        NSDictionary *dic = [CHKeychain load:@"userAccount"];
        self.accountwordT.text = [dic objectForKey:@"account"];
        self.passwordT.text = [dic objectForKey:@"password"];
    }else{
        self.checkImg.image = [UIImage imageNamed:@"uncheck"];
        NSDictionary *dic = [CHKeychain load:@"userAccount"];
        if (dic) {
            self.accountwordT.text = [dic objectForKey:@"account"];
            [self.passwordT becomeFirstResponder];
        }else{
            [self.accountwordT becomeFirstResponder];
        }
    }
	
	self.navigationItem.leftBarButtonItem.tintColor = [UIColor clearColor];
	self.navigationItem.rightBarButtonItem.tintColor = [UIColor clearColor];
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
    NSURL *url = [NSURL URLWithString:API_ACCOUNT_LOGIN];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request addPostValue:u forKey:@"mobile"];
    [request addPostValue:p forKey:@"password"];
    [request setCompletionBlock:^{
        [self setWaitStop];
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSDictionary *dic = [[request responseString]JSONValue];
        WarningAlert
		if ([dic objectForKey:@"DefaultStationId"]) {
			[USER_DEFAULTS setBool:YES forKey:@"isHasDefaultStationId"];
		}
		
        [self getExpressList];
        [self getAddressList];
        [self updateUserInfo:dic];
    }];
    [request setFailedBlock:^{
        [self setWaitStop];
        NetworkError
    }];
    [request startAsynchronous];
}

-(void)updateUserInfo:(NSDictionary *)dic{
    NSDictionary *keychainData = @{@"account":self.accountwordT.text,@"password":self.passwordT.text};
    [CHKeychain save:@"userAccount" data:keychainData];
    [APService setTags:[NSSet setWithArray:[dic objectForKey:@"Tags"]] alias:[dic objectForKey:@"Id"] callbackSelector:nil object:nil];
	[USER_DEFAULTS setBool:YES forKey:@"userLogined"];
	
	[UIView transitionWithView:ApplicationDelegate.window
					  duration:0.65
					   options:UIViewAnimationOptionTransitionFlipFromLeft
					animations:^{
						ApplicationDelegate.window.rootViewController = ApplicationDelegate.tabBarVC;
					}
					completion:^(BOOL finished){
						QFEvent(@"fetchDataSource", nil);
					}];
}

-(IBAction)forgetPassWord:(id)sender{
    TKDActivateViewController *activateVC = [TKDActivateViewController new];
    [self.navigationController pushViewController:activateVC animated:YES];
}

-(IBAction)checkRemPassword:(id)sender{
    if ([USER_DEFAULTS boolForKey:@"remPassword"]) {
        [USER_DEFAULTS setBool:NO forKey:@"remPassword"];
        self.checkImg.image = [UIImage imageNamed:@"uncheck"];
    }else{
        [USER_DEFAULTS setBool:YES forKey:@"remPassword"];
        self.checkImg.image = [UIImage imageNamed:@"check"];
    }
}

-(IBAction)activateAccount:(id)sender{
    TKDActivateViewController *regVC = [TKDActivateViewController new];
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

-(void)getExpressList{
    
    NSURL *url = [NSURL URLWithString:API_INFO_VENDOR];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSArray *dic = [[request responseString]JSONValue];
        [USER_DEFAULTS setObject:dic forKey:@"expressList"];
        [USER_DEFAULTS synchronize];
    }];
    [request setFailedBlock:^{
        NetworkError
    }];
    [request startAsynchronous];
    
}


-(void)getAddressList{
    
    NSURL *url = [NSURL URLWithString:API_INFO_STATION];
    __weak ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    ASIFormDataRequestDefine_ToKen
    [request setCompletionBlock:^{
        NSLog(@"%@:%@",[url path],[request responseString]);
        NSArray *array = [[request responseString]JSONValue];
        [USER_DEFAULTS setObject:array forKey:@"addressList"];
        [USER_DEFAULTS synchronize];
    }];
    [request setFailedBlock:^{
        NetworkError
    }];
    [request startAsynchronous];
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	
	[[UIApplication sharedApplication].keyWindow endEditing:YES];
	
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
