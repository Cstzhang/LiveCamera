//
//  PhotoListViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/29.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "PhotoListViewController.h"
#import "PhotoViewModel.h"
@interface PhotoListViewController ()
@property (strong, nonatomic) PhotoViewModel *photoViewModel;
@end

@implementation PhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.title  = @"Photo Album";
}

- (void)viewWillAppear:(BOOL)animated{
     [super viewWillAppear:animated];
     [self checkPhoto];
}

- (void)checkPhoto{
    NSArray *hostArray = [UserDefaultUtil objectForKey:@"HostArray"];
    if (hostArray.count == 0) {
        return;
    }
    for (NSString *host in hostArray) {
        [self udpateDevice:host];
    }
}


#pragma mark - http
//获取摄像头照片 存入相册
/**
 升级设备
 */
- (void)udpateDevice:(NSString *)host{
    if (![USER_INFO isLogin]) {
        return;
    }
    [self.photoViewModel setBlockWithReturnBlock:^(id returnValue) {
        [MBProgressHUD hideHUD];

    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
    }];
    [MBProgressHUD hideHUD];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.photoViewModel snapshot:host];
}



- (PhotoViewModel *)photoViewModel{
    if (!_photoViewModel) {
        _photoViewModel= [[PhotoViewModel alloc]init];
    }
    return _photoViewModel;
}


@end
