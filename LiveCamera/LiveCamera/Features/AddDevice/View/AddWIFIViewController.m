//
//  AddWIFIViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/4.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "AddWIFIViewController.h"
#import "GenerateQRCodeViewController.h"
@interface AddWIFIViewController ()
@property (weak, nonatomic) IBOutlet UITextField *wifiNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *wifiPasswordLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextStapButton;

@end

@implementation AddWIFIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.wifiNameLabel.text = [UtilitesMethods getWifiName];
}

-(void)setupNavigationItems{
    [super setupNavigationItems];
     self.title = @"Add Device";
}

- (IBAction)nextStapEvent:(id)sender {
    GenerateQRCodeViewController *addVc=[[GenerateQRCodeViewController alloc]init];
    [self.navigationController pushViewController:addVc animated:YES];

}

@end
