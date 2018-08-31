//
//  DeviceViewCell.m
//  LiveCamera
//
//  Created by bigfish on 2018/8/30.
//  Copyright © 2018年 bigfish. All rights reserved.
//


#import "DeviceViewCell.h"
@interface DeviceViewCell()
@property (weak, nonatomic) IBOutlet UILabel *deviceNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;


@end

@implementation DeviceViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
   
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}



-(void)setFrame:(CGRect)frame
{
    frame.origin.x = 10;
    frame.size.width -= 2 * frame.origin.x;
    frame.size.height -= 2 * frame.origin.x;
    [super setFrame:frame];
}


@end
