//
//  UtilitesMethods.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/28.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface UtilitesMethods : NSObject
/**判断是否是第一次启动*/
+ (BOOL)isFirstLaunching;
/**根据iPhone6大小适配*/
+ (CGFloat)adaptationIphone6Height:(CGFloat)height;

/********************** NSString Utils ***********************/
+(NSString*)getCurrentTime;
/**字符串转换成时间*/
+ (NSDate *)dateFromString:(NSString *)string;
/**判断字符串是否为空*/
+(BOOL)isEmptyOrNull:(NSString *)str;
/**去掉空格*/
+ (NSString *)deleteBlank:(NSString *)string;
/**去掉回车和空格*/
+ (NSString *)deleteBlankAndEnter:(NSString *)string;
/**格式化浮点数（若有一位小数，显示一位；若有两位小数，则显示两位）*/
+(NSString *)formaterDoubleString:(double)doublevalue;
/**
 *  ios比较日期大小默认会比较到秒
 *
 *  @param oneDate     第一个时间
 *  @param anotherDate 第二个时间
 *
 *  @return 1 第一个时间靠后  -1 第一个时间靠前  0 两个时间相同
 */
+ (int)junc_CompareOneDate:(NSDate *)oneDate withAnotherDate:(NSDate *)anotherDate;
/**
 *  ios比较日期大小默认会比较到秒
 *
 *  @param oneDateStr     第一个时间
 *  @param anotherDateStr 第二个时间
 *
 *  @return 1 第一个时间靠后  -1 第一个时间靠前  0 两个时间相同
 */
+ (int)junc_CompareOneDateStr:(NSString *)oneDateStr withAnotherDateStr:(NSString *)anotherDateStr;

/********************** Verification Utils ***********************/
/**验证该字符串是否是6-16位字母和数字组合*/
+ (BOOL)checkIsDigitalAndLetter:(NSString *)string;
/**利用正则表达式验证手机号码*/
+ (BOOL)checkTel:(NSString *)str;
/**利用正则表达式验证邮箱*/
+ (BOOL)checkEmail:(NSString *)email;
/**颜色转图片*/
+ (UIImage *)createImageWithColor:(UIColor *)color;

/**
 比较两个版本号的大小
 
 @param v1 第一个版本号
 @param v2 第二个版本号
 @return 版本号相等,返回0; v1小于v2,返回-1; 否则返回1.
 */
+ (NSInteger)compareVersion:(NSString *)v1 to:(NSString *)v2;

// 获取当前wifi名称代码
+ (NSString *)getWifiName;


/**
 生成二维码

 @param urlStr 需要生成二维码的字符串
 @param codeSize 尺寸
 @return 二维码图片
 */
+(UIImage *)imageOfQRFromURL:(NSString *)urlStr codeSize:(CGFloat)codeSize;
/**
 *  读取图片中的二维码
 *
 *  @param image 图片
 *
 *  @return 图片中的二维码数据集合 CIQRCodeFeature对象
 */
+ (NSArray *)readQRCodeFromImage:(UIImage *)image;


/**
 sdp string 解析

 @param tmpString sdp string
 @return 字典
 */
+ (NSDictionary *)sdpSeparatedString:(NSString *)tmpString;

// md5
+ (NSString *) md5WithString:(NSString *) str;

+ (NSString *)base64EncodeString:(NSString *)string;

@end
