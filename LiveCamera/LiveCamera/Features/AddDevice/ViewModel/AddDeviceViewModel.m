//
//  AddDeviceViewModel.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/6.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "AddDeviceViewModel.h"

@implementation AddDeviceViewModel


/**
 升级
 */
- (void)qrupgrade:(NSString *)host
        udpateUrl:(NSString *)udpateUrl
          version:(NSString *)version{
    NSDictionary *params = @{
                             @"server":udpateUrl,
                             @"version" : version,
                             };
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",host,QR_UP_GRADE];
    entity.needCache = NO;
    entity.parameters = params;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        [self upgradeSuccessWithDic:response];
    } failureBlock:^(NSError *error) {
        [self netFailure:error];
    } progressBlock:nil];
    
    
}


/**
检查升级
 
 */
- (void)qrcheckVersion:(NSString *)host udpateUrl:(NSString *)udpateUrl{
    
    NSDictionary *params = @{
                             @"server":udpateUrl,
                             };
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",host,QR_CHECK_VERSION];
    entity.needCache = NO;
    entity.parameters = params;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        [self checkVersionSuccessWithDic:response];
    } failureBlock:^(NSError *error) {
        [self netFailure:error];
    } progressBlock:nil];
    
}
/**
 通知设备绑定信息
 */
- (void)qrBind:(NSString *)host{
    NSDictionary *params = @{
                             @"key":[UserDefaultUtil objectForKey:@"qrKey"],
                             @"app_device_id":host,
                             };
    NSLog(@" qrBind  params %@ ",params);
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",host,QR_BIND];
    entity.needCache = NO;
    entity.parameters = params;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        [self fetchqrBindSuccessWithDic:response];
    } failureBlock:^(NSError *error) {
        [self netFailure:error];
    } progressBlock:nil];
}

/**
 绑定设备

 */
- (void)BondedDevice:(NSDictionary *)info{
    
    NSDictionary *params = @{
                             @"placeUserId":USER_INFO.placeUserId,
                             @"deviceSn":info[@"deviceSn"] ? info[@"deviceSn"]:@"",
                             @"deviceId":info[@"deviceSn"] ? info[@"deviceSn"]:@"",
                             @"deviceIp":info[@"deviceIp"] ? info[@"deviceIp"]:@"",
                             @"devicePort":info[@"devicePort"] ? info[@"devicePort"]:@"",
                             @"deviceAccount":info[@"deviceAccount"] ? info[@"deviceAccount"]:@"",
                             @"devicePassword":info[@"devicePassword"] ? info[@"devicePassword"]:@"",
                             @"deviceSv":info[@"deviceSv"] ? info[@"deviceSv"]:@"",
                             @"deviceOnvif":info[@"deviceOnvif"] ? info[@"deviceOnvif"]:@"",
                             @"devicePn":info[@"devicePn"] ? info[@"devicePn"]:@"",
                             @"devicePn":info[@"deviceSn"] ? info[@"deviceSn"]:@"",
                             };
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",SERVER,API_BIND_DEVICE];
    entity.needCache = NO;
    entity.parameters = params;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        [self fetchListSuccessWithDic:response];
    } failureBlock:^(NSError *error) {
        [self netFailure:error];
    } progressBlock:nil];
}



/**
 升级
 
 @param returnValue 设备列表数据
 */
- (void)upgradeSuccessWithDic:(NSDictionary *)returnValue{
    NSString * code = returnValue[@"code"];
    if ([code isEqualToString:@"0"]) {
        self.returnBlock(returnValue[@"data"]);
    }else{
        [self errorWithMsg:returnValue[@"desc"]];
    }
    
    
}


/**
判断升级
 
 @param returnValue 设备列表数据
 */
- (void)checkVersionSuccessWithDic:(NSDictionary *)returnValue{
    NSString * code = returnValue[@"code"];
    if ([code isEqualToString:@"0"]) {
        self.returnBlock(returnValue[@"data"]);
    }else{
        [self errorWithMsg:returnValue[@"desc"]];
    }
    
    
}

/**
 请求设备列表成功
 
 @param returnValue 设备列表数据
 */
- (void)fetchqrBindSuccessWithDic:(NSDictionary *)returnValue{
    NSString * code = returnValue[@"code"];
    if ([code isEqualToString:@"0"]) {
        self.returnBlock(returnValue[@"data"]);
    }else{
        [self errorWithMsg:returnValue[@"desc"]];
    }
    
    
}

/**
 绑定成功
 
 @param returnValue 设备列表数据
 */
- (void)fetchListSuccessWithDic:(NSDictionary *)returnValue{
    NSString * code = returnValue[@"code"];
    if ([code isEqualToString:@"0000"]) {
        self.returnBlock(returnValue[@"info"]);
    }else{
        [self errorWithMsg:@"Bind device failed"];
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
