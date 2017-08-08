//
//  JfgProductJduge.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/5.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JfgProductJduge.h"

@implementation JfgProductJduge

+ (BOOL)isAutoRecordSwitch:(productType)pType
{

    switch (pType)
    {
        case productType_RSDoorBell:
        case productType_CatEye:
        case productType_KKS_DoorBell:
        case productType_720:
        case productType_720p:
        {
            return YES;
        }
            break;
            
        default:
        {
            return NO;
        }
            break;
    }
    
    return NO;
}

+ (BOOL)isDoubleFishEyeDevice:(productType)pType
{
    switch (pType) {
        case productType_720:
        case productType_720p:
            return YES;
            break;
            
        default:
            return NO;
            break;
    }
    return NO;
}

@end
