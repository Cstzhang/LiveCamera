//
//  BroadCastHandle.h
//  LiveCamera
//
//  Created by bigfish on 2018/9/5.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"
#import "GCDAsyncSocket.h"

typedef void(^callBackBlock)(id sender,UInt16 port);

@interface BroadCastHandle : NSObject<AsyncUdpSocketDelegate,GCDAsyncSocketDelegate>{
    NSMutableArray * allClientArray;//获取到的客户端数组
}

@property (nonatomic,strong)AsyncUdpSocket * udpSocket;

@property (nonatomic,strong)GCDAsyncSocket * gcdSocket;

@property (nonatomic,copy)callBackBlock callBackBlock;

@property (nonatomic,copy)callBackBlock getIPBlock;

+(BroadCastHandle*)shared;

-(void)sendBroadCastWithPort:(UInt16)port andCallBack:(callBackBlock)callBack;

-(void)gcdSocketGetIPWithPort:(UInt16)port andCallBack:(callBackBlock)callBack;
@end
