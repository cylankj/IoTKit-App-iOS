//
//  JFGSDKVideo.h
//  JFGFramworkDemo
//
//  Created by yangli on 16/3/28.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
/*!
 *  历史录像信息
 */
@interface JFGSDKHistoryVideoInfo : NSObject

/*!
 *  设备标示
 */
@property (nonatomic,copy)NSString *cid;

/*!
 *  开始时间
 */
@property (nonatomic,assign)int64_t beginTime;

/*!
 *  持续时长(单位：s)
 */
@property (nonatomic,assign)int duration;

/**
 *  全景摄像头模式定义：吊顶，MODE_TOP=0 壁挂 MODE_WALL=1
 */
@property (nonatomic,assign)int mode;

@end


/*!
 *  历史录像错误信息
 */
@interface JFGSDKHistoryVideoErrorInfo : NSObject

/*!
 *  开始时间
 */
@property (nonatomic,assign)int64_t beginTime;


/*!
 *  错位码
 */
@property (nonatomic,assign)int code;

@end
