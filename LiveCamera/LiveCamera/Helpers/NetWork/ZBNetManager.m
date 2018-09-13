 //
//  ZBNetManager.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/3/1.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "ZBNetManager.h"
#import <AVFoundation/AVAsset.h>
#import <AVFoundation/AVAssetExportSession.h>
#import <AVFoundation/AVMediaFormat.h>
/*! 系统相册 */
#import <Photos/Photos.h>

#import "UIImage+CompressImage.h"
#import "ZBNetManagerCache.h"
#import "ZBDataEntity.h"

static NSMutableArray *tasks;

@interface ZBNetManager ()

@property(nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end

@implementation ZBNetManager

+ (instancetype)sharedZBNetManager
{
    /*! 为单例对象创建的静态实例，置为nil，因为对象的唯一性，必须是static类型 */
    static id sharedZBNetManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedZBNetManager = [[super allocWithZone:NULL] init];
    });
    return sharedZBNetManager;
}

+ (void)initialize
{
    [self setupZBNetManager];
}

/**
 监测网络的可链接性
 
 @param strUrl URL地址
 @return 是否可达
 */
+(BOOL)netWorkReachabilityWithURLString:(NSString *) strUrl {
    __block BOOL netState = YES;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
            case AFNetworkReachabilityStatusUnknown:
                netState = NO;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
            case AFNetworkReachabilityStatusReachableViaWWAN:
                netState = YES;
                break;
                
            default:
                break;
        }
        DSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
    }];
    
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    return netState;
}


