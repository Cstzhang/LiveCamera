//
//  MBProgressHUD+ZBAdditions.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/3/1.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (ZBAdditions)
/**
 show tips
 
 @param message msg
 */
+ (void)showTipMessageInWindow:(NSString*)message;
+ (void)showTipMessageInWindow:(NSString*)message timer:(int)aTimer;
+ (void)showTipMessageInView:(NSString*)message;
+ (void)showTipMessageInView:(NSString*)message timer:(int)aTimer;


/**
 show Activity msg

 @param message msg
 */
+ (void)showActivityMessageInWindow:(NSString*)message;
+ (void)showActivityMessageInView:(NSString*)message;
+ (void)showActivityMessageInWindow:(NSString*)message timer:(int)aTimer;
+ (void)showActivityMessageInView:(NSString*)message timer:(int)aTimer;


/**
 show success error info warn

 @param Message msg
 */
+ (void)showSuccessMessage:(NSString *)Message;
+ (void)showErrorMessage:(NSString *)Message;
+ (void)showInfoMessage:(NSString *)Message;
+ (void)showWarnMessage:(NSString *)Message;


/**
 show Custom Icon

 @param iconName Icon
 @param message msg
 */
+ (void)showCustomIconInWindow:(NSString *)iconName message:(NSString *)message;
+ (void)showCustomIconInView:(NSString *)iconName message:(NSString *)message;


/**
 hide hud
 */
+ (void)hideHUD;
@end
