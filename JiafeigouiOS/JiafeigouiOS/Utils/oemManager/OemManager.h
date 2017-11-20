//
//  OemManager.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, oemType)
{
    oemTypeCylan,
    oemTypeDoby,
    oemTypeCell_C
};

extern NSString *const domainKey;

NSString *const oemRecommendKey = @"recommend"; //dict
NSString *const oemShowRecommendKey = @"showRecommend";
NSString *const oemRecommendUrl = @"recommendurl";
NSString *const oemRecommendDobyUrl = @"recommenForDobyUrl";
NSString *const oemRecommendCellCUrl = @"recommenForCellCUrl";


NSString *const oemAboutKey = @"about"; // dict
NSString *const oemShowAboutKey = @"showAbout";
NSString *const oemShowWebKey = @"showWeb";
NSString *const oemShowTELKey = @"showTel";

NSString *const oemShowCopyRightKey = @"showCopyRight";

NSString *const oemShowProtocolKey = @"showProtocol";

NSString *const oemRobotHostKey = @"jfgOemRobotHostKey_";
NSString *const oemRobotPostKey = @"jfgOemRobotPostKey_";


@interface OemManager : NSObject

// oem 类型
+ (NSInteger)oemType;
// appName
+ (NSString *)appName;

#pragma mark 配置读取
+ (id)getOemConfig:(NSString *)oemConfigKey;

#pragma mark oem config
+ (NSString *)getOemProtocolUrl;
+ (NSString *)getOemHelpUrl;

/**
 *  根据平台获取相应的Vid
 *
 *  @return Vid
 */
+ (NSString *)getOemVid;
/**
 *  根据平台获取相应的vkey
 *
 *  @return vkey
 */
+ (NSString *)getOemVKey;

#pragma mark  域名获取
+ (NSString *)getdomainWithPortURLString;

+ (NSString *)getdomainURLString;

+ (NSString *)getPort;

@end
