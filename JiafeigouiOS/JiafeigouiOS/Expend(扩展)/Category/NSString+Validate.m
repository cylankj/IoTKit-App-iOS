//
//  NSString+Validate.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "NSString+Validate.h"

@implementation NSString (Validate)
#pragma mark - 验证通讯录电话
/*验证电话号码*/
+ (NSString *)validatePhone:(NSString *)phone{
    phone = [self stringByTrimmingCharactersInSets:phone];
    /**
     * 手机号码
     * 移动：134[0-8],135、136、137、138、139、150、151、152、157、158、159、182、183、184、187、178、188、147
     * 联通：130、131、132、145、155、156、176、185、186
     * 电信：133、153、177、180、181、189 ,1349
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[0-9])\\d{8}$";
    /**
     10         * 中国移动：China Mobile
     11         * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     12         */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|47|5[0-27-9]|78|8[23478])\\d)\\d{7}$";
    /**
     15         * 中国联通：China Unicom
     16         * 130,131,132,152,155,156,185,186
     17         */
    NSString * CU = @"^1(3[0-2]|45|5[56]|76|8[56])\\d{8}$";
    /**
     20         * 中国电信：China Telecom
     21         * 133,1349,153,180,189
     22         */
    NSString * CT = @"^1((33|53|8[019])[0-9]|349)\\d{7}$";
    /**
     25         * 大陆地区固话及小灵通
     26         * 区号：010,020,021,022,023,024,025,027,028,029
     27         * 号码：七位或八位
     28         */
    // NSString * PHS = @"^0(10|2[0-5789]|\\d{3})\\d{7,8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    NSPredicate *regextestcm = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CM];
    NSPredicate *regextestcu = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CU];
    NSPredicate *regextestct = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", CT];
    
    if (([regextestmobile evaluateWithObject:phone] == YES)
        || ([regextestcm evaluateWithObject:phone] == YES)
        || ([regextestct evaluateWithObject:phone] == YES)
        || ([regextestcu evaluateWithObject:phone] == YES))
    {
        if([regextestcm evaluateWithObject:phone] == YES) {
            NSLog(@"China Mobile");
        } else if([regextestct evaluateWithObject:phone] == YES) {
            NSLog(@"China Telecom");
        } else if ([regextestcu evaluateWithObject:phone] == YES) {
            NSLog(@"China Unicom");
        } else {
            NSLog(@"Unknow");
        }
        
        return phone;
    }
    else
    {
        return nil;
    }
}
//去除特殊字符（自定义）
+ (NSString *)trimmingCharacters:(NSString *)str{
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"@／：；（）¥「」＂、[]{}#%-*+=_\\|~＜＞$€^•'@#$%^&*()_+'\""];
    NSString *trimmedString = [str stringByTrimmingCharactersInSet:set];
    return trimmedString;
}
//去除中间的‘-’，‘空格’，用上面的方法没效果
+ (NSString *)stringByTrimmingCharactersInSets:(NSString *)str{
    NSLog(@"stringByTrimmingCharactersInSet=%@",str);
    //+86开头的号码
    if([[str substringWithRange:NSMakeRange(0, 3)] isEqualToString:@"+86"]){
        str = [str substringFromIndex:4];//有一个空格
    }
    NSString *tempStr = @"";
    for (int i=0; i<[str length]; i++) {
        NSString * strc = [str substringWithRange:NSMakeRange(i, 1)];
        if (![strc isEqualToString:@"-"] && ![strc isEqualToString:@"("]&& ![strc isEqualToString:@")"]) {
            tempStr = [tempStr stringByAppendingString:strc];
            tempStr = [tempStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        }
    }
    return tempStr;
}
/*验证邮箱*/
+ (NSString *)validateEmail:(NSString *)email
{
    email = [self stringByTrimmingCharactersInSets:email];
    
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    if ([emailTest evaluateWithObject:email])
    {
        return email;
    }
    
    return nil;
}
@end
