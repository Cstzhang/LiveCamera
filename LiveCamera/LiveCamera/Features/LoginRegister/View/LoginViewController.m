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

@property (strong, nonatomic) GIDSignIn *signIn;
@end

@implementation LoginViewController

#pragma mark - UI

- (void)viewDidLoad {
    [super viewDidLoad];

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
}




#pragma mark -  callBack func

- (void)youTubeSignIn{
    if (USER_INFO.isYTSinIn) {
        NSLog(@"已经登录 无需再登录");
        [self dismissViewControllerAnimated:YES completion:nil];
    }else if(_signIn.hasAuthInKeychain){
        NSLog(@"已经缓存，快速登录");
        [_signIn signInSilently];
    }else{
        NSLog(@"YT 点击登录");
        [self.signIn signIn];
    }
}

- (void)SignInServer:(GIDGoogleUser *)user{
    [self.viewModel setBlockWithReturnBlock:^(id returnValue) {
        
    } WithErrorBlock:^(NSString *error) {
        
    } WithFailureBlock:^(NSError *error) {
        
    }];
    
    [self.viewModel YTSignInServerWithUser:user viewController:self];
    
}


#pragma mark - lazy func


- (LoginViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc]init];
    }
    return _viewModel;
}


- (GIDSignIn *)signIn{
    if (!_signIn) {
        _signIn = [GIDSignIn sharedInstance];
        _signIn.delegate = self;
        _signIn.uiDelegate = self;
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _signIn.clientID  = [infoDictionary objectForKey:@"CLIENT_ID"];
        _signIn.scopes  = @[@"https://www.googleapis.com/auth/youtube"];
    }
    return _signIn;
}


#pragma mark - Third login
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


@end
