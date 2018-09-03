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
#ifdef DEBUG
//do sth.
#define SERVER @"http://172.18.223.207:80"


#else
//do sth.

#endif

// ============================= USER_INFO =====================================
//用户信息
#define USER_INFO [UserModel sharedUserInfoContext]

// ============================= API ===========================================
//注册
#define API_LOGIN                @"/opssee-api/V1_0/directseedinglogin"
#define API_DEVICELIST           @"/opssee-api/V1_0/querybondeddevicelist"

// =========================YouTube API ========================================
#define YT_API_CREATE_BROADCAST  @"https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,contentDetails,status"

#define YT_API_CREATE_LIVESTREAM  @"https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status"

#define YT_API_CREATE_BIND  @"https://www.googleapis.com/youtube/v3/liveBroadcasts/bind?part=id,snippet,contentDetails,status"
#define YT_API_LIVEBROADCASTS @"https://www.googleapis.com/youtube/v3/liveBroadcasts?broadcastStatus=upcoming&maxResults=50&part=id,snippet,contentDetails"
#define YT_API_GET_BROADCASTS @"https://www.googleapis.com/youtube/v3/liveBroadcasts?part=id,snippet,contentDetails,status"

#define YT_API_GET_LIVESTREAM @"https://www.googleapis.com/youtube/v3/liveStreams?part=id,snippet,cdn,status"

#define YT_API_GET_TRABSUTION @"https://www.googleapis.com/youtube/v3/liveBroadcasts/transition?part=id,snippet,contentDetails,status"

#endif /* APIMacros_h */
