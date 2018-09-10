//
//  APIMacros.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/27.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#ifndef APIMacros_h
#define APIMacros_h
#define SHIRO_COOKIE @"SESSION"
#define LOGIN_TYPE @2 //IOS
#define broadCastType @"broadCastType" // 1,add  2 checkList
#define broadCastTypeAdd @"broadCastTypeAdd"
#define broadCastTypeCheckList @"broadCastTypeCheckList"
#define broadCastDeviceArray @"broadCastDeviceArray"

#ifdef DEBUG
//do sth.
#define SERVER @"http://172.18.223.207:80"


#else
//do sth.
#define SERVER @"http://cms.opssee.com.cn:8088"

#endif

// ============================= USER_INFO =====================================
//用户信息
#define USER_INFO [UserModel sharedUserInfoContext]

// ============================= API ===========================================
//注册
#define API_LOGIN                  @"/opssee-api/V1_0/directseedinglogin"

#define API_LOGIN_OUT              @"/opssee-api/V1_0/directseedinglogout"

#define API_DEVICELIST             @"/opssee-api/V1_0/querybondeddevicelist"

#define API_BIND_DEVICE            @"/opssee-api/V1_0/bondeddevice"

#define API_CANCEL_BIND_DEVICE     @"/opssee-api/V1_0/cancelbondeddevice"



// =========================YouTube API ========================================
#define YT_API_CREATE_BROADCAST  @"https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,contentDetails,status"

#define YT_API_CREATE_LIVESTREAM  @"https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status"

#define YT_API_CREATE_BIND  @"https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?part=id,snippet,contentDetails,status"
#define YT_API_LIVEBROADCASTS @"https://www.googleapis.com/youtube/v3/liveBroadcasts?broadcastStatus=upcoming&maxResults=50&part=id,snippet,contentDetails"
#define YT_API_GET_BROADCASTS @"https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,contentDetails,status"

#define YT_API_GET_LIVESTREAM @"https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status"

#define YT_API_GET_TRABSUTION @"https://www.googleapis.com/youtube/v3/liveBroadcasts/transition?part=id,snippet,contentDetails,status"


// =========================QR API ========================================

#define QR_BIND @"/v1/app/qrBind"

#define QR_CHECK_VERSION @"/v1/system/checkVersion"

#define QR_UP_GRADE @"/v1/system/upgrade"

#define QR_SNAPSHOT @"/v1/snapshot"

#endif /* APIMacros_h */
