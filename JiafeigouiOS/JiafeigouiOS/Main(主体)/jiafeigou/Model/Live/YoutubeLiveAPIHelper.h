//
//  YoutubeLiveAPIHelper.h
//  JiafeigouiOS
//
//  Created by yangli on 2017/9/6.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "YoutubeLiveStreamsModel.h"
#import "YoutubeLiveStreamingAPI.h"

@protocol YoutubeLiveAPIHelperDelegate <NSObject>

@optional

//授权登录结果
-(void)signInResultForError:(NSError *)error;

//创建频道结果
-(void)createLiveChannelResultForError:(NSError *)error liveModel:(YoutubeLiveStreamsModel *)liveModel;

//直播流状态
-(void)liveStreamForIdentifier:(NSString *)identifier streamStatus:(NSString *)streamStatus healthStatus:(NSString *)healthStatus error:(NSError *)error;

//直播频道状态
-(void)liveBroadcastForIdentifier:(NSString *)identifier lifeCycleStatus:(NSString *)lifeCycleStatus error:(NSError *)error;

//切换直播状态结果
-(void)transitionBroadcastStatueResultForIdentifier:(NSString *)identifier lifeCycleStatus:(NSString *)lifeCycleStatus error:(NSError *)error;

//请求超时
-(void)liveReqTimeout;

@end



@interface YoutubeLiveAPIHelper : NSObject

@property (nonatomic,weak)id <YoutubeLiveAPIHelperDelegate> delegate;

//登录信息，如果未授权登录则为nil
-(GIDGoogleUser *)signInUser;

//登录授权
-(void)signInWithPresentVC:(UIViewController *)VC;

//取消授权登录
-(void)signOut;

//创建直播频道
-(void)createLiveChannelWithTitle:(NSString *)title
                      description:(NSString *)description
                        startTime:(NSDate *)startDate
                          endTime:(NSDate *)endDate
                              cid:(NSString *)cid;

//查询直播流的状态
-(void)checkLiveStreamStateForIdentifier:(NSString *)identifier;

//查询直播频道状态
-(void)checkLiveBroadcastStateForIdentifier:(NSString *)identifier;

//切换直播状态
-(void)transitionBroadcastStatue:(NSString *)statue identifier:(NSString *)identifier;

@end
