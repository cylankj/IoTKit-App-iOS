//
//  CylanJFGSDK.h
//  JFGSDK
//
//  Created by yangli on 16/9/30.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CylanJFGSDK : NSObject

#pragma mark- 摄像头相关
+(void)connectCamera:(NSString *)cid;
+(void)playVideoByTime:(int64_t)time cid:(NSString *)cid;
+(void)startRenderRemoteView:(UIView *)view;
+(BOOL)openLocalCamera:(BOOL)front;
+(void)startRenderLocalView:(UIView *)view;
+(void)stopRenderView:(BOOL)local withCid:(NSString *)cid;
+(void)disconnectVideo:(NSString *)remote;

+(UIImage *)imageForSnapshot;
+(void)getHistoryVideoListForCid:(NSString *)cid;
+(void)setAudio:(BOOL)local openMic:(BOOL)openMic openSpeaker:(BOOL)openSpeaker;
+(void)switchLiveVideo:(BOOL)isLive beigenTime:(int64_t)beigenTime;


@end
