//
//  VideoPlayFor720ViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/11.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFGBaseViewController.h"
#import "JiafeigouDevStatuModel.h"
#import "videoPlay1ViewController.h"
#import "YoutubeLiveAPIHelper.h"
#import "LiveTypeModel.h"


typedef NS_ENUM(NSInteger,YoutubeLiveStatue){
    
    YoutubeLiveStatueUrlInvalid,//推流地址失效
    YoutubeLiveStatueInternetBad,//推流环境网络差
    YoutubeLiveStatueTimeout,//请求超时
    YoutubeLiveStatueAction,//活跃状态，已经开始获取稳定的推流
    YoutubeLiveStatueTesting,//频道开始测试推流
    YoutubeLiveStatueLive,//推流成功，可以观看
    
};

@interface VideoPlayFor720ViewController : JFGBaseViewController

@property (nonatomic,strong)JiafeigouDevStatuModel *devModel;

//当前设备，当前选择的直播平台相关信息
@property (nonatomic,strong)LiveTypeModel *liveModel;

//youtube相关
@property (nonatomic,strong)YoutubeLiveAPIHelper *youtubeAPIHelper;

-(void)youtubeLiveStatue:(YoutubeLiveStatue)statue;

@end