+ (void)setupZBNetManager
{
    ZBNetManagerShare.sessionManager = [AFHTTPSessionManager manager];
    
    ZBNetManagerShare.requestSerializer = ZBHttpRequestSerializerJSON;
    ZBNetManagerShare.responseSerializer = ZBHttpResponseSerializerJSON;
    /*! 设置请求超时时间，默认：15秒 */
    ZBNetManagerShare.timeoutInterval = 15;
    /*! 打开状态栏的等待菊花 */
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;

    //如果cookie里面有值，就插入
    if ([UserDefaultUtil valueForKey:SHIRO_COOKIE]) {
        [ZBNetManagerShare.sessionManager.requestSerializer
         setValue:[UserDefaultUtil valueForKey:SHIRO_COOKIE] forHTTPHeaderField:@"Cookie"];
    }
    if ([UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]) {
        NSString *authValue = [NSString stringWithFormat:@"Bearer %@", [UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]];
        
        [ZBNetManagerShare.sessionManager.requestSerializer setValue: authValue forHTTPHeaderField:@"Authorization"];
    }
    if ([UserDefaultUtil valueForKey:REQYEST_TOKEN]) {
        [ZBNetManagerShare.sessionManager.requestSerializer setValue: [UserDefaultUtil valueForKey:REQYEST_TOKEN] forHTTPHeaderField:@"RequestToken"];
    }
//
    /*! 复杂的参数类型 需要使用json传值-设置请求内容的类型*/
 

    /*! 设置响应数据的基本类型 */
    ZBNetManagerShare.sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/css", @"text/xml", @"text/plain", @"application/javascript", @"application/x-www-form-urlencoded", @"image/*",@"image/jpeg", nil];
    
    // 配置自建证书的Https请求
    [self zb_setupSecurityPolicy];
}

+ (void)saveCookie {
    NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
    
    for (NSHTTPCookie *cookie in cookies){
        if ([cookie.name isEqualToString:SHIRO_COOKIE]) {
            [UserDefaultUtil setObject:[NSString stringWithFormat:@"%@=%@",SHIRO_COOKIE,cookie.value] forKey:SHIRO_COOKIE];
        }
    }
}
/**
 配置自建证书的Https请求，只需要将CA证书文件放入根目录就行
 */
+ (void)zb_setupSecurityPolicy
{
    //    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
    
    if (cerSet.count == 0)
    {
        /*!
         采用默认的defaultPolicy就可以了. AFN默认的securityPolicy就是它, 不必另写代码. AFSecurityPolicy类中会调用苹果security.framework的机制去自行验证本次请求服务端放回的证书是否是经过正规签名.
         */
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
        securityPolicy.allowInvalidCertificates = YES;
        securityPolicy.validatesDomainName = NO;
        ZBNetManagerShare.sessionManager.securityPolicy = securityPolicy;
    }
    else
    {
        /*! 自定义的CA证书配置如下： */
        /*! 自定义security policy, 先前确保你的自定义CA证书已放入工程Bundle */
        /*!
         https://api.github.com网址的证书实际上是正规CADigiCert签发的, 这里把Charles的CA根证书导入系统并设为信任后, 把Charles设为该网址的SSL Proxy (相当于"中间人"), 这样通过代理访问服务器返回将是由Charles伪CA签发的证书.
         */
        // 使用证书验证模式
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
        // 如果需要验证自建证书(无效证书)，需要设置为YES
        securityPolicy.allowInvalidCertificates = YES;
        // 是否需要验证域名，默认为YES
        //    securityPolicy.pinnedCertificates = [[NSSet alloc] initWithObjects:cerData, nil];
        
        ZBNetManagerShare.sessionManager.securityPolicy = securityPolicy;
        
        
        /*! 如果服务端使用的是正规CA签发的证书, 那么以下几行就可去掉: */
        //            NSSet <NSData *> *cerSet = [AFSecurityPolicy certificatesInBundle:[NSBundle mainBundle]];
        //            AFSecurityPolicy *policy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate withPinnedCertificates:cerSet];
        //            policy.allowInvalidCertificates = YES;
        //            ZBNetManagerShare.sessionManager.securityPolicy = policy;
    }
}

#pragma mark - 网络请求的类方法 --- get / post / put / delete
/*!
 *  网络请求的实例方法
 *
 *  @param type         get / post / put / delete
 *  @param isNeedCache  是否需要缓存，只有 get / post 请求有缓存配置
 *  @param urlString    请求的地址
 *  @param parameters    请求的参数
 *  @param successBlock 请求成功的回调
 *  @param failureBlock 请求失败的回调
 *  @param progressBlock 进度
 */
+ (ZBURLSessionTask *)zb_requestWithType:(ZBHttpRequestType)type
                             isNeedCache:(BOOL)isNeedCache
                               urlString:(NSString *)urlString
                              parameters:(id)parameters
                            successBlock:(ZBResponseSuccessBlock)successBlock
                            failureBlock:(ZBResponseFailBlock)failureBlock
                           progressBlock:(ZBDownloadProgressBlock)progressBlock{
    if (urlString == nil)
    {
        return nil;
    }
    
    ZBWeak;
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:urlString] ? urlString : [self strUTF8Encoding:urlString];
    //设置请求头
    ZBNetManagerShare.requestSerializer = ZBHttpRequestSerializerJSON;
    ZBNetManagerShare.responseSerializer = ZBHttpResponseSerializerJSON;
    NSString *requestType;
    switch (type) {
        case 0:
            requestType = @"GET";
            break;
        case 1:
            requestType = @"POST";
            break;
        case 2:
            requestType = @"PUT";
            break;
        case 3:
            requestType = @"DELETE";
            break;

        default:
            break;
    }
    if ([UserDefaultUtil valueForKey:SHIRO_COOKIE]) {
        [ZBNetManagerShare.sessionManager.requestSerializer
         setValue:[UserDefaultUtil valueForKey:SHIRO_COOKIE] forHTTPHeaderField:@"Cookie"];
    }
  
    if ([UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]) {
        //  NSLog(@"[UserDefaultUtil valueForKey:YT_ACCESS_TOKEN] %@",[UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]);
        NSString *authValue = [NSString stringWithFormat:@"Bearer %@", [UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]];
        
        [ZBNetManagerShare.sessionManager.requestSerializer setValue: authValue forHTTPHeaderField:@"Authorization"];
    }
    if ([UserDefaultUtil valueForKey:REQYEST_TOKEN]) {
         // NSLog(@"[UserDefaultUtil valueForKey:REQYEST_TOKEN] %@",[UserDefaultUtil valueForKey:REQYEST_TOKEN]);
        [ZBNetManagerShare.sessionManager.requestSerializer setValue: [UserDefaultUtil valueForKey:REQYEST_TOKEN] forHTTPHeaderField:@"RequestToken"];
    
        
    }
    NSString * tempStr = [UserDefaultUtil valueForKey:HTTPResponse_Http];
    if (tempStr.length != 0) {
        ZBNetManagerShare.responseSerializer = ZBHttpResponseSerializerHTTP;
    }else{
        ZBNetManagerShare.responseSerializer = ZBHttpResponseSerializerJSON;
    }
    
//    AFHTTPSessionManager *scc = ZBNetManagerShare.sessionManager;
//        AFHTTPResponseSerializer *scc2 = scc.responseSerializer;
//        AFHTTPRequestSerializer *scc3 = scc.requestSerializer;
//        NSTimeInterval timeoutInterval = ZBNetManagerShare.timeoutInterval;
//    //
//        NSString *isCache = isNeedCache ? @"开启":@"关闭";
//        CGFloat allCacheSize = [ZBNetManagerCache zb_getAllHttpCacheSize];
//
//        DSLog(@"\n******************** 请求参数 ***************************");
//        DSLog(@"\n请求头: %@\n超时时间设置：%.1f 秒【默认：30秒】\nAFHTTPResponseSerializer：%@【默认：AFJSONResponseSerializer】\nAFHTTPRequestSerializer：%@【默认：AFJSONRequestSerializer】\n请求方式: %@\n请求URL: %@\n请求param: %@\n是否启用缓存：%@【默认：开启】\n目前总缓存大小：%.6fM\n", ZBNetManagerShare.sessionManager.requestSerializer.HTTPRequestHeaders, timeoutInterval, scc2, scc3, requestType, URLString, parameters, isCache, allCacheSize);
//        DSLog(@"\n********************************************************");
  
    ZBURLSessionTask *sessionTask = nil;
    // 读取缓存
    id responseCacheData = [ZBNetManagerCache zb_httpCacheWithUrlString:urlString parameters:parameters];
    
    if (isNeedCache && responseCacheData != nil)
    {
        if (successBlock)
        {
            successBlock(responseCacheData);
        }
//        DSLog(@"取用缓存数据结果： *** %@", responseCacheData);
        
        [[weakSelf tasks] removeObject:sessionTask];
        return nil;
    }
    
    if (type == ZBHttpRequestTypeGet)
    {
        sessionTask = [ZBNetManagerShare.sessionManager GET:URLString parameters:parameters  progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (successBlock)
            {
                successBlock(responseObject);
            }
            // 对数据进行异步缓存
            [ZBNetManagerCache zb_setHttpCache:responseObject urlString:urlString parameters:parameters];
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
    }
    else if (type == ZBHttpRequestTypePost)
    {
        sessionTask = [ZBNetManagerShare.sessionManager POST:URLString parameters:parameters progress:^(NSProgress * _Nonnull uploadProgress) {
//            DSLog(@"上传进度--%lld, 总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
            
            /*! 回到主线程刷新UI */
            dispatch_async(dispatch_get_main_queue(), ^{
                if (progressBlock)
                {
                    progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
                }
            });
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

            [self saveCookie];
            
            if (successBlock)
            {
                successBlock(responseObject);
            }
            // 对数据进行异步缓存
            [ZBNetManagerCache zb_setHttpCache:responseObject urlString:urlString parameters:parameters];
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            DSLog(@"错误信息：%@",error);
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
    }
    else if (type == ZBHttpRequestTypePut)
    {
        sessionTask = [ZBNetManagerShare.sessionManager PUT:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            if (successBlock)
            {
                successBlock(responseObject);
            }
            
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
    }
    else if (type == ZBHttpRequestTypeDelete)
    {
        sessionTask = [ZBNetManagerShare.sessionManager DELETE:URLString parameters:parameters success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if (successBlock)
            {
                successBlock(responseObject);
            }
            
            [[weakSelf tasks] removeObject:sessionTask];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            if (failureBlock)
            {
                failureBlock(error);
            }
            [[weakSelf tasks] removeObject:sessionTask];
            
        }];
    }
    
    if (sessionTask)
    {
        [[weakSelf tasks] addObject:sessionTask];
    }
    
    return sessionTask;
}

#pragma mark - 网络请求的类方法 + Entity --- get / post / put / delete

/**
 网络请求的实例方法 get
 
 @param entity 请求信息载体
 @param successBlock 请求成功的回调
 @param failureBlock 请求失败的回调
 @param progressBlock 进度回调
 @return ZBURLSessionTask
 */
+ (ZBURLSessionTask *)zb_request_GETWithEntity:(ZBDataEntity *)entity
                                  successBlock:(ZBResponseSuccessBlock)successBlock
                                  failureBlock:(ZBResponseFailBlock)failureBlock
                                 progressBlock:(ZBDownloadProgressBlock)progressBlock{
    if (!entity || ![entity isKindOfClass:[ZBDataEntity class]]) {
        return nil;
    }
    return [self zb_requestWithType:ZBHttpRequestTypeGet
                        isNeedCache:entity.isNeedCache
                          urlString:entity.urlString
                         parameters:entity.parameters
                       successBlock:successBlock
                       failureBlock:failureBlock
                      progressBlock:progressBlock];
}

/**
 网络请求的实例方法 post
 
 @param entity 请求信息载体
 @param successBlock 请求成功的回调
 @param failureBlock 请求失败的回调
 @param progressBlock 进度
 @return ZBURLSessionTask
 */
+ (ZBURLSessionTask *)zb_request_POSTWithEntity:(ZBDataEntity *)entity
                                   successBlock:(ZBResponseSuccessBlock)successBlock
                                   failureBlock:(ZBResponseFailBlock)failureBlock
                                  progressBlock:(ZBDownloadProgressBlock)progressBlock{
    if (!entity || ![entity isKindOfClass:[ZBDataEntity class]]) {
        return nil;
    }
    return [self zb_requestWithType:ZBHttpRequestTypePost
                        isNeedCache:entity.isNeedCache
                          urlString:entity.urlString
                         parameters:entity.parameters
                       successBlock:successBlock
                       failureBlock:failureBlock
                      progressBlock:progressBlock];
}

/**
 网络请求的实例方法 put
 
 @param entity 请求信息载体
 @param successBlock 请求成功的回调
 @param failureBlock 请求失败的回调
 @param progressBlock 进度
 @return ZBURLSessionTask
 */
+ (ZBURLSessionTask *)zb_request_PUTWithEntity:(ZBDataEntity *)entity
                                  successBlock:(ZBResponseSuccessBlock)successBlock
                                  failureBlock:(ZBResponseFailBlock)failureBlock
                                 progressBlock:(ZBDownloadProgressBlock)progressBlock{
    if (!entity || ![entity isKindOfClass:[ZBDataEntity class]]) {
        return nil;
    }
    return [self zb_requestWithType:ZBHttpRequestTypePut
                        isNeedCache:NO
                          urlString:entity.urlString
                         parameters:entity.parameters
                       successBlock:successBlock
                       failureBlock:failureBlock
                      progressBlock:progressBlock];
}

/**
 网络请求的实例方法 delete
 
 @param entity 请求信息载体
 @param successBlock 请求成功的回调
 @param failureBlock 请求失败的回调
 @param progressBlock 进度
 @return ZBURLSessionTask
 */
+ (ZBURLSessionTask *)zb_request_DELETEWithEntity:(ZBDataEntity *)entity
                                     successBlock:(ZBResponseSuccessBlock)successBlock
                                     failureBlock:(ZBResponseFailBlock)failureBlock
                                    progressBlock:(ZBDownloadProgressBlock)progressBlock{
    if (!entity || ![entity isKindOfClass:[ZBDataEntity class]]) {
        return nil;
    }
    return [self zb_requestWithType:ZBHttpRequestTypeDelete
                        isNeedCache:NO
                          urlString:entity.urlString
                         parameters:entity.parameters
                       successBlock:successBlock
                       failureBlock:failureBlock
                      progressBlock:progressBlock];
}

/**
 上传图片(多图)
 
 @param entity 请求信息载体
 @param successBlock 上传成功的回调
 @param failureBlock 上传失败的回调
 @param progressBlock 上传进度
 @return ZBURLSessionTask
 */
+ (ZBURLSessionTask *)zb_uploadImageWithEntity:(ZBDataEntity *)entity
                                  successBlock:(ZBResponseSuccessBlock)successBlock
                                   failurBlock:(ZBResponseFailBlock)failureBlock
                                 progressBlock:(ZBUploadProgressBlock)progressBlock{
    if (!entity || entity.urlString == nil || ![entity isKindOfClass:[ZBImageDataEntity class]]) {
        return nil;
    }
    @autoreleasepool{
    ZBImageDataEntity *imageEntity = (ZBImageDataEntity *)entity;
    
    ZBWeak;
    /*! 检查地址中是否有中文 */
    NSString *URLString = [NSURL URLWithString:imageEntity.urlString] ? imageEntity.urlString : [self strUTF8Encoding:imageEntity.urlString];
    
//    DSLog(@"******************** 请求参数 ***************************");
    NSString *boundary = @"wfWiEWrgEFA9A78512weF7106A";
    [self zb_setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderKey:@"Content-Type"];
//    DSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",ZBNetManagerShare.sessionManager.requestSerializer.HTTPRequestHeaders, @"POST",URLString, imageEntity.parameters);
//    DSLog(@"ZBNetManagerShare.sessionManager : %@",ZBNetManagerShare.sessionManager.requestSerializer.HTTPRequestHeaders);
//    DSLog(@"********************************************************");
    
    __block  UIImage *resizedImage = nil;
    ZBURLSessionTask *sessionTask = nil;
    sessionTask = [ZBNetManagerShare.sessionManager POST:URLString parameters:imageEntity.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {

        /*! 出于性能考虑,将上传图片进行压缩 */
        [imageEntity.imageArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            /*! image的压缩方法 */
              @autoreleasepool{
                resizedImage = obj;
                [weakSelf zb_uploadImageWithFormData:formData
                                        resizedImage:resizedImage
                                           imageType:imageEntity.imageType
                                          imageScale:imageEntity.imageScale
                                           fileNames:imageEntity.fileNames
                                               index:idx
                                          appendName:imageEntity.appendName];
              }
        }];
  
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        DSLog(@"上传进度--%lld, 总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock) {
                progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }
        });
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        DSLog(@"上传图片成功 = %@",responseObject);
        if (successBlock) {
            successBlock(responseObject);
        }
        
        [[weakSelf tasks] removeObject:sessionTask];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if (failureBlock) {
            failureBlock(error);
        }
        [[weakSelf tasks] removeObject:sessionTask];
    }];
  
    if (sessionTask) {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
    }
}

/**
 视频上传
 
 @param entity 请求信息载体
 @param successBlock 成功的回调
 @param failureBlock 失败的回调
 @param progressBlock 上传的进度
 */
+ (void)zb_uploadVideoWithEntity:(ZBDataEntity *)entity
                    successBlock:(ZBResponseSuccessBlock)successBlock
                    failureBlock:(ZBResponseFailBlock)failureBlock
                   progressBlock:(ZBUploadProgressBlock)progressBlock{
    if (!entity || entity.urlString == nil || ![entity isKindOfClass:[ZBFileDataEntity class]]) {
        return;
    }
    ZBFileDataEntity *fileEntity = (ZBFileDataEntity *)entity;
    /*! 获得视频资源 */
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:[NSURL URLWithString:fileEntity.filePath]  options:nil];
    
    /*! 压缩 */
    
    //    NSString *const AVAssetExportPreset640x480;
    //    NSString *const AVAssetExportPreset960x540;
    //    NSString *const AVAssetExportPreset1280x720;
    //    NSString *const AVAssetExportPreset1920x1080;
    //    NSString *const AVAssetExportPreset3840x2160;
    
    /*! 创建日期格式化器 */
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    [formatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss"];
    
    /*! 转化后直接写入Library---caches */
    NSString *videoWritePath = [NSString stringWithFormat:@"output-%@.mp4",[formatter stringFromDate:[NSDate date]]];
    NSString *outfilePath = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", videoWritePath];
    
    AVAssetExportSession *avAssetExport = [[AVAssetExportSession alloc] initWithAsset:avAsset presetName:AVAssetExportPresetMediumQuality];
    
    avAssetExport.outputURL = [NSURL fileURLWithPath:outfilePath];
    avAssetExport.outputFileType =  AVFileTypeMPEG4;
    
    [avAssetExport exportAsynchronouslyWithCompletionHandler:^{
        switch ([avAssetExport status]) {
            case AVAssetExportSessionStatusCompleted:
            {
                [ZBNetManagerShare.sessionManager POST:fileEntity.urlString parameters:fileEntity.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                    
                    NSURL *filePathURL2 = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", outfilePath]];
                    // 获得沙盒中的视频内容
                    [formData appendPartWithFileURL:filePathURL2 name:@"video" fileName:outfilePath mimeType:@"application/octet-stream" error:nil];
                    
                } progress:^(NSProgress * _Nonnull uploadProgress) {
                    DSLog(@"上传进度--%lld, 总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
                    
                    /*! 回到主线程刷新UI */
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (progressBlock)
                        {
                            progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
                        }
                    });
                } success:^(NSURLSessionDataTask * _Nonnull task, NSDictionary *  _Nullable responseObject) {
                    DSLog(@"上传视频成功 = %@",responseObject);
                    if (successBlock)
                    {
                        successBlock(responseObject);
                    }
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    DSLog(@"上传视频失败 = %@", error);
                    if (failureBlock)
                    {
                        failureBlock(error);
                    }
                }];
                break;
            }
            default:
                break;
        }
    }];
}

