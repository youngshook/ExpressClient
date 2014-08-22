//
//  TKDHeaderView.m
//  TKD
//
//  Created by YoungShook on 14-8-23.
//  Copyright (c) 2014年 qfpay. All rights reserved.
//

#import "TKDHeaderView.h"

@implementation TKDHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)sendExpress:(id)sender{
	QFEvent(@"sendExpress", nil);
}

- (IBAction)checkExpress:(id)sender{
	QFEvent(@"checkExpress", nil);
}

@end
