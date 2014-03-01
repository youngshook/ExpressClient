//
//  TKDExpressSiteViewController.h
//  TKD
//
//  Created by YoungShook on 14-3-2.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ExpressSiteSelectBlock)(NSString *expressSiteStr);
@interface TKDExpressSiteViewController : UIViewController
@property (nonatomic,copy)ExpressSiteSelectBlock expressSiteSelectBlock;
@end