/**
 文件下载
 
 @param entity 请求信息载体
 @param successBlock 下载文件成功的回调
 @param failureBlock 下载文件失败的回调
 @param progressBlock 下载文件的进度显示
 @return ZBURLSessionTask
 */

+ (ZBURLSessionTask *)zb_downLoadFileWithEntity:(ZBDataEntity *)entity
                                   successBlock:(ZBResponseSuccessBlock)successBlock
                                   failureBlock:(ZBResponseFailBlock)failureBlock
                                  progressBlock:(ZBDownloadProgressBlock)progressBlock{
    if (!entity || entity.urlString == nil || ![entity isKindOfClass:[ZBFileDataEntity class]]) {
        return nil;
    }
    
    ZBFileDataEntity *fileEntity = (ZBFileDataEntity *)entity;
    
    NSURLRequest *downloadRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:fileEntity.urlString]];
//
//    DSLog(@"******************** 请求参数 ***************************");
//    DSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",ZBNetManagerShare.sessionManager.requestSerializer.HTTPRequestHeaders, @"download", fileEntity.urlString, fileEntity.parameters);
//    DSLog(@"******************************************************");
    
    
    ZBURLSessionTask *sessionTask = nil;
    
    sessionTask = [ZBNetManagerShare.sessionManager downloadTaskWithRequest:downloadRequest progress:^(NSProgress * _Nonnull downloadProgress) {
        
        DSLog(@"下载进度：%.2lld%%",100 * downloadProgress.completedUnitCount/downloadProgress.totalUnitCount);
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (progressBlock)
            {
                progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
            }
            
        });
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        if (!fileEntity.filePath)
        {
            NSURL *downloadURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
            DSLog(@"默认路径--%@",downloadURL);
            return [downloadURL URLByAppendingPathComponent:[response suggestedFilename]];
        }
        else
        {
            return [NSURL fileURLWithPath:fileEntity.filePath];
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        [[self tasks] removeObject:sessionTask];
        
        DSLog(@"下载文件成功");
        if (error == nil)
        {
            if (successBlock)
            {
                /*! 返回完整路径 */
                successBlock([filePath path]);
            }
            else
            {
                if (failureBlock)
                {
                    failureBlock(error);
                }
            }
        }
    }];
    
    /*! 开始启动任务 */
    [sessionTask resume];
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
}

