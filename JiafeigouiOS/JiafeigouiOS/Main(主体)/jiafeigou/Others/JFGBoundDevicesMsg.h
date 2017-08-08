//
//  JFGBoundDevicesMsg.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/8/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JiafeigouDevStatuModel.h"

#define BoundDevicesRefreshNotification @"BoundDevicesRefreshNotification"

@interface JFGBoundDevicesMsg : NSObject

@property (nonatomic,readonly)NSMutableArray *delDeviceList;

+(instancetype)sharedDeciceMsg;

-(NSMutableArray <JiafeigouDevStatuModel *>*)getDevicesList;

- (JiafeigouDevStatuModel *)getDevModelWithCid:(NSString *)cid;

-(NSArray *)getCacheDeviceList;

//保存自己删除的设备的cid
-(void)addDelDeviceCid:(NSString *)cid;

-(void)removeDelDeviceCid:(NSString *)cid;

-(void)clearDeviceList;

@end
