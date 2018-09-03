//
//  LiveViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/29.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "LiveViewController.h"
#import "LoginViewModel.h"
#import "LiveViewModel.h"
#import "LoginViewController.h"
static NSString *inputUrl =@"rtsp://admin:cvte123456@172.18.223.100:554/mpeg4/ch1/sub/av_stream";

@interface LiveViewController ()
@property (nonatomic, strong) NodePlayer *clientPlayer;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (strong, nonatomic) QMUIGhostButton *YTLiveButton;
@property (strong, nonatomic) QMUIGhostButton *FBLiveButton;
@property (strong, nonatomic) QMUIGhostButton *recordButton;
@property (strong, nonatomic) LiveViewModel *liveViewModel;
@property (strong, nonatomic) LoginViewModel *loginViewModel;
@property (strong, nonatomic) NodeStreamer *nodeStreamer;

@end

@implementation LiveViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.clientPlayer start];
    //facebook监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_accessTokenChanged:)
                                                 name:FBSDKAccessTokenDidChangeNotification
                                               object:nil];
}


- (void)initSubviews{
    [super initSubviews];
    self.YTLiveButton = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorRed];
    self.YTLiveButton.titleLabel.font = UIFontMake(14);
    [self.YTLiveButton setTitle:@"Connect with YouTube" forState:UIControlStateNormal];
    [self.YTLiveButton setImage:UIImageMake(@"ic_登陆_youtube") forState:UIControlStateNormal];
    self.YTLiveButton.imageEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 8);
    self.YTLiveButton.adjustsImageWithGhostColor = YES;
    [self.YTLiveButton addTarget:self action:@selector(handleYTButtonLiveEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.YTLiveButton];
    
    
    self.FBLiveButton = [[QMUIGhostButton alloc] initWithGhostColor:UIColorMake(70,115,214)];
    self.FBLiveButton.titleLabel.font = UIFontMake(14);
    [self.FBLiveButton setTitle:@"Connect with FaceBook" forState:UIControlStateNormal];
    [self.FBLiveButton setImage:UIImageMake(@"ic_登陆_facebook") forState:UIControlStateNormal];
    self.FBLiveButton.imageEdgeInsets = UIEdgeInsetsMake(0, 20, 0, 8);
    self.FBLiveButton.adjustsImageWithGhostColor = YES;
    [self.FBLiveButton addTarget:self action:@selector(handleFBButtonLiveEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.FBLiveButton];
    
    self.recordButton = [[QMUIGhostButton alloc] initWithGhostColor:UIColorWhite];
    self.recordButton.titleLabel.font = UIFontMake(14);
    [self.recordButton setTitle:@"Record Video" forState:UIControlStateNormal];
    [self.recordButton setImage:UIImageMake(@"ic_登陆_录制视频") forState:UIControlStateNormal];
    self.recordButton.imageEdgeInsets = UIEdgeInsetsMake(0, -42, 0, 8);
    self.recordButton.adjustsImageWithGhostColor = YES;
    [self.recordButton addTarget:self action:@selector(handleRCButtonLiveEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.recordButton];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat buttonMinY =  CGRectGetHeight(self.view.bounds) - 80;
    CGFloat buttonSpacing = 20;
    CGSize  buttonSize = CGSizeMake(240, 40);
    CGFloat buttonMinX = CGFloatGetCenter(CGRectGetWidth(self.view.bounds), buttonSize.width);
    
    self.YTLiveButton.frame = CGRectFlatMake(buttonMinX, buttonMinY - (buttonSize.height *3) - (buttonSpacing *2), buttonSize.width, buttonSize.height);
    
    self.FBLiveButton.frame = CGRectFlatMake(buttonMinX, buttonMinY - (buttonSize.height *2) - buttonSpacing, buttonSize.width, buttonSize.height);
    
    self.recordButton.frame = CGRectFlatMake(buttonMinX,  buttonMinY - buttonSize.height, buttonSize.width, buttonSize.height);
}




-(void)viewWillDisappear:(BOOL)animated{
    [self.clientPlayer stop];
    [self.nodeStreamer stopStreaming];
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}



#pragma mark - Button event
- (IBAction)backButtonEvent:(id)sender {
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)jumpTologin{
    LoginViewController *loginVc=[[LoginViewController alloc]init];
    loginVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:loginVc animated:YES completion:nil];
    
}
/**
 start youtube live stream
 */
- (void)handleYTButtonLiveEvent{
     //data
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss"];
    NSTimeInterval secondsInEightHours = 3 * 60 ;
    NSDate *dateEightHoursAhead = [[NSDate date] dateByAddingTimeInterval:secondsInEightHours];
    NSString *dateString = [formatter stringFromDate:dateEightHoursAhead];
    NSString *time = [NSString stringWithFormat:@"%@+00:00",dateString];
    NSDictionary *broadcastParameters = @{ @"snippet": @{ @"title":@"CVTE Hello World!",
                                                 @"scheduledStartTime":time,
                                                 @"description":@"CVTE直播间"},
                                  @"status": @{ @"privacyStatus": @"public" }

                                };
    NSDictionary *liveStreamParameters = @{
                              @"snippet": @{ @"title": @"CVTE Hello World!",
                                             @"description": @"CVTE直播间" },
                                  @"cdn": @{ @"resolution": @"720p",
                                             @"frameRate": @"60fps" ,
                                             @"ingestionType":@"rtmp"},
                        @"ingestionInfo": @{ @"streamName": @"CVTE" }
                                          };
    if ([UserDefaultUtil valueForKey:YT_ACCESS_TOKEN]) {
        ZBWeak;
        [self.liveViewModel setBlockWithReturnBlock:^(id returnValue) {
            [MBProgressHUD hideHUD];
            NSDictionary * broadCastDict = returnValue[@"broadCastDict"];
            NSDictionary * streamDict = returnValue[@"streamDict"];
//            NSString* broadcastStatus = broadCastDict[@"status"][@"lifeCycleStatus"];
//            NSString* streamStatus = streamDict[@"status"][@"streamStatus"];
//            NSString* healthStatus = streamDict[@"status"][@"healthStatus"][@"status"];
            NSString* ingestionAddress = streamDict[@"cdn"][@"ingestionInfo"][@"ingestionAddress"];
            NSString* streamName = streamDict[@"cdn"][@"ingestionInfo"][@"streamName"];
            NSString *outUrl = [NSString stringWithFormat:@"%@/%@",ingestionAddress,streamName];
            //开始推流
            [weakSelf startPushRTMPWithURL:outUrl];
            [weakSelf countdownToLive:broadCastDict status:@"testing"];
            //开启计时，10秒后 获取直播间状态，如果是测试状态 ，改成直播状态即可
            
          
        } WithErrorBlock:^(NSString *error) {
            [MBProgressHUD hideHUD];
            NSLog(@"===需要登录============== ");
//                [weakSelf jumpTologin];
        } WithFailureBlock:^(NSError *error) {
            [MBProgressHUD hideHUD];
            if (error.code == -1011) {
                 NSLog(@"-================error.code ================- %ld",(long)error.code);
                 NSLog(@"===需要登录==============");
            }
            NSLog(@"error.code  %ld",(long)error.code);
//                [weakSelf jumpTologin];
        }];
        [MBProgressHUD showActivityMessageInWindow:@""];
        //creat createBroadcast bind
        [self.liveViewModel createBroadcastWith:ThirdTypeYouTube BroadcastInfoDic:broadcastParameters LiveStreamInfoDic:liveStreamParameters];
        
    }else{
//        [self jumpTologin];
        NSLog(@"===需要登录==============");
    }

}


/**
 倒计时10秒，然后检查直播状态 YT 等待客户端推流到youtube服务器
 */
- (void)countdownToLive:(NSDictionary *)broadCastDict status:(NSString *)status{
    ZBWeak;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [weakSelf changeYouTubeLiveStatus:broadCastDict status:status];
    });
    
}

