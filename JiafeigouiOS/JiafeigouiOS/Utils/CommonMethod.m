//
//  CommonMethod.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "CommonMethod.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import "ContactModel.h"
#import "NSString+FLExtension.h"
#import "AuthorizedMethod.h"
#import "JfgTypeDefine.h"
#import <ZipArchive/ZipArchive.h>
#import "JfgLanguage.h"
#import "JfgConfig.h"
#import "UIImageView+WebCache.h"
#import "LoginManager.h"
#import "ProgressHUD.h"
#import "UIAlertView+FLExtension.h"
#import <AddressBook/AddressBook.h>
#import <CommonCrypto/CommonDigest.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "OemManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "sys/utsname.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import "LSAlertView.h"
#import <SDWebImage/SDImageCache.h>
#import "PropertyManager.h"
#import "JFGBoundDevicesMsg.h"
#import "JfgCacheManager.h"

#define HANZI_START 19968
#define HANZI_COUNT 20902

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IOS_VPN         @"utun0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

NSString *const cameraWifiPrefix = @"DOG-";
NSString *const doorbellWifiPrefix = @"DOG-ML-";

@implementation CommonMethod
+ (NSMutableArray *)copyAddressBook:(ABAddressBookRef)addressBook
{
    NSMutableArray * modelArr = [NSMutableArray array];
    long numberOfPeople = ABAddressBookGetPersonCount(addressBook);
    CFArrayRef allPeople= ABAddressBookCopyArrayOfAllPeople(addressBook);
    
    for ( int i = 0; i < numberOfPeople; i++){
        ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);
        // 获取姓
        NSString *lastName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonLastNameProperty));
        // 获取名
        NSString *firstName = (__bridge NSString *)(ABRecordCopyValue(person, kABPersonFirstNameProperty));
        //全名
        //CFStringRef comName = (ABRecordCopyCompositeName(person));
        
        // NSLog(@"comName:%@,last:%@,first:%@",comName,lastName,firstName);
        //拼接姓名
        NSString *name = @"";
        if (firstName && lastName) {
            name = [NSString stringWithFormat:@"%@%@",lastName,firstName];
        }else if(lastName && !firstName){
            name = lastName;
        }else if(!lastName && firstName){
            name = firstName;
        }else
        {
            name = @"(null)";
        }
        
        //NSLog(@"%@",name);
        //读取电话多值
        ABMultiValueRef phone = ABRecordCopyValue(person, kABPersonPhoneProperty);
        CFRelease(phone);
        
        for (int k = 0; k<ABMultiValueGetCount(phone); k++)
        {
            //获取該电话值
            NSString * personPhone = @"";
            if (ABMultiValueCopyValueAtIndex(phone, k) != NULL) {
                personPhone = [[NSString stringWithFormat:@"%@", ABMultiValueCopyValueAtIndex(phone, k)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            
            //NSLog(@"%@",personPhone);
            
            //赋值给model
            ContactModel * model = [[ContactModel alloc]init];
            model.name = name;
            
            NSString *ph = [NSString stringWithFormat:@"%@",personPhone];
            ph = [ph stringByReplacingOccurrencesOfString:@"-" withString:@""];
            ph = [[self class] formatPhoneNum:ph];
            if ([ph isMobileNumber]) {
                model.phoneNum = personPhone;
                model.isShared = NO;
                model.isAdded = NO;
                [modelArr addObject:model];
            }
        }
        //获取邮箱
        ABMultiValueRef email = ABRecordCopyValue(person, kABPersonEmailProperty);

        CFRelease(email);
        for (int h = 0; h<ABMultiValueGetCount(email); h++)
        {
            //获取該email
            NSString * personEmail = @"";
            if (ABMultiValueCopyValueAtIndex(email, h) != NULL) {
                personEmail = [[NSString stringWithFormat:@"%@", ABMultiValueCopyValueAtIndex(email, h)] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            }
            //赋值给model
            ContactModel * model = [[ContactModel alloc]init];
            model.name = name;

            //personEmail = [NSString validateEmail:personEmail];
            if (personEmail != nil) {
                model.phoneNum = personEmail;
                model.isShared = NO;
                model.isAdded = NO;
                [modelArr addObject:model];
            }
        }
    }
    NSMutableArray * sortedArr = (NSMutableArray *)[modelArr sortedArrayUsingFunction:nameSort context:NULL];
    return sortedArr;
}

+ (NSString *)formatPhoneNum:(NSString *)phone
{
    if ([phone hasPrefix:@"86"]) {
        NSString *formatStr = [phone stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
        formatStr = [formatStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray *components = [formatStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
        formatStr = [components componentsJoinedByString:@" "];
        return formatStr;
    }
    else if ([phone hasPrefix:@"+86"])
    {
        if ([phone hasPrefix:@"+86·"] || [phone hasPrefix:@"+86 "]) {
            NSString *formatStr = [phone stringByReplacingCharactersInRange:NSMakeRange(0, 4) withString:@""];
            formatStr = [formatStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSArray *components = [formatStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
            formatStr = [components componentsJoinedByString:@" "];
            return formatStr;
        }
        else
        {
            NSString *formatStr = [phone stringByReplacingCharactersInRange:NSMakeRange(0, 3) withString:@""];
            formatStr = [formatStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            NSArray *components = [formatStr componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            components = [components filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self <> ''"]];
            formatStr = [components componentsJoinedByString:@" "];
            
            return formatStr;
        }
    }
    return phone;
}

+(UIImage *)sdwebImageCacheForKey:(NSString *)key
{
    UIImage *image = [[SDImageCache sharedImageCache] imageFromMemoryCacheForKey:key];
    if (!image) {
        image = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:key];
    }
    return image;
}

+(NSString *)sdwebImageDefauleCachePathForKey:(NSString *)key
{
    return [[SDImageCache sharedImageCache] defaultCachePathForKey:key];
}

+ (NSMutableArray *)copyAddressBook
{
    __block NSMutableArray *addressBookArray;
    
    if ([AuthorizedMethod isAdressBookAuthorized] == YES)
    {
        
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        addressBookArray = [CommonMethod copyAddressBook:addressBook];
    }else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // 弹出提示
//            [hud turnToError:@"没有获取通讯录权限"];
        });
    }
    
    return addressBookArray;
}
//按首字母排序
NSInteger nameSort(id mod1, id mod2,void*context)
{
    ContactModel *m1, *m2;
    
    //类型转换
    
    m1=(ContactModel*)mod1;
    
    m2=(ContactModel*)mod2;
    
    return[m1.name localizedCompare:m2.name];
}
+ (UIViewController *)viewControllerForView:(UIView *)view
{
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder *nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

+ (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}


//获取当前wifi名称
+ (NSString *)currentConnecttedWifi
{
    NSString *wifiName = @"";
    CFArrayRef myArray = CNCopySupportedInterfaces();
    if (myArray != nil) {
        CFDictionaryRef myDict = CNCopyCurrentNetworkInfo((CFStringRef)CFArrayGetValueAtIndex(myArray, 0));
        if (myDict != nil) {
            NSDictionary *dict = (NSDictionary*)CFBridgingRelease(myDict);
            wifiName = [dict valueForKey:@"SSID"];
        }
    }
    if (myArray) {
        CFRelease(myArray);
    }
    
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"current wifi :[%@]", wifiName]];
    return wifiName;
}

+ (BOOL)isWifiConnectted
{
    if ([self currentConnecttedWifi] != nil && ![[self currentConnecttedWifi] isEqualToString:@""])
    {
        return YES;
    }
    return NO;
}

+(BOOL)isAPModelCurrentNetForCid:(NSString *)cid pid:(NSString *)pid
{
    PropertyManager *_propertyTool = [[PropertyManager alloc] init];
    _propertyTool.propertyFilePath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"json"];
    NSString *str = [_propertyTool propertyWithPid:[pid intValue] key:pSsidPrefix];
    
    if ([cid isKindOfClass:[NSString class]] && cid.length>6) {
        
        NSString *ap = [NSString stringWithFormat:@"%@%@",str,[cid substringFromIndex:6]];
        NSString * currentwifi = [CommonMethod currentConnecttedWifi];
        if ([currentwifi isEqualToString:ap]) {
            return YES;
        }
    }
    return NO;
}

+ (BOOL)isConnectedAPWithPid:(int)productID Cid:(NSString *)cid
{
    NSString * currentwifi = [CommonMethod currentConnecttedWifi];
    NSString * apName = [CommonMethod appendAPNameWithPid:productID Cid:cid];
    if ([currentwifi isEqualToString:apName]) {
        return YES;
    }
    return NO;
}

+(NSString *)appendAPNameWithPid:(int)productID Cid:(NSString *)cid
{
    NSString * ap;
    switch (productID) {
        case productType_DoorBell:
        case productType_CatEye:
            ap = [NSString stringWithFormat:@"DOG-ML-%@",[cid substringFromIndex:6]];
            break;
        case productType_WIFI:
            ap = [NSString stringWithFormat:@"DOG-%@",[cid substringFromIndex:6]];
            break;
        case productType_720:
        case productType_720p:
        {
            ap = [NSString stringWithFormat:@"DOG-5W-%@",[cid substringFromIndex:6]];
        }
            break;
        case productType_IPCam:
        {
            ap = [NSString stringWithFormat:@"RS-CAM-%@", [cid substringFromIndex:6]];
        }
            break;
        default:
            break;
    }
    return ap;
}



+ (BOOL)isConnecttedDeviceWifiWithPid:(int)productID
{
    NSString *currentWifi = [CommonMethod currentConnecttedWifi];
    
    if ([currentWifi hasPrefix:@"DOG"] || [currentWifi hasPrefix:@"BELL"])
    {
        return YES;
    }

    switch (productID)
    {
        
        case productType_DoorBell:
        case productType_CatEye:
        {
            if ([currentWifi hasPrefix:doorbellWifiPrefix] && currentWifi.length == 13) //门铃 ap
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
            break;
        case productType_IPCam:
        {
            if ([currentWifi hasPrefix:@"RS"])
            {
                return YES;
            }
            else
            {
                return NO;
            }
        }
            break;
        case productType_3G:
        case productType_4G:
        case productType_WIFI:
        default:
        {
            if ([currentWifi hasPrefix:cameraWifiPrefix] && currentWifi.length == 10)
            {
                return YES;
                
            }else{
                
                return NO;
            }
        }
            break;
    }

    return NO;
}

//设备类型
+(NSString*)deviceType// 需要#import "sys/utsname.h"
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    // iPhone 相关判断
    if ([deviceString isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([deviceString isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([deviceString isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"Verizon iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5C";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5S";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    // iPad  相关判断
    if ([deviceString isEqualToString:@"iPad1,1"])   return @"iPad 1";
    
    if ([deviceString isEqualToString:@"iPad2,1"])   return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])   return @"iPad 2 (GSM)";
    if ([deviceString isEqualToString:@"iPad2,3"])   return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])   return @"iPad 2 (32nm)";
    if ([deviceString isEqualToString:@"iPad2,5"])   return @" ipad mini(Wifi)";
    if ([deviceString isEqualToString:@"iPad2,6"])   return @"ipad mini(GSM)";
    if ([deviceString isEqualToString:@"iPad2,7"])   return @"iPad mini(CDMA)";
    
    if ([deviceString isEqualToString:@"iPad3,1"])   return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])   return @"iPad 3 (CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])   return @"iPad 3 (4G)";
    if ([deviceString isEqualToString:@"iPad3,4"])   return @"iPad 4 (Wifi)";
    if ([deviceString isEqualToString:@"iPad3,5"])   return @" ipad 4(4G)";
    if ([deviceString isEqualToString:@"iPad3,6"])   return @"ipad 4(CDMA)";
    
    if ([deviceString isEqualToString:@"iPad4,1"])   return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,2"])   return @"iPad Air";
    if ([deviceString isEqualToString:@"iPad4,3"])   return @"iPad Air";
    
    if ([deviceString isEqualToString:@"iPad4,4"])   return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,5"])   return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,6"])   return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])   return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])   return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])   return @"iPad Mini 3";
    
    if ([deviceString isEqualToString:@"iPad5,1"])   return @"iPad Mini 4";
    if ([deviceString isEqualToString:@"iPad5,2"])   return @"iPad Mini 4";
    if ([deviceString isEqualToString:@"iPad5,3"])   return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])   return @"iPad Air 2";
    
    if ([deviceString isEqualToString:@"iPad6,7"])   return @"iPad Pro";
    if ([deviceString isEqualToString:@"iPad6,8"])   return @"iPad Pro";
    
    // iPod 相关判断
    if ([deviceString isEqualToString:@"iPod1,1"])  return @"iPod Touch 1";
    if ([deviceString isEqualToString:@"iPod2,1"])  return @"iPod Touch 2";
    if ([deviceString isEqualToString:@"iPod3,1"])  return @"iPod Touch 3";
    if ([deviceString isEqualToString:@"iPod4,1"])  return @"iPod Touch 4";
    if ([deviceString isEqualToString:@"iPod5,1"])  return @"iPod Touch 5";
    
    // 模拟器
    if ([deviceString isEqualToString:@"i386"])     return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])   return @"Simulator";
    
    return deviceString;
}

