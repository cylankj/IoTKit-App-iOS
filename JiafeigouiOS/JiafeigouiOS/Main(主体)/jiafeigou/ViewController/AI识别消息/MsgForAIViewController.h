//
//  MsgForAIViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"
#import "JiafeigouDevStatuModel.h"
#import "MessageViewController.h"

@interface MsgForAIViewController : UIViewController

@property (nonatomic,strong)JiafeigouDevStatuModel *devModel;
@property (nonatomic,copy)NSString *cid;
@property(nonatomic,weak)id <MessageVCDelegate> delegate;
@property (nonatomic,assign)BOOL isDeviceOffline;//设备是否离线

-(void)cancelEditingState;
-(void)hasNewMsgNotification;

@end
