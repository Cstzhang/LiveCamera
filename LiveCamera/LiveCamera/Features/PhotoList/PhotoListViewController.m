//
//  PhotoListViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/29.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "PhotoListViewController.h"



#pragma clang diagnostic ignored "-Wprotocol"
static CGFloat CELL_ROW = 4;
static CGFloat CELL_MARGIN = 2;
static CGFloat CELL_LINE_MARGIN = 2;
static CGFloat TOOLBAR_HEIGHT = 44;
static NSString *const _cellIdentifier = @"cell";
static NSString *const _footerIdentifier = @"FooterView";
static NSString *const _identifier = @"toolBarThumbCollectionViewCell";

//@interface LGPhotoPickerCollectionView:UICollectionView<UICollectionViewDelegate>
//
//// scrollView滚动的升序降序
//@property (nonatomic, assign) LGPickerCollectionViewShowOrderStatus status;
//// 保存所有的数据
//@property (nonatomic) NSArray<__kindof LGPhotoAssets*> *dataArray;
//// 保存选中的图片
//@property (nonatomic) NSMutableArray<__kindof LGPhotoAssets*> *selectAssets;
//// 最后保存的一次图片
//@property (nonatomic) NSMutableArray *lastDataArray;
//// 限制最大数
//@property (nonatomic, assign) NSInteger maxCount;
//// 置顶展示图片
//@property (nonatomic, assign) BOOL topShowPhotoPicker;
//// 记录选中的值
//@property (nonatomic, assign) BOOL isRecoderSelectPicker;
//
//@end

@interface PhotoListViewController ()<LGPhotoPickerCollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, assign) NSUInteger privateTempMaxCount;
@property (nonatomic) NSMutableArray *assets;
@property (nonatomic) NSMutableArray<__kindof LGPhotoAssets*> *selectAssets;
@property (strong, nonatomic) NSMutableArray *takePhotoImages;

// 1 - 相册浏览器的数据源是 selectAssets， 0 - 相册浏览器的数据源是 assets
@property (nonatomic, assign) BOOL isPreview;
// 是否发送原图
@property (nonatomic, assign) BOOL isOriginal;

@property (strong, nonatomic) PhotoViewModel *photoViewModel;
@property (strong, nonatomic) NSMutableArray *photoArray;
@property (nonatomic) LGPhotoPickerCollectionView *collectionView;
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
     self.maxCount = 1;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.collectionView.selectAssets = [NSMutableArray arrayWithArray:self.selectAssets];
    self.collectionView.maxCount = self.maxCount;
}



-(void)initSubviews{
    [super initSubviews];
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
        [weakSelf setupAssets];
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
        [weakSelf setupAssets];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [weakSelf setupAssets];
    }];
    [MBProgressHUD hideHUD];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.photoViewModel snapshot:host token:token];
}






#pragma mark - 搜索指定相册照片
///**
// 搜索指定相册照片
// */
//- (void)searchPhotoAlbum{
//    // 获得相机胶卷的图片
//    PHFetchResult<PHAssetCollection *> *collectionResult1 = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
//    NSString *title = [NSBundle mainBundle].infoDictionary[(__bridge NSString *)kCFBundleNameKey];
//    for (PHAssetCollection *collection in collectionResult1) {
//        if (![collection.localizedTitle isEqualToString:title]) continue;
//        [self searchAllImagesInCollection:collection];
//        break;
//    }
//}
//
//
///**
// * 查询某个相册里面的所有图片
// */
//- (void)searchAllImagesInCollection:(PHAssetCollection *)collection{
//    // 采取同步获取图片（只获得一次图片）
//    PHImageRequestOptions *imageOptions = [[PHImageRequestOptions alloc] init];
//    imageOptions.synchronous = YES;
//
//    NSLog(@"相册名字：%@", collection.localizedTitle);
//
//    // 遍历这个相册中的所有图片
//    PHFetchResult<PHAsset *> *assetResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
//    for (PHAsset *asset in assetResult) {
//        // 过滤非图片
//        if (asset.mediaType != PHAssetMediaTypeImage) continue;
//        // 图片原尺寸
//        CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
//        // 请求图片
//        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageOptions resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
//            NSLog(@"图片：%@ %@", result, [NSThread currentThread]);
//            [self.photoArray addObject:result];
//        }];
//    }
//}






