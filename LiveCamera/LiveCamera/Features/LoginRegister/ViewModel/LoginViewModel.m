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
@property (strong, nonatomic) FBSDKLoginManager *FBSignIn;

@end

@implementation LoginViewModel

- (void)FBlogin:(UIViewController *)viewController{
    self.LoginVc = viewController;
    [self.FBSignIn logInWithPublishPermissions:@[ @"manage_pages", @"publish_pages"]
                            fromViewController:nil
                                       handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                           if (error) {
                                               NSLog(@"facebook auth failed");
                                           }else if (result.isCancelled) {
                                               NSLog(@"facebook auth canceled");
                                           }else {
                                              
                                             [self FBSignInServerWithResult:result viewController:self.LoginVc];
                                           }
   }];
}

- (void)FBautoLoginWithToken:(FBSDKAccessToken *)token  viewController:(UIViewController *)viewController{
    self.LoginVc = viewController;
    [FBSDKAccessToken setCurrentAccessToken:token];
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil];
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        //token过期，删除存储的token和profile
        if (error) {
            NSLog(@"The user token is no longer valid.");
            NSInteger slot = 0;
            [SUCache deleteItemInSlot:slot];
            [FBSDKAccessToken setCurrentAccessToken:nil];
            [FBSDKProfile setCurrentProfile:nil];
        }
        //做登录完成的操作
        else {
            [self.LoginVc dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

- (void)FBSignInServerWithResult:(FBSDKLoginManagerLoginResult *)result
                  viewController:(UIViewController *)viewController{
    self.result = result;
    self.LoginVc = viewController;
    NSDictionary*params= @{@"fields":@"id,name,email,age_range,first_name,last_name,link,gender,locale,picture,timezone,updated_time,verified,token"};
    
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
                                         @"clientType":LOGIN_TYPE,
                                         @"thirdType":[NSString stringWithFormat:@"%lu",(unsigned long)ThirdTypeFacebook],
                                         @"placeUserId":USER_INFO.placeUserId ?  USER_INFO.placeUserId : @"",
                                         };

            [self loginServer:parameters loginType:ThirdTypeFacebook];
            
            
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
                                 @"clientType":LOGIN_TYPE,
                                 @"thirdType":[NSString stringWithFormat:@"%lu",(unsigned long)ThirdTypeYouTube],
                                 @"placeUserId":USER_INFO.placeUserId ? USER_INFO.placeUserId : @"",
                                 };
    
   
    [self loginServer:parameters loginType:ThirdTypeYouTube];
}

- (void)loginServer:(NSDictionary *)params loginType:(ThirdType)type{
    
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
                     typey:(ThirdType)type
                    params:(NSDictionary *)params{

    NSString * code = returnValue[@"code"];
    if ([code isEqualToString:@"0000"]) {
        NSMutableDictionary * info =[[NSMutableDictionary alloc]init];
        //save user info
        switch (type) {
            case ThirdTypeYouTube:{
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
                                      @"placeUserId":returnValue[@"placeUserId"]
                                      }];
                break;
                
            }
         
            case ThirdTypeFacebook:{
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
                                      @"placeUserId":returnValue[@"placeUserId"]
                                      }];
                   break;
            }
                
        }
      
        
        [USER_INFO saveYTLoginInfoWith:info tpye:type];
        self.returnBlock(returnValue);
        [self.LoginVc dismissViewControllerAnimated:YES completion:nil];

    }else{
        [USER_INFO loginOutAndDeleteUsrInfo];
        [self errorWithMsg:@"Sign fail"];
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

#pragma mark - lazy func
- (FBSDKLoginManager *)FBSignIn{
    if (!_FBSignIn) {
        _FBSignIn = [[FBSDKLoginManager alloc] init];
        _FBSignIn.loginBehavior = FBSDKLoginBehaviorNative;
    }
    return _FBSignIn;
}


@end
