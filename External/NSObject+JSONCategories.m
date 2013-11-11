//
//  NSObject+JSONCategories.m
//  QMM
//
//  Created by YoungShook on 13-10-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "NSObject+JSONCategories.h"

@implementation NSObject (JSONCategories)

-(NSString*)JSONString;
{
    NSError* error = nil;
    id result = [NSJSONSerialization dataWithJSONObject:self
                                                options:kNilOptions error:&error];
    if (error != nil) return nil;

    return  [[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding];
}

@end
