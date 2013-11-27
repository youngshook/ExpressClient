//
//  TKDKit.m
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import "TKDKit.h"
static TKDKit *sharedTKDKit = nil;
#pragma mark -
#pragma mark 全局的工具类方法

/** 快速UIAlertView*/
void QFAlert(NSString *title, NSString *msg, NSString *buttonText){
	UIAlertView *av=[[UIAlertView alloc] initWithTitle:title
											   message:msg
											  delegate:nil
									 cancelButtonTitle:buttonText
									 otherButtonTitles:nil];
	[av show];
}

/** Notification便捷方法*/
void QFEvent(NSString *eventName,id data){
	[[NSNotificationCenter defaultCenter] postNotificationName:eventName object:data];
}

void QFListenEvent(NSString *eventName,id target,SEL method){
	[[NSNotificationCenter defaultCenter] addObserver:target selector:method name:eventName object:nil];
}

void QFForgetEvent(NSString *eventName,id target){
	[[NSNotificationCenter defaultCenter] removeObserver:target name:eventName object:nil];
}


UIImage* resizeImageWithImage(NSString* imageName, UIEdgeInsets capInsets, UIImageResizingMode resizingMode){
    CGFloat systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    UIImage *image = [UIImage imageNamed:imageName];
    
    if (systemVersion >= 6.0) {
        return [image resizableImageWithCapInsets:capInsets resizingMode:resizingMode];
        return [image resizableImageWithCapInsets:capInsets];;
    }
    
    if (systemVersion >= 5.0) {
        return [image resizableImageWithCapInsets:capInsets];;
    }
    return  [image stretchableImageWithLeftCapWidth:capInsets.left topCapHeight:capInsets.top];
}

@implementation TKDKit

@synthesize shouldRefresh;

/** 构造方法*/
- (id)init {
    
    self = [super init];
    
    if (self) {
        if ([CLLocationManager locationServicesEnabled]) {
            locationMgr = [CLLocationManager new];
            locationMgr.delegate = self;
            locationMgr.desiredAccuracy = kCLLocationAccuracyBest;
            locationMgr.distanceFilter = kCLDistanceFilterNone;
        }
    }
    
    return self;
}

-(BOOL)refreshGPS_{
    
	if ([CLLocationManager locationServicesEnabled]) {
		[locationMgr startUpdatingLocation];
        return YES;
	}
	return NO;
}

//更新GPS
+(BOOL)refreshGPS{
	return [[TKDKit kit] refreshGPS_];
}

/** 单例方法*/
+(TKDKit *)kit {
    @synchronized(self) {
        if (sharedTKDKit == nil) {
            sharedTKDKit = [[self alloc] init];
            
        }
    }
    return sharedTKDKit;
}

#pragma mark -
#pragma mark -=GPS实现协议location Delegate=-

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    CLLocationCoordinate2D coor = newLocation.coordinate;
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:coor.longitude] forKey:@"gpslon"];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithDouble:coor.latitude] forKey:@"gpslat"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [locationMgr stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    
    [locationMgr stopUpdatingLocation];
    
    if ([[error domain] isEqualToString: kCLErrorDomain] && [error code] == kCLErrorDenied) {
        QFEvent(@"QFEventGPSUpdate", nil);
    }
}

@end
