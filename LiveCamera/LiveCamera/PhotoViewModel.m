//
//  PhotoViewModel.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/10.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "PhotoViewModel.h"
#import "DeviceModel.h"
@implementation PhotoViewModel
/**
 获取照片
 */
- (void)snapshot:(NSString *)host token:(NSString *)token{
    
    [UserDefaultUtil setObject:token forKey:REQYEST_TOKEN];
    [UserDefaultUtil setObject:HTTPResponse_Http forKey:HTTPResponse_Http];
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@%@",host,QR_SNAPSHOT];
    entity.needCache = NO;
    entity.parameters = nil;
    [ZBNetManager zb_request_GETWithEntity:entity successBlock:^(id response) {
        [self snapshotSuccessWithDic:response];
        [UserDefaultUtil setObject:@"" forKey:HTTPResponse_Http];
    } failureBlock:^(NSError *error) {
        [self netFailure:error];
        [UserDefaultUtil setObject:@"" forKey:HTTPResponse_Http];
    } progressBlock:nil];
    [UserDefaultUtil setObject:@"" forKey:HTTPResponse_Http];
}

/**
 获取照片
 
 @param returnValue 设备列表数据
 */
- (void)snapshotSuccessWithDic:(id)returnValue{
    UIImage *image = [[UIImage alloc] initWithData:returnValue];
    if (image != nil) {
        self.returnBlock(@"success");
        [self save:image];
    }else{
         [self errorWithMsg:@"no photo"];
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


-(void)save:(UIImage *)tmpImage{
    UIImage *oneImage = tmpImage;
    //(1) 获取当前的授权状态
    PHAuthorizationStatus lastStatus = [PHPhotoLibrary authorizationStatus];
    
    //(2) 请求授权
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        //回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(status == PHAuthorizationStatusDenied) //用户拒绝（可能是之前拒绝的，有可能是刚才在系统弹框中选择的拒绝）
            {
                if (lastStatus == PHAuthorizationStatusNotDetermined) {
                    //说明，用户之前没有做决定，在弹出授权框中，选择了拒绝
                    [MBProgressHUD showErrorMessage:@"save fail"];
                    return;
                }
                // 说明，之前用户选择拒绝过，现在又点击保存按钮，说明想要使用该功能，需要提示用户打开授权
                 [MBProgressHUD showInfoMessage:@"Please open access album permissions in system Settings"];
            }
            else if(status == PHAuthorizationStatusAuthorized) //用户允许
            {
                //保存图片---调用上面封装的方法
                [self saveImageToCustomAblum:oneImage];
            }
            else if (status == PHAuthorizationStatusRestricted)
            {
                  [MBProgressHUD showErrorMessage:@"System reason, unable to access album"];
            }
        });
    }];
}

/**将图片保存到自定义相册中*/
-(void)saveImageToCustomAblum:(UIImage *)tmpImage{
      UIImage *oneImage = tmpImage;
    //1 将图片保存到系统的【相机胶卷】中---调用刚才的方法
    PHFetchResult<PHAsset *> *assets = [self syncSaveImageWithPhotos:oneImage];
    if (assets == nil)
    {
         [MBProgressHUD showErrorMessage:@"保存失败"];
        return;
    }
    //2 拥有自定义相册（与 APP 同名，如果没有则创建）--调用刚才的方法
    PHAssetCollection *assetCollection = [self getAssetCollectionWithAppNameAndCreateIfNo];
    if (assetCollection == nil) {
          [MBProgressHUD showErrorMessage:@"相册创建失败"];
        return;
    }
    
    
    //3 将刚才保存到相机胶卷的图片添加到自定义相册中 --- 保存带自定义相册--属于增的操作，需要在PHPhotoLibrary的block中进行
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //--告诉系统，要操作哪个相册
        PHAssetCollectionChangeRequest *collectionChangeRequest = [PHAssetCollectionChangeRequest changeRequestForAssetCollection:assetCollection];
        //--添加图片到自定义相册--追加--就不能成为封面了
        //--[collectionChangeRequest addAssets:assets];
        //--插入图片到自定义相册--插入--可以成为封面
        [collectionChangeRequest insertAssets:assets atIndexes:[NSIndexSet indexSetWithIndex:0]];
    } error:&error];
    
    
    if (error) {
         [MBProgressHUD showErrorMessage:@"save fail"];
        return;
    }
    [MBProgressHUD showSuccessMessage:@"save success"];
}

/**拥有与 APP 同名的自定义相册--如果没有则创建*/
-(PHAssetCollection *)getAssetCollectionWithAppNameAndCreateIfNo
{
    //1 获取以 APP 的名称
    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
    //2 获取与 APP 同名的自定义相册
    PHFetchResult<PHAssetCollection *> *collections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in collections) {
        //遍历
        if ([collection.localizedTitle isEqualToString:title]) {
            //找到了同名的自定义相册--返回
            return collection;
        }
    }
    
    //说明没有找到，需要创建
    NSError *error = nil;
    __block NSString *createID = nil; //用来获取创建好的相册
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //发起了创建新相册的请求，并拿到ID，当前并没有创建成功，待创建成功后，通过 ID 来获取创建好的自定义相册
        PHAssetCollectionChangeRequest *request = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:title];
        createID = request.placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    if (error) {
          [MBProgressHUD showErrorMessage:@"Create  failure"];
        return nil;
    }else{
           [MBProgressHUD showSuccessMessage:@"Create success"];
        //通过 ID 获取创建完成的相册 -- 是一个数组
        return [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[createID] options:nil].firstObject;
    }
    
}

/**同步方式保存图片到系统的相机胶卷中---返回的是当前保存成功后相册图片对象集合*/
-(PHFetchResult<PHAsset *> *)syncSaveImageWithPhotos:(UIImage *)tmpImage{
    UIImage *oneImage = tmpImage;
    //--1 创建 ID 这个参数可以获取到图片保存后的 asset对象
    __block NSString *createdAssetID = nil;
    
    //--2 保存图片
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        //----block 执行的时候还没有保存成功--获取占位图片的 id，通过 id 获取图片---同步
        createdAssetID = [PHAssetChangeRequest          creationRequestForAssetFromImage:oneImage].placeholderForCreatedAsset.localIdentifier;
    } error:&error];
    
    //--3 如果失败，则返回空
    if (error) {
        return nil;
    }
    
    //--4 成功后，返回对象
    //获取保存到系统相册成功后的 asset 对象集合，并返回
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetID] options:nil];
    return assets;
    
}





@end
