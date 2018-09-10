//
//  BondedDeviceViewModel.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/6.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "BondedDeviceViewModel.h"

@implementation BondedDeviceViewModel
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
