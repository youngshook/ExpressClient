//
//  TKDMyReserveCell.h
//  TKD
//
//  Created by YoungShook on 14-8-24.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TKDReserveAction <NSObject>
@required
-(void)selectReserveStatus:(id)sender;
@end


@interface TKDMyReserveCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *reserveCount;
@property (nonatomic, weak) IBOutlet UILabel *reserveTime;
@property (nonatomic, weak) IBOutlet UILabel *reserveTitle;
@property (nonatomic, weak) IBOutlet UIButton *reserveStatus;
@property (nonatomic, weak) id<TKDReserveAction> delegate;
@property (nonatomic, copy) NSString *reserveID;
@end
