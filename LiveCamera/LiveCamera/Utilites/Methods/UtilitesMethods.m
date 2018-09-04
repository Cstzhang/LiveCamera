//
//  UtilitesMethods.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/28.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "UtilitesMethods.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <CoreImage/CoreImage.h>
@implementation UtilitesMethods

/**判断是否是第一次启动*/
+ (BOOL)isFirstLaunching
{
    BOOL firstLaunching = false;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *lastAppVersion =  [userDefaults valueForKey:@"LastAppVersion"];
    
    NSString *currentAppVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    if ([lastAppVersion floatValue] < [currentAppVersion floatValue])
    {

        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:currentAppVersion forKey:@"LastAppVersion"];
        [userDefaults synchronize];
        firstLaunching = true;
    }

    return firstLaunching;
}

+ (CGFloat)adaptationIphone6Height:(CGFloat)height {
    if (IS_IPHONE6) {
        return height;
    }else if (IS_IPHONE6_PLUS){
        return height * 1.10;
    }else if (IS_IPHONE5){
        return height * 0.85;
    }
    return height;
}

/**字符串转换成时间*/
+ (NSDate *)dateFromString:(NSString *)string
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date   = [formatter dateFromString:string];
    return date;
}

/**判断字符串是否为空*/
+(BOOL)isEmptyOrNull:(NSString *)str
{
    if (!str || [str isKindOfClass:[NSNull class]])
    {
        // null object
        return true;
    } else {
        NSString *trimedString = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if ([trimedString length] == 0) {
            
            // empty string
            return true;
        }
        else{
            // is neither empty nor null
            return false;
        }
        
    }
}

