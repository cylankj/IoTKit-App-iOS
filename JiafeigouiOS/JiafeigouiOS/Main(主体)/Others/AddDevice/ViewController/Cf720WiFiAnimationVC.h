//
//  Cf720WiFiAnimationVC.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/4/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JfgTypeDefine.h"

typedef NS_ENUM(NSInteger,EventType) {
    EventTypeConfigWifi,//配置wifi
    EventTypeOpenAPModel,//开启Ap模式
    EventTypeHotSpot,//设置热点
};

@interface Cf720WiFiAnimationVC : UIViewController

@property (nonatomic, copy) NSString *cidStr;
@property (nonatomic,assign)EventType eventType;


@end
