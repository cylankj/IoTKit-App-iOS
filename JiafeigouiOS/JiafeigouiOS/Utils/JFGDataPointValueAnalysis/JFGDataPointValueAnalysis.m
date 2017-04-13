//
//  JFGDataPointValueAnalysis.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGDataPointValueAnalysis.h"
#import <JFGSDK/MPMessagePackReader.h>


@implementation JFGDataPointValueAnalysis

+(JFGDeviceSDCardInfo *)dpFor204Msg:(DataPointSeg *)seg
{
    if (seg.msgId == 204) {
        
        id obj = [MPMessagePackReader readData:seg.value error:nil];
        if (obj && [obj isKindOfClass:[NSArray class]]) {
            NSArray *objArr = obj;
            if (objArr.count >= 4) {
                JFGDeviceSDCardInfo *info = [[JFGDeviceSDCardInfo alloc]init];
                info.storage = [objArr[0] longLongValue];
                info.storage_used = [objArr[1] longLongValue];
                info.errorCode = [objArr[2] integerValue];
                info.isHaveCard = [objArr[3] boolValue];
                return info;
            }
        }
    }
    return nil;
}

@end
