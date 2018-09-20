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
 通知设备绑定信息
 */
- (void)qrBind:(NSString *)host{
    NSDictionary *params = @{
                             @"key":[UserDefaultUtil objectForKey:@"qrKey"],
                             @"app_device_id":[HDeviceIdentifier deviceIdentifier],
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
    NSString *deviceSn = info[@"deviceSn"];
    //截取SN后四位作为deviceName
    NSString *deviceName;
    if (!kObjectIsEmpty(info[@"deviceSn"])){
        NSString *idNum = [deviceSn substringFromIndex:deviceSn.length-4];
        deviceName = [NSString stringWithFormat:@"Device%@",idNum];
    }else{
        deviceName = @"Device0000";
    }
 
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
                             @"deviceName":deviceName,
                             
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
 请求设备列表成功
 
 @param returnValue 设备列表数据
 */
- (void)fetchqrBindSuccessWithDic:(NSDictionary *)returnValue{
    NSNumber * code = returnValue[@"code"];
    if (code.intValue == 0) {
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
    NSNumber * code = returnValue[@"code"];
    if (code.intValue == 0) {
        self.returnBlock(returnValue[@"data"]);
    }else{
        [self errorWithMsg:returnValue[@"desc"]];
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
