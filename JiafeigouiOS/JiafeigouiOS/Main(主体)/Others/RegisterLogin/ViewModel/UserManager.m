//
//  UserManager.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/26.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "UserManager.h"
#import <SSKeychain/SSKeychain.h>

static NSString * const JFGLoginAccountPwServerKey = @"JFGLoginAccountKeyForServer";

@interface UserManager()

@end


@implementation UserManager

-(void)saveAccount:(NSString *)account pw:(NSString *)pw
{
    [SSKeychain setPassword:pw forService:JFGLoginAccountPwServerKey account:account];
}

-(void)deleteAccount:(NSString *)account
{
    [SSKeychain deletePasswordForService:JFGLoginAccountPwServerKey account:account];
}

-(NSArray <NSString *>*)allAccounts
{
    NSArray *allChains = [SSKeychain accountsForService:JFGLoginAccountPwServerKey];
    NSMutableArray *accounts = [[NSMutableArray alloc]init];
    for (NSDictionary *dic in allChains) {
        [accounts addObject:dic[@"acct"]];
    }
    return accounts;
}

-(NSString *)passwordForAccount:(NSString *)account
{
    return [SSKeychain passwordForService:JFGLoginAccountPwServerKey account:account];
}

@end
