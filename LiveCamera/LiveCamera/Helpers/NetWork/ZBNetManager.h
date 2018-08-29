//
//  ZBNetManager.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/3/1.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define ZBNetManagerShare [ZBNetManager sharedZBNetManager]

#define ZBWeak  __weak __typeof(self) weakSelf = self
/*! 过期属性或方法名提醒 */
#define ZBNetManagerDeprecated(instead) __deprecated_msg(instead)

/*! 使用枚举NS_ENUM:区别可判断编译器是否支持新式枚举,支持就使用新的,否则使用旧的 */
typedef NS_ENUM(NSUInteger, ZBNetworkStatus)
{
    /*! 未知网络 */
    ZBNetworkStatusUnknown           = 0,
    /*! 没有网络 */
    ZBNetworkStatusNotReachable,
    /*! 手机 3G/4G 网络 */
    ZBNetworkStatusReachableViaWWAN,
    /*! wifi 网络 */
    ZBNetworkStatusReachableViaWiFi
};

/*！定义请求类型的枚举 */
typedef NS_ENUM(NSUInteger, ZBHttpRequestType)
{
    /*! get请求 */
    ZBHttpRequestTypeGet = 0,
    /*! post请求 */
    ZBHttpRequestTypePost,
    /*! put请求 */
    ZBHttpRequestTypePut,
    /*! delete请求 */
    ZBHttpRequestTypeDelete
};

typedef NS_ENUM(NSUInteger, ZBHttpRequestSerializer) {
    /** 设置请求数据为JSON格式*/
    ZBHttpRequestSerializerJSON,
    /** 设置请求数据为HTTP格式*/
    ZBHttpRequestSerializerHTTP,
};

typedef NS_ENUM(NSUInteger, ZBHttpResponseSerializer) {
    /** 设置响应数据为JSON格式*/
    ZBHttpResponseSerializerJSON,
    /** 设置响应数据为HTTP格式*/
    ZBHttpResponseSerializerHTTP,
};

/*! 实时监测网络状态的 block */
typedef void(^ZBNetworkStatusBlock)(ZBNetworkStatus status);

/*! 定义请求成功的 block */
typedef void( ^ ZBResponseSuccessBlock)(id response);
/*! 定义请求失败的 block */
typedef void( ^ ZBResponseFailBlock)(NSError *error);

/*! 定义上传进度 block */
typedef void( ^ ZBUploadProgressBlock)(int64_t bytesProgress,
                                       int64_t totalBytesProgress);
/*! 定义下载进度 block */
typedef void( ^ ZBDownloadProgressBlock)(int64_t bytesProgress,
                                         int64_t totalBytesProgress);

/*!
 *  方便管理请求任务。执行取消，暂停，继续等任务.
 *  - (void)cancel，取消任务
 *  - (void)suspend，暂停任务
 *  - (void)resume，继续任务
 */
typedef NSURLSessionTask ZBURLSessionTask;

/*! 请求数据实例 */
@class ZBDataEntity;

@interface ZBNetManager : NSObject

/**
 创建的请求的超时间隔（以秒为单位），此设置为全局统一设置一次即可，默认超时时间间隔为30秒。
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 设置网络请求参数的格式，此设置为全局统一设置一次即可，默认：ZBHttpRequestSerializerJSON
 */
@property (nonatomic, assign) ZBHttpRequestSerializer requestSerializer;

/**
 设置服务器响应数据格式，此设置为全局统一设置一次即可，默认：ZBHttpResponseSerializerJSON
 */
@property (nonatomic, assign) ZBHttpResponseSerializer responseSerializer;

/**
 自定义请求头：httpHeaderField
 */
@property(nonatomic, strong) NSDictionary *httpHeaderFieldDictionary;

/*!
 *  获得全局唯一的网络请求实例单例方法
 *
 *  @return 网络请求类ZBNetManager单例
 */
+ (instancetype)sharedZBNetManager;

#pragma 监测网络的可链接性
+(BOOL)netWorkReachabilityWithURLString:(NSString *) strUrl;


#pragma mark - 网络请求的类方法 --- get / post / put / delete



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
                                 progressBlock:(ZBDownloadProgressBlock)progressBlock;

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
                                  progressBlock:(ZBDownloadProgressBlock)progressBlock;

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
                                 progressBlock:(ZBDownloadProgressBlock)progressBlock;

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
                                    progressBlock:(ZBDownloadProgressBlock)progressBlock;

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
                                 progressBlock:(ZBUploadProgressBlock)progressBlock;

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
                   progressBlock:(ZBUploadProgressBlock)progressBlock;

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
                                  progressBlock:(ZBDownloadProgressBlock)progressBlock;

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
                                    progressBlock:(ZBUploadProgressBlock)progressBlock;


#pragma mark - 网络状态监测
/*!
 *  开启实时网络状态监测，通过Block回调实时获取(此方法可多次调用)
 */
+ (void)zb_startNetWorkMonitoringWithBlock:(ZBNetworkStatusBlock)networkStatus;

#pragma mark - 自定义请求头
/**
 *  自定义请求头
 */
+ (void)zb_setValue:(NSString *)value forHTTPHeaderKey:(NSString *)HTTPHeaderKey;

/**
 删除所有请求头
 */
+ (void)zb_clearAuthorizationHeader;

#pragma mark - 取消 Http 请求
/*!
 *  取消所有 Http 请求
 */
+ (void)zb_cancelAllRequest;

/*!
 *  取消指定 URL 的 Http 请求
 */
+ (void)zb_cancelRequestWithURL:(NSString *)URL;

/**
 清空缓存：此方法可能会阻止调用线程，直到文件删除完成。
 */
- (void)zb_clearAllHttpCache;
@end
