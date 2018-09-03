//
//  LiveViewModel.h
//  LiveCamera
//
//  Created by bigfish on 2018/8/31.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "ViewModelClass.h"

@interface LiveViewModel : ViewModelClass




/**
 创建直播

 @param type 平台
 @param broadcastInfo 直播间信息
 @param liveStreamInfo 直播信息 
 */
- (void)createBroadcastWith:(ThirdType)type
           BroadcastInfoDic:(NSDictionary *)broadcastInfo
           LiveStreamInfoDic:(NSDictionary *)liveStreamInfo;





/**
 修改直播间状态

 @param broadcastId 直播间id
 @param broadcastInfo 直播状态
 */
- (void)transitionYouTubeBroadcastWith:(NSString *)broadcastId
                                status:(NSString *)broadcastInfo;

@end
