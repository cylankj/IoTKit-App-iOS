//
//  jiafeigouTableView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLRefreshHeader.h"
#import "JiafeigouDevStatuModel.h"

@interface jiafeigouTableView : UITableView<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)FLRefreshHeader *refreshView;

@property (nonatomic,strong)NSMutableArray <JiafeigouDevStatuModel *>*dataArray;
@property (nonatomic,strong)NSMutableDictionary *dataDict;

@property (nonatomic,assign)NSTimeInterval dpReqForLastTimeInterval;

/**
 *  设置顶部可拉伸视图
 *
 *  @param view    可以被拉伸的视图
 *  @param subview 内容视图，不会被拉伸
 */
- (void)stretchHeaderView:(UIView*)view subViews:(UIView*)subview;

/**
 *  设置推上去后，自定义navigationBar的颜色
 *
 *  @param night 是否是晚上
 */
-(void)setBarViewColor:(BOOL)night;


-(void)startRipple;

-(void)stopRipple;

//检查登录状态
-(void)loginStatueChick;

@end


@interface DoorSensorStatusLabel : UILabel

-(void)mySetBackgroundColor:(UIColor *)backgroundColor;

@end
