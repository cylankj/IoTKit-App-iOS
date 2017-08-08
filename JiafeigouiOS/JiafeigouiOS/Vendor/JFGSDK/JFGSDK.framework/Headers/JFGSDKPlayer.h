//
//  JFGSDKPlayer.h
//  JFGSDK
//
//  Created by yangli on 2017/4/22.
//  Copyright © 2017年 yangli. All rights reserved.
//  720设备，本地视频播放类

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class JFGSDKPlayer;

/*!
 * 视频播放回调代理
 */
@protocol JFGSDKPlayerDelegate <NSObject>

//视频解析成功，可以开始render
-(void)jfgSDKPlayerReady:(JFGSDKPlayer *)player width:(int)width height:(int)height durationTime:(int)duration;

//视频播放，当前进度(视频总时间，见上面方法)
-(void)jfgSDKPlayer:(JFGSDKPlayer *)player progress:(int)progress;

//视频播放失败
-(void)jfgSDKPlayerFailed:(JFGSDKPlayer *)player;

//视频播放结束
-(void)jfgSDKPlayerFinished:(JFGSDKPlayer *)player;

@end


/*!
 * 视频类
 */
@interface JFGSDKPlayer : NSObject

@property(nonatomic,weak)id <JFGSDKPlayerDelegate>delegate;

@property(nonatomic,readonly)NSString *playUrl;//当前播放视频地址

/*!
* 开始播放视频
 
* @param url 本地文件地址
*/
-(void)playForUrl:(NSString *)url;


/*!
 * 暂停播放视频
 */
-(void)pause;


/*!
 * 恢复视频播放
 */
-(void)resume;


/*!
 * 跳转至某时刻播放
 */
-(void)seekToTime:(int)time;


/*!
 * 停止播放视频
 */
-(void)stopPlay;


/*!
 * 开始render画面
 
 * @param renderView  传入VideoRenderIosView，并在此view上绘制图像
 * @note （#jfgSDKPlayerReady:width：height）后，开始调用此函数
 */
-(void)startRenderForView:(UIView *)renderView;


@end
