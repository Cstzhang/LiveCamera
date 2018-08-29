//
//  AppDelegate+ViewController.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/28.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "AppDelegate+ViewController.h"
#import "RootTabBarController.h"
#import "RootNavigationController.h"
#import "DeviceListViewController.h"
#import "PhotoListViewController.h"
@implementation AppDelegate (ViewController)

- (void)setAppWindows
{
    // 界面
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self createTabBarController];
    
    // 启动动画
    [self startLaunchingAnimation];
    

    
}


- (void)createTabBarController {
    RootTabBarController *tabBarViewController = [[RootTabBarController alloc] init];
    
    // DeviceList
    DeviceListViewController *deviceListViewController = [[DeviceListViewController alloc] init];
    deviceListViewController.hidesBottomBarWhenPushed = NO;
    RootNavigationController *deviceListNavController = [[RootNavigationController alloc] initWithRootViewController:deviceListViewController];
    deviceListNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"DeviceList" image:[UIImageMake(@"ic_tab_devices") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"ic_tab_devices_selected") tag:0];
    
    // UIComponents
    PhotoListViewController *photoListViewController = [[PhotoListViewController alloc] init];
    photoListViewController.hidesBottomBarWhenPushed = NO;
    RootNavigationController *photoListNavController = [[RootNavigationController alloc] initWithRootViewController:photoListViewController];
    photoListNavController.tabBarItem = [QDUIHelper tabBarItemWithTitle:@"Components" image:[UIImageMake(@"ic_tab_photos") imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] selectedImage:UIImageMake(@"ic_tab_photos_selected") tag:1];
    

    
    // window root controller
    tabBarViewController.viewControllers = @[deviceListNavController, photoListNavController];
    self.window.rootViewController = tabBarViewController;
    [self.window makeKeyAndVisible];
}

- (void)startLaunchingAnimation {
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    UIView *launchScreenView = [[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil].firstObject;
    launchScreenView.frame = window.bounds;
    [window addSubview:launchScreenView];
    
    UIImageView *backgroundImageView = launchScreenView.subviews[0];
    backgroundImageView.clipsToBounds = YES;
    
    UIImageView *logoImageView = launchScreenView.subviews[1];
    UILabel *copyrightLabel = launchScreenView.subviews.lastObject;
    
    UIView *maskView = [[UIView alloc] initWithFrame:launchScreenView.bounds];
    maskView.backgroundColor = UIColorWhite;
    [launchScreenView insertSubview:maskView belowSubview:backgroundImageView];
    
    [launchScreenView layoutIfNeeded];
    
    
    [launchScreenView.constraints enumerateObjectsUsingBlock:^(__kindof NSLayoutConstraint * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:@"bottomAlign"]) {
            obj.active = NO;
            [NSLayoutConstraint constraintWithItem:backgroundImageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:launchScreenView attribute:NSLayoutAttributeTop multiplier:1 constant:NavigationContentTop].active = YES;
            *stop = YES;
        }
    }];
    
    [UIView animateWithDuration:.15 delay:0.9 options:QMUIViewAnimationOptionsCurveOut animations:^{
        [launchScreenView layoutIfNeeded];
        logoImageView.alpha = 0.0;
        copyrightLabel.alpha = 0;
    } completion:nil];
    [UIView animateWithDuration:1.2 delay:0.9 options:UIViewAnimationOptionCurveEaseOut animations:^{
        maskView.alpha = 0;
        backgroundImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [launchScreenView removeFromSuperview];
    }];
}

@end