/**
 文件上传
 
 @param entity 请求信息载体
 @param successBlock successBlock description
 @param failureBlock failureBlock description
 @param progressBlock progressBlock description
 @return ZBURLSessionTask
 */

+ (ZBURLSessionTask *)zb_uploadFileWithWithEntity:(ZBDataEntity *)entity
                                     successBlock:(ZBResponseSuccessBlock)successBlock
                                     failureBlock:(ZBResponseFailBlock)failureBlock
                                    progressBlock:(ZBUploadProgressBlock)progressBlock{
    if (!entity || entity.urlString == nil || ![entity isKindOfClass:[ZBFileDataEntity class]]) {
        return nil;
    }
    
    ZBFileDataEntity *fileEntity = (ZBFileDataEntity *)entity;
    
//    DSLog(@"******************** 请求参数 ***************************");
//    DSLog(@"请求头: %@\n请求方式: %@\n请求URL: %@\n请求param: %@\n\n",ZBNetManagerShare.sessionManager.requestSerializer.HTTPRequestHeaders, @"uploadFile", fileEntity.urlString, fileEntity.parameters);
//    DSLog(@"******************************************************");
    
    ZBURLSessionTask *sessionTask = nil;
    sessionTask = [ZBNetManagerShare.sessionManager POST:fileEntity.urlString parameters:fileEntity.parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSError *error = nil;
        [formData appendPartWithFileURL:[NSURL URLWithString:fileEntity.filePath] name:fileEntity.fileName error:&error];
        if (failureBlock && error)
        {
            failureBlock(error);
        }
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        DSLog(@"上传进度--%lld, 总进度---%lld",uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
        
        /*! 回到主线程刷新UI */
        dispatch_async(dispatch_get_main_queue(), ^{
            if (progressBlock)
            {
                progressBlock(uploadProgress.completedUnitCount, uploadProgress.totalUnitCount);
            }
        });
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        [[self tasks] removeObject:sessionTask];
        if (successBlock)
        {
            successBlock(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        [[self tasks] removeObject:sessionTask];
        if (failureBlock)
        {
            failureBlock(error);
        }
    }];
    
    /*! 开始启动任务 */
    [sessionTask resume];
    
    if (sessionTask)
    {
        [[self tasks] addObject:sessionTask];
    }
    return sessionTask;
}

#pragma mark - 网络状态监测
/*!
 *  开启网络监测
 */
+ (void)zb_startNetWorkMonitoringWithBlock:(ZBNetworkStatusBlock)networkStatus
{
    /*! 1.获得网络监控的管理者 */
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    /*! 当使用AF发送网络请求时,只要有网络操作,那么在状态栏(电池条)wifi符号旁边显示  菊花提示 */
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    /*! 2.设置网络状态改变后的处理 */
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        /*! 当网络状态改变了, 就会调用这个block */
        switch (status)
        {
            case AFNetworkReachabilityStatusUnknown:
                DSLog(@"未知网络");
                networkStatus ? networkStatus(ZBNetworkStatusUnknown) : nil;
                break;
            case AFNetworkReachabilityStatusNotReachable:
                DSLog(@"没有网络");
                networkStatus ? networkStatus(ZBNetworkStatusNotReachable) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                DSLog(@"手机自带网络");
                networkStatus ? networkStatus(ZBNetworkStatusReachableViaWWAN) : nil;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                DSLog(@"wifi 网络");
                networkStatus ? networkStatus(ZBNetworkStatusReachableViaWiFi) : nil;
                break;
        }
    }];
    [manager startMonitoring];
}

