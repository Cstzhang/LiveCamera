//
//  DeviceViewCell.h
//  LiveCamera
//
//  Created by bigfish on 2018/8/30.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceListViewModel.h"
@class DeviceModel;
@interface DeviceViewCell : UITableViewCell
- (void)setValueWithDic:(DeviceModel *) model;
- (void)setStatus:(NSString *)status;

@end
