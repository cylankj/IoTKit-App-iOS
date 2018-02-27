//
//  MessageModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/9/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "MessageModel.h"
#import "JfgDataTool.h"
#import "JfgLanguage.h"
#import "JfgMsgDefine.h"
#import "JfgTimeFormat.h"
#import "OemManager.h"
#import "CommonMethod.h"
#import "LoginManager.h"
#import "JfgConfig.h"
#import "SDWebImageCacheHelper.h"

@interface MessageModel()

@property (nonatomic, copy) NSString *leftImageUrl;
@property (nonatomic, copy) NSString *centerImageUrl;
@property (nonatomic, copy) NSString *rightImageUrl;

@end

@implementation MessageModel

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (NSString *)topString
{
    return [NSString stringWithFormat:@"%@  %@",self.timeString, self.textString];
}


- (NSString *)timeString
{
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:self.timestamp];
    //实例化一个NSDateFormatter对象
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//设置本地时区
    //设定时间格式,这里可以设置成自己需要的格式
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    return currentDateStr;
}

- (NSString *)textString
{
    switch (self.msgID)
    {
        case dpMsgCamera_WarnMsg:
        {
            if ([self.objects isKindOfClass:[NSArray class]] && self.objects.count) {
                return [self stringFromObjects:self.objects];
            }
            return [JfgLanguage getLanTextStrByKey:@"MSG_WARNING"];
        }
            break;
        case dpMsgBase_SDStatus:
        {
            return [JfgLanguage getLanTextStrByKey:self.isSDCardOn?@"MSG_SD_ON":@"MSG_SD_OFF"];
        }
            break;
        case 401:{
            if (self.isAnswer) {
                return [JfgLanguage getLanTextStrByKey:@"DOOR_CALL"];
            }else{
                return [JfgLanguage getLanTextStrByKey:@"DOOR_UNCALL"];
            }
        }
            break;
        case 527:{
            return [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"SUCCESS_REGFACE"],self.otherMsg];
        }
            break;
        default:{
            return [JfgLanguage getLanTextStrByKey:@"MSG_WARNING"];
        }
            break;
    }
}

-(NSString *)stringFromObjects:(NSArray *)objects
{
    NSMutableString *text = [[NSMutableString alloc]initWithString:[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"]];
    for (NSNumber *num in objects) {
        
        if (![num isKindOfClass:[NSNumber class]]) {
            break; 
        }
        
        if (![text isEqualToString:[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"]]) {
            [text appendString:@","];
        }
        if ([num intValue] == 1) {
            [text appendString:[JfgLanguage getLanTextStrByKey:@"AI_HUMAN"]];
        }else if ([num intValue] == 2){
            [text appendString:[JfgLanguage getLanTextStrByKey:@"AI_CAT"]];
        }else if ([num intValue] == 3){
            [text appendString:[JfgLanguage getLanTextStrByKey:@"AI_DOG"]];
        }else if ([num intValue] == 4){
            [text appendString:[JfgLanguage getLanTextStrByKey:@"AI_VEHICLE"]];
        }
    }
    return text;
}

- (BOOL)isShowVideoBtn
{
    if (self.msgID == 401 || self.msgID == 403) {
        return self.is_record;
    }
    long localTime = [[NSDate date] timeIntervalSince1970];
    if ((localTime - self.timestamp) >= 30*60)
    {
        return YES;
    }
    return NO;
}

- (NSString *)leftImageUrl
{
    
    if (self.imageNum & 0x1)
    {
        return [self imageUrlWithOrder:1];
    }
    return nil;
}

- (NSString *)centerImageUrl
{
    if (self.imageNum>>1 & 0x1)
    {
        return [self imageUrlWithOrder:2];
    }
    return nil;
}


- (NSString *)rightImageUrl
{
    if (self.imageNum>>2 & 0x1)
    {
        return [self imageUrlWithOrder:3];
    }
    return nil;
}


- (NSString *)imageUrlWithOrder:(int)order
{
    NSString *fileName = [NSString stringWithFormat:@"/%@/%lld_%d.jpg",self.cid,(long long)self.timestamp,order];
    if (order == 0) {
        fileName = [NSString stringWithFormat:@"/%@/%lld.jpg",self.cid,(long long)self.timestamp];
    }
    
    if (self.deviceVersion == 3) {
        
        fileName = [NSString stringWithFormat:@"cid/%@/%@/%lld_%d.jpg",[OemManager getOemVid],self.cid,(uint64_t)self.timestamp,order];
        if (order == 0) {
            fileName = [NSString stringWithFormat:@"cid/%@/%@/%lld.jpg",[OemManager getOemVid],self.cid,(uint64_t)self.timestamp];
        }

    }

    BOOL isExist = [SDWebImageCacheHelper diskImageExistsForFileName:fileName];
    if (isExist) {
        
        return [SDWebImageCacheHelper sdwebCacheForTempPathForFileName:fileName];
    }else{
        
        return [JFGSDK getCloudUrlWithFlag:self.flag fileName:fileName];
    }
}

- (NSMutableArray *)msgImages
{
    if (!_msgImages) {
        _msgImages = [[NSMutableArray alloc] initWithCapacity:3];
        if (self.imageNum == 0) {
            [self addmsgImages:[self imageUrlWithOrder:0]];
        }else{
            [self addmsgImages:self.leftImageUrl];
            [self addmsgImages:self.centerImageUrl];
            [self addmsgImages:self.rightImageUrl];
        }
    }
    return _msgImages;
}

- (void)addmsgImages:(id)obj
{
    if (obj != nil)
    {
        [_msgImages addObject:obj];
    }
}

@end

@implementation faceProperty

@end
