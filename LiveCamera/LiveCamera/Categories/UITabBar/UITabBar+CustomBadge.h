//
//  UITabBar+CustomBadge.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/4/20.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (CustomBadge)
/** 添加tabBar的小红点
 *  导航控制器
 *  num：显示的数字(无数字 num = 0)
 */
- (void)showBadgeOnTabbarIndex:(int)index withNumber:(NSInteger)num;

/** 移除小红点
 * 导航控制器
 */
- (void)hideBadgeOnTabbarIndex:(int)index;
@end
