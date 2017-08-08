//
//  ShareDeviceCell.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ExploreModel.h"

@interface exploreBtn : UIButton
@property (nonatomic,strong)ExploreModel *model;
@end

@interface ShareDeviceCell : UITableViewCell
@property (nonatomic, strong)UIImageView * iconImageView;
@property (nonatomic, strong)UILabel * deviceNameLabel;
@property (nonatomic, strong)UILabel * deviceNumLabel;
@property (nonatomic, strong)exploreBtn * shareButton;
@end
