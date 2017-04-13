//
//  SysMsgTableViewCell.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/9/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#define SysViewWidth @"ViewWidth"


@interface SysWebView : UIWebView

@property (nonatomic,strong)NSIndexPath *indexPath;

@end



@interface SysMsgTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *msgBgImageView;
@property (weak, nonatomic) IBOutlet UILabel *msgLabel;
@property (weak, nonatomic) IBOutlet UIImageView *editSelectedBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *msgBgViewRightConstraint;
@property (weak, nonatomic) IBOutlet SysWebView *msgWebView;

//编辑状态
@property (nonatomic,assign)BOOL isEditing;
//选中状态
@property (nonatomic,assign)BOOL isEditSelected;

//根据传入文本计算cell高度
+(CGSize)heightForRowWithString:(NSString *)string;

@end
