//
//  DeviceListViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/29.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "DeviceListViewController.h"
#import "LoginViewController.h"
#import "DeviceViewCell.h"
#import "LiveViewController.h"
#import "DeviceListViewModel.h"
#import "AddWIFIViewController.h"
static int CELL_H=148;
static  CGFloat footViewH = 50;
static NSString *cellReuseIdentifier = @"DeviceViewCell";
@interface DeviceListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *devicesTableView;

@property (strong, nonatomic) NSMutableArray *devicesArray;

@property (strong, nonatomic) UIView *footView;

@property (strong, nonatomic) QMUIGhostButton *addButton;

@property (strong, nonatomic) DeviceListViewModel *deviceViewModel;

@property (strong, nonatomic) NSMutableArray *deviceArray;

@end

@implementation DeviceListViewController


#pragma mark - UI
- (void)viewDidLoad {
    [super viewDidLoad];
    //facebook监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(_accessTokenChanged:)
                                                 name:FBSDKAccessTokenDidChangeNotification
                                               object:nil];
    
    [self requestDeviceListData];
}


- (void)initSubviews{
    [super initSubviews];
    // add button
    self.addButton = [[QMUIGhostButton alloc] initWithGhostType:QMUIGhostButtonColorGray];
    self.addButton.titleLabel.font = UIFontMake(14);
    [self.addButton setTitle:@"Add Device" forState:UIControlStateNormal];
    [self.addButton setImage:UIImageMake(@"ic_按钮_添加设备") forState:UIControlStateNormal];
    self.addButton.imageEdgeInsets = UIEdgeInsetsMake(0, 14, 0, 8);
    self.addButton.adjustsImageWithGhostColor = YES;
    [self.addButton addTarget:self action:@selector(handleAddButtonEvent) forControlEvents:UIControlEventTouchUpInside];
    [self.footView addSubview:self.addButton];
    
    
    //tableview
    self.devicesTableView = [[UITableView alloc]init];
    _devicesTableView.backgroundColor=[UIColor clearColor];
    _devicesTableView.delegate=self;
    _devicesTableView.dataSource=self;
    _devicesTableView.separatorStyle = NO;
    _devicesTableView.tableFooterView.backgroundColor = [UIColor clearColor];
    _devicesTableView.tableHeaderView.backgroundColor = [UIColor clearColor];
    _devicesTableView.showsVerticalScrollIndicator = NO;//滑动条
    _devicesTableView.tableFooterView = self.footView;
    //注册
    [_devicesTableView registerNib:[UINib nibWithNibName:cellReuseIdentifier bundle:nil] forCellReuseIdentifier:cellReuseIdentifier];
    _devicesTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(onRefresh)];
    _devicesTableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(onNextPage)];
    [self.view addSubview:_devicesTableView];
    

}

- (void)setupNavigationItems {
    [super setupNavigationItems];
    self.title = @"Device List";
}


- (void)viewDidLayoutSubviews{
    self.devicesTableView.frame = CGRectMake(16, 74, SCREEN_WIDTH-32, SCREEN_HEIGHT-HEAD_TABBAR_HEIGHT);
    CGFloat buttonW = 170;
    CGFloat buttonH = 42;
    self.addButton.frame = CGRectFlatMake((SCREEN_WIDTH - buttonW) /2 -16, (footViewH -buttonH) /2 ,buttonW, buttonH);
}


#pragma mark - NetWork
- (void)requestDeviceListData{
    if (!USER_INFO.isLogin) {
        [self jumpTologin];
        return;
    }
    ZBWeak;
    [self.deviceViewModel setBlockWithReturnBlock:^(id returnValue) {
        
        [MBProgressHUD hideHUD];
        
        weakSelf.deviceArray = returnValue;
    } WithErrorBlock:^(NSString *error) {
        [MBProgressHUD hideHUD];
    } WithFailureBlock:^(NSError *error) {
        [MBProgressHUD hideHUD];
    }];
    [MBProgressHUD hideHUD];
    [MBProgressHUD showActivityMessageInWindow:@""];
    [self.deviceViewModel fetchDeviceList];
}


#pragma mark - EVENT
- (void)handleAddButtonEvent{
    NSLog(@"add device");
    AddWIFIViewController *addVc=[[AddWIFIViewController alloc]init];
    [self.navigationController pushViewController:addVc animated:YES];
}

-(void)jumpTologin{
    LoginViewController *loginVc=[[LoginViewController alloc]init];
    loginVc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:loginVc animated:YES completion:nil];

}

#pragma mark - tableview delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    LiveViewController *LiveVC = [[LiveViewController alloc]init];
    [self.navigationController pushViewController:LiveVC animated:YES];
}

#pragma mark - tableview datasource
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return CELL_H * (SCREEN_WIDTH/NORM_SCREEN_WIDTH);
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
//    return self.deviceArray.count;
    return 1;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellReuseIdentifier forIndexPath:indexPath];
    if (cell==nil) {
        cell=[[NSBundle mainBundle]loadNibNamed:cellReuseIdentifier owner:nil options:nil][0];
    }
    return cell;
}

#pragma mark - refresh
//刷新
-(void)onRefresh{
    [self.devicesTableView.mj_header endRefreshing];
}
//下一页
-(void)onNextPage{

    [self.devicesTableView.mj_footer endRefreshingWithNoMoreData];
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

#pragma mark - lazy func

- (UIView *)footView{
    if(!_footView){
        _footView = [[UIView alloc]init];
        _footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, footViewH);
    }
    return _footView;
}

- (DeviceListViewModel *)deviceViewModel{
    if (!_deviceViewModel) {
         _deviceViewModel = [[DeviceListViewModel alloc]init];
    }
    return _deviceViewModel;
}

- (NSMutableArray *)deviceArray{
    if (!_deviceArray) {
        _deviceArray = [[NSMutableArray alloc]init];
    }
    return _deviceArray;
}

@end