#pragma mark - 提交日志
+ (NSString *)logZipPath:(NSString *)fileName
{
    NSString *logPath = @"";
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * logFolderPath = [path stringByAppendingPathComponent:@"jfgworkdic"];
    logPath = [logFolderPath stringByAppendingPathComponent:fileName]; // @"log.zip"
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:logPath error:nil];
    [SSZipArchive createZipFileAtPath:logPath withFilesAtPaths:@[[logFolderPath stringByAppendingPathComponent:@"smartCall_t.txt"],[logFolderPath stringByAppendingPathComponent:@"smartCall_w.txt"]]];
    
    return logPath;
}

+(NSString *)languaeKeyForLiveVideoErrorType:(JFGErrorType)error
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"liveVideoErrorNo. [%lu] ",(unsigned long)error]];
    
    NSString *errorString = @"";
    if (error == JFGErrorTypeVideoPeerNotExist) {
        //设备离线
        errorString = [JfgLanguage getLanTextStrByKey:@"NOT_ONLINE"];
    }else if (error == JFGErrorTypeVideoPeerDisconnect){
        //连接中断
        errorString = [JfgLanguage getLanTextStrByKey:@"CONN_INTERRUPTED"];
    }else if (error == JFGErrorTypeVideoPeerInConnect){
        //多人查看
        errorString = [JfgLanguage getLanTextStrByKey:@"CONNECTING"];
    }else if(error == JFGErrorTypeVideoPeerNotLogin){
        //本端不在线
        errorString = [JfgLanguage getLanTextStrByKey:@"LOGIN_ERR"];
    }else if (error == JFGErrorTypeInvalidSession){
        //会话无效
        errorString = [JfgLanguage getLanTextStrByKey:@"RET_ESESSION_TIMEOUT"];
    }else if (error == JFGErrorTypeDataBase){
        //数据库错误
        errorString = [JfgLanguage getLanTextStrByKey:@"RET_MSG_EDATABASE"];
    }else if(error == 11){
        errorString = [NSString stringWithFormat:@"%@(11)",[JfgLanguage getLanTextStrByKey:@"Device_Disconnected"]];
    }else if(error == 10){
        errorString = [NSString stringWithFormat:@"%@(10)",[JfgLanguage getLanTextStrByKey:@"RET_MSG_EUNKNOWN"]];
    }else if(error == 13){
        errorString = [NSString stringWithFormat:@"%@(13)",[JfgLanguage getLanTextStrByKey:@"Device_Disconnected"]];;
    }else
    {
        errorString = [JfgLanguage getLanTextStrByKey:@"RET_MSG_EUNKNOWN"];
    }
    
    //未知错误
    return errorString;
}

