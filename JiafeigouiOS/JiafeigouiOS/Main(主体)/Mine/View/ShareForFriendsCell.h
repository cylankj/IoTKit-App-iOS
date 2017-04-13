//
//  ShareForFriendsCell.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BtnImageView : UIImageView

@property (nonatomic,assign)BOOL isSelected;

@end


@interface ShareForFriendsCell : UITableViewCell
@property (nonatomic, strong)UIImageView * iconImageView;
@property (nonatomic, strong)UILabel * nameLabel;
@property (nonatomic, strong)UILabel * shareNumLabel;
@property (nonatomic, strong)BtnImageView * selectButton;

@end


