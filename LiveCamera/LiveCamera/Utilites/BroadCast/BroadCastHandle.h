//
//  BroadCastHandle.h
//  LiveCamera
//
//  Created by bigfish on 2018/9/5.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncUdpSocket.h"


typedef void(^callBackBlock)(id sender,UInt16 port);

@interface BroadCastHandle : NSObject<AsyncUdpSocketDelegate>{
    NSMutableArray * allClientArray;//获取到的客户端数组
}

@property (nonatomic,strong)AsyncUdpSocket * udpSocket;


@property (nonatomic,copy)callBackBlock callBackBlock;



+(BroadCastHandle*)shared;

-(void)sendBroadCastWithPort:(UInt16)port timeout:(NSTimeInterval)timeout andCallBack:(callBackBlock)callBack ;

- (void)closeBroadCast;

@end
