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
static int CELL_H=148;
static NSString *cellReuseIdentifier = @"DeviceViewCell";
@interface DeviceListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (strong, nonatomic) UITableView *devicesTableView;

@property (strong, nonatomic) NSMutableArray *devicesArray;

@end

@implementation DeviceListViewController


#pragma mark - UI
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)initSubviews{
    [super initSubviews];
    //tableview
    self.devicesTableView = [[UITableView alloc]init];
    _devicesTableView.backgroundColor=[UIColor clearColor];
    _devicesTableView.delegate=self;
    _devicesTableView.dataSource=self;
    _devicesTableView.separatorStyle = NO;
    _devicesTableView.tableFooterView.backgroundColor = [UIColor clearColor];
    _devicesTableView.tableHeaderView.backgroundColor = [UIColor clearColor];
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
}
#pragma mark - TEST
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (![USER_INFO isYTLogin]) {
        [self jumpTologin];
    }
}



#pragma mark - EVENT

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
    return 0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    return CELL_H * (SCREEN_WIDTH/NORM_SCREEN_WIDTH);
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 8;
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

@end
