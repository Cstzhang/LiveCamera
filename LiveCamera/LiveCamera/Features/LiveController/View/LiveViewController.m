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
typedef NS_ENUM(NSUInteger,LiveStatus){
    LiveStatusWait,//初始状态
    LiveStatusYTPrepare,//准备直播
    LiveStatusFBPrepare,//准备直播
    LiveStatusLive,//直播中
    LiveStatusRecord,//录屏中
};
static NSString *inputUrl =@"rtsp://admin:cvte123456@172.18.223.100:554/mpeg4/ch1/sub/av_stream";
//static NSString *inputUrl =@"rtsp://172.18.220.227/main";
@interface LiveViewController ()<GIDSignInDelegate,GIDSignInUIDelegate>
@property (nonatomic, strong) NodePlayer *clientPlayer;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (strong, nonatomic) QMUIGhostButton *YTLiveButton;
@property (strong, nonatomic) QMUIGhostButton *FBLiveButton;
@property (strong, nonatomic) QMUIGhostButton *recordButton;
@property (strong, nonatomic) QMUIFillButton *beginLiveButton;
@property (strong, nonatomic) UIButton  *livingButton;
@property (strong, nonatomic) UIButton  *recordingButton;
@property (strong, nonatomic) LiveViewModel *liveViewModel;
@property (strong, nonatomic) LoginViewModel *loginViewModel;
@property (strong, nonatomic) NodeStreamer *nodeStreamer;
@property (strong, nonatomic) GIDSignIn *YTSignIn;
@property (copy, nonatomic)   NSMutableString *broadCastId;
@property (nonatomic) LiveStatus currentLiveStatus;
@end



@implementation LiveViewController

#pragma mark - UI
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.clientPlayer start];
    //facebook监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_accessTokenChanged:)
                                                 name:FBSDKAccessTokenDidChangeNotification
                                               object:nil];
    self.currentLiveStatus = LiveStatusWait;
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
    
    
    self.beginLiveButton = [[QMUIFillButton alloc] initWithFillType:QMUIFillButtonColorRed];
    self.beginLiveButton.titleLabel.font = UIFontMake(14);
    [self.beginLiveButton setTitle:@"Begin To Live" forState:UIControlStateNormal];
    [self.beginLiveButton addTarget:self action:@selector(handleBeginLiveEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.beginLiveButton];
    
    self.livingButton = [[UIButton alloc]init];
    [self.livingButton setImage:[UIImage imageNamed:@"ic_直播中"] forState:UIControlStateNormal];
    self.livingButton.clipsToBounds = YES;
    self.livingButton.layer.cornerRadius = 40;
    [self.livingButton addTarget:self action:@selector(handleCloseLivingEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.livingButton];
    
    self.recordingButton = [[UIButton alloc]init];
    [self.recordingButton setImage:[UIImage imageNamed:@"ic_录制视频"] forState:UIControlStateNormal];
    self.recordingButton.clipsToBounds = YES;
    self.recordingButton.layer.cornerRadius = 40;
    [self.recordingButton addTarget:self action:@selector(handleCloseRecordingEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview: self.recordingButton];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat buttonMinY =  (CGRectGetHeight(self.view.bounds) - (20* kHScaleFit)) ;
    CGFloat buttonSpacing = 18 * kHScaleFit;
    CGSize  buttonSize = CGSizeMake(240 * kWScaleFit, 40 * kHScaleFit);
    CGSize  livebuttonSize = CGSizeMake(80 * kWScaleFit, 80 * kHScaleFit);
    CGFloat buttonMinX = CGFloatGetCenter(CGRectGetWidth(self.view.bounds), buttonSize.width);
    CGFloat livebuttonMinX = CGFloatGetCenter(CGRectGetWidth(self.view.bounds), livebuttonSize.width);
    
    self.YTLiveButton.frame = CGRectFlatMake(buttonMinX, buttonMinY - (buttonSize.height *3) - (buttonSpacing *2), buttonSize.width, buttonSize.height);

    self.FBLiveButton.frame = CGRectFlatMake(buttonMinX, buttonMinY - (buttonSize.height *2) - buttonSpacing, buttonSize.width, buttonSize.height);

    self.recordButton.frame = CGRectFlatMake(buttonMinX, buttonMinY - (buttonSize.height ), buttonSize.width, buttonSize.height);

    self.beginLiveButton.frame = CGRectFlatMake(buttonMinX, buttonMinY - (buttonSize.height ), buttonSize.width, buttonSize.height);
    
    self.livingButton.frame = CGRectFlatMake(livebuttonMinX, buttonMinY - (livebuttonSize.height ), livebuttonSize.width , livebuttonSize.height);
    
    self.recordingButton.frame = CGRectFlatMake(livebuttonMinX, buttonMinY - (livebuttonSize.height ), livebuttonSize.width , livebuttonSize.height);
}

-(void)viewWillDisappear:(BOOL)animated{
    [self stopLive];
    [self stopPlayer];
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    
}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    if(_clientPlayer){
     [self.clientPlayer start];
    }
}





#pragma mark - Button event

- (IBAction)backButtonEvent:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)handleBeginLiveEvent{
    switch (self.currentLiveStatus) {
        case LiveStatusFBPrepare:{
            self.currentLiveStatus = LiveStatusLive;
            [self geginToFBLive];
             break;
        }
            
           
        case LiveStatusYTPrepare:{
            self.currentLiveStatus = LiveStatusLive;
            [self beginToYTLive];
            break;
        }
        case LiveStatusWait:
            break;
        case LiveStatusLive:
            break;
        case LiveStatusRecord:
            break;
    }
}

