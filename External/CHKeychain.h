//
//  CHKeychain.h
//  Apps
//
//  Created by guol shi on 12-6-5.
//  Copyright (c) 2012年 QFPay. All rights reserved.
//

#import <Foundation/Foundation.h>  
#import <Security/Security.h>  

@interface CHKeychain : NSObject  

+ (void)save:(NSString *)service data:(id)data;  
+ (id)load:(NSString *)service;  
+ (void)delete:(NSString *)service;  

@end 