#pragma mark - 取消 Http 请求
/*!
 *  取消所有 Http 请求
 */
+ (void)zb_cancelAllRequest
{
    // 锁操作
    @synchronized(self)
    {
        [[self tasks] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            [task cancel];
        }];
        [[self tasks] removeAllObjects];
    }
}

/*!
 *  取消指定 URL 的 Http 请求
 */
+ (void)zb_cancelRequestWithURL:(NSString *)URL
{
    if (!URL)
    {
        return;
    }
    @synchronized (self)
    {
        [[self tasks] enumerateObjectsUsingBlock:^(NSURLSessionTask  *_Nonnull task, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([task.currentRequest.URL.absoluteString hasPrefix:URL])
            {
                [task cancel];
                [[self tasks] removeObject:task];
                *stop = YES;
            }
        }];
    }
}


#pragma mark - 压缩图片尺寸
/*! 对图片尺寸进行压缩 */
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
    if (newSize.height > 375/newSize.width*newSize.height)
    {
        newSize.height = 375/newSize.width*newSize.height;
    }
    
    if (newSize.width > 375)
    {
        newSize.width = 375;
    }
    
    UIImage *newImage = [UIImage needCenterImage:image size:newSize scale:1.0];
    
    return newImage;
}

#pragma mark - url 中文格式化
+ (NSString *)strUTF8Encoding:(NSString *)str
{
    /*! ios9适配的话 打开第一个 */
    if ([[UIDevice currentDevice] systemVersion].floatValue >= 9.0)
    {
        return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    }
    else
    {
//        return [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
          return [str stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLPathAllowedCharacterSet]];
    }
}

