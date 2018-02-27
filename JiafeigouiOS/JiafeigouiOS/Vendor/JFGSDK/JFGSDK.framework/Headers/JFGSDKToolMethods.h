//
//  JFGSDKToolMethods.h
//  JFGFramworkDemo
//
//  Created by yangli on 16/3/30.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JFGSDKToolMethods : NSObject
/*!
 *  当前系统语言
 *
 *  @return 语言
 */
+(NSInteger)languageType;


//获取当前wifi名称
+(NSString *)currentWifiName;

/**
 *  十进制转二进制
 */
+(NSString *)toBinarySystemWithDecimalSystem:(NSInteger)decimal;
//  二进制转十进制
+(NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary;

+(UIImage *)createImageFromData:(void *)data width:(float)width height:(float)height;
@end
