//
//  Pano720TableViewCell.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "Pano720PhotoModel.h"

#define cellImgHeight (Kwidth - 39.0 - 15.0f)/3
#define cellRowHeight cellImgHeight + 5

@interface Pano720TableViewCell : BaseTableViewCell

@property (nonatomic, strong) UIImageView *picImageView;
@property (nonatomic, strong) UIImageView *phoneIconImgeView;
@property (nonatomic, strong) UIImageView *deviceIconImgeView;
@property (nonatomic, strong) UILabel *durationLabel;
@property (nonatomic, strong) UILabel *progressLabel;

- (void)updateIconImageViewLayout;
@end
