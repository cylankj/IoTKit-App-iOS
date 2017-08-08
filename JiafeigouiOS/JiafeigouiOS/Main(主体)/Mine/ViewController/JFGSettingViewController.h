//
//  JFGSettingViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/6/22.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"

@interface JFGSettingViewController : JFGBaseViewController

@end

@interface JFGSettingModel : NSObject

@property (nonatomic,copy)NSString *text;
@property (nonatomic,copy)NSString *detailText;
@property (nonatomic,assign)NSInteger contentID;//每个内容的唯一标记，不可重复
@property (nonatomic,assign)BOOL isShowSwitch;
@property (nonatomic,assign)BOOL switchValue;
@property (nonatomic,assign)BOOL isShowRedPoint;

@end
