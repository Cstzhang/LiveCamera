//
//  ZBDataEntity.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/3/1.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

/** 请求实体，承载请求参数 */
@interface ZBDataEntity : NSObject

/** 请求路径 */
@property (nonatomic, copy) NSString *urlString;
/** 请求参数 */
@property (nonatomic, copy) id parameters;
/** 是否缓存响应 */
@property (nonatomic, assign, getter=isNeedCache) BOOL needCache;

@end


@interface ZBFileDataEntity : ZBDataEntity

/** 文件名字 */
@property (nonatomic, copy) NSString *fileName;

/** 1、如果是上传操作，为上传文件的本地沙河路径
 2、如果是下载操作，为下载文件保存路径
 */
@property (nonatomic, copy) NSString *filePath;

@end

@interface ZBImageDataEntity : ZBDataEntity

/** 上传的图片数组 */
@property (nonatomic, copy) NSArray *imageArray;

/** 图片名称 */
@property (nonatomic, copy) NSArray<NSString *> *fileNames;
/** 图片类型 png、jpg、gif */
@property (nonatomic, copy) NSString *imageType;
/** 与后台约好的名字 */
@property (nonatomic, copy) NSString *appendName;
/** 图片压缩比率（0~1.0）*/
@property (nonatomic, assign) CGFloat imageScale;

@end
