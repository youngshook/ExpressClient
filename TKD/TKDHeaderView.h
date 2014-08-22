//
//  TKDHeaderView.h
//  TKD
//
//  Created by YoungShook on 14-8-23.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TKDHeaderView : UIView
@property(nonatomic,strong)IBOutlet UILabel *siteName;
- (IBAction)sendExpress:(id)sender;
- (IBAction)checkExpress:(id)sender;
@end
