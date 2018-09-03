//
//  LiveViewModel.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/31.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "LiveViewModel.h"

@implementation LiveViewModel


- (void)createBroadcastWith:(ThirdType)type
           BroadcastInfoDic:(NSDictionary *)broadcastInfo
          LiveStreamInfoDic:(NSDictionary *)liveStreamInfo{
    ZBWeak;
    switch (type) {
        case ThirdTypeFacebook:{
            [self creatFacebookBroadcast:broadcastInfo callback:^(NSDictionary *resultInfo) {
                if (!resultInfo) {
                    [weakSelf errorWithMsg:@"unauthorized"];
                }else{
                    weakSelf.returnBlock(resultInfo);
                }
            }];
            break;
        }
        case ThirdTypeYouTube:{
            // 1  create YouTube BroadCast
            if ([UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]) {
                [self autoCreateYouTubeBroadCastwithBroadcastInfoDic:broadcastInfo LiveStreamInfoDic:liveStreamInfo
                                                            callback:^(BOOL success, NSDictionary *dict) {
                                                                if (success) {
                                                                      weakSelf.returnBlock(dict);
                                                                }else{
                                                                     [self errorWithMsg:@"unauthorized"];
                                                                }
                                                            }];
            }else{
                 [self errorWithMsg:@"unauthorized"];
            }
          
            break;
        }
    }
}





/**
 自动创建 绑定 直播

 @param broadcastInfo 直播间信息
 @param liveStreamInfo 直播流信息
 @param completion 回调
 */
- (void)autoCreateYouTubeBroadCastwithBroadcastInfoDic:(NSDictionary *)broadcastInfo
                                     LiveStreamInfoDic:(NSDictionary *)liveStreamInfo
                                              callback:(void (^)(BOOL success, NSDictionary *dict))completion{
    ZBWeak;
    [self createYouTubeBroadCastwith:broadcastInfo
                            callback:^(BOOL success, NSDictionary *dict) {
                                
                                if (success) {
                                    // 2 binding YouTube BroadCast
                                    NSLog(@" 1 =======  create YouTubeBroadCast   ======= ");
                                    NSString *boardingcastId = dict[@"id"];
                                    [weakSelf createYouTubeLiveStreamwith:liveStreamInfo callback:^(BOOL success, NSDictionary *dict) {
                                        if (success) {
                                            NSString *streamingId = dict[@"id"];
                                            NSLog(@" 2 =======  create LiveStream   =======");
                                            // 3  blind Live Stream boardCast
                                            [weakSelf bindLiveStreamWithBoardCastId:boardingcastId streamid:streamingId with:^(BOOL success, NSDictionary *liveStreamDict) {
                                                if (success) {
                                                    NSLog(@" 3 =======   bind LiveStream   ======= ");
                                                    [weakSelf getBroadCasstRequest:boardingcastId with:streamingId with:^(BOOL success, NSDictionary *broadCastDict, NSDictionary *streamDict) {
                                                        if (success) {
                                                            NSLog(@"4 =======  get broadCastDict   =======");
                                                            NSLog(@"5 =======  get streamDict    =======");
                                                            if ([broadCastDict[@"items"] count] >0 && [streamDict[@"items"] count] >0) {
                                                                NSDictionary *result = @{@"broadCastDict":broadCastDict[@"items"][0],
                                                                                         @"streamDict":streamDict[@"items"][0],
                                                                                         
                                                                                         };
                                                                weakSelf.returnBlock(result);
                                                            }else{
                                                                [weakSelf errorWithMsg:@"unauthorized"];
                                                            }
                                                            
                                                        }else{
                                                            [weakSelf errorWithMsg:@"unauthorized"];
                                                        }
                                                        
                                                    }];
                                                }else{
                                                    [weakSelf errorWithMsg:@"unauthorized"];
                                                }
                                            }];
                                            
                                        }else{
                                            [weakSelf errorWithMsg:@"unauthorized"];
                                        }
                                        
                                    }];
                                    
                                }else{
                                    [weakSelf errorWithMsg:@"unauthorized"];
                                }
                            }];
    
}

/**
 创建直播间

 @param info 直播信息
 @param completion 回调
 */
- (void)createYouTubeBroadCastwith:(NSDictionary *)info
                        callback :(void (^)(BOOL success, NSDictionary *dict))completion{
    // 1 create
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@&key=%@",YT_API_CREATE_BROADCAST,API_KEY];
    entity.needCache = NO;
    entity.parameters = info;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
          // 2 bind
        completion(YES,response);
    } failureBlock:^(NSError *error) {
        NSLog(@" createYouTubeBroadCast  error \n %@ ",error);
        completion(NO,nil);
    } progressBlock:nil];
  
}


/**
 创建直播

 @param info 直播信息
 @param completion 回调
 */
- (void)createYouTubeLiveStreamwith:(NSDictionary *)info
                          callback :(void (^)(BOOL success, NSDictionary *dict))completion{
  
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@&key=%@",YT_API_CREATE_LIVESTREAM,API_KEY];
    entity.needCache = NO;
    entity.parameters = info;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
       
        completion(YES,response);
    } failureBlock:^(NSError *error) {
        NSLog(@" createYouTubeBroadCast  error \n : %@ ",error);
        completion(NO,nil);
    } progressBlock:nil];
    
    
}


/**
 绑定直播间和直播

 @param boardCastId 直播间ID
 @param streamid 直播流ID
 @param completion 回调
 */
