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
@property (strong, nonatomic) FBSDKLoginManagerLoginResult *result;


@end

@implementation LoginViewModel

- (void)FBSignInServerWithResult:(FBSDKLoginManagerLoginResult *)result
                  viewController:(UIViewController *)viewController{
    self.result = result;
    self.LoginVc = viewController;
    NSDictionary*params= @{@"fields":@"id,name,email,age_range,first_name,last_name,link,gender,locale,picture,timezone,updated_time,verified"};
    
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc]
                                  initWithGraphPath:result.token.userID
                                  parameters:params
                                  HTTPMethod:@"GET"];
    ZBWeak;
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                          id result,
                                          NSError *error) {
        if (!error) {
            NSDictionary *parameters = @{
                                         @"userId":weakSelf.result.token.userID,
                                         @"idToken":weakSelf.result.token.tokenString,
                                         @"fullName":result[@"name"],
                                         @"givenName":result[@"first_name"],
                                         @"familyName":result[@"last_name"],
                                         @"email":result[@"email"] ? result[@"email"] : @"" ,
                                         @"type":LOGIN_TYPE,
                                         };

            [self loginServer:parameters loginType:LoginTypeFacebook];
            
            
        }else{
            [self netFailure:error];
        }
        
    }];
    
    
}

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
    
   
    [self loginServer:parameters loginType:LoginTypeYouTube];
}

- (void)loginServer:(NSDictionary *)params loginType:(LoginType)type{
    
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",SERVER,API_LOGIN];
    entity.needCache = NO;
    entity.parameters = params;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        [self loginSuccessWithDic:response typey:type params:(NSDictionary *)params];
    } failureBlock:^(NSError *error) {
        [self netFailure:error];
    } progressBlock:nil];
}


#pragma mark - callback
-(void)loginSuccessWithDic: (NSDictionary *) returnValue
                     typey:(LoginType)type
                    params:(NSDictionary *)params{

    NSString * code = returnValue[@"code"];
    if ([code isEqualToString:@"0000"]) {
        NSMutableDictionary * info =[[NSMutableDictionary alloc]init];
        //save user info
        switch (type) {
            case LoginTypeYouTube:{
                [info setDictionary:@{
                                      @"userId":_userInfo.userID,
                                      @"fullName":_userInfo.profile.name,
                                      @"givenName":_userInfo.profile.givenName,
                                      @"familyName":_userInfo.profile.familyName,
                                      @"email":_userInfo.profile.email,
                                      @"idToken":_userInfo.authentication.idToken,
                                      @"refreshToken":_userInfo.authentication.refreshToken,
                                      @"accessToken":_userInfo.authentication.accessToken,
                                      @"clientID":_userInfo.authentication.clientID,
                                      }];
                
                break;
                
            }
         
            case LoginTypeFacebook:{
                [info setDictionary:@{
                                      @"userId":_result.token.userID,
                                      @"fullName":params[@"fullName"],
                                      @"givenName":params[@"givenName"],
                                      @"familyName":params[@"familyName"],
                                      @"email":params[@"email"] ? params[@"email"]:@"",
                                      @"idToken":_result.token.tokenString,
                                      @"refreshToken":@"",
                                      @"accessToken":@"",
                                      @"clientID":@"",
                                      }];
                   break;
            }
                
        }
      
        
        [USER_INFO saveYTLoginInfoWith:info tpye:type];
        self.returnBlock(returnValue);
        [self.LoginVc dismissViewControllerAnimated:YES completion:nil];

    }else{
        [self errorWithMsg:returnValue[@"message"]];
    }
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
