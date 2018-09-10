//
//  AddDeviceViewModel.h
//  LiveCamera
//
//  Created by bigfish on 2018/9/6.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "ViewModelClass.h"

@interface AddDeviceViewModel : ViewModelClass


/**
  绑定设备

 @param info 设备信息
 */
- (void)BondedDevice:(NSDictionary *)info;


/**
 通知设备绑定信息
 */
- (void)qrBind:(NSString *)host;




@end
