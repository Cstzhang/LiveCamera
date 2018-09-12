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
#import "RootNavigationController.h"
@interface PhotoListViewController ()
@property (strong, nonatomic) PhotoViewModel *photoViewModel;
@property (strong, nonatomic) NSMutableArray *photoArray;
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
     [self searchPhotoAlbum];
}

#pragma mark - 检查是否有新拍的照片
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
    ZBWeak;
    [self.photoViewModel setBlockWithReturnBlock:^(id returnValue) {
        [MBProgressHUD hideHUD];
        [weakSelf searchPhotoAlbum];
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
    }];
    [MBProgressHUD hideHUD];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.photoViewModel snapshot:host token:token];
}


#pragma mark - 搜索指定相册照片
/**
 搜索指定相册照片
 */
- (void)searchPhotoAlbum{
    // 获得相机胶卷的图片
    PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    for (PHAssetCollection *collection in collectionResult1) {
        if (![collection.localizedTitle isEqualToString:title]) continue;
        [self searchAllImagesInCollection:collection];
        break;
    }
}


/**
 * 查询某个相册里面的所有图片
 */
- (void)searchAllImagesInCollection:(PHAssetCollection *)collection{
    // 采取同步获取图片（只获得一次图片）
    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
    imageOptions.synchronous = YES;
    
    NSLog(@"相册名字：%@", collection.localizedTitle);
    
    // 遍历这个相册中的所有图片
    PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    for (PHAsset *asset in assetResult) {
        // 过滤非图片
        if (asset.mediaType != PHAssetMediaTypeImage) continue;
        // 图片原尺寸
        CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        // 请求图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            NSLog(@"图片：%@ %@", result, [NSThread currentThread]);
            [self.photoArray addObject:result];
        }];
    }
}


#pragma mark - lazy func

- (PhotoViewModel *)photoViewModel{
    if (!_photoViewModel) {
        _photoViewModel= [[PhotoViewModel alloc]init];
    }
    return _photoViewModel;
}




@end