- (void)changeYouTubeLiveStatus:(NSDictionary *)broadCastDict status:(NSString *)status{
    ZBWeak;
    [self.liveViewModel setBlockWithReturnBlock:^(id returnValue) {
        [MBProgressHUD hideHUD];
        NSString *lifeCycleStatus =returnValue[@"status"][@"lifeCycleStatus"];
        NSLog(@"lifeCycleStatus %@",lifeCycleStatus);
        if ([lifeCycleStatus isEqualToString:@"testStarting"]) {
            [weakSelf countdownToLive:broadCastDict status:@"live"];
        }else if ([lifeCycleStatus isEqualToString:@"ready"] || [lifeCycleStatus isEqualToString:@"active"] ){
            [weakSelf countdownToLive:broadCastDict status:@"testing"];
        }else if ([lifeCycleStatus isEqualToString:@"liveStarting"]){
            NSLog(@"!!!开始正式直播！！！！！！！！！！！！！！！");
        }
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error timer:1.5];
        [weakSelf countdownToLive:broadCastDict status:@"testing"];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error.domain timer:1.5];
        [weakSelf countdownToLive:broadCastDict status:@"testing"];
    }];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.liveViewModel transitionYouTubeBroadcastWith:broadCastDict[@"id"] status:status];
    // [weakSelf.liveViewModel transitionYouTubeBroadcastWith:broadCastDict[@"id"] status:@"live"];
}

