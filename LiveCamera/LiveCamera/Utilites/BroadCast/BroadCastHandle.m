//
//  BroadCastHandle.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/5.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "BroadCastHandle.h"
static BroadCastHandle * manager = nil;
@implementation BroadCastHandle

+(BroadCastHandle*)shared{

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[BroadCastHandle alloc]init];
        
    });
    return manager;
}

-(void)sendBroadCastWithPort:(UInt16)port
                     timeout:(NSTimeInterval)timeout
                 andCallBack:(callBackBlock)callBack {

    NSError * error = nil;
    //实例化
    self.udpSocket = [[AsyncUdpSocket alloc]initWithDelegate:self];

    self.callBackBlock = callBack;

    //绑定端口
     [self.udpSocket bindToPort:port error:&error];

     //发送广播设置
    [self.udpSocket enableBroadcast:YES error:&error];

   

    NSData * data = [@"v=1\r\nc=1\r\n" dataUsingEncoding:NSUTF8StringEncoding];
    /*
     发送请求
     sendData:发送的内容
     toHost:目标的ip
     port:端口号
     timeOut:请求超时
     */
    [self.udpSocket sendData:data
                      toHost:@"255.255.255.255"
                        port:port
                 withTimeout:2000 tag:1];
    //启动接收线程 - n?秒超时（-1表示死等）
    [self.udpSocket receiveWithTimeout:-1 tag:0];

}


/**
 停止广播
 */
- (void)closeBroadCast{
    
    [self.udpSocket closeAfterSendingAndReceiving];
}


#pragma mark asyncsocket 的代理方法

//已接收到消息

- (BOOL)onUdpSocket:(AsyncUdpSocket *)sock
     didReceiveData:(NSData *)data
            withTag:(long)tag
           fromHost:(NSString *)host
               port:(UInt16)port{
    #pragma mark - 两种情况在这回调：1，添加设备的时候 c=4然后去解密pw,能解，停止监听，
    #pragma mark - 2，设备列表检查IP更新，遍历设备SN ,修改已有设备的IP

    NSString *result;
    result = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    NSLog(@"============ didReceiveData result ============： \n%@",result);
    self.callBackBlock(result,port);
    NSLog(@" closeBroadCast %@",[UserDefaultUtil objectForKey:@"closeBroadCast"]);
    return NO;

}

//没有接受到消息

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"============ not received ============");

}

//没有发送出消息

-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"%@",error);
    NSLog(@"============ not send ============");

}

//已发送出消息

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    if (tag  == 0) {
        NSLog(@" ============   send   ============");
    }
 
}

//断开连接

-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{

    NSLog(@"============ onUdpSocketDidClose closed    ============");

}


@end
