//
//  JFGDevTypeManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/11/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

//按设备功能区分
typedef NS_ENUM(NSInteger,JFGDevFctType) {
    JFGDevFctTypeDoorLock,//门锁
    JFGDevFctTypeOutdoor,//户外设备（不支持对讲）
    JFGDevFctTypeWired,//支持有线
    JFGDevFctTypeAIRecognition,//支持AI识别(人脸识别)
};

@interface JFGDevTypeManager : NSObject

+(BOOL)devIsType:(JFGDevFctType)type forPid:(NSInteger)pid;

@end
