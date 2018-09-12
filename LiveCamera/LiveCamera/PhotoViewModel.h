//
//  PhotoViewModel.h
//  LiveCamera
//
//  Created by bigfish on 2018/9/10.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "ViewModelClass.h"
@class DeviceModel;
@interface PhotoViewModel : ViewModelClass
/**
获取照片
 */
- (void)snapshot:(NSString *)host token:(NSString *)token;
@end

