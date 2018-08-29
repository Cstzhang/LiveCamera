//
//  AppDelegate.h
//  LiveCamera
//
//  Created by bigfish on 2018/8/29.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

/** 网络状态是否正常 isNormalConnection网络连接正常 */
@property(nonatomic,assign)BOOL  netConnection;
@end

