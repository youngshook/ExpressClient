//
//  TKDMsgDetailViewController.h
//  TKD
//
//  Created by YoungShook on 13-11-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKDMsgDetailViewController : UIViewController
@property(nonatomic,copy)NSString *messageId;
@property(nonatomic,copy)NSString *messageTitle;
@property(nonatomic,copy)NSString *messageContent;
@end
