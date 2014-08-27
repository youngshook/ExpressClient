//
//  TKDMyReserveCell.m
//  TKD
//
//  Created by YoungShook on 14-8-24.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDMyReserveCell.h"

@implementation TKDMyReserveCell

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)selectReserve:(id)sender{
	[self.reserveStatus setTitle:@"正在取消中" forState:UIControlStateNormal];
	[self.delegate selectReserveStatus:self.reserveID];
}

@end
