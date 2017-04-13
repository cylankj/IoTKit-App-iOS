//
//  VideoChatVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, videoChatType)
{
    videoChatTypeActive,// 主动
    videoChatTypeUnactive, // 被动
};

@interface VideoChatVC : BaseViewController<UIScrollViewDelegate>
{
    UIScrollView *_remoteScrollView; // 远程 View
    UIScrollView *_localScrollView; // 本地 View
    
    NSTimer *checkTimer; //呼叫 30s 超时
    NSTimer *titleTimer; //定时 更改标题
    NSTimer *_callRepeatTimer;
    
    CGSize remoteCallViewSize;
    CGSize localCallViewSize;
    
    NSMutableArray *_efamilyRecordArray; // 中控记录 数组
    
    BOOL isVideoConnectted; // 视频是否 连通
    BOOL isEverConnectted; // 是否 连通 过
    
    long connecttedDuration; // 通话时长
    long callTime; // 记录 当前的呼叫时间
    long long ntpTimeError; // NTP 时间误差
    int connectTimes;  //连接次数
}

@property (assign, nonatomic) videoChatType chatType; //是否主动
@property (retain, nonatomic) AVAudioPlayer *avAudioPlayer;
@property (copy, nonatomic) NSString *cidString; // cid 唯一识别
@property (assign,nonatomic) int64_t timeStamp;
@property (copy, nonatomic) NSString *nickName; // 昵称
@property (nonatomic, nonatomic) NSUInteger os; // 类型


@end
