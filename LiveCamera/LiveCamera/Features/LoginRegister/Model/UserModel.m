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
-(void)saveYTLoginInfoWith:(id)data{
    _userID       = [data valueForKey:@"userID"];
    _fullName     = [data valueForKey:@"fullName"];
    _givenName    = [data valueForKey:@"givenName"];
    _familyName   = [data valueForKey:@"familyName"];
    _email        = [data valueForKey:@"email"];
    _idToken      = [data valueForKey:@"idToken"];
    _refreshToken = [data valueForKey:@"refreshToken"];
    _accessToken  = [data valueForKey:@"accessToken"];
    _clientID     = [data valueForKey:@"clientID"];
    _isYTSinIn    = !kObjectIsEmpty(_accessToken);
    [UserDefaultUtil setValue:_userID forKey:@"userID"];
    [UserDefaultUtil setValue:_fullName forKey:@"fullName"];
    [UserDefaultUtil setValue:_givenName forKey:@"givenName"];
    [UserDefaultUtil setValue:_familyName forKey:@"familyName"];
    [UserDefaultUtil setValue:_email forKey:@"email"];
    [UserDefaultUtil setValue:_idToken forKey:@"idToken"];
    [UserDefaultUtil setValue:_refreshToken forKey:@"refreshToken"];
    [UserDefaultUtil setValue:_accessToken forKey:@"accessToken"];
    [UserDefaultUtil setValue:_clientID forKey:@"clientID"];
}

/** 注销删除数据 */
-(void)loginOutAndDeleteUsrInfo{
    _userID       = nil;
    _fullName     = nil;
    _givenName    = nil;
    _familyName   = nil;
    _email        = nil;
    _idToken      = nil;
    _refreshToken = nil;
    _accessToken  = nil;
    _clientID     = nil;
    _isYTSinIn    = NO;
    [UserDefaultUtil removeObjectForKey:@"userID"];
    [UserDefaultUtil removeObjectForKey:@"fullName"];
    [UserDefaultUtil removeObjectForKey:@"givenName"];
    [UserDefaultUtil removeObjectForKey:@"familyName"];
    [UserDefaultUtil removeObjectForKey:@"email"];
    [UserDefaultUtil removeObjectForKey:@"idToken"];
    [UserDefaultUtil removeObjectForKey:@"refreshToken"];
    [UserDefaultUtil removeObjectForKey:@"accessToken"];
    [UserDefaultUtil removeObjectForKey:@"clientID"];
    //清除用户cookie
    [UserDefaultUtil removeObjectForKey:SHIRO_COOKIE];
}

/** 重启APP的时候重新给单例的属性赋值 */
-(void)restart{
    _userID       = [UserDefaultUtil valueForKey:@"userID"];
    _fullName     = [UserDefaultUtil valueForKey:@"fullName"];
    _givenName    = [UserDefaultUtil valueForKey:@"givenName"];
    _familyName   = [UserDefaultUtil valueForKey:@"familyName"];
    _email        = [UserDefaultUtil valueForKey:@"email"];
    _idToken      = [UserDefaultUtil valueForKey:@"idToken"];
    _refreshToken = [UserDefaultUtil valueForKey:@"refreshToken"];
    _accessToken  = [UserDefaultUtil valueForKey:@"accessToken"];
    _clientID     = [UserDefaultUtil valueForKey:@"clientID"];
    _isYTSinIn    = !kObjectIsEmpty(_accessToken);
}



@end
