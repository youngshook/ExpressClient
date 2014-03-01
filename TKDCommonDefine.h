//
//  TKDCommonDefine.h
//  TKD
//
//  Created by YoungShook on 13-11-10.
//  Copyright (c) 2013年 qfpay. All rights reserved.
//

#ifndef TKD_TKDCommonDefine_h
#define TKD_TKDCommonDefine_h

#define API_APP_INIT [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Application/Initialize"]

#define API_APP_VERIFY_CODE [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Application/RequestVerifyCode"]

#define API_APP_UPGRADE [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Application/Upgrade"]

//-----------------ACCOUNT

#define API_ACCOUNT_REGISTER [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Account/Register"]

#define API_ACCOUNT_RECOVER [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Account/Recover"]

#define API_ACCOUNT_LOGIN [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Account/Login"]

#define API_ACCOUNT_RESET [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Account/Reset"]

#define API_ACCOUNT_EDIT [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Account/Edit"]

//-----------------INFO

#define API_INFO_VENDOR [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Info/Vendor"]

#define API_INFO_STATION [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Info/Station"]

#define API_INFO_SMS [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Info/Sms"]

//-----------------SHEET

#define API_SHEET_INDEX [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sheet/Index"]

#define API_SHEET_NEWEST [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sheet/Newest"]

#define API_SHEET_NOTIFIED [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sheet/Notified"]

#define API_SHEET_RETRIEVE [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sheet/Retrieve"]

#define API_SHEET_RETRIEVE_STATUS [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sheet/RetrieveStatus"]

#define API_SHEET_AUTHORIZE [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sheet/Authorize"]

#define API_SHEET_AUTHORIZE_CANCEL [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sheet/AuthorizeCancel"]

#define API_SHEET_AUTHORIZE_REJECT [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sheet/AuthorizeReject"]

//-----------------SENT

#define API_SENT_INDEX [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sent/Index"]

#define API_SENT_CONTACT [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sent/Contact"]

#define API_SENT_CREATE [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sent/Create"]

#define API_SENT_DETAILS [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/Sent/Details"]

//-----------------NEWS

#define API_NEWS_INDEX [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/News/Index"]

#define API_NEWS_DETAILS [NSString stringWithFormat:@"https://express.xiaoyuan100.net/Api/Client/News/Details"]



//----------------- Static Value

#define APP_ID [NSString stringWithFormat:@"1591b8bf-12d2-4006-b4d0-6f1622937f66"]

#define APP_SECRET [NSString stringWithFormat:@"Vm3d0jTmQe/7kR8ViHMzDg=="]

#define APP_TOKEN  [[NSUserDefaults standardUserDefaults]objectForKey:@"ApplicationToken"]

#define USER_LOGIN [USER_DEFAULTS boolForKey:@"userLogined"]


//----------------- Define code

#define WarningAlert \
if (!dic) {\
QFAlert(@"提示", @"服务器错误,请稍后再试", @"确定");\
return;\
}else{\
if ([dic objectForKey:@"Error"]) {\
QFAlert(@"提示", [NSString stringWithFormat:@"%@",[dic objectForKey:@"Error"]], @"我知道了");\
return;\
}else if ([dic objectForKey:@"error"]){\
QFAlert(@"提示", [NSString stringWithFormat:@"%@",[dic objectForKey:@"error"]], @"我知道了");\
return;\
}\
}\


#define NetworkError  \
QFAlert(@"提示", @"您当前网络不佳,请检查网络后再试", @"我知道了");

#define NetworkError_HUD \
[self.HUD hide:YES];\
QFAlert(@"提示", @"您当前网络不佳,请检查网络后再试", @"我知道了");

#define HUD_Define \
self.HUD = [[MBProgressHUD alloc]initWithView:self.view];\
[self.view addSubview:self.HUD];

#define ASIFormDataRequestDefine \
[request setRequestMethod:@"POST"];\
[request setTimeOutSeconds:10.0f];\
[request setShouldAttemptPersistentConnection:YES];\
[request setPersistentConnectionTimeoutSeconds:300];\
[request addRequestHeader:@"Host" value:[request.url host]];\
request.defaultResponseEncoding = NSUTF8StringEncoding;

#define ASIFormDataRequestDefine_ToKen \
[request setRequestMethod:@"POST"];\
[request setTimeOutSeconds:10.0f];\
[request setShouldAttemptPersistentConnection:YES];\
[request setPersistentConnectionTimeoutSeconds:300];\
[request addRequestHeader:@"Host" value:[request.url host]];\
request.defaultResponseEncoding = NSUTF8StringEncoding;\
[request addPostValue:APP_TOKEN forKey:@"applicationToken"];\
[request addPostValue:APP_ID forKey:@"applicationId"];

#endif