/**去掉空格*/
+ (NSString *)deleteBlank:(NSString *)string
{
    NSString *newString= [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    return newString;
}

/**去掉空格及空行*/
+ (NSString *)deleteBlankAndEnter:(NSString *)string
{
    NSString *newString= [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    newString= [newString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    return newString;
}

/**格式化浮点数*/
+(NSString *)formaterDoubleString:(double)doublevalue{
    NSString *doubleStr = [NSString stringWithFormat:@"%.2f",doublevalue];
    NSRange pointRange = [doubleStr rangeOfString:@"."];
    if (pointRange.length > 0) {
        //包含小数点
        if ([[doubleStr substringWithRange:NSMakeRange(pointRange.location+2, 1)] isEqualToString:@"0"]) {
            //最后一位为0
            if ([[doubleStr substringWithRange:NSMakeRange(pointRange.location+1, 1)] isEqualToString:@"0"]) {
                //小数点后一位为0
                doubleStr = [NSString stringWithFormat:@"%.f",doublevalue];
            }
            else{
                doubleStr = [NSString stringWithFormat:@"%.1f",doublevalue];
            }
        }
    }
    else{
        //整数
        doubleStr = [NSString stringWithFormat:@"%.f",doublevalue];
    }
    return doubleStr;
}

/**验证该字符串是否是6-16位字母和数字组合*/
+ (BOOL)checkIsDigitalAndLetter:(NSString *)string
{
    if (string.length < 6 || string.length > 16)
    {
        return NO;
    }
    NSString *regex = @"^[A-Za-z0-9]+$";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    if ([predicate evaluateWithObject:string]) {
        if ([self hasDigital:string] && [self hasLetter:string]) {
            return YES;
        }else{
            return NO;
        }
    }else{
        return NO;
    }
}

/**
 *  是否有数字
 *
 *  @param string 字符串
 *
 *  @return YES 有数字 ，NO 没有数字
 */
+ (BOOL)hasDigital:(NSString *)string
{
    for(int i = 0; i < string.length ; i++){
        unichar a = [string characterAtIndex:i];
        if ((a >= '0' && a <= '9' )) {
            return YES;
        }
    }
    return NO;
}

/**
 *  是否有字母
 *
 *  @param string 字符串
 *
 *  @return YES 有字母 ，NO 没有字母
 */
+ (BOOL)hasLetter:(NSString *)string
{
    for(int i = 0; i < string.length ; i++){
        unichar a = [string characterAtIndex:i];
        if ((a >= 'A' && a <= 'Z' ) || (a >= 'a' && a <= 'z')) {
            return YES;
        }
    }
    return NO;
}

/**利用正则表达式验证手机号码*/
+ (BOOL)checkTel:(NSString *)str
{
    if ([str length] != 11) {
        return NO;
    }
    //修改电话号码限制规则
    //    NSString *regex = @"0{0,1}(13[0-9]|14[0-9]|15[0-9]|18[0-9])[0-9]{8}$";
    NSString *regex = @"0{0,1}1[0-9]{10}$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    BOOL isMatch = [pred evaluateWithObject:str];
    if (!isMatch) {
        return NO;
    }
    
    return YES;
}

/**邮箱有效性检查*/
+ (BOOL)checkEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/**生成图片*/
+ (UIImage *)createImageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImage;
}


/**
 *  ios比较日期大小默认会比较到秒
 *
 *  @param oneDate     第一个时间
 *  @param anotherDate 第二个时间
 *
 *  @return 1 第一个时间靠后  -1 第一个时间靠前  0 两个时间相同
 */
+ (int)junc_CompareOneDate:(NSDate *)oneDate withAnotherDate:(NSDate *)anotherDate
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    [df setDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    
    NSString *oneDayStr = [df stringFromDate:oneDate];
    
    NSString *anotherDayStr = [df stringFromDate:anotherDate];
    
    NSDate *dateA = [df dateFromString:oneDayStr];
    
    NSDate *dateB = [df dateFromString:anotherDayStr];
    
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedAscending)
    {  // oneDate < anotherDate
        return 1;
        
    }else if (result == NSOrderedDescending)
    {  // oneDate > anotherDate
        return -1;
    }
    
    // oneDate = anotherDate
    return 0;
}


/**
 *  ios比较日期大小默认会比较到秒
 *
 *  @param oneDateStr     第一个时间
 *  @param anotherDateStr 第二个时间
 *
 *  @return 1 第一个时间靠后  -1 第一个时间靠前  0 两个时间相同
 */
+ (int)junc_CompareOneDateStr:(NSString *)oneDateStr withAnotherDateStr:(NSString *)anotherDateStr
{
    NSDateFormatter *df = [[NSDateFormatter alloc]init];
    
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *dateA = [[NSDate alloc]init];
    
    NSDate *dateB = [[NSDate alloc]init];
    
    dateA = [df dateFromString:oneDateStr];
    
    dateB = [df dateFromString:anotherDateStr];
    
    NSComparisonResult result = [dateA compare:dateB];
    
    if (result == NSOrderedAscending)
    {  // oneDateStr < anotherDateStr
        return 1;
        
    }else if (result == NSOrderedDescending)
    {  // oneDateStr > anotherDateStr
        return -1;
    }
    
    // oneDateStr = anotherDateStr
    return 0;
}
/**
 比较两个版本号的大小
 
 @param v1 第一个版本号
 @param v2 第二个版本号
 @return 版本号相等,返回0; v1小于v2,返回-1; 否则返回1.
 */
+ (NSInteger)compareVersion:(NSString *)v1 to:(NSString *)v2 {
    // 都为空，相等，返回0
    if (!v1 && !v2) {
        return 0;
    }
    
    // v1为空，v2不为空，返回-1
    if (!v1 && v2) {
        return -1;
    }
    
    // v2为空，v1不为空，返回1
    if (v1 && !v2) {
        return 1;
    }
    
    // 获取版本号字段
    NSArray *v1Array = [v1 componentsSeparatedByString:@"."];
    NSArray *v2Array = [v2 componentsSeparatedByString:@"."];
    // 取字段最少的，进行循环比较
    NSInteger smallCount = (v1Array.count > v2Array.count) ? v2Array.count : v1Array.count;
    
    for (int i = 0; i < smallCount; i++) {
        NSInteger value1 = [[v1Array objectAtIndex:i] integerValue];
        NSInteger value2 = [[v2Array objectAtIndex:i] integerValue];
        if (value1 > value2) {
            // v1版本字段大于v2版本字段，返回1
            return 1;
        } else if (value1 < value2) {
            // v2版本字段大于v1版本字段，返回-1
            return -1;
        }
        
        // 版本相等，继续循环。
    }
    
    // 版本可比较字段相等，则字段多的版本高于字段少的版本。
    if (v1Array.count > v2Array.count) {
        return 1;
    } else if (v1Array.count < v2Array.count) {
        return -1;
    } else {
        return 0;
    }
    
    return 0;
}

// 获取当前wifi名称代码
+ (NSString *)getWifiName{
    NSString *wifiName = nil;
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    NSLog(@" wifiName :%@",wifiName);
    return wifiName;
}


/**
 生成二维码
 
 @param urlStr 需要生成二维码的字符串
 @param codeSize 尺寸
 @return 二维码图片
 */
+(UIImage *)imageOfQRFromURL:(NSString *)urlStr codeSize:(CGFloat)codeSize{
    
    return [self createUIImageFormCIImage:[self creatQRcodeWithUrlstring:urlStr]
                                 withSize:codeSize];
}

/**
 *  根据字符串生成二维码 CIImage 对象
 *
 *  @param urlString 需要生成二维码的字符串
 *
 *  @return 生成的二维码
 */
+ (CIImage *)creatQRcodeWithUrlstring:(NSString *)urlString{
    
    // 1.实例化二维码滤镜
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复滤镜的默认属性 (因为滤镜有可能保存上一次的属性)
    [filter setDefaults];
    // 3.将字符串转换成NSdata
    NSData *data  = [urlString dataUsingEncoding:NSUTF8StringEncoding];
    // 4.通过KVO设置滤镜, 传入data, 将来滤镜就知道要通过传入的数据生成二维码
    [filter setValue:data forKey:@"inputMessage"];
    // 5.生成二维码
    CIImage *outputImage = [filter outputImage];
    return outputImage;
}


/** 根据CIImage生成指定大小的UIImage */
+ (UIImage *)createUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size {
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}

/**
 *  读取图片中的二维码
 *
 *  @param image 图片
 *
 *  @return 图片中的二维码数据集合 CIQRCodeFeature对象
 */
+ (NSArray *)readQRCodeFromImage:(UIImage *)image{
    
    // 创建一个CIImage对象
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    CIContext *context = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}]; // 软件渲染
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:context options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];// 二维码识别
    // 注意这里的CIDetectorTypeQRCode
    NSArray *features = [detector featuresInImage:ciImage];
    NSLog(@"features = %@",features); // 识别后的结果集
    for (CIQRCodeFeature *feature in features) {
        NSLog(@"msg = %@",feature.messageString); // 打印二维码中的信息
    }
    return features;
}


@end
