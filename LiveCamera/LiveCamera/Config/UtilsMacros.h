//
//  UtilsMacros.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/27.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#ifndef UtilsMacros_h
#define UtilsMacros_h
//系统版本号
#define kSystemVersion [[UIDevice currentDevice] systemVersion]
//APP版本号
#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
//UUID用户设备标识
#define DEVICE_UUID [[UIDevice currentDevice].identifierForVendor UUIDString]
//判断是否为iPhone
#define kISiPhone (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//判断是否为iPad
#define kISiPad (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
//判断是否是iPhone4s
#define IS_IPHONE4S (([[UIScreen mainScreen] bounds].size.height-480)?NO:YES)
//判断是否是iPhone5
#define IS_IPHONE5 (([[UIScreen mainScreen] bounds].size.height-568)?NO:YES)
//判断是否是iPhone6、iPhone7
#define IS_IPHONE6 (([[UIScreen mainScreen] bounds].size.height-667)?NO:YES)
//判断是否是iPhone6plush、7plus
#define IS_IPHONE6_PLUS (([[UIScreen mainScreen] bounds].size.height-736)?NO:YES)
//当前设备的ios版本
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

#define KIsiPhoneX ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)

#pragma mark - **************** 判断属性
//字符串是否为空
#define kStringIsEmpty(str) ([str isKindOfClass:[NSNull class]] || str == nil || [str length] < 1 ? YES : NO )
//数组是否为空
#define kArrayIsEmpty(array) (array == nil || [array isKindOfClass:[NSNull class]] || array.count == 0)
//字典是否为空
#define kDictIsEmpty(dic) (dic == nil || [dic isKindOfClass:[NSNull class]] || dic.allKeys == 0)
//是否是空对象
#define kObjectIsEmpty(_object) (_object == nil \
|| [_object isKindOfClass:[NSNull class]] \
|| ([_object respondsToSelector:@selector(length)] && [(NSData *)_object length] == 0) \
|| ([_object respondsToSelector:@selector(count)] && [(NSArray *)_object count] == 0))

#pragma mark - **************** 注册，强弱引用

//Appdelegate
#define kAppDelegate (AppDelegate *)[UIApplication sharedApplication].delegate
//弱引用
#define kWeakSelf(type)  __weak typeof(type) weak##type = type;
//强引用
#define kStrongSelf(type) __strong typeof(type) type = weak##type;

#pragma mark - **************** 其他
//开发的时候打印，但是发布的时候不打印的DSLog
#ifdef DEBUG
#define DSLog(...) NSLog(@"%s 第%d行 \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define DSLog(...)
#endif
//带alert的log
#ifdef DEBUG
//#define ULog(...)
#define ULog(fmt, ...)  { UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%s\n [Line %d] ", __PRETTY_FUNCTION__, __LINE__] message:[NSString stringWithFormat:fmt, ##__VA_ARGS__]  delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil]; [alert show]; }
#else
#define ULog(...)
#endif

#pragma mark - **************** 沙盒路径
//获取沙盒temp路径
#define kPathTemp                   NSTemporaryDirectory()
//获取沙盒Document路径
#define kPathDocument               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
//获取沙盒Cache路径
#define kPathCache                  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define kPathSearch                 [kPathDocument stringByAppendingPathComponent:@"Search.plist"]
#define kPathMagazine               [kPathDocument stringByAppendingPathComponent:@"Magazine"]
#define kPathDownloadedMgzs         [kPathMagazine stringByAppendingPathComponent:@"DownloadedMgz.plist"]
#define kPathDownloadURLs           [kPathMagazine stringByAppendingPathComponent:@"DownloadURLs.plist"]
#define kPathOperation              [kPathMagazine stringByAppendingPathComponent:@"Operation.plist"]
#define kPathSplashScreen           [kPathCache stringByAppendingPathComponent:@"splashScreen"]

#pragma mark - **************** 其他
//获取系统时间戳
#define getCurentTime [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]]
//是否竖屏
#define IsPortrait ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait || [UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortraitUpsideDown)



#endif /* UtilsMacros_h */