#pragma mark - setter / getter
/**
 存储着所有的请求task数组
 
 @return 存储着所有的请求task数组
 */
+ (NSMutableArray *)tasks
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
//        DSLog(@"创建数组");
        tasks = [[NSMutableArray alloc] init];
    });
    return tasks;
}

- (void)setTimeoutInterval:(NSTimeInterval)timeoutInterval
{
    _timeoutInterval = timeoutInterval;
    ZBNetManagerShare.sessionManager.requestSerializer.timeoutInterval = timeoutInterval;
}

- (void)setRequestSerializer:(ZBHttpRequestSerializer)requestSerializer
{
    _requestSerializer = requestSerializer;
    switch (requestSerializer) {
        case ZBHttpRequestSerializerJSON:
        {
            ZBNetManagerShare.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer] ;
        }
            break;
        case ZBHttpRequestSerializerHTTP:
        {
            ZBNetManagerShare.sessionManager.requestSerializer = [AFHTTPRequestSerializer serializer] ;
        }
            break;
            
        default:
            break;
    }
}

- (void)setResponseSerializer:(ZBHttpResponseSerializer)responseSerializer
{
    _responseSerializer = responseSerializer;
    switch (responseSerializer) {
        case ZBHttpResponseSerializerJSON:
        {
            ZBNetManagerShare.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer] ;
        }
            break;
        case ZBHttpResponseSerializerHTTP:
        {
            ZBNetManagerShare.sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer] ;
        }
            break;
            
        default:
            break;
    }
}

