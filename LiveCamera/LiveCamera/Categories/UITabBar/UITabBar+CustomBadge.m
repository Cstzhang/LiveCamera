//
//  UITabBar+CustomBadge.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/4/20.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "UITabBar+CustomBadge.h"

@implementation UITabBar (CustomBadge)
/** 添加tabBar的小红点
 *  导航控制器
 *  num：显示的数字(无数字 num = 0)
 */
- (void)showBadgeOnTabbarIndex:(int)index withNumber:(NSInteger)num{
    /** 移除原有红点 */
    [self removeBadgeOnItemIndex:index];
    /** 新建小红点 */
    UIView *badgeView = [[UIView alloc]init];
    /** tag标志 */
    badgeView.tag = 888+index;
    /** 设置圆角 */
    badgeView.layer.cornerRadius = 8;
    badgeView.clipsToBounds = YES;
    /** 设置红色 */
    badgeView.backgroundColor = [UIColor redColor];
    CGRect tabFram = self.frame;
    
    float percentX = (index+0.6)/TabbarItemNums;
    CGFloat x = ceilf(percentX*tabFram.size.width);
    CGFloat y = ceilf(0.1*tabFram.size.height);
    badgeView.frame = CGRectMake(x, y, 10, 10);
    
    
    // 判断是否有数字
    if (num <= 0) {
        // 只显示小红点
        
        // 圆形的宽度和高度
        CGFloat badgeViewWidthAndHeight = 8.0;
        badgeView.frame = CGRectMake(x, y, badgeViewWidthAndHeight, badgeViewWidthAndHeight);
    } else {
        // 显示小红点和数量
        // 圆形的宽度和高度
        CGFloat badgeViewWidthAndHeight = 17.0;
        badgeView.frame = CGRectMake(x, y, badgeViewWidthAndHeight, badgeViewWidthAndHeight);
        
        // 添加数量文字label
        UILabel *numLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(badgeView.frame), CGRectGetHeight(badgeView.frame))];
        numLabel.textAlignment = NSTextAlignmentCenter;
        if (num>=99) {
            numLabel.text = [NSString stringWithFormat:@"%@", @"99+"];
        }else{
            numLabel.text = [NSString stringWithFormat:@"%ld", (long)num];
        }
        
        numLabel.font = [UIFont systemFontOfSize:8];
        numLabel.textColor = [UIColor whiteColor];
        [badgeView addSubview:numLabel];
    }
    [self addSubview:badgeView];
    [self bringSubviewToFront:badgeView];
    
    
}

//隐藏红点
-(void)hideBadgeOnTabbarIndex:(int)index{
    [self removeBadgeOnItemIndex:index];
}
//移除控件
- (void)removeBadgeOnItemIndex:(int)index{
    for (UIView*subView in self.subviews) {
        if (subView.tag == 888+index) {
            [subView removeFromSuperview];
        }
    }
}

@end
