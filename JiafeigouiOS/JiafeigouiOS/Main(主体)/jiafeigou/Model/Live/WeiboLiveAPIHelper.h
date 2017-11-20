//
//  WeiboLiveAPIHelper.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/12.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import <weibolive_ios_sdk/WeiboLiveSDK.h>

#define WEIBOLIVETITLEKEY @"WEIBOLIVETITLEKEYFOFJFG"//微博标题存储key

@interface WeiboLiveAPIHelper : NSObject

//当前创建微博的直播ID
@property (nonatomic,readonly)NSString *liveID;

/**!
 *  创建微博直播，返回直播推流地址
 */
-(void)createLiveWithHandler:(void(^)(NSError *error,id result))handler;

@end
