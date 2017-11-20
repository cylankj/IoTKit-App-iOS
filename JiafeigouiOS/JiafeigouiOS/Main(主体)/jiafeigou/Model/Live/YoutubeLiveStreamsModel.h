//
//  YoutubeLiveStreamsModel.h
//  JiafeigouiOS
//
//  Created by yangli on 2017/9/5.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface YoutubeLiveStreamsModel : NSObject

@property (nonatomic,assign)BOOL isValid;//推流地址是否有效
@property (nonatomic,copy)NSString *liveBroadcastID;//直播频道唯一ID
@property (nonatomic,copy)NSString *liveStreamsID;//直播流唯一ID
@property (nonatomic,copy)NSString *watchUrl;//观看地址
@property (nonatomic,copy)NSString *streamsUrl;//推流地址
@property (nonatomic,copy)NSString *title;//标题
@property (nonatomic,copy)NSString *descrips;//描述
@property (nonatomic,strong)NSDate *scheduledStartTime;//直播开始时间
@property (nonatomic,strong)NSDate *scheduledEndTime;//直播结束时间
@property (nonatomic,copy)NSString *cid;//为哪个设备所创建的直播流

@end



