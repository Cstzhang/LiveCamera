//
//  UtilitesMethods.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/28.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "UtilitesMethods.h"

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
@end
