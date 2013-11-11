//
//  NSString+JSONCategories.m
//  QMM
//
//  Created by YoungShook on 13-10-14.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "NSString+JSONCategories.h"

@implementation NSString (JSONCategories)

-(id)JSONValue;
{
    NSData* data = [self dataUsingEncoding:NSUTF8StringEncoding];
    __autoreleasing NSError* error = nil;
    id result = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    if (error != nil) return nil;
    return result;
}

@end
