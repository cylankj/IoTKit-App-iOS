//
//  JFGDevTypeManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/11/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGDevTypeManager.h"
#import "PropertyManager.h"

@implementation JFGDevTypeManager

+(BOOL)devIsType:(JFGDevFctType)type forPid:(NSInteger)pid
{
    if (type == JFGDevFctTypeDoorLock) {
        //门锁功能
        return [PropertyManager showPropertiesRowWithPid:pid key:pDoorLockKey];
        
    }else if(type == JFGDevFctTypeOutdoor){
        //户外版设备，没有对讲功能
        if (pid == 82 || pid == 84 || pid == 92) {
            return YES;
        }
    }else if (type == JFGDevFctTypeWired){
        //半球设备  WIREDMODE
        return [PropertyManager showPropertiesRowWithPid:pid key:pWiredModel];
        
    }else if (type == JFGDevFctTypeAIRecognition){
        //人脸识别
        return [PropertyManager showPropertiesRowWithPid:pid key:pFaceRecognition];
    }
    return NO;
}

@end
