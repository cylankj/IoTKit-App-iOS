//
//  UserManager.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/26.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

/**
 *  用户账号，密码本地化处理（钥匙串）
 *
 */

#import <Foundation/Foundation.h>

@interface UserManager : NSObject

/**
 *  保存账号密码到钥匙串（同一个账号保存多次，只会把最后一次记录到钥匙串中）
 *
 *  @param account 账号
 *  @param pw      密码
 */
-(void)saveAccount:(NSString *)account pw:(NSString *)pw;

/**
 *  删除钥匙串中相关账号信息
 *
 *  @param account 账号
 */
-(void)deleteAccount:(NSString *)account;

/**
 *  返回所有存储钥匙串的账号
 *
 *  @return 账号集合（lastObject为最后一次存储的账号）
 */
-(NSArray <NSString *>*)allAccounts;


/**
 *  获取相关账号对应的密码
 *
 *  @param account 账号
 *
 *  @return 密码
 */
-(NSString *)passwordForAccount:(NSString *)account;

@end
