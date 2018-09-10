//
//  GenerateQRCodeViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/4.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "GenerateQRCodeViewController.h"
#import "AddDeviceViewModel.h"
#import "BondedDeviceViewModel.h"
#import "BroadCastHandle.h"

@interface GenerateQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@property (weak, nonatomic) IBOutlet UIButton *addButton;

@property (strong, nonatomic) AddDeviceViewModel *addViewModel;

@property (strong, nonatomic) BondedDeviceViewModel *bondedViewModel;

@property (strong, nonatomic) BroadCastHandle *broadCastHandle;

@property (copy, nonatomic) NSString *deviveHost;
@property (strong, nonatomic) NSDictionary   *deviveInfo;
@property (assign, nonatomic) UInt16   devivePort;
@end

@implementation GenerateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.qrImageView.image = [UtilitesMethods imageOfQRFromURL:_qrUrl codeSize:175];
    self.checkButton.selected = NO;
    [self addDevicesbroadCast];
    self.checkButton.enabled = NO;
}
-(void)setupNavigationItems{
    [super setupNavigationItems];
    self.title = @"Scan QR Code";
}



#pragma mark - event

- (IBAction)checkEvent:(id)sender {
    self.checkButton.selected =  !self.checkButton.selected;
    
}

- (IBAction)addEvent:(id)sender {
    if(!self.checkButton.isSelected){
        [MBProgressHUD showWarnMessage:@"请确认指示灯已经是绿色"];
        return;
    }

   
    [self bindDevice:self.deviveInfo port:self.devivePort];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    

}


#pragma mark - NetWork
- (void)addDevicesbroadCast{
    self.broadCastHandle = [BroadCastHandle shared];
    [UserDefaultUtil setObject:broadCastTypeAdd forKey:broadCastType];

    ZBWeak;
    dispatch_async(dispatch_queue_create(0, 0), ^{
        
        weakSelf.broadCastHandle = [BroadCastHandle shared];
        
        [weakSelf.broadCastHandle sendBroadCastWithPort:13702 timeout:30 andCallBack:^(id sender, UInt16 port) {
            NSString *result = sender;
            if ([result rangeOfString:@"c=4"].location != NSNotFound) {
                NSDictionary *resultDic = [UtilitesMethods sdpSeparatedString:result];
                NSLog(@"c=4   resultDic  %@ ",resultDic);
                dispatch_async(dispatch_get_main_queue(), ^{
                    // 通知主线程刷新 神马的
                    //            NSString *spw = resultDic[@"spw"];
                    //            if ([spw isEqualToString:@"cvte123456"]) {
                    self.deviveInfo = resultDic;
                    self.devivePort = port;
                     weakSelf.checkButton.enabled = YES;
                     [weakSelf.broadCastHandle closeBroadCast];
                    //            }
                });
                
            }
        }];
        
        [[NSRunLoop currentRunLoop] run];
        // 子线程执行任务（比如获取较大数据）
    });

  
    
}


- (void)bindDevice:(NSDictionary *)info port:(UInt16)port{
    NSDictionary *deviceInfo = @{
                             @"deviceSn":info[@"sn"],
                             @"deviceIp":info[@"ip"],
                             @"devicePort":[NSString stringWithFormat:@"%d",port],
                             @"deviceAccount":info[@"user"],
                             @"devicePassword":info[@"spw"],
                             @"deviceSv":info[@"sv"],
                             @"deviceOnvif":info[@"ip"],
                             @"devicePn":info[@"pn"],
                             };
    self.deviveHost =[NSString stringWithFormat:@"%@:%hu",info[@"ip"],port];
    ZBWeak;
    [self.addViewModel setBlockWithReturnBlock:^(id returnValue) {
        [MBProgressHUD hideHUD];
        NSLog(@"add success returnValue %@",returnValue);
        //调用QEBING 接口
        [weakSelf qrBindDevice];
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error timer:1.5];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error.domain timer:1.5];
    }];
    [self.addViewModel BondedDevice:deviceInfo];
}


- (void)qrBindDevice{
    if (!self.deviveHost) {
        return;
    }
    ZBWeak;
    [self.addViewModel setBlockWithReturnBlock:^(id returnValue) {
        [MBProgressHUD hideHUD];
        NSLog(@"add success returnValue %@",returnValue);
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
        //调用QEBING 接口
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error timer:1.5];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error.domain timer:1.5];
    }];
    [self.addViewModel qrBind:self.deviveHost ];
}



/**
 sdp字符串处理 返回字典

 @param tmpString sdp 字符串
 @return 解析字典
 */
- (NSDictionary *)sdpSeparatedString:(NSString *)tmpString{
    NSArray *contentArr = [tmpString componentsSeparatedByString:@"\n"];
    NSMutableDictionary *resultDic = [[NSMutableDictionary alloc]init];
    for (NSString *string in contentArr) {
        NSArray *tmpArr = [string componentsSeparatedByString:@"="];
        [resultDic setObject:tmpArr[1] forKey:tmpArr[0]];
    }
    
    
    NSLog(@"resultDic %@",resultDic);
    return resultDic;
}


#pragma mark - http

- (void)addDevice:(NSDictionary *)deviceInfo{
    ZBWeak;
    [self.addViewModel setBlockWithReturnBlock:^(id returnValue) {
        [MBProgressHUD hideHUD];
        NSLog(@"returnValue %@",returnValue);
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error timer:1.5];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error.domain timer:1.5];
    }];
    [MBProgressHUD showActivityMessageInView:@""];
    [self.addViewModel BondedDevice:deviceInfo];
}


#pragma mark - lazy func

- (AddDeviceViewModel *)addViewModel{
    if(!_addViewModel){
        _addViewModel = [[AddDeviceViewModel alloc]init];
    }
    return _addViewModel;
}

- (BondedDeviceViewModel *)bondedViewModel{
    if(!_bondedViewModel){
        _bondedViewModel = [[BondedDeviceViewModel alloc]init];
        
    }
    return _bondedViewModel;
}


@end
