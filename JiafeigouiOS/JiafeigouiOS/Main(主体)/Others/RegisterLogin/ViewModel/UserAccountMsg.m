//
//  UserAccountMsg.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "UserAccountMsg.h"
#import "FTBase64.h"

@implementation UserAccountMsg

+(void)saveAccount:(NSString *)account withPw:(NSString *)pw
{
    NSMutableDictionary *dict =[[NSMutableDictionary alloc]initWithContentsOfFile:[[self class] accountCachePath]];
    if (dict == nil) {
        dict = [[NSMutableDictionary alloc]init];
    }
    
    if (account && pw) {
        
        NSData *keyData = [dict objectForKey:account];
        if (keyData) {
            NSString *keyStirng = [[self class] decodeForData:keyData];
            if ([keyStirng isEqualToString:pw]) {
                
                return;
                
            }else{
                
                [dict removeObjectForKey:account];
            }
            
        }
        
        NSData *_keyData = [[self class] encodeForString:pw];
        [dict setObject:_keyData forKey:account];
        [dict writeToFile:[[self class] accountCachePath] atomically:YES];
        
    }
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

+(void)deleteWithAccount:(NSString *)account
{
    if (account){
        NSMutableDictionary *dict =[[NSMutableDictionary alloc]initWithContentsOfFile:[[self class] accountCachePath]];
        [dict removeObjectForKey:account];
        [dict writeToFile:[[self class] accountCachePath] atomically:YES];
    }
}

+(void)deleteAll
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[[self class] accountCachePath] error:nil];
}

+(NSString *)decodeForData:(NSData *)encodeData
{
    NSData *unKey = b64_decode(encodeData);
    NSString *key = [[NSString alloc] initWithData:unKey encoding:NSUTF8StringEncoding];
    return key;
}

+(NSData *)encodeForString:(NSString *)decodeString
{
    NSData *data = [decodeString dataUsingEncoding: NSUTF8StringEncoding];
    NSData *encodeData = b64_encode(data);
    return encodeData;
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


@end