#pragma mark - lazy func
- (LGPhotoPickerCollectionView *)collectionView {
    if (!_collectionView) {
        
        CGFloat cellW = (self.view.frame.size.width - CELL_MARGIN * CELL_ROW + 1) / CELL_ROW;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(cellW, cellW);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = CELL_LINE_MARGIN;
        layout.footerReferenceSize = CGSizeMake(self.view.frame.size.width, TOOLBAR_HEIGHT * 2);
        
        LGPhotoPickerCollectionView *collectionView = [[LGPhotoPickerCollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        // 时间置顶
        collectionView.status = LGPickerCollectionViewShowOrderStatusTimeDesc;
        collectionView.translatesAutoresizingMaskIntoConstraints = NO;
        collectionView.maxCount = 9;
        [collectionView registerClass:[LGPhotoPickerCollectionViewCell class] forCellWithReuseIdentifier:_cellIdentifier];
        // 底部的View
        [collectionView registerClass:[LGPhotoPickerFooterCollectionReusableView class]  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:_footerIdentifier];
        collectionView.contentInset = UIEdgeInsetsMake(5, 0,TOOLBAR_HEIGHT, 0);
        collectionView.collectionViewDelegate = self;
        [self.view addSubview:_collectionView = collectionView];
        collectionView.frame = self.view.bounds;
    }
    return _collectionView;
}
- (PhotoViewModel *)photoViewModel{
    if (!_photoViewModel) {
        _photoViewModel= [[PhotoViewModel alloc]init];
    }
    return _photoViewModel;
}

- (NSMutableArray *)selectAssets {
    if (!_selectAssets) {
        _selectAssets = [NSMutableArray array];
    }
    return _selectAssets;
}

- (NSMutableArray *)takePhotoImages {
    if (!_takePhotoImages) {
        _takePhotoImages = [NSMutableArray array];
    }
    return _takePhotoImages;
}
- (void)setAssetsGroup:(LGPhotoPickerGroup *)assetsGroup {
    if (!assetsGroup.groupName.length) return ;
    
    _assetsGroup = assetsGroup;
    
    self.title = assetsGroup.groupName;
    
    // 获取Assets
    //    [self setupAssets];
}
- (void)setMaxCount:(NSInteger)maxCount {
    _maxCount = maxCount;
    
    if (!_privateTempMaxCount) {
        _privateTempMaxCount = maxCount;
    }
    
    if (self.selectAssets.count == maxCount) {
        maxCount = 0;
    }else if (self.selectPickerAssets.count - self.selectAssets.count > 0) {
        maxCount = _privateTempMaxCount;
    }
    
    self.collectionView.maxCount = maxCount;
}
- (void)setSelectPickerAssets:(NSArray *)selectPickerAssets {
    NSSet *set = [NSSet setWithArray:selectPickerAssets];
    _selectPickerAssets = [set allObjects];
    
    if (!self.assets) {
        self.assets = [NSMutableArray arrayWithArray:selectPickerAssets];
    }else{
        [self.assets addObjectsFromArray:selectPickerAssets];
    }
    
    self.selectAssets = [selectPickerAssets mutableCopy];
    self.collectionView.lastDataArray = nil;
    self.collectionView.isRecoderSelectPicker = YES;
    self.collectionView.selectAssets = self.selectAssets;
  //  NSInteger count = self.selectAssets.count;
//    self.makeView.hidden = !count;
//    self.makeView.text = [NSString stringWithFormat:@"%ld",(long)count];
//    self.sendBtn.enabled = (count > 0);
//    self.previewBtn.enabled = (count > 0);
//
//    [self updateToolbar];
}

//- (void)setTopShowPhotoPicker:(BOOL)topShowPhotoPicker {
//    _topShowPhotoPicker = topShowPhotoPicker;
//
//    if (self.topShowPhotoPicker == YES) {
//        NSMutableArray *reSortArray= [[NSMutableArray alloc] init];
//        for (id obj in [self.collectionView.dataArray reverseObjectEnumerator]) {
//            [reSortArray addObject:obj];
//        }
//
//        LGPhotoAssets *lgAsset = [[LGPhotoAssets alloc] init];
//        [reSortArray insertObject:lgAsset atIndex:0];
//
//        self.collectionView.status = LGPickerCollectionViewShowOrderStatusTimeAsc;
//        self.collectionView.topShowPhotoPicker = topShowPhotoPicker;
//        self.collectionView.dataArray = reSortArray;
//        [self.collectionView reloadData];
//    }
//}
#pragma mark - dealloc

- (void)dealloc {
    
}

#pragma mark 初始化组内图片

- (void) setupAssets {
    if (!self.assets) {
        self.assets = [NSMutableArray array];
    }
    
    __block NSMutableArray *assetsM = [NSMutableArray array];
    __weak typeof(self) weakSelf = self;
    LGPhotoPickerDatas *datas = [LGPhotoPickerDatas defaultPicker];
    // 获取所有的图片URLs
    [datas getAllGroupWithPhotos:^(NSArray *groups) {
        weakSelf.assetsGroup = [[groups reverseObjectEnumerator] allObjects][0];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [[LGPhotoPickerDatas defaultPicker] getGroupPhotosWithGroup:self.assetsGroup finished:^(NSArray *assets) {
            
            [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
                LGPhotoAssets *lgAsset = [[LGPhotoAssets alloc] init];
                lgAsset.asset = asset;
                [assetsM addObject:lgAsset];
            }];
            weakSelf.collectionView.dataArray = assetsM;
            [self.assets setArray:assetsM];
        }];
        
        [self.collectionView reloadData];
    });
}

#pragma mark - LGPhotoPickerCollectionViewDelegate



//cell的右上角选择框被点击会调用
- (void) pickerCollectionViewDidSelected:(LGPhotoPickerCollectionView *) pickerCollectionView deleteAsset:(LGPhotoAssets *)deleteAssets {
    
    if (self.selectPickerAssets.count == 0){
        self.selectAssets = [NSMutableArray arrayWithArray:pickerCollectionView.selectAssets];
    } else if (deleteAssets == nil) {
        [self.selectAssets addObject:[pickerCollectionView.selectAssets lastObject]];
    } else if(deleteAssets) { //取消所选的照片
        //根据url删除对象
        NSArray *arr = [self.selectAssets copy];
        for (LGPhotoAssets *selectAsset in arr) {
            if ([selectAsset.assetURL isEqual:deleteAssets.assetURL]) {
                [self.selectAssets removeObject:selectAsset];
            }
        }
    }
    

}


#pragma mark - UICollectionViewDataSource
- (NSInteger) numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger) collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.selectAssets.count;
}


- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:_identifier forIndexPath:indexPath];
    
    if (self.selectAssets.count > indexPath.item) {
        UIImageView *imageView = [[cell.contentView subviews] lastObject];
        // 判断真实类型
        if (![imageView isKindOfClass:[UIImageView class]]) {
            imageView = [[UIImageView alloc] initWithFrame:cell.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            imageView.clipsToBounds = YES;
            [cell.contentView addSubview:imageView];
        }
        imageView.tag = indexPath.item;
        if ([self.selectAssets[indexPath.item] isKindOfClass:[LGPhotoAssets class]]) {
            imageView.image = [self.selectAssets[indexPath.item] thumbImage];
        }else if ([self.selectAssets[indexPath.item] isKindOfClass:[UIImage class]]){
            imageView.image = (UIImage *)self.selectAssets[indexPath.item];
        }
    }
    
    return cell;
}











@end
