//
//  JFGPidMap.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/12/13.
//  Copyright © 2017年 lirenguang. All rights reserved.
//  pid(大号)映射 os

#import <Foundation/Foundation.h>

@interface JFGPidMap : NSObject

//根据pid获取os
-(NSInteger)osFromPid:(NSInteger)pid;

@end
