//
//  jiafeigouTableView+Data.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "jiafeigouTableView.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKSock.h>

@interface jiafeigouTableView (Data)<JFGSDKCallbackDelegate>

-(void)addDataDelegate;

-(void)deviceNetworkState:(DataPointSeg *)seg devModel:(JiafeigouDevStatuModel *)model;

@end
