//
//  APIMacros.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/27.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#ifndef APIMacros_h
#define APIMacros_h
//列表一页请求数量
#define REQUEST_MIN_PAGE_NUM 40
#define LIVE_PASSWORD @"cvte123456"
#define SHIRO_COOKIE @"SESSION"
#ifdef DEBUG
//do sth.
//#define SERVER @"http://172.18.223.206:80"
#define SERVER @"http://120.24.56.178:80"
//#define SERVER @"http://172.18.220.141:8088"
//#define SERVER @"http://172.18.220.169:80"
//#define DEVICE_IP @"172.18.223.207"
//#define DEVICE_IP @"120.24.56.178"
//#define SERVER @"http://cms.opssee.com.cn"
#define DEVICE_IP @"120.24.56.178"
#define DEVICE_PORT @"5060"


#else
//do sth.
#define SERVER @"http://cms.opssee.com.cn"
#define DEVICE_IP @"120.24.56.178"
#define DEVICE_PORT @"5060"
#endif

// ============================= USER_INFO =====================================
//用户信息
#define USER_INFO [UserModel sharedUserInfoContext]

// ============================= API ===========================================
//注册
#define API_REGISTER                @"/opssee-cms/V1_0/appregister"
//登录 POST
#define API_LOGIN                   @"/opssee-cms/V1_0/userlogin"
//学校列表
#define API_SCHOOL_LIST             @"/opssee-cms/V1_0/schoollist"
//班级列表
#define API_CLASS_LIST              @"/opssee-cms/V1_0/classlist"
//获取用户详细信息
#define API_USER_INFO               @"/opssee-cms/V1_0/queryregisterinfo"
//上传认证照片
#define API_UPLOAD_PICTURE          @"/opssee-cms/V1_0/uploadpicture"


//获取验证码
#define API_AUTHCODE                @"/opssee-cms/V1_0/userverificate"
//修改密码
#define API_UPDATE_PASSWORD         @"/opssee-cms/V1_0/userpassword"
//首页监控点列表获取 monitoring  POST
#define API_MONITORING_LIST         @"/opssee-cms/V1_0/querydevicesproperty"
//获取相册目录
#define API_ALBUMCATALOG_LIST       @"/opssee-cms/V1_0/albumcataloglist"
//预览相册列表
#define API_PREVIEWPICTURE_LIST     @"/opssee-cms/V1_0/previewpicture"
//获取相册参数筛选
#define API_ENUMBASEINFO            @"/opssee-cms/V1_0/getenumbaseinfo"
//手机上传照片
#define API_CAPTURE_UPLOAD_IMAGE    @"/opssee-cms/V1_0/captureuploadimage"
//删除照片 actType为1时，放入纸质相册；为2时，放回电子相册；为3时，表示删除
#define API_CAPTURE_DELETE_IMAGE    @"/opssee-cms/V1_0/dealpicture"
//查询纸质打印相册列表(IF2)
#define API_QUERY_ALBUM_PHOTO       @"/opssee-cms/V1_0/querychildalbumphoto"
//查询是否有新照片
#define API_QUERY_JUDGE_UPDATE      @"/opssee-cms/V1_0/judgeifupdate"
//删除相册中的照片
#define API_DELETE_ALBUM_PHOTO      @"/opssee-cms/V1_0/deletealbumphoto"
//重新上传照片（修改过位置后）
#define API_UPDATE_ALBUM_POSITION   @"/opssee-cms/V1_0/updatealbumposition"
//上传单张修改过的照片
#define API_UPLOAD_SINGEL_IAMGE     @"/opssee-cms/V1_0/singeluploadalbum"
//商品列表
#define API_QUERY_GOODS_LIST        @"/opssee-cms/V1_0/querygoodslist"
//商品订购
#define API_ORDER_CHARGE            @"/opssee-cms/V1_0/ordercharge"
//是否订购过
#define API_IF_PRINT_ALBUM          @"/opssee-cms/V1_0/ifprintalbum"
//生成订单号
#define API_FORMAT_ORDER_SERIAL     @"/opssee-cms/V1_0/formatorderserial"
//我的订购记录
#define API_MY_ORDER_CHARGE_RECORD  @"/opssee-cms/V1_0/myorderchargerecord"
//查询订单记录
#define API_QUERY_ORDER_STATUS      @"/opssee-cms/V1_0/queryorderstatus"
//获取相模板
#define API_QUERY_PHOTO_TEMPLET     @"/opssee-cms/V1_0/albumTemplateList"
//修改模板
#define API_CHANGE_PHOTO_TEMPLET     @"/opssee-cms/V1_0/changealbumtemplet"
//获取相册月份数据
#define API_ELECTRONIC_ALBUMLIST     @"/opssee-cms/V1_0/electronicalbumlist"



#endif /* APIMacros_h */
