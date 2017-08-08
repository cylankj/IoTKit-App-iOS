//
//  UserMessageForThird.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/4.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "UserMessageForThird.h"
#import "FTBase64.h"

@implementation UserMessageForThird

+(NSString *)getAccountForThird
{
    NSString *lastAccount = [[NSUserDefaults standardUserDefaults] objectForKey:@"JFGCurrentLoginedAccountKey"];
    return lastAccount;
}

+(NSString *)getPwForThirdWithAccount:(NSString *)account
{
    return [[self class] pwWithAccount:account];
}

+(NSString *)pwWithAccount:(NSString *)account
{
    if (!account) {
        return nil;
    }
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]initWithContentsOfFile:[[self class] accountCachePath]];
    NSData *keyData = [dict objectForKey:account];
    NSString *keyString = [[self class] decodeForData:keyData];
    return keyString;
}

+(NSString *)accountCachePath
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Library"];
    path = [path stringByAppendingPathComponent:@"jfgConfig"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:@"user.db"];
    return path;
}

+(NSString *)decodeForData:(NSData *)encodeData
{
    NSData *unKey = b64_decode(encodeData);
    NSString *key = [[NSString alloc] initWithData:unKey encoding:NSUTF8StringEncoding];
    return key;
}

@end
