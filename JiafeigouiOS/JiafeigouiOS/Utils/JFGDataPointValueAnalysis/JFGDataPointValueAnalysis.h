//
//  JFGDataPointValueAnalysis.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFGDataPointValueModel.h"
#import <JFGSDK/JFGSDK.h>

@interface JFGDataPointValueAnalysis : NSObject

//204消息解析，解析失败返回nil
+(JFGDeviceSDCardInfo *)dpFor204Msg:(DataPointSeg *)seg;

@end
