//
//  PhotoListViewController.h
//  LiveCamera
//
//  Created by bigfish on 2018/8/29.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewModel.h"
#import "DeviceModel.h"
#import "RootNavigationController.h"
#import "LGPhotoAssets.h"
#import "LGPhoto.h"
#import "LGPhotoPickerCollectionView.h"
#import "LGPhotoPickerGroup.h"
#import "LGPhotoPickerCollectionViewCell.h"
#import "LGPhotoPickerFooterCollectionReusableView.h"

@interface PhotoListViewController : QMUICommonViewController

@property (assign, nonatomic) NSInteger maxCount;

@property (copy, nonatomic) NSArray *selectPickerAssets;

@property (nonatomic) LGPhotoPickerGroup *assetsGroup;
@end
