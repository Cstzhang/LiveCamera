//
//  ViewModelClass.m
//  opsseeBaby
//
//  Created by zhangzb on 2018/3/8.
//  Copyright © 2018年 Guangzhou Shirui Electronics Co., Ltd. All rights reserved.
//

#import "ViewModelClass.h"
#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"
#define CopyString(temp) (temp != NULL)? strdup(temp):NULL
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#include <sys/socket.h>
#include <netdb.h>
#include <arpa/inet.h>
#include <err.h>
@implementation ViewModelClass
#pragma 获取网络可到达状态
- (void)netWorkStateWithNetConnectBlock:(NetWorkBlock)
netConnectBlock WithURlStr:(NSString *) strURl;
{
    BOOL netState = [ZBNetManager netWorkReachabilityWithURLString:strURl];
    netConnectBlock(netState);
}

#pragma 接收传过来的block
- (void)setBlockWithReturnBlock: (ReturnValueBlock) returnBlock
                 WithErrorBlock: (ErrorCodeBlock) errorBlock
               WithFailureBlock: (FailureBlock) failureBlock
{
    _returnBlock = returnBlock;
    _errorBlock = errorBlock;
    _failureBlock = failureBlock;
}







@end
