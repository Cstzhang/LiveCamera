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
    if(![self checkData]){
        return;
    }
    GenerateQRCodeViewController *addVc=[[GenerateQRCodeViewController alloc]init];
    NSString *qrKey = [UtilitesMethods getCurrentTime];
    [UserDefaultUtil setObject:qrKey forKey:@"qrKey"];
    NSString *url = [NSString stringWithFormat:@"cvt_account=%@,cvt_password=%@,cvt_key=%@",_wifiNameLabel.text,_wifiPasswordLabel.text,qrKey];
    NSLog(@"url %@",url);
    addVc.qrUrl = url;
    [self.navigationController pushViewController:addVc animated:YES];

}




#pragma mark - check
- (BOOL)checkData{
    if(_wifiNameLabel.text.length == 0 || _wifiPasswordLabel.text.length == 0){
        [MBProgressHUD showWarnMessage:@"请填写WIFI信息"];
        return NO;
    }
    return YES;
    
}
@end
