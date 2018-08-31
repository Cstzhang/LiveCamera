//
//  UserModel.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/3/5.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "UserModel.h"
@implementation UserModel

static UserModel *sharedUserInfoContext = nil;

/** 实例化方法 */
+ (UserModel*)sharedUserInfoContext{
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(sharedUserInfoContext == nil){
            sharedUserInfoContext = [[self alloc] init];
        }
    });
    return sharedUserInfoContext;
}

/**
 *  保存登录的信息
 *  @param data 用户登录成功返回的数据
 */
-(void)saveYTLoginInfoWith:(id)data tpye:(LoginType)type{
    switch (type) {
        case LoginTypeFacebook:
            _FBuserID       = [data valueForKey:@"userID"];
            _FBidToken      = [data valueForKey:@"idToken"];
            [UserDefaultUtil setValue:_FBuserID forKey:@"FBuserID"];
            [UserDefaultUtil setValue:_FBidToken forKey:@"FBidToken"];
            break;
        case LoginTypeYouTube:
            _YTuserID       = [data valueForKey:@"userID"];
            _YTidToken      = [data valueForKey:@"idToken"];
            _YTrefreshToken = [data valueForKey:@"refreshToken"];
            _YTaccessToken  = [data valueForKey:@"accessToken"];
            _YTclientID     = [data valueForKey:@"clientID"];
            [UserDefaultUtil setValue:_YTuserID forKey:@"YTuserID"];
            [UserDefaultUtil setValue:_YTidToken forKey:@"YTidToken"];
            [UserDefaultUtil setValue:_YTrefreshToken forKey:@"YTrefreshToken"];
            [UserDefaultUtil setValue:_YTaccessToken forKey:@"YTaccessToken"];
            [UserDefaultUtil setValue:_YTclientID forKey:@"YTclientID"];
            break;
    }
   
    _fullName     = [data valueForKey:@"fullName"];
    _givenName    = [data valueForKey:@"givenName"];
    _familyName   = [data valueForKey:@"familyName"];
    _email        = [data valueForKey:@"email"];
    
    [UserDefaultUtil setValue:_fullName forKey:@"fullName"];
    [UserDefaultUtil setValue:_givenName forKey:@"givenName"];
    [UserDefaultUtil setValue:_familyName forKey:@"familyName"];
    [UserDefaultUtil setValue:_email forKey:@"email"];
  

}

/** 注销删除数据 */
-(void)loginOutAndDeleteUsrInfo{
    _FBuserID       = nil;
     _YTuserID      = nil;
    _fullName       = nil;
    _givenName      = nil;
    _familyName     = nil;
    _email          = nil;
    _YTidToken      = nil;
    _FBidToken      = nil;
    _YTrefreshToken = nil;
    _YTaccessToken  = nil;
    _YTclientID     = nil;

    [GIDSignIn.sharedInstance signOut];
    
    [UserDefaultUtil removeObjectForKey:@"YTuserID"];
    [UserDefaultUtil removeObjectForKey:@"FBuserID"];
    [UserDefaultUtil removeObjectForKey:@"fullName"];
    [UserDefaultUtil removeObjectForKey:@"givenName"];
    [UserDefaultUtil removeObjectForKey:@"familyName"];
    [UserDefaultUtil removeObjectForKey:@"email"];
    [UserDefaultUtil removeObjectForKey:@"YTidToken"];
    [UserDefaultUtil removeObjectForKey:@"FBidToken"];
    [UserDefaultUtil removeObjectForKey:@"YTrefreshToken"];
    [UserDefaultUtil removeObjectForKey:@"YTaccessToken"];
    [UserDefaultUtil removeObjectForKey:@"YTclientID"];
    //清除用户cookie
    [UserDefaultUtil removeObjectForKey:SHIRO_COOKIE];
}

/** 重启APP的时候重新给单例的属性赋值 */
-(void)restart{
    _YTuserID       = [UserDefaultUtil valueForKey:@"YTuserID"];
    _FBuserID       = [UserDefaultUtil valueForKey:@"FBuserID"];
    _fullName     = [UserDefaultUtil valueForKey:@"fullName"];
    _givenName    = [UserDefaultUtil valueForKey:@"givenName"];
    _familyName   = [UserDefaultUtil valueForKey:@"familyName"];
    _email        = [UserDefaultUtil valueForKey:@"email"];
    _YTidToken      = [UserDefaultUtil valueForKey:@"YTidToken"];
    _FBidToken      = [UserDefaultUtil valueForKey:@"FBidToken"];
    _YTrefreshToken = [UserDefaultUtil valueForKey:@"YTrefreshToken"];
    _YTaccessToken  = [UserDefaultUtil valueForKey:@"YTaccessToken"];
    _YTclientID     = [UserDefaultUtil valueForKey:@"YTclientID"];
}

- (BOOL)isYTLogin{
    return GIDSignIn.sharedInstance.currentUser;
}

- (BOOL)isFBLogin{
    return YES;
}

@end
