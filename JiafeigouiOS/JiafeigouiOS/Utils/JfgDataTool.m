//
//  JfgDataTool.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/9/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JfgDataTool.h"
#import "JfgLanguage.h"
#import "XMLDictionary.h"
#import <JFGSDK/JFGSDK.h>
#import "JfgTypeDefine.h"
#import "JfgUserDefaultKey.h"
#import "PropertyManager.h"
#import "LoginManager.h"

@implementation JfgDataTool

NSString *const timezoneDictKey = @"timezone";
NSString *const timezoneKey = @"_id";
NSString *const timezoneValue = @"__text";


#pragma mark
#pragma mark  === 功能设置 ===
/**
 *  将位移 重复时间 转换成 字符串
 *  加菲狗 功能设置 用到
 *  @param repeatTime
 *
 *  @return
 */
+ (NSString *)repeatTimeStr:(long)repeatTime
{
    NSString *resultStr = @"";
    
    switch (repeatTime)
    {
        case 0:
        {
            
        }
            break;
        case 3:
        {
            resultStr = [JfgLanguage getLanTextStrByKey:@"WEEKEND"];
        }
            break;
        case 124:
        {
            resultStr = [JfgLanguage getLanTextStrByKey:@"WEEKDAYS"];
        }
            break;
        case 127:
        {
            resultStr = [JfgLanguage getLanTextStrByKey:@"EVERY_DAY"];
        }
            break;
        default:
        {
            resultStr = [JfgLanguage getLanTextStrByKey:@"WEEK"];
            if (repeatTime>>6 & 0x1)
            {
                resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@、", [JfgLanguage getLanTextStrByKey:@"MON_2"]]];
            }
            if (repeatTime>>5 & 0x1) {
                if (resultStr.length > 1) {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@、", [JfgLanguage getLanTextStrByKey:@"TUE_2"]]];
                }else{
                    resultStr = [resultStr stringByAppendingString:[JfgLanguage getLanTextStrByKey:@"TUE_2"]];
                }
            }
            if (repeatTime>>4 & 0x1) {
                if (resultStr.length > 1) {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@、", [JfgLanguage getLanTextStrByKey:@"WED_2"]]];
                }else{
                    resultStr = [resultStr stringByAppendingString:[JfgLanguage getLanTextStrByKey:@"WED_2"]];
                }
            }
            if (repeatTime>>3 & 0x1) {
                if (resultStr.length > 1) {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@、", [JfgLanguage getLanTextStrByKey:@"THU_2"]]];
                }else{
                    resultStr = [resultStr stringByAppendingString:[JfgLanguage getLanTextStrByKey:@"THU_2"]];
                }
            }
            if (repeatTime>>2 & 0x1) {
                if (resultStr.length > 1)
                {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@、", [JfgLanguage getLanTextStrByKey:@"FRI_2"]]];
                }else{
                    resultStr = [resultStr stringByAppendingString:[JfgLanguage getLanTextStrByKey:@"FRI_2"]];
                }
            }
            if (repeatTime>>1 & 0x1) {
                if (resultStr.length > 1)
                {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@、", [JfgLanguage getLanTextStrByKey:@"SAT_2"]]];
                }else{
                    resultStr = [resultStr stringByAppendingString:[JfgLanguage getLanTextStrByKey:@"SAT_2"]];
                }
            }
            if (repeatTime & 0x1) {
                if (resultStr.length > 1)
                {
                    resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@、", [JfgLanguage getLanTextStrByKey:@"SUN_2"]]];
                }else{
                    resultStr = [resultStr stringByAppendingString:[JfgLanguage getLanTextStrByKey:@"SUN_2"]];
                }
            }
            if ([resultStr hasSuffix:@"、"])
            {
                resultStr = [resultStr substringToIndex:resultStr.length - 1];
            }
        }
            break;
    }
    
    return resultStr;
}

/**
 *  获取 自动录像 字符串
 *
 *  @param autoPhoto
 *
 *  @return
 */
+ (NSString *)autoPhotoStr:(int)autoPhoto
{
    switch (autoPhoto)
    {
        case MotionDetectNever:
        {
            return [JfgLanguage getLanTextStrByKey:@"RECORD_MODE_2"];
        }
            break;
        case MotionDetectAllDay:
        {
            return [JfgLanguage getLanTextStrByKey:@"RECORD_MODE_1"];
        }
            break;
        case MotionDetectAbnormal:
        {
            return [JfgLanguage getLanTextStrByKey:@"RECORD_MODE"];
        }
            break;
        default:
            return @"";
            break;
    }
}

+ (BOOL)deviceIsOnline:(DeviceNetType)netType
{
    if (netType == DeviceNetType_Offline || netType == DeviceNetType_Connetct)
    {
        return NO;
    }
    return YES;
}

