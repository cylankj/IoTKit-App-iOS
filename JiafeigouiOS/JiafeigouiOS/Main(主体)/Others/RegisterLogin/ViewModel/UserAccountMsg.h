//
//  UserAccountMsg.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserAccountMsg : NSObject

+(void)saveAccount:(NSString *)account withPw:(NSString *)pw;

+(NSString *)pwWithAccount:(NSString *)account;

+(void)deleteWithAccount:(NSString *)account;

@end
