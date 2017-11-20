//
//  LiveTypeModel.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/8.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

//直播平台类型
typedef NS_ENUM(NSInteger,LivePlatformType){
    
    LivePlatformTypeFacebook,//facebook
    LivePlatformTypeYoutube,//youtube
    LivePlatformTypeWeibo,//微博
    LivePlatformTypeRTMP,//rtmp
    
};

//当前设备，当前选择的直播平台相关信息
@interface LiveTypeModel : NSObject

@property (nonatomic,copy)NSString *cid;
@property (nonatomic,assign)LivePlatformType liveType;//直播推送平台
@property (nonatomic,copy)NSString *liveStreamingUrl;//推流地址
@property (nonatomic,copy)NSString *watchUrl;//观看地址
@property (nonatomic,strong)NSMutableDictionary *parameterDict;//其他参数
@property (nonatomic,assign)BOOL isValid;//此时地址是否有效，主要针对youtube地址，其他平台这个字段无效

@end
