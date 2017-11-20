//
//  LiveTypeViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/29.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"
#import "YoutubeLiveStreamingAPI.h"
#import "LiveTypeModel.h"

#define LiveTypeModelRefreshNotification @"LiveTypeModelRefreshNotificationKey"


@protocol LiveTypeViewControllerDelegate <NSObject>

//选择Live类型后回调
-(void)liveType:(LivePlatformType)platformType parameter:(NSDictionary *)parameter;

@end

@interface LiveTypeViewController : JFGBaseViewController

@property (nonatomic,copy)NSString *cid;
@property (nonatomic,assign)LivePlatformType platformType;
@property (nonatomic,weak)id <LiveTypeViewControllerDelegate> delegate;

@end
