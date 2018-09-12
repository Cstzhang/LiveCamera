//
//  PhotoListViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/29.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "PhotoListViewController.h"
#import "PhotoViewModel.h"
#import "DeviceModel.h"
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
    NSDictionary *hostDic = [UserDefaultUtil objectForKey:@"HostArray"];
    if (hostDic.count == 0) {
        return;
    }
    for (id key in hostDic) {
        NSString * requst = [hostDic objectForKey:key];
        [self getPhoto:key token:requst];
    }
    

}


#pragma mark - http
//获取摄像头照片 存入相册
/**
get photo
 */
- (void)getPhoto:(NSString *)host token:(NSString *) token{
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
    [self.photoViewModel snapshot:host token:token];
}



- (PhotoViewModel *)photoViewModel{
    if (!_photoViewModel) {
        _photoViewModel= [[PhotoViewModel alloc]init];
    }
    return _photoViewModel;
}


@end
