//
//  AppDelegate+AppService.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/28.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "AppDelegate+AppService.h"

@implementation AppDelegate (AppService)

/**
 *  系统配置
 */
- (void)systemConfigration{
    // QD自定义的全局样式渲染
//    [QDCommonUI renderGlobalAppearances];
    
    // 预加载 QQ 表情，避免第一次使用时卡顿
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [QDUIHelper qmuiEmotions];
//    });
    //启动网络状态监听
    [self startNetworkMonitoring];
    //获取用户信息
    [self getUserInformation];
    
}
/**
 *  网络监测
 */
- (void)startNetworkMonitoring{
    /** 初始化网络状态为异常 */
    self.netConnection=NO;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager ] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case -1:
                DSLog(@"未知网络");
                break;
            case 0:
                DSLog(@"网络异常");
                break;
            case 1:
                DSLog(@"GPRS网络");
                break;
            case 2:
                DSLog(@"wifi网络");
                break;
            default:
                break;
        }
        if(status ==AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi)
        {
            //DSLog(@"网络正常");
            self.netConnection=YES;
        }else
        {
            //DSLog(@"失去网络连接");
            self.netConnection=NO;
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"网络失去连接，请检查网络" message:nil preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *actionConfirm = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil];
            [alert addAction:actionConfirm];
            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }];
}

- (BOOL)firstStart{
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"firstStart"]){
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"firstStart"];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"statusSwitch"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        DSLog(@"第一次启动");
        return YES;
    }else{
        DSLog(@"不是第一次启动");
        return NO;
    }
    
}

/**
 *  重新获取用户信息 读取用户状态和配置信息到单例中
 */
- (void)getUserInformation{
    //是否第一次启动
    if (![self firstStart]){
        //个人信息
        [USER_INFO  restart];
    };
}




@end
