//
//  PhotoViewModel.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/10.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "PhotoViewModel.h"

@implementation PhotoViewModel
/**
 获取照片
 */
- (void)snapshot:(NSString *)host{
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",host,QR_SNAPSHOT];
    entity.needCache = NO;
    entity.parameters = nil;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        [self snapshotSuccessWithDic:response];
    } failureBlock:^(NSError *error) {
        [self netFailure:error];
    } progressBlock:nil];
    
    
}

/**
 获取照片
 
 @param returnValue 设备列表数据
 */
- (void)snapshotSuccessWithDic:(NSDictionary *)returnValue{
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
- (void)netFailure:(NSError *)error{
    self.failureBlock(error);
}



/**
 对Error进行处理
 */
- (void)errorWithMsg:(NSString *)errorMsg {
    self.errorBlock(errorMsg);
}

@end
