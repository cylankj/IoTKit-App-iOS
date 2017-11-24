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
        return [PropertyManager showPropertiesRowWithPid:pid key:pDoorLockKey];
    }else if(type == JFGDevFctTypeOutdoor){
        if (pid == 82 || pid == 84) {
            return YES;
        }
    }
    return NO;
}

@end