+ (NSString *)aiRecognitionStr:(NSArray *)aiRecognitions
{
    NSString *resultStr = @" ";
    
    if (aiRecognitions.count > 0)
    {
        @try {
            for (NSInteger i = 0; i < aiRecognitions.count; i ++)
            {
                int aiRecognitionType = [[aiRecognitions objectAtIndex:i] intValue];
                
                switch (aiRecognitionType)
                {
                    case AIRecType_Person:
                    {
                        resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@ ",[JfgLanguage getLanTextStrByKey:@"AI_HUMAN"]]];
                    }
                        break;
                    case AIRecType_Cat:
                    {
                        resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@ ",[JfgLanguage getLanTextStrByKey:@"AI_CAT"]]];
                    }
                        break;
                    case AIRecType_Dog:
                    {
                        resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@ ",[JfgLanguage getLanTextStrByKey:@"AI_DOG"]]];
                    }
                        break;
                    case AIRecType_Car:
                    {
                        resultStr = [resultStr stringByAppendingString:[NSString stringWithFormat:@"%@ ",[JfgLanguage getLanTextStrByKey:@"AI_VEHICLE"]]];
                    }
                        break;
                    default:
                        break;
                }
            }
        } @catch (NSException *exception) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"jfgDataTool aiRecognitionStr %@", exception]];
        } @finally {
            resultStr = @"";
        }
        
    }
    return resultStr;
}


+ (NSDictionary *)timeZoneDict
{
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:[JfgLanguage languageType] == LANGUAGE_TYPE_CHINESE?@"timezones":@"timezones-en" ofType:@"xml"];
    return [NSDictionary dictionaryWithXMLFile:xmlPath];
}
+ (NSString *)timeZoneForKey:(NSString *)key
{
    NSDictionary *timeZoneDict = [self timeZoneDict];
    NSArray *timeZoneArray = [timeZoneDict objectForKey:timezoneDictKey];
    
    for (NSInteger i = 0; i < timeZoneArray.count ; i ++)
    {
        NSDictionary *dictTemp = [timeZoneArray objectAtIndex:i];
        if ([[dictTemp objectForKey:timezoneKey] isEqualToString:key])
        {
            return [dictTemp objectForKey:timezoneValue];
        }
    }
    
    return key;
    
}

/**
 *  返回 拼接 好的 图片url
 *
 *  @param cid       cid description
 *  @param timestamp 时间戳
 *  @param order     数序 第几张
 *  @param flag      flag description
 *
 *  @return 字符串
 */
+ (NSString *)getCloudUrlForCid:(NSString *)cid timestamp:(uint64_t)timestamp order:(int)order flag:(int)flag
{
    ///cid/[vid]/[cid]/[timestamp]_[id].jpg   3.0
    ///[cid]/[timestamp]_[id].jpg   2.0
    NSString *filaName = [NSString stringWithFormat:@"/%@/%lld_%d.jpg",cid,timestamp,order];
    if (order == 0) {
        filaName = [NSString stringWithFormat:@"/%@/%lld.jpg",cid,timestamp];
    }
    return [JFGSDK getCloudUrlWithFlag:flag fileName:filaName];

//    return [JFGSDK getCloudUrlByType:JFGSDKGetCloudUrlTypeWarning flag:flag fileName:[NSString stringWithFormat:@"%lld_%d.jpg",timestamp,order] cid:cid];
    //}
}
/**
 返回拼接好的延时摄影视频url

 @param cid       cid
 @param timestamp 时间戳
 @param vid       登陆的时候用到的LoginManager里有
 @param flag      flag description
 @param type      获取的文件的类型
 
 @return 字符串
 */
+ (NSString *)getTimeLapseForCid:(NSString *)cid timestamp:(uint64_t)timestamp vid:(NSString *)vid flag:(int)flag fileType:(NSString *)type
{
    JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
    ///long/[vid]/[account]/wonder/[cid]/[timestamp].mp4
    NSString *fileNm = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%lld.mp4",vid,account.account,cid,timestamp];
    NSString *filaName = [JFGSDK getCloudUrlWithFlag:flag fileName:fileNm];
    return filaName;
}

#pragma mark 红点 显示
+ (BOOL)isShowRedDotInSettingButton:(NSString *)cid pid:(NSInteger)pType
{
    BOOL isShowSafeRedDot = NO;
    BOOL isShowAutoPhotoRedDot = NO;
    
    if ([PropertyManager showPropertiesRowWithPid:pType key:pProtectionKey])
    {
        isShowSafeRedDot = [JfgDataTool isShowRedDotInSafeProColumn:cid pid:pType];
    }
    
    if ([PropertyManager showPropertiesRowWithPid:pType key:pRecordSettingKey])
    {
        isShowAutoPhotoRedDot = [[NSUserDefaults standardUserDefaults] boolForKey:isShowAutoPhotoRedDot(cid)];
    }
    
    return (
            isShowSafeRedDot ||
            isShowAutoPhotoRedDot ||
            [[NSUserDefaults standardUserDefaults] boolForKey:isShowDelayPhotoRedDot(cid)]
            );
    
}

+ (BOOL)isShowRedDotInSafeProColumn:(NSString *)cid pid:(NSInteger)pType
{
    BOOL isShowAIRedDot = NO;
    
    if ([PropertyManager showPropertiesRowWithPid:pType key:pAiRecognition] || [PropertyManager showSharePropertiesRowWithPid:pType key:pAiRecognition]) // 如果显示 AI识别 才 返回值，否则返回 NO
    {
        isShowAIRedDot = [[NSUserDefaults standardUserDefaults] boolForKey:isShowSafeAIRedDot(cid)];
    }
    
    return  isShowAIRedDot;
}


@end
