//
//  LoginViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/29.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginViewModel.h"
@interface LoginViewController ()<GIDSignInDelegate,GIDSignInUIDelegate>

@property (strong, nonatomic) QMUIGhostButton *YTLoginButton;

@property (strong, nonatomic) QMUIGhostButton *FBLoginButton;

@property (strong, nonatomic) LoginViewModel *viewModel;

@property (strong, nonatomic) GIDSignIn *YTSignIn;

@property (strong, nonatomic) FBSDKLoginManager *FBSignIn;
@end

@implementation LoginViewController

#pragma mark - UI

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //facebook监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_accessTokenChanged:)
                                                 name:FBSDKAccessTokenDidChangeNotification
                                               object:nil];
}


- (void)initSubviews{
    [super initSubviews];
    
    self.YTLoginButton = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorRed];
    self.YTLoginButton.titleLabel.font = UIFontMake(14);
    [self.YTLoginButton setTitle:@"Connect with YouTube" forState:UIControlStateNormal];
    [self.YTLoginButton setImage:UIImageMake(@"ic_登陆_youtube") forState:UIControlStateNormal];
    self.YTLoginButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6);
    self.YTLoginButton.adjustsImageWithGhostColor = YES;
    [self.YTLoginButton addTarget:self action:@selector(handleYTButtonLoginEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.YTLoginButton];
    
    
    self.FBLoginButton = [[QMUIGhostButton alloc] initWithGhostColor:UIColorMake(70,115,214)];
    self.FBLoginButton.titleLabel.font = UIFontMake(14);
    [self.FBLoginButton setTitle:@"Connect with FaceBook" forState:UIControlStateNormal];
    [self.FBLoginButton setImage:UIImageMake(@"ic_登陆_facebook") forState:UIControlStateNormal];
    self.FBLoginButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 6);
    self.FBLoginButton.adjustsImageWithGhostColor = YES;
    [self.FBLoginButton addTarget:self action:@selector(handleFBButtonLoginEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.FBLoginButton];
    
 
}


-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    CGFloat buttonMinY =  CGRectGetHeight(self.view.bounds) - 80;
    CGFloat buttonSpacing = 30;
    CGSize  buttonSize = CGSizeMake(260, 40);
    CGFloat buttonMinX = CGFloatGetCenter(CGRectGetWidth(self.view.bounds), buttonSize.width);
    
    self.YTLoginButton.frame = CGRectFlatMake(buttonMinX, buttonMinY - (buttonSize.height *2) - buttonSpacing, buttonSize.width, buttonSize.height);
    
    self.FBLoginButton.frame = CGRectFlatMake(buttonMinX,  buttonMinY - buttonSize.height, buttonSize.width, buttonSize.height);
}


#pragma mark - Button Event

- (void)handleYTButtonLoginEvent{
    [self youTubeSignIn];

}


- (void)handleFBButtonLoginEvent{
   NSLog(@"FB 点击登录");
    [self facebookSignIn];
}

#pragma mark -  third login func

- (void)youTubeSignIn{
    if ([USER_INFO isYTLogin]) {
        NSLog(@"已经登录 无需再登录");
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(self.YTSignIn.hasAuthInKeychain){
        NSLog(@"已经缓存，快速登录");
        [self.YTSignIn signInSilently];
    }else{
        NSLog(@"YT 点击登录");
        [self.YTSignIn signIn];
    }
}

- (void)facebookSignIn{
    NSInteger slot = 0;
    FBSDKAccessToken *token = [SUCache itemForSlot:slot].token;
    if (token) {//是否已经登录
        [self.viewModel FBautoLoginWithToken:token viewController:self];
    }
    else {
        [self fbLoginEvent];
    }
}

- (void)fbLoginEvent{
 
    [self.FBSignIn logInWithPublishPermissions:@[ @"manage_pages", @"publish_pages"]
                    fromViewController:nil
                               handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
                                   if (error) {
                                       NSLog(@"facebook auth failed");
                                   }else if (result.isCancelled) {
                                       NSLog(@"facebook auth canceled");
                                   }else {
                                       [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
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
                                       [self.viewModel FBSignInServerWithResult:result viewController:self];
                                   }
                               }];
}

- (void)SignInServer:(GIDGoogleUser *)user{
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
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
    [self.viewModel YTSignInServerWithUser:user viewController:self];
    
}


#pragma mark - lazy func


- (LoginViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc]init];
    }
    return _viewModel;
}



- (FBSDKLoginManager *)FBSignIn{
    if (!_FBSignIn) {
        _FBSignIn = [[FBSDKLoginManager alloc] init];
        _FBSignIn.loginBehavior = FBSDKLoginBehaviorNative;
    }
    return _FBSignIn;
}

- (GIDSignIn *)YTSignIn{
    if (!_YTSignIn) {
        _YTSignIn = [GIDSignIn sharedInstance];
        _YTSignIn.delegate = self;
        _YTSignIn.uiDelegate = self;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _YTSignIn.clientID  = [infoDictionary objectForKey:@"CLIENT_ID"];
        _YTSignIn.scopes  = @[@"https://www.googleapis.com/auth/youtube"];
    }
    return _YTSignIn;
}


#pragma mark - Third login delegate
// The sign-in flow has finished and was successful if |error| is |nil|.
- (void)signIn:(GIDSignIn *)signIn
        didSignInForUser:(GIDGoogleUser *)user
        withError:(NSError *)error{
    if (error != nil) {
        NSLog(@"error %@",error);
        [MBProgressHUD showErrorMessage:@"登录失败,请检查网络"];
    }else{
        [self SignInServer:user];
    }
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
