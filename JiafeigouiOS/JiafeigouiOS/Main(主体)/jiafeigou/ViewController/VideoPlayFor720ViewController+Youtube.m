//
//  VideoPlayFor720ViewController+Youtube.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "VideoPlayFor720ViewController+Youtube.h"
#import <objc/runtime.h>
#import "JfgCacheManager.h"

static const char YoutubeMdKey = '\0';

int streamsCount = 0;//推流状态请求次数
int broadcastCount = 0;//频道状态请求次数
int transitionCount = 0;//切换频道状态次数
NSString *_streamsStatue = @"";
NSString *_broadcastStatue = @"";
BOOL isStop = NO;

@implementation VideoPlayFor720ViewController (Youtube)

-(void)startYoutubeLive
{
    if (self.liveModel.liveType != LivePlatformTypeYoutube) {
        return;
    }
    if (!self.youtubeModel || ![self.youtubeModel.cid isEqualToString:self.devModel.uuid]) {
        self.youtubeModel = [JfgCacheManager youtubeModelForCid:self.devModel.uuid];
    }
    
    if (!self.youtubeModel.isValid) {
        [self youtubeLiveStatue:YoutubeLiveStatueUrlInvalid];
        return;
    }
    
    
    if (self.youtubeModel.liveStreamsID) {
        streamsCount = 1;
        broadcastCount = 0;
        transitionCount = 0;
        isStop = NO;
        //1.获取直播流状态
        [self.youtubeAPIHelper checkLiveStreamStateForIdentifier:self.youtubeModel.liveStreamsID];
    }else{
        [self youtubeLiveStatue:YoutubeLiveStatueUrlInvalid];;
    }
}



#pragma mark- Youtube Delegate
//直播流状态
-(void)liveStreamForIdentifier:(NSString *)identifier streamStatus:(NSString *)streamStatus healthStatus:(NSString *)healthStatus error:(NSError *)error
{
    if ([identifier isEqualToString:self.youtubeModel.liveStreamsID]) {
        
        NSLog(@"liveStreamStatue:%@ %@ %@",streamStatus,healthStatus,error);
        _streamsStatue = streamStatus;
        //active  error
        if ([streamStatus isEqualToString:@"error"] || [healthStatus isEqualToString:@"revoked"]) {
            //链接失效了
            if (!isStop) {
                [self youtubeLiveStatue:YoutubeLiveStatueUrlInvalid];
            }
            self.youtubeModel.isValid = NO;
            self.liveModel.isValid = NO;
            [JfgCacheManager updateYoutubeModel:self.youtubeModel];
            
        }else{
            
            if ([streamStatus isEqualToString:@"active"]) {
                
                //获取直播频道状态
                if (!isStop) {
                    [self youtubeLiveStatue:YoutubeLiveStatueAction];
                    broadcastCount ++;
                    [self.youtubeAPIHelper checkLiveBroadcastStateForIdentifier:self.youtubeModel.liveBroadcastID];
                }
               
            }else{
                
                 if (!isStop) {
                     if (streamsCount>4) {
                         [self youtubeLiveStatue:YoutubeLiveStatueInternetBad];
                         return;
                     }
                     int64_t delayInSeconds = 1.0;
                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                         streamsCount ++;
                         [self.youtubeAPIHelper checkLiveStreamStateForIdentifier:self.youtubeModel.liveStreamsID];
                     });
                 }
                
            }
        }
    }
}

//直播频道状态
-(void)liveBroadcastForIdentifier:(NSString *)identifier lifeCycleStatus:(NSString *)lifeCycleStatus error:(NSError *)error
{
    if ([identifier isEqualToString:self.youtubeModel.liveStreamsID]){
        
        NSLog(@"liveBroadcastStatue:%@ %@",lifeCycleStatus,error);
        _broadcastStatue = lifeCycleStatus;
        if ([lifeCycleStatus isEqualToString:@"live"] || [lifeCycleStatus isEqualToString:@"liveStarting"]) {
            
            if (!isStop) {
                [self youtubeLiveStatue:YoutubeLiveStatueLive];
            }
           
            
        }else if ([lifeCycleStatus isEqualToString:@"testing"]){
            
            if (!isStop) {
                //3.切换直播频道状态为live
                transitionCount ++;
                if (transitionCount>5) {
                    [self youtubeLiveStatue:YoutubeLiveStatueInternetBad];
                    return;
                }
                [self.youtubeAPIHelper transitionBroadcastStatue:@"live" identifier:self.youtubeModel.liveBroadcastID];
            }
            
            
        }else if([lifeCycleStatus isEqualToString:@"testStarting"]){
            
            if (!isStop) {
                if (broadcastCount>15) {
                    [self youtubeLiveStatue:YoutubeLiveStatueInternetBad];
                    return;
                }
                broadcastCount ++;
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [self.youtubeAPIHelper checkLiveBroadcastStateForIdentifier:self.youtubeModel.liveBroadcastID];
                    
                });
            }
            
            
        }else if ([lifeCycleStatus isEqualToString:@"revoked"]){
            
            if (!isStop) {
                 [self youtubeLiveStatue:YoutubeLiveStatueUrlInvalid];
            }
            self.youtubeModel.isValid = NO;
            self.liveModel.isValid = NO;
            [JfgCacheManager updateYoutubeModel:self.youtubeModel];
            
        }else{
            
            //2.切换直播频道状态为testing
            if (!isStop) {
                transitionCount ++;
                if (transitionCount>5) {
                    [self youtubeLiveStatue:YoutubeLiveStatueInternetBad];
                    return;
                }
                [self.youtubeAPIHelper transitionBroadcastStatue:@"testing" identifier:self.youtubeModel.liveBroadcastID];
            }
            
        }
    }
}

//切换直播状态结果
-(void)transitionBroadcastStatueResultForIdentifier:(NSString *)identifier lifeCycleStatus:(NSString *)lifeCycleStatus error:(NSError *)error
{
    if ([identifier isEqualToString:self.youtubeModel.liveStreamsID]){
        
        if (!isStop) {
            if (broadcastCount>15) {
                [self youtubeLiveStatue:YoutubeLiveStatueInternetBad];
                return;
            }
            broadcastCount ++;
            int64_t delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                [self.youtubeAPIHelper checkLiveBroadcastStateForIdentifier:self.youtubeModel.liveBroadcastID];
                
            });
        }
        
        
    }
}


-(void)liveReqTimeout
{
    if (!isStop) {
        [self youtubeLiveStatue:YoutubeLiveStatueTimeout];
    }
    
}

-(void)stopYoutubeReq
{
    isStop = YES;
}

-(void)setYoutubeModel:(YoutubeLiveStreamsModel *)youtubeModel
{
    if (youtubeModel != self.youtubeModel) {
        objc_setAssociatedObject(self, &YoutubeMdKey,
                                 youtubeModel, OBJC_ASSOCIATION_RETAIN);
    }
}

-(YoutubeLiveStreamsModel *)youtubeModel
{
    return objc_getAssociatedObject(self, &YoutubeMdKey);
}

@end
