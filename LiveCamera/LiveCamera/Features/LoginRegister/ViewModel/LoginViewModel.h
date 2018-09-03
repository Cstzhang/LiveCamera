//
//  LoginViewModel.h
//  LiveCamera
//
//  Created by bigfish on 2018/8/30.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "ViewModelClass.h"


@interface LoginViewModel : ViewModelClass

/**
   第三方信息登录到服务器

 @param user 用户信息
 @param viewController 控制器
 */
- (void)YTSignInServerWithUser:(GIDGoogleUser *)user viewController:(UIViewController *)viewController;


- (void)FBlogin:(UIViewController *)viewController;


- (void)FBSignInServerWithResult:(FBSDKLoginManagerLoginResult *)result viewController:(UIViewController *)viewController;


- (void)FBautoLoginWithToken:(FBSDKAccessToken *)token  viewController:(UIViewController *)viewController;

@end
