//
//  DeviceModel.h
//  LiveCamera
//
//  Created by bigfish on 2018/9/6.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeviceModel : NSObject
@property (nonatomic,strong) NSString *channelCount;
@property (nonatomic,strong) NSString *createTime;
@property (nonatomic,strong) NSString *deviceAccount;
@property (nonatomic,strong) NSString *deviceDescription;
@property (nonatomic,strong) NSString *deviceId;
@property (nonatomic,strong) NSString *deviceIp;
@property (nonatomic,strong) NSString *deviceMac;
@property (nonatomic,strong) NSString *deviceName;
@property (nonatomic,strong) NSString *deviceOnvif;
@property (nonatomic,strong) NSString *devicePn;
@property (nonatomic,strong) NSNumber *devicePort;
@property (nonatomic,strong) NSString *deviceSn;
@property (nonatomic,strong) NSString *deviceSv;
@property (nonatomic,strong) NSString *deviceVersion;
@property (nonatomic,strong) NSString *mfrsName;
@property (nonatomic,strong) NSString *pictureUrl;
@property (nonatomic,strong) NSString *updatePackageUrl;
@property (nonatomic,strong) NSNumber *userId;
@property (nonatomic,assign) BOOL isConnectd;
@end
