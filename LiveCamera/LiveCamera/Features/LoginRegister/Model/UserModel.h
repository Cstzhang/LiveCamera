//
//  UserModel.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/3/5.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger,ThirdType){
    ThirdTypeFacebook = 1,
    ThirdTypeYouTube = 2,
};
@interface UserModel : NSObject

@property (nonatomic,strong) NSString *YTuserID;

@property (nonatomic,strong) NSString *FBuserID;

@property (nonatomic,strong) NSString *fullName;

@property (nonatomic,strong) NSString *givenName;

@property (nonatomic,strong) NSString *familyName;

@property (nonatomic,strong) NSString *email;

@property (nonatomic,strong) NSString *YTidToken;//TokenString

@property (nonatomic,strong) NSString *FBidToken;

@property (nonatomic,strong) NSString *YTrefreshToken;

@property (nonatomic,strong) NSString *YTaccessToken;

@property (nonatomic,strong) NSString *YTclientID;

@property (nonatomic,strong) NSString *placeUserId;


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
-(void)saveYTLoginInfoWith:(id)data tpye:(ThirdType)type;


- (BOOL)isYTLogin;

- (BOOL)isFBLogin;
- (BOOL)isLogin;

@end
