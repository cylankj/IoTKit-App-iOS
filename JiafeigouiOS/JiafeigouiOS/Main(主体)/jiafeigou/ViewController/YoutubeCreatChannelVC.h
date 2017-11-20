//
//  YoutubeCreatChannelVC.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/6.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"
#import "YoutubeLiveAPIHelper.h"

@interface YoutubeCreatChannelVC : JFGBaseViewController

@property (nonatomic,weak)YoutubeLiveAPIHelper *youtubeHelper;
@property (nonatomic,copy)NSString *cid;

@end


@interface TimeCell : UIControl

@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UILabel *detailLabel;
@property (nonatomic,strong)NSDate *selectedDate;

@end
