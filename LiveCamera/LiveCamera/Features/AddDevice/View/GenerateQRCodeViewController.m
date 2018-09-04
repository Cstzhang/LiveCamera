//
//  GenerateQRCodeViewController.m
//  LiveCamera
//
//  Created by bigfish on 2018/9/4.
//  Copyright © 2018年 bigfish. All rights reserved.
//

#import "GenerateQRCodeViewController.h"

@interface GenerateQRCodeViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *qrImageView;

@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@end

@implementation GenerateQRCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.qrImageView.image = [UtilitesMethods imageOfQRFromURL:@"test" codeSize:175];
}
-(void)setupNavigationItems{
    [super setupNavigationItems];
    self.title = @"Scan QR Code";
}


- (IBAction)addEvent:(id)sender {
    
    
    
}


@end
