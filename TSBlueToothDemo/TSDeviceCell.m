//
//  TSDeviceCell.m
//  TSBlueToothDemo
//
//  Created by Dylan Chen on 2017/9/6.
//  Copyright © 2017年 Dylan Chen. All rights reserved.
//

#import "TSDeviceCell.h"

@interface TSDeviceCell()



@end
@implementation TSDeviceCell


+(instancetype)cellWithTableView:(UITableView *)tableView
{
    NSString * identifity=NSStringFromClass([self class]);
    [tableView registerClass:[self class] forCellReuseIdentifier:identifity];
    TSDeviceCell *cell=[tableView dequeueReusableCellWithIdentifier:identifity];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    if (cell==nil) {
        cell=[[TSDeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifity];
    }
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.titleLabel];
        [self.contentView addSubview:self.detailLabel];
        
        [self _layoutSubviews];
    }
    return  self;
}

- (void)_layoutSubviews
{
    self.titleLabel.frame = CGRectMake(30, 0, [UIScreen mainScreen].bounds.size.width, 24);
    self.detailLabel.frame = CGRectMake(30, 24, [UIScreen mainScreen].bounds.size.width, 24);

}

- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont systemFontOfSize:14];
    }
    return _titleLabel;
}

- (UILabel *)detailLabel{
    if (_detailLabel == nil) {
        _detailLabel = [UILabel new];
        _detailLabel.font = [UIFont systemFontOfSize:12];
    }
    return _detailLabel;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
