//
//  TKDRegisterViewController.h
//  TKD
//
//  Created by YoungShook on 13-11-11.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//
#import "UIKeyboardViewController.h"
#import <UIKit/UIKit.h>

@interface TKDRegisterViewController : UIViewController<UIKeyboardViewControllerDelegate>{
    UIKeyboardViewController *keyBoardController;
}
@property(nonatomic,copy)NSString *verifyCode;
@property(nonatomic,copy)NSString *phoneTel;
@end