- (void)startFacebookLive:(NSDictionary *)broadCastDict{
    //    ZBWeak;
    [self.liveViewModel setBlockWithReturnBlock:^(id returnValue) {
        [MBProgressHUD hideHUD];
        
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error timer:1.5];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showTipMessageInWindow:error.domain timer:1.5];
    }];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.liveViewModel transitionYouTubeBroadcastWith:broadCastDict[@"id"] status:@"live"];
}


/**
 start facebook live stream
 */
- (void)handleFBButtonLiveEvent{
    NSDictionary *param = @{
                            @"description":@"CVTE直播间",
                            @"title":@"CVTE Hello World!",
                            @"privacy":@{@"value":@"EVERYONE"},
                            };
    ZBWeak;
    if ([USER_INFO isFBLogin]) {
        [self.liveViewModel setBlockWithReturnBlock:^(id returnValue) {
            [MBProgressHUD hideHUD];
            NSString *outUrl = returnValue[@"stream_url"];
            [weakSelf startPushRTMPWithURL:outUrl];
        } WithErrorBlock:^(NSString *error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showTipMessageInWindow:error timer:1.5];
        } WithFailureBlock:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showTipMessageInWindow:error.domain timer:1.5];
        }];
        [MBProgressHUD showActivityMessageInWindow:@""];
        [self.liveViewModel createBroadcastWith:ThirdTypeFacebook BroadcastInfoDic:param LiveStreamInfoDic:nil];
    }else{
//        [self jumpTologin];
        [self.loginViewModel setBlockWithReturnBlock:^(id returnValue) {
            NSLog(@"login success %@",returnValue);
            [MBProgressHUD hideHUD];
        } WithErrorBlock:^(NSString *error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showTipMessageInWindow:error timer:1.5];
        } WithFailureBlock:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [MBProgressHUD showTipMessageInWindow:error.domain timer:1.5];
        }];
        [MBProgressHUD showActivityMessageInWindow:@""];
        [self.loginViewModel FBlogin:self];
    }
   
}

- (void)handleRCButtonLiveEvent{

    
    
    
    
    
    
    
}



#pragma mark - lazy func
- (NodePlayer *)clientPlayer{
    if (!_clientPlayer) {
        _clientPlayer = [[NodePlayer alloc]init];
        _clientPlayer.playerView = self.view;
        [_clientPlayer setInputUrl:inputUrl];
        [_clientPlayer setContentMode:1];
    }
    return _clientPlayer;
}

- (LiveViewModel *)liveViewModel{
    if (!_liveViewModel) {
        _liveViewModel = [[LiveViewModel alloc]init];
    }
    return _liveViewModel;
}

- (LoginViewModel *)loginViewModel{
    if (!_loginViewModel) {
        _loginViewModel = [[LoginViewModel alloc]init];
    }
    return _loginViewModel;
}

- (NodeStreamer *)nodeStreamer{
    if (!_nodeStreamer) {
        _nodeStreamer  = [[NodeStreamer alloc]init];
        _nodeStreamer.rtspTransport = RTSP_TRANSPORT_TCP;
    }
    return _nodeStreamer;
}


#pragma mark - live streamer

- (void)startPushRTMPWithURL:(NSString *)stream_url{
    
    [self.nodeStreamer startStreamingWithInput:inputUrl output:stream_url];
    
}
#pragma mark - Notification
- (void)_accessTokenChanged:(NSNotification *)notification
{
    FBSDKAccessToken *token = notification.userInfo[FBSDKAccessTokenChangeNewKey];
    if (!token) {
        [FBSDKAccessToken setCurrentAccessToken:nil];
        [FBSDKProfile setCurrentProfile:nil];
    } else {
        NSInteger slot = 0;
        SUCacheItem *item = [SUCache itemForSlot:slot] ?: [[SUCacheItem alloc] init];
        if (![item.token isEqualToAccessToken:token]) {
            item.token = token;
            [SUCache saveItem:item slot:slot];
        }
    }
}
@end