- (void)bindLiveStreamWithBoardCastId:(NSString*)boardCastId
                             streamid:(NSString*)streamid
                                 with:(void (^)(BOOL success,
                                                NSDictionary *liveStreamDict))completion{
 
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@&key=%@&id=%@&streamId=%@",YT_API_CREATE_BIND,API_KEY,boardCastId,streamid];
    entity.needCache = NO;
    entity.parameters = nil;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        completion(YES,response);
    } failureBlock:^(NSError *error) {
        NSLog(@" bindLiveStream  error \n  %@ ",error);
        completion(NO,nil);
    } progressBlock:nil];
    
    
    
    
}


/**
 获取未开始直播的直播间

 @param completion 回调
 */
-(void)listUpcomingVideosCompletion:(void (^)(BOOL success, NSDictionary *dict))completion{
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@&key=%@",YT_API_LIVEBROADCASTS,API_KEY];
    entity.needCache = NO;
    entity.parameters = nil;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        completion(YES,response);
    } failureBlock:^(NSError *error) {
        NSLog(@" listUpcomingVideosCompletion  error  \n  %@ ",error);
        completion(NO,nil);
    } progressBlock:nil];
    
}



- (void)transitionYouTubeBroadcastWith:(NSString *)broadcastId status:(NSString *)broadcastInfo{
    
    [self transitionBroadcastdictionary:broadcastId withStatus:broadcastInfo with:^(BOOL success, NSDictionary *transistionDict) {
       
        if (success) {
            self.returnBlock(transistionDict);
        }else{
            [self errorWithMsg:@"transitionYouTubeBroadcast fail"];
        }
    }];
    
}
/**
 改变直播间状态

 @param broadCastId 直播间ID
 @param status 状态 {live  complete testing}
 @param completion 回调
 */
-(void)transitionBroadcastdictionary:(NSString*)broadCastId
                          withStatus:(NSString*)status
                                with:(void (^)(BOOL success,
                                               NSDictionary *transistionDict))completion{
    
    ZBDataEntity *entity = [ZBDataEntity new];
    entity.urlString = [NSString stringWithFormat:@"%@&key=%@&id=%@&broadcastStatus=%@",YT_API_GET_TRABSUTION,API_KEY,broadCastId,status];
    entity.needCache = NO;
    entity.parameters = nil;
    [ZBNetManager zb_request_POSTWithEntity:entity successBlock:^(id response) {
        completion(YES,response);
    } failureBlock:^(NSError *error) {
        NSLog(@" transitionBroadcastdictionary  error  \n  %@ ",error);
        completion(NO,nil);
    } progressBlock:nil];
}



-(void)getBroadCasstRequest:(NSString*)broadCastId
                       with:(NSString *)streamId
                       with:(void (^)(BOOL success, NSDictionary *broadCastDict,NSDictionary *streamDict))completion{
    
    ZBDataEntity *broadEntity = [ZBDataEntity new];
    broadEntity.urlString = [NSString stringWithFormat:@"%@&key=%@&id=%@",YT_API_GET_BROADCASTS,API_KEY,broadCastId];
    broadEntity.needCache = NO;
    broadEntity.parameters = nil;
    [ZBNetManager zb_request_GETWithEntity:broadEntity successBlock:^(id broadResponse) {
        ZBDataEntity *liveEntity = [ZBDataEntity new];
        liveEntity.urlString = [NSString stringWithFormat:@"%@&key=%@&id=%@",YT_API_GET_LIVESTREAM,API_KEY,streamId];
        liveEntity.needCache = NO;
        liveEntity.parameters = nil;
        [ZBNetManager zb_request_GETWithEntity:liveEntity successBlock:^(id liveResponse) {
            
            completion(YES,broadResponse,liveResponse);
            
        } failureBlock:^(NSError *error) {
            NSLog(@" getBroadCasstRequest  error %@ ",error);
            completion(NO,nil,nil);
        } progressBlock:nil];
        
    } failureBlock:^(NSError *error) {
        NSLog(@" getBroadCasstRequest  error %@ ",error);
        completion(NO,nil,nil);
    } progressBlock:nil];
    
}


/**
 创建feceBook直播

 @param info 直播信息
 @param callback 回调
 */
- (void)creatFacebookBroadcast:(NSDictionary *)info
                      callback:(void (^)(NSDictionary *))callback{
    FBSDKGraphRequest *UserIDRequest = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me"
                                                                         parameters:
                                                                        @{@"fields": @"id, name",}
                                                                         HTTPMethod:@"GET"];
    [UserIDRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                                id requestResult, NSError *requestError) {
        if (requestError) {
            NSLog(@"request fb user id failed%@",requestError);
            [self netFailure:requestError];
        }else {
            NSDictionary *userInfo = (NSDictionary *)requestResult;
            NSLog(@"facebook user info: %@", userInfo);
            NSString * userId = userInfo[@"id"];
            FBSDKGraphRequest *liveRequest = [[FBSDKGraphRequest alloc]
                                              initWithGraphPath:[NSString stringWithFormat:@"%@/live_videos", userId]
                                                                               parameters:info
                                                                               HTTPMethod:@"POST"];
            [liveRequest startWithCompletionHandler:^(FBSDKGraphRequestConnection *liveConnection,
                                                      id liveRequest, NSError *liveError) {
                if (liveError) {
                    NSLog(@"request fb user id failed %@",liveError);
                    callback(nil);
                }else{
                   
                    NSDictionary *streamInfo = (NSDictionary *)liveRequest;
                    NSLog(@"facebook live info: %@", streamInfo);
                    callback(streamInfo);
                }
            }];
        
        }
    }];

    
}



#pragma mark - callback
/**
 对网路异常进行处理
 */
-(void) netFailure:(NSError *)error{
    self.failureBlock(error);
}



/**
 对Error进行处理
 */
-(void)errorWithMsg:(NSString *)errorMsg {
    self.errorBlock(errorMsg);
}

@end
