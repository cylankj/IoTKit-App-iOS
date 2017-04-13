//
//  NSString+Validate.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Validate)
//+ (NSString *)validatePhone:(NSString *)phone;
+ (NSString *)trimmingCharacters:(NSString *)str;
+ (NSString *)stringByTrimmingCharactersInSets:(NSString *)str;
//+ (NSString *)validateEmail:(NSString *)email;
@end
