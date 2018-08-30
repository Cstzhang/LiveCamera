//
//  UserModel.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/3/5.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject

@property (nonatomic,strong) NSString *userID;

@property (nonatomic,strong) NSString *fullName;

@property (nonatomic,strong) NSString *givenName;

@property (nonatomic,strong) NSString *familyName;

@property (nonatomic,strong) NSString *email;

@property (nonatomic,strong) NSString *idToken;

@property (nonatomic,strong) NSString *refreshToken;

@property (nonatomic,strong) NSString *accessToken;

@property (nonatomic,strong) NSString *clientID;

@property(nonatomic,assign)BOOL  isYTSinIn;
@property(nonatomic,assign)BOOL  isFBSinIn;



/** share方法 */
+ (UserModel*)sharedUserInfoContext;

/** 重启APP的时候重新给单例的属性赋值 */
- (void)restart;

/** 注销删除数据 */
- (void)loginOutAndDeleteUsrInfo;

/**
 *  保存登录的信息
 *  @param data 用户登录成功返回的数据
 */
-(void)saveYTLoginInfoWith:(id)data;


@end
