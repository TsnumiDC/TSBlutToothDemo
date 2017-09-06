//
//  TSDeviceCell.h
//  TSBlueToothDemo
//
//  Created by Dylan Chen on 2017/9/6.
//  Copyright © 2017年 Dylan Chen. All rights reserved.
//  55

#import <UIKit/UIKit.h>

@interface TSDeviceCell : UITableViewCell


@property (strong, nonatomic)UILabel * titleLabel;//名称

@property (strong, nonatomic)UILabel * detailLabel;//内容


+(instancetype)cellWithTableView:(UITableView *)tableView;


@end
