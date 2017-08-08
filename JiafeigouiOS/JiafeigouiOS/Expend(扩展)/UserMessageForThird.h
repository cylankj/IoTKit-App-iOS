//
//  UserMessageForThird.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/4.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserMessageForThird : NSObject

//获取已经登录过的账号
+(NSString *)getAccountForThird;

//根据账号获取密码（未加密）
+(NSString *)getPwForThirdWithAccount:(NSString *)account;

@end