- (void)handleCloseLivingEvent{
    [self stopLive];
    self.currentLiveStatus = LiveStatusWait;
 
}

- (void)handleCloseRecordingEvent{
//    [self stopLive];
    self.currentLiveStatus = LiveStatusWait;
}

- (void)handleRCButtonLiveEvent{
    self.currentLiveStatus = LiveStatusRecord;
    
    
}

- (void)setCurrentLiveStatus:(LiveStatus)currentLiveStatus{
    _currentLiveStatus = currentLiveStatus;
    switch (currentLiveStatus) {
        case LiveStatusWait:{
            self.FBLiveButton.hidden =NO;
            self.YTLiveButton.hidden =NO;
            self.recordButton.hidden =NO;
            self.beginLiveButton.hidden = YES;
            self.livingButton.hidden = YES;
            self.recordingButton.hidden = YES;
            break;
        }
        case LiveStatusYTPrepare:{
            self.FBLiveButton.hidden =YES;
            self.YTLiveButton.hidden =YES;
            self.recordButton.hidden =YES;
            self.beginLiveButton.hidden = NO;
            self.livingButton.hidden = YES;
            self.recordingButton.hidden = YES;
            break;
        }
        case LiveStatusFBPrepare:{
            self.FBLiveButton.hidden =YES;
            self.YTLiveButton.hidden =YES;
            self.recordButton.hidden =YES;
            self.beginLiveButton.hidden = NO;
            self.livingButton.hidden = YES;
            self.recordingButton.hidden = YES;
            break;
        }
        case LiveStatusLive:{
            self.FBLiveButton.hidden =YES;
            self.YTLiveButton.hidden =YES;
            self.recordButton.hidden =YES;
            self.beginLiveButton.hidden = YES;
            self.livingButton.hidden = NO;
            self.recordingButton.hidden = YES;
            break;
        }
        case LiveStatusRecord:{
            self.FBLiveButton.hidden =YES;
            self.YTLiveButton.hidden =YES;
            self.recordButton.hidden =YES;
            self.beginLiveButton.hidden = YES;
            self.livingButton.hidden = YES;
            self.recordingButton.hidden = NO;
            break;
        }
            
            
    }
}
/**
 start facebook live stream
 */
- (void)handleFBButtonLiveEvent{
    self.currentLiveStatus = LiveStatusFBPrepare;
    
    
}


/**
 start youtube live stream
 */
- (void)handleYTButtonLiveEvent{
    self.currentLiveStatus = LiveStatusYTPrepare;
    
}

- (void)geginToFBLive{
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
//        [MBProgressHUD showActivityMessageInWindow:@""];
        [self.loginViewModel FBlogin:self];
    }
}



- (void)beginToYTLive{

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
            NSDictionary *broadCastDict = returnValue[@"broadCastDict"];
            NSDictionary *streamDict = returnValue[@"streamDict"];
            NSString* ingestionAddress = streamDict[@"cdn"][@"ingestionInfo"][@"ingestionAddress"];
            NSString* streamName = streamDict[@"cdn"][@"ingestionInfo"][@"streamName"];
            NSString *outUrl = [NSString stringWithFormat:@"%@/%@",ingestionAddress,streamName];
            //开始推流
            [weakSelf startPushRTMPWithURL:outUrl];
            //开启计时，3秒后 获取直播间状态，如果是测试状态 ，改成直播状态即可 循环获取知道直播状态为liveStarting
            [weakSelf countdownToLive:broadCastDict status:@"testing"];
            
        } WithErrorBlock:^(NSString *error) {
            [MBProgressHUD hideHUD];
            [weakSelf loginYoutube];
        } WithFailureBlock:^(NSError *error) {
            [MBProgressHUD hideHUD];
            [weakSelf loginYoutube];
        }];
        [MBProgressHUD hideHUD];
        [MBProgressHUD showActivityMessageInWindow:@""];
        //creat createBroadcast bind
        [self.liveViewModel createBroadcastWith:ThirdTypeYouTube
                               BroadcastInfoDic:broadcastParameters
                              LiveStreamInfoDic:liveStreamParameters];
    }else{
        [self loginYoutube];
    }
}


/**
 倒计时10秒，然后检查直播状态 YT 等待客户端推流到youtube服务器
 */
- (void)countdownToLive:(NSDictionary *)broadCastDict status:(NSString *)status{
    ZBWeak;
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        if ([status isEqualToString:@"live"]){
            [weakSelf startFacebookLive:broadCastDict];
        }else{
           [weakSelf changeYouTubeLiveStatus:broadCastDict status:status];
        }
       
    });
    
}