- (void)setHttpHeaderFieldDictionary:(NSDictionary *)httpHeaderFieldDictionary
{
    _httpHeaderFieldDictionary = httpHeaderFieldDictionary;
    
    if (![httpHeaderFieldDictionary isKindOfClass:[NSDictionary class]])
    {
        DSLog(@"请求头数据有误，请检查！");
        return;
    }
    NSArray *keyArray = httpHeaderFieldDictionary.allKeys;
    
    if (keyArray.count <= 0)
    {
        DSLog(@"请求头数据有误，请检查！");
        return;
    }
    
    for (NSInteger i = 0; i < keyArray.count; i ++)
    {
        NSString *keyString = keyArray[i];
        NSString *valueString = httpHeaderFieldDictionary[keyString];
        
        [ZBNetManager zb_setValue:valueString forHTTPHeaderKey:keyString];
    }
}

/**
 *  自定义请求头
 */
+ (void)zb_setValue:(NSString *)value forHTTPHeaderKey:(NSString *)HTTPHeaderKey
{
    [ZBNetManagerShare.sessionManager.requestSerializer setValue:value forHTTPHeaderField:HTTPHeaderKey];
}


/**
 删除所有请求头
 */
+ (void)zb_clearAuthorizationHeader
{
    [ZBNetManagerShare.sessionManager.requestSerializer clearAuthorizationHeader];
}

