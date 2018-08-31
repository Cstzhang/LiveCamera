//
//  AppDelegate+AppService.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/28.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate (AppService)
/**
 *  系统配置
 */
- (void)systemConfigration;

/**
 *  网络监测
 */
- (void)startNetworkMonitoring;
/**
 第一次启动
 */
-(BOOL)firstStart;

/**
 *  获取已经用户信息
 */
- (void)getUserInformation;



@end