+(NSString *)languageKeyForShareDeviceErrorType:(JFGErrorType)error
{
    if (error == JFGErrorTypeShareInvalidAccount) {
        //分享账号不存在
        return [JfgLanguage getLanTextStrByKey:@"RET_ELOGIN_ACCOUNT_NOT_EXIST"];
    }else if (error == JFGErrorTypeShareAlready){
        //已分享
        return [JfgLanguage getLanTextStrByKey:@"RET_ESHARE_REPEAT"];
    }else if (error == JFGErrorTypeShareToSelf){
        //不能分享给自己
        return [JfgLanguage getLanTextStrByKey:@"RET_ESHARE_NOT_YOURSELF"];
    }else if (error == JFGErrorTypeShareExceedsLimit){
        //设备分享，被分享账号不能超过5个
        return [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_ExceedTips"];
    }
    return [JfgLanguage getLanTextStrByKey:@"RET_MSG_EUNKNOWN"];
}

+(NSString *)languageKeyForAddFriendErrorType:(JFGErrorType)error
{
    
    if (error == JFGErrorTypeFriendInvalidAccount) {
        //添加好友失败 对方账户未注册
        return [JfgLanguage getLanTextStrByKey:@"RET_ELOGIN_ACCOUNT_NOT_EXIST"];
    }else if (error == JFGErrorTypeFriendAlready){
        // 已经是好友关系
        return [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_AlreadyFriend"];
    }else if (error == JFGErrorTypeFriendToSelf){
        // 不能添加自己为好友
        return [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_NotYourself"];
    }else if (error == JFGErrorTypeFriendInvalidRequest){
        // 好友请求消息过期
        return [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_ExpiredTips"];
    }
    return [JfgLanguage getLanTextStrByKey:@"RET_MSG_EUNKNOWN"];
}

+(NSString *)languageKeyForLoginErrorType:(JFGErrorType)error
{
    if (error == JFGErrorTypeLoginInvalidPass) {
        //账号密码错误
        return [JfgLanguage getLanTextStrByKey:@"RET_ELOGIN_ERROR"];
    }else if (error == JFGErrorTypeAccountNotExist || error == 29 || error == 190){
        //账号不存在(29兼容2.x  190忘记密码专属)
        return [JfgLanguage getLanTextStrByKey:@"RET_ELOGIN_ACCOUNT_NOT_EXIST"];
    }else if (error == JFGErrorTypeSMSCodeNotMatch){
        //验证码错误
        return [JfgLanguage getLanTextStrByKey:@"RET_ELOGIN_VCODE_ERROR"];
    }else if (error == JFGErrorTypeSMSCodeTimeout){
        //验证码过期
        return [JfgLanguage getLanTextStrByKey:@"RET_ESMS_CODE_TIMEOUT"];
    }else if (error == JFGErrorTypeAccountAlreadyExist){
        //账号已经存在
        return [JfgLanguage getLanTextStrByKey:@"RET_EREGISTER_PHONE_EXIST"];
    }else if (error == JFGErrorTypeSamePass){
        //原密码与新密码相同
        return [JfgLanguage getLanTextStrByKey:@"RET_ECHANGEPASS_SAME"];
    }else if (error == JFGErrorTypeInvalidPass){
        //原密码错误
        return [JfgLanguage getLanTextStrByKey:@"RET_ECHANGEPASS_OLDPASS_ERROR"];
    }else if (error == JFGErrorTypePhoneExist){
        //手机号已被使用
        return [JfgLanguage getLanTextStrByKey:@"RET_EEDITUSERINFO_SMS_PHONE"];
    }else if (error == JFGErrorTypeEmailExist){
        //邮箱已被使用
        return [JfgLanguage getLanTextStrByKey:@"RET_EEDITUSERINFO_EMAIL"];
    }else if (error == JFGErrorTypeIsNotPhone){
        //手机号不合法
        return [JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER_2"];
    }else if (error == JFGErrorTypeIsNotEmail){
        //邮箱不合法
        return [JfgLanguage getLanTextStrByKey:@"EMAIL_2"];
        
    }else if (error == JFGErrorTypeLoginInvalidVKey){
        
        return @"Invalid VKey(160)";
    }else if (error == 192){
        return [JfgLanguage getLanTextStrByKey:@"GetCode_FrequentlyTips"];
    }
    
    return [JfgLanguage getLanTextStrByKey:@"RET_MSG_EUNKNOWN"];
}


+(NSString *)headImageUrlForAccount:(NSString *)account
{
    ///image/[account].jpg
    NSString *fileName = [NSString stringWithFormat:@"/image/%@.jpg",account];
    NSString *h = [JFGSDK getCloudUrlWithFlag:1 fileName:fileName];
    return h;
}

+(NSString *)uplodUrlForLogWithAccount:(NSString *)account timestamp:(int64_t)timestamp
{
    NSString *uploadUrl = [NSString stringWithFormat:@"/log/%@/%@/%lld.zip",[OemManager getOemVid],account,timestamp];
    return uploadUrl;
}

+(NSString *)uplodUrlForHeadImageWithAccount:(NSString *)account
{
    NSString *url = [NSString stringWithFormat:@"/image/%@.jpg",account];
    return url;
}

+(void)setHeadImageForImageView:(UIImageView *)imageView account:(NSString *)account
{
    NSString *fileName = [NSString stringWithFormat:@"/image/%@.jpg",account];
    NSString *h = [JFGSDK getCloudUrlWithFlag:1 fileName:fileName];
    [imageView sd_setImageWithURL:[NSURL URLWithString:h] placeholderImage:[UIImage imageNamed:@"friends_head"]];
}


+(NSString *)getCloudHeadImageForAccount:(NSString *)account
{
    NSString *_account;
    
    if (account== nil || [account isEqualToString:@""]) {
        JFGSDKAcount *acc =[[LoginManager sharedManager] accountCache];
        _account = acc.account;
    }else{
        _account = account;
    }
    if (_account == nil) {
        _account = @"";
    }
    NSString *fileName = [NSString stringWithFormat:@"/image/%@.jpg",_account];
    NSString *headUrl = [JFGSDK getCloudUrlWithFlag:1 fileName:fileName];
    if (headUrl && ![headUrl isEqualToString:@""]) {
        [[NSUserDefaults standardUserDefaults] setObject:headUrl forKey:_account];
    }else{
        headUrl = [[NSUserDefaults standardUserDefaults] objectForKey:_account];
        if (headUrl == nil) {
            headUrl = @"";
        }
    }
    //[JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"hear url [%@]", headUrl]];
    
    return headUrl;
}

+(void)delDeviceByOtherClientWithNotification:(NSNotification *)notification cid:(NSString *)vcCid superViweController:(UIViewController *)vc
{
    if (notification == nil) {
        return;
    }
    
    static BOOL isShow = NO;
    
    NSDictionary *dict = notification.object;
    NSString *cid = dict[@"cid"];
    int isDel = [dict[@"delType"] intValue];
    
    if ([cid isEqualToString:vcCid] && isShow == NO) {
        
        NSString *str;
        if (isDel == 0) {
            str = [JfgLanguage getLanTextStrByKey:@"Tap1_shareDevice_canceledshare"];
        }else{
            str = [JfgLanguage getLanTextStrByKey:@"Tap1_device_deleted"];
        }
        
        isShow = YES;
        
        __weak UIViewController* weakvc = vc;
        [LSAlertView showAlertWithTitle:nil Message:str CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
            
            isShow = NO;
            [weakvc.navigationController popToRootViewControllerAnimated:YES];
            
        } OKBlock:^{
        
        }];
        
    }
}

+(void)showNetDisconnectAlert
{
    [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
}

+(NSTimeInterval)sheetAnimationTimeIntervalForHeight:(CGFloat)height
{
//    CGFloat speed = 390;
//    double time = height/speed;
//    if (time>2) {
//        time = 2;
//    }
//    NSLog(@"interval:%f",time);
//    return time;
    return 0.3;
}

//十进制转二进制
+(NSString *)toBinarySystemWithDecimalSystem:(NSInteger)decimal
{
    NSInteger num = decimal;//[decimal intValue];
    NSInteger remainder = 0;      //余数
    NSInteger divisor = 0;        //除数
    
    NSString * prepare = @"";
    
    while (true)
    {
        remainder = num%2;
        divisor = num/2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%ld",(long)remainder];
        
        if (divisor == 0)
        {
            break;
        }
    }
    
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i --)
    {
        result = [result stringByAppendingFormat:@"%@",
                  [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    
    return result;
}

+(NSString *)urlForLANFor720DevWithReqType:(JFG720DevLANReqUrlType)type ipAdd:(NSString *)ipAdd
{
    switch (type) {
        case JFG720DevLANReqUrlTypeSnapShot:{
            NSString *str = [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=snapShot",ipAdd];
            return str;
        }

            break;
      
        case JFG720DevLANReqUrlTypeGetRecStatue:{
            return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getRecStatus",ipAdd];
        }
            
            break;
        case JFG720DevLANReqUrlTypeSDFormat:{
             return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=sdFormat",ipAdd];
        }
            
            break;
        case JFG720DevLANReqUrlTypeGetSDInfo:{
            return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getSdInfo",ipAdd];
        }
            
            break;
        case JFG720DevLANReqUrlTypeGetPowerLine:{
            return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getPowerLine",ipAdd];
        }
            
            break;
        case JFG720DevLANReqUrlTypeBattery:{
            return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getBattery",ipAdd];
        }
            
            break;
        case JFG720DevLANReqUrlTypeGetRP:{
            return [NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getResolution",ipAdd];
        }
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - 获取设备当前网络IP地址
+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}
+ (BOOL)isValidatIP:(NSString *)ipAddress {
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result=[ipAddress substringWithRange:resultRange];
            //输出结果
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"ipv4 address %@",result]];
            return YES;
        }
    }
    return NO;
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ IOS_VPN @"/" IP_ADDR_IPv4, IOS_VPN @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[ IOS_VPN @"/" IP_ADDR_IPv6, IOS_VPN @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}


/*
 * 二进制转十进制
 **/
+ (NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary
{
    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}

#pragma mark
#pragma mark  -- 设备类型判断
/**
 * 是否 是 摄像头
 */
+ (BOOL)isCameraWithType:(NSInteger)pType
{
    if (pType == productType_WIFI ||
        pType == productType_WIFI_V2 ||
        pType == productType_WIFI_V3 ||
        pType == productType_3G ||
        pType == productType_3G_2X ||
        pType == productType_4G ||
        pType == productType_FreeCam ||
        pType == productType_Camera_GK ||
        pType == productType_Camera_HS ||
        pType == productType_CesCamera ||
        pType == productType_Camera_ZY ||
        pType == productType_RS_180
        )
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isPanoCameraWithType:(NSInteger)pType
{
    if (pType == productType_Camera_GK ||
        pType == productType_Camera_HS ||
        pType == productType_720p   ||
        pType == productType_720    ||
        pType == productType_IPCam     ||
        pType == productType_CesCamera ||
        pType == productType_Camera_ZY)
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isDeviceHasBattery:(NSInteger)pType
{
    switch (pType)
    {
        case productType_3G:
        case productType_3G_2X:
        case productType_4G:
        case productType_FreeCam:
        {
            return YES;
        }
            break;
            
        default:
        {
            return NO;
        }
            break;
    }
    

    return NO;
}

+ (BOOL)isDeviceBlockUpgrade:(NSInteger)pType
{
    switch (pType) {
        case productType_720:
        case productType_720p:
        {
            return YES;
        }
            break;
            
        default:
            break;
    }
    
    return NO;
}

+(NSDictionary *)jfgConfigPlist
{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"jfgConfig" ofType:@"plist"];
    NSDictionary *dict = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    return dict;
}

+(BOOL)isSingleFisheyeCameraForCid:(NSString *)cid
{
     NSArray *devicesList = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    for (JiafeigouDevStatuModel *model in devicesList) {
        
        if ([model.uuid isEqualToString:cid]) {
            
            if ([[self class] devBigTypeForOS:model.pid] ==JFGDevBigTypeSinglefisheyeCamera) {
                return YES;
            }else{
                return NO;
            }
            
        }
        
    }
    return NO;
}

+(JFGDevViewType)devBigTypeForOS:(NSString *)os
{
    
    PropertyManager *_propertyTool = [[PropertyManager alloc] init];
    _propertyTool.propertyFilePath = [[NSBundle mainBundle] pathForResource:@"properties" ofType:@"json"];
    NSString *str = [_propertyTool propertyWithPid:[os intValue] key:pViewShapeKey];
    if ([os isEqualToString:@"21"] || [os isEqualToString:@"1089"]) {
        return JFGDevBigTypeEyeCamera;
    }else if (
              [os isEqualToString:@"10"] ||
              [os isEqualToString:@"18"] ||
              [os isEqualToString:@"20"] ||
              [os isEqualToString:@"36"] ||
              [os isEqualToString:@"39"] ||
              [os isEqualToString:@"47"] ||
              [os isEqualToString:@"49"]){
        //10、18、36、20、39、49、47鱼缸
        return JFGDevBigType360;
    }else if ([str isEqualToString:@"圆形"] || [str isEqualToString:@"圆形（切掉上下部分）"] || [str isEqualToString:@"鱼缸"]){
        return JFGDevBigTypeSinglefisheyeCamera;
    }else{
        return JFGDevBigTypeSquareness;
    }
}

+(NSInteger)lenghtForString:(NSString *)string
{
    int j = 0;
    for(int i =0; i < [string length]; i++)
    {
        NSString *temp = [string substringWithRange:NSMakeRange(i, 1)];
        if ([temp isEqualToString:@""]) {
            j = j+0;
        }else if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1){
            j = j+2;
        }else{
            j = j+1;
        }
        
    }
    return j;
}

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize
{
    UIImage *newimage;
    if (nil == image)
    {
        newimage = nil;
    } else {
        
        CGSize oldsize = image.size;
        
        CGRect rect;
        
        if (asize.width/asize.height > oldsize.width/oldsize.height)
            
        {
            
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            
            rect.size.height = asize.height;
            
            rect.origin.x = (asize.width - rect.size.width)/2;
            
            rect.origin.y = 0;
            
        } else {
            
            rect.size.width = asize.width;
            
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            
            rect.origin.x = 0;
            
            rect.origin.y = (asize.height - rect.size.height)/2;
            
        }
        
        UIGraphicsBeginImageContext(asize);
        
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        
        [image drawInRect:rect];
        
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
    }
    
    return newimage;
    
}

+(SFCParamModel *)panoramicViewParamModelForCid:(NSString *)cid
{
    SFCParamModel *paramModel = [JfgCacheManager getSfcPatamModelForCid:cid];
    if (paramModel) {
        if (paramModel.x >1920 ||paramModel.y>1500 ||paramModel.r >1500 ) {
            paramModel = nil;
        }
    }
    return paramModel;
}

@end
