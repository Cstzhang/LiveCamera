//
//  ACMacros.h
//  opsseeBaby
//
//  Created by zhangzb on 2018/2/27.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#ifndef ACMacros_h
#define ACMacros_h

#define TabbarItemNums 3.0 //tabbar 数量 一定要记得改

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000 // 当前Xcode支持iOS8及以上

#define SCREEN_WIDTH ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.width)
#define SCREENH_HEIGHT ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale:[UIScreen mainScreen].bounds.size.height)
#define SCREEN_SIZE ([[UIScreen mainScreen] respondsToSelector:@selector(nativeBounds)]?CGSizeMake([UIScreen mainScreen].nativeBounds.size.width/[UIScreen mainScreen].nativeScale,[UIScreen mainScreen].nativeBounds.size.height/[UIScreen mainScreen].nativeScale):[UIScreen mainScreen].bounds.size)
#else
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size
#endif

#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
//设计屏幕宽度 IPHONE 6 的尺寸作为基准
#define NORM_SCREEN_WIDTH 375
//随机颜色
#define KRandomColor [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0]
//RGB转UIColor（不带alpha值）
#define UIColorFromRGB(rgbValue) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
//RGB转UIColor（带alpha值）
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor  colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0  green:((float)((rgbValue & 0xFF00) >> 8))/255.0  blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]
//返回一个RGBA格式的UIColor对象
#define RGBA(r, g, b, a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

//返回一个RGB格式的UIColor对象
#define RGB(r, g, b) RGBA(r, g, b, 1.0f)
#define TITLE_COLOR [UIColor blackColor]//标题颜色
#define TEXT_COLOR [UIColor grayColor]//正文颜色
#define TIPTEXT_COLOR UIColorFromRGB(0x888888)//提示语文本颜色
#define MAIN_GROUNDCOLOR UIColorFromRGB(0x2ab1e7)//主题景色
#define BACKGROUNDCOLOR UIColorFromRGB(0xF7F7F7)//背景颜色

//主题色
#define MAIN_COLOR  UIColorFromRGB(0x77EBE3)
//tab选中颜色
# define TABBAR_SELECT_TINTCOLOR [UIColor colorWithRed:244/255.0 green:190/255.0 blue:65/255.0 alpha:1.0]
//tab未选中颜色
# define TABBAR_NORMAL_TINTCOLOR [UIColor whiteColor]

//常用字体大小
#define TITLE_FONT [UIFont systemFontOfSize:18]
#define TEXT_FONT [UIFont systemFontOfSize:16]
#define TIP_TEXT_FONT [UIFont systemFontOfSize:12]


//app中统一的一些size定义
#define kNavigationBarHeight  64.0

#define CELL_HEIGHT 50 //cell高度
#define LEFT_ORIGIN 20 //控件左边距
#define BUTTON_HEIGHT 45 //按钮高度
#define BUTTON_WIDTH SCREEN_WIDTH - LEFT_ORIGIN * 2
#define BUTTON_LAYER_CORNER_RADIUS 2 //按钮圆角
#define LINE_COLOR UIColorFromRGB(0x464646) //线条颜色
#define LINE_WIDTH 0.5f //线条粗度
#define WHITE_COLOR [UIColor whiteColor]
#define CLEAR_COLOR [UIColor clearColor]

//h264 解码后宽高(设置的时候是反过来的)
#define h264outputWidth  SCREEN_WIDTH*9/16
#define h264outputHeight SCREEN_WIDTH
//自适应高度和宽度
#define HEIGHT_RATIO_6 (SCREENH_HEIGHT / 667)
#define WIDTH_RATIO_6 (SCREEN_WIDTH / 475)
//比例数
#define RATIO_H(number) number*HEIGHT_RATIO_6
#define RATIO_W(number) number*WIDTH_RATIO_6
// 等比例适配系数
#define kScaleFit (SCREEN_WIDTH / 375.0f)


#endif /* ACMacros_h */
