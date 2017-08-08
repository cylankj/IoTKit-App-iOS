//
//  BellMsgDataReq.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MessageModel.h"
#import "MessageVCDateModel.h"

@protocol BellMsgDataReqDelegate <NSObject>

@optional
//数据请求成功
-(void)requestBellSuccess:(NSArray <MessageModel *> *)dataList forCid:(NSString *)cid refresh:(BOOL)refresh;

//数据请求失败
-(void)requestBellFailedForCid:(NSString *)cid refresh:(BOOL)refresh;

@end

@interface BellMsgDataReq : NSObject


@property (nonatomic,weak)id <BellMsgDataReqDelegate> delegate;

-(void)getDataForCid:(NSString *)cid timestamp:(uint64_t)timestamp isRefresh:(BOOL)isRefresh;

@end
