//
//  TKDKit.h
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
@interface TKDKit : NSObject<CLLocationManagerDelegate>{
	CLLocationManager *locationMgr;
	BOOL shouldRefresh;
}


@property(nonatomic, assign) BOOL shouldRefresh;

#pragma mark -
#pragma mark 全局的工具类方法，可以直接调用

/** 快速弹出提醒窗口 */
void QFAlert(NSString *title, NSString *msg, NSString *buttonText);

/** 快速发送一个事件 */
void QFEvent(NSString *eventName,id data);

/** 快速注册事件侦听 */
void QFListenEvent(NSString *eventName,id target,SEL method);

/** 快速注销事件侦听 */
void QFForgetEvent(NSString *eventName,id target);


/** 图片拉伸
 imageName : 需要拉伸的图片名称
 capInsets : 设置不拉伸的比例参数
 return : 返回处理好的图片
 UIEdgeInsets (top,left,bottom,right)
 UIImageResizingModeTile 平铺模式 填充Insets
 UIImageResizingModeStretch 拉伸模式 拉伸Insets
 */
UIImage* resizeImageWithImage(NSString* imageName, UIEdgeInsets capInsets, UIImageResizingMode resizingMode);


/** QFKit单体实例
 *	这是访问QFKit的唯一方法!!
 */
+(TKDKit *)kit;

/** 刷新GPS位置
 *	@return 返回是否可以刷新GPS位置
 */
+(BOOL)refreshGPS;

@end
