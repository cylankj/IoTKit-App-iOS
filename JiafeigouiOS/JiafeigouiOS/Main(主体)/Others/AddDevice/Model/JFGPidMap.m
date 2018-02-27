//
//  JFGPidMap.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/12/13.
//  Copyright © 2017年 lirenguang. All rights reserved.
//  pid(大号)映射 os

#import "JFGPidMap.h"
#import "PropertyManager.h"

@interface JFGPidMap()

@property (nonatomic,strong)PropertyManager *propert;

@end

@implementation JFGPidMap

-(NSInteger)osFromPid:(NSInteger)pid
{
    NSArray *propertyArr = self.propert.propertyArr;
    for (NSInteger i = 0; i < propertyArr.count; i ++)
    {
        NSDictionary *aproperty = [propertyArr objectAtIndex:i];
        if ([[aproperty objectForKey:pPIDKey] integerValue] == pid || [[aproperty objectForKey:pOSKey] intValue] == pid)
        {
            return [[aproperty objectForKey:pOSKey] intValue];
        }
    }
    return 0;
    
}

-(PropertyManager *)propert
{
    if (!_propert) {
        _propert =[[PropertyManager alloc]init];
        _propert.propertyFilePath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"json"];
    }
    return _propert;
}

@end
