//
//  BondedDeviceViewModel.h
//  LiveCamera
//
//  Created by bigfish on 2018/9/6.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "ViewModelClass.h"

@interface BondedDeviceViewModel : ViewModelClass



/**
 检查升级
 */
- (void)qrcheckVersion:(NSString *)host
             udpateUrl:(NSString *)udpateUrl;


/**
 升级
 */
- (void)qrupgrade:(NSString *)host
        udpateUrl:(NSString *)udpateUrl
          version:(NSString *)version;



@end