/**
 turn  youtube live status to testStarting

 @param broadCastDict broadcast id
 @param status testing
 */
- (void)changeYouTubeLiveStatus:(NSDictionary *)broadCastDict status:(NSString *)status{
    ZBWeak;
    [self.liveViewModel setBlockWithReturnBlock:^(id returnValue) {
     
        NSString *lifeCycleStatus =returnValue[@"status"][@"lifeCycleStatus"];
        NSLog(@"lifeCycleStatus %@",lifeCycleStatus);
        if ([lifeCycleStatus isEqualToString:@"testStarting"]) {
            [weakSelf countdownToLive:broadCastDict status:@"live"];
        }else if ([lifeCycleStatus isEqualToString:@"ready"] || [lifeCycleStatus isEqualToString:@"active"] ){
            [weakSelf countdownToLive:broadCastDict status:@"testing"];
        }
    } WithErrorBlock:^(NSString *error) {
        [weakSelf countdownToLive:broadCastDict status:@"testing"];
    } WithFailureBlock:^(NSError *error) {
        [weakSelf countdownToLive:broadCastDict status:@"testing"];
    }];
    [MBProgressHUD hideHUD];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.liveViewModel transitionYouTubeBroadcastWith:broadCastDict[@"id"] status:status];
}

/**
 turn  youtube live status to liveStarting
 
 @param broadCastDict broadcast id
 */
- (void)startFacebookLive:(NSDictionary *)broadCastDict{
        ZBWeak;
    [self.liveViewModel setBlockWithReturnBlock:^(id returnValue) {
       NSString *lifeCycleStatus =returnValue[@"status"][@"lifeCycleStatus"];
       if ([lifeCycleStatus isEqualToString:@"liveStarting"]){
            [MBProgressHUD hideHUD];
            NSLog(@"!!!开始正式直播！！！！！！！！！！！！！！！");
            weakSelf.broadCastId = broadCastDict[@"id"];
            [MBProgressHUD showTipMessageInWindow:@"直播开始" timer:2];
       }else{
           [weakSelf countdownToLive:broadCastDict status:@"live"];
       }
    } WithErrorBlock:^(NSString *error) {
        [weakSelf countdownToLive:broadCastDict status:@"live"];

    } WithFailureBlock:^(NSError *error) {
        [weakSelf countdownToLive:broadCastDict status:@"live"];
    }];
     [MBProgressHUD hideHUD];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.liveViewModel transitionYouTubeBroadcastWith:broadCastDict[@"id"] status:@"live"];
}


- (void)finishYoutuLive{

    [self.liveViewModel setBlockWithReturnBlock:^(id returnValue) {
        NSString *lifeCycleStatus =returnValue[@"status"][@"lifeCycleStatus"];

        [MBProgressHUD hideHUD];
        NSLog(@"直播结束: %@",lifeCycleStatus);
        [MBProgressHUD showTipMessageInWindow:@"直播结束" timer:2];

    } WithErrorBlock:^(NSString *error) {
          [MBProgressHUD hideHUD];
        
    } WithFailureBlock:^(NSError *error) {
          [MBProgressHUD hideHUD];
    }];
    [MBProgressHUD hideHUD];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.liveViewModel transitionYouTubeBroadcastWith:self.broadCastId status:@"complete"];
}


- (void)stopPlayer{
    [self.clientPlayer stop];
}


- (void)stopLive{
    if(_clientPlayer && _nodeStreamer && _broadCastId){
        [self finishYoutuLive];
    }
    [self.nodeStreamer stopStreaming];
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

- (GIDSignIn *)YTSignIn{
    if (!_YTSignIn) {
        _YTSignIn = [GIDSignIn sharedInstance];
        _YTSignIn.delegate = self;
        _YTSignIn.uiDelegate = self;
        _YTSignIn.clientID  = CLIENT_ID;
        _YTSignIn.scopes  =  @[@"https://www.googleapis.com/auth/youtube.upload",
                               @"https://www.googleapis.com/auth/youtube",
                               @"https://www.googleapis.com/auth/youtube.force-ssl",
                               @"https://www.googleapis.com/auth/youtube.readonly"];
    }
    return _YTSignIn;
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

#pragma mark - youtube login

- (void)loginYoutube{
    [self.YTSignIn signIn];
}
- (void)SignInServer:(GIDGoogleUser *)user{
    [self.loginViewModel setBlockWithReturnBlock:^(id returnValue) {
        NSLog(@"login success %@",returnValue);
        [MBProgressHUD hideHUD];
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showErrorMessage:error];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
        [MBProgressHUD showErrorMessage:error.domain];
    }];
    [MBProgressHUD showActivityMessageInView:@""];
    [self.loginViewModel YTSignInServerWithUser:user viewController:self];
    
}

#pragma mark - Third login delegate
// The sign-in flow has finished and was successful if |error| is |nil|.
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user
     withError:(NSError *)error{
    if (error != nil) {
        NSLog(@"error %@",error);
        [MBProgressHUD showErrorMessage:@"登录失败,请检查网络"];
    }else{
        [self SignInServer:user];
    }
}



@end
