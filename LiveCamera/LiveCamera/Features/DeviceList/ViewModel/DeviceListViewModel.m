//
//  DeviceListViewModel.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/4.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "DeviceListViewModel.h"

@implementation DeviceListViewModel

- (void)fetchDeviceList{
    NSDictionary *params = @{
                             @"placeUserId":USER_INFO.placeUserId
                             };
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",SERVER,API_DEVICELIST];
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
- (void)fetchListSuccessWithDic:(NSDictionary *)returnValue{
    NSString * code = returnValue[@"code"];
    if ([code isEqualToString:@"0000"]) {
        self.returnBlock(returnValue[@"info"]);
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
