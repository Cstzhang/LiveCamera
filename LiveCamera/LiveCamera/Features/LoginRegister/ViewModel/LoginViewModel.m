//
//  LoginViewModel.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/30.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "LoginViewModel.h"

@interface LoginViewModel()

@property (strong, nonatomic) UIViewController *LoginVc;
@property (strong, nonatomic) GIDGoogleUser *userInfo;

@end

@implementation LoginViewModel
/**
 第三方信息登录到服务器
 
 @param user 用户信息
 @param viewController 控制器
 */
- (void)YTSignInServerWithUser:(GIDGoogleUser *)user viewController:(UIViewController *)viewController{
    self.LoginVc = viewController;
    self.userInfo= user;
    // -login servers
    NSDictionary *parameters = @{
                                 @"userId":user.userID,
                                 @"idToken":user.authentication.idToken,
                                 @"fullName":user.profile.name,
                                 @"givenName":user.profile.givenName,
                                 @"familyName":user.profile.familyName,
                                 @"email":user.profile.email,
                                 @"type":LOGIN_TYPE,
                                 };
    
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",SERVER,API_LOGIN];
    entity.needCache = NO;
    entity.parameters = parameters;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        [self loginSuccessWithDic:response];
        
    } failureBlock:^(NSError *error) {
      [self netFailure:error];
    } progressBlock:nil];
    
}


#pragma mark - callback
-(void)loginSuccessWithDic: (NSDictionary *) returnValue{
  
    NSString * code = returnValue[@"code"];
    if ([code isEqualToString:@"0000"]) {
        //save user info
        NSDictionary * info  = @{
                                 @"userId":_userInfo.userID,
                                 @"fullName":_userInfo.profile.name,
                                 @"givenName":_userInfo.profile.givenName,
                                 @"familyName":_userInfo.profile.familyName,
                                 @"email":_userInfo.profile.email,
                                 @"idToken":_userInfo.authentication.idToken,
                                 @"refreshToken":_userInfo.authentication.refreshToken,
                                 @"accessToken":_userInfo.authentication.accessToken,
                                 @"clientID":_userInfo.authentication.clientID,
                                 };
        
        [USER_INFO saveYTLoginInfoWith:info];
        self.returnBlock(returnValue);
        [self.LoginVc dismissViewControllerAnimated:YES completion:nil];

    }else{
        [self errorWithMsg:returnValue[@"message"]];
    }
}


- (void)signInSuccess:(GIDGoogleUser *)user{
    
   
    
}



/**
 对网路异常进行处理
 */
-(void) netFailure:(NSError *)error{
    self.failureBlock(error);
}



/**
 对Error进行处理
 */
-(void)errorWithMsg:(NSString *)errorMsg {
    self.errorBlock(errorMsg);
}


@end