+ (void)zb_uploadImageWithFormData:(id<AFMultipartFormData>  _Nonnull )formData
                      resizedImage:(UIImage *)resizedImage
                         imageType:(NSString *)imageType
                        imageScale:(CGFloat)imageScale
                         fileNames:(NSArray <NSString *> *)fileNames
                             index:(NSUInteger)index
                        appendName:(NSString *)appendName{
    /*! 此处压缩方法是jpeg格式是原图大小的0.8倍，要调整大小的话，就在这里调整就行了还是原图等比压缩 */
    if (imageScale == 0)
    {
        imageScale = 0.9;
    }
    @autoreleasepool{
        NSData  *imageData = UIImageJPEGRepresentation(resizedImage, imageScale ?: 1.f);
        /*! 拼接data */
        if (imageData != nil){
            //图片名称
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyyMMddHHmmss";
            NSString *str = [formatter stringFromDate:[NSDate date]];
            NSString *imageFileName = [NSString stringWithFormat:@"%@%ld.%@",str, (unsigned long)index, imageType?:@"jpg"];
            //上传
            [formData appendPartWithFileData:imageData
                                    name:appendName
                                fileName:fileNames ? [NSString stringWithFormat:@"%@.%@",fileNames[index],imageType?:@"jpg"] : imageFileName
                                mimeType:[NSString stringWithFormat:@"image/%@",imageType ?: @"jpg"]];
        }
    }
}




/**
 清空缓存：此方法可能会阻止调用线程，直到文件删除完成。
 */
- (void)zb_clearAllHttpCache{
    [ZBNetManagerCache zb_clearAllHttpCache];
}

@end

#pragma mark - NSDictionary,NSArray的分类
/*
 ************************************************************************************
 *新建 NSDictionary 与 NSArray 的分类, 控制台打印 json 数据中的中文
 ************************************************************************************
 */

#ifdef DEBUG
@implementation NSArray (ZBNetManager)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString stringWithString:@"(\n"];
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [strM appendFormat:@"\t%@,\n", obj];
    }];
    
    [strM appendString:@")"];
    
    return strM;
}

@end

@implementation NSDictionary (ZBNetManager)

- (NSString *)descriptionWithLocale:(id)locale
{
    NSMutableString *strM = [NSMutableString stringWithString:@"{\n"];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [strM appendFormat:@"\t%@ = %@;\n", key, obj];
    }];
    
    [strM appendString:@"}\n"];
    
    return strM;
}
@end

#endif
