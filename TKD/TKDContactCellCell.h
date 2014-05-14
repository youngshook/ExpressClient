//
//  TKDContactCellCell.h
//  TKD
//
//  Created by YoungShook on 14-5-13.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TKDExpressTel <NSObject>
@required
-(void)expressSiteCallTel:(id)sender;
@end

@interface TKDContactCellCell : UITableViewCell
@property(nonatomic,weak)IBOutlet UILabel *expressSiteName;
@property(nonatomic,weak)IBOutlet UIButton *expressSiteTel;
@property(nonatomic,weak)IBOutlet UILabel *expressSiteAddress;
@property(nonatomic,weak)IBOutlet UILabel *expressSiteInfo;
@property(nonatomic,weak)IBOutlet UILabel *expressSiteContact;
@property(nonatomic,weak) id<TKDExpressTel> delegate;
@end
