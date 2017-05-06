//
//  MessageViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DelButton.h"
#import "JiafeigouDevStatuModel.h"

@protocol MessageVCDelegate <NSObject>

-(void)lookHistoryForTimestamp:(uint64_t)timestamp;

@end

@interface MessageViewController : UIViewController
//顶部日期选择按钮
@property(nonatomic, strong)UIButton * timeSelectButton;
//编辑按钮
@property(nonatomic, strong)DelButton * editButton;

@property(nonatomic,weak)id <MessageVCDelegate> delegate;

@property (nonatomic,strong)NSString *cid;

@property (nonatomic,assign)BOOL isDeviceOffline;//设备是否离线

@property (nonatomic,strong)JiafeigouDevStatuModel *devModel;

-(void)editButtonAction:(DelButton *)button;

-(void)selectDate:(UIButton *)button;
@end
