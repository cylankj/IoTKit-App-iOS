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
            return [JfgLanguage getLanTextStrByKey:@"MSG_WARNING"];
        }
            break;
        case dpMsgBase_SDStatus:
        default:
        {
            return [JfgLanguage getLanTextStrByKey:self.isSDCardOn?@"MSG_SD_ON":@"MSG_SD_OFF"];
        }
            break;
    }
}

- (BOOL)isShowVideoBtn
{
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
    ////拼一个假的url作为key，获取缓存图片
    //_url =
    NSString *url = [JfgDataTool getCloudUrlForCid:self.cid timestamp:self.timestamp order:order flag:self.flag];
    
    if (self.deviceVersion == 3) {
        
        ///cid/[vid]/[cid]/[timestamp]_[id].jpg
        NSString *filaName = [NSString stringWithFormat:@"cid/%@/%@/%lld_%d.jpg",[OemManager getOemVid],self.cid,(uint64_t)self.timestamp,order];
        url = [JFGSDK getCloudUrlWithFlag:self.flag fileName:filaName];
        
    }
    
    if (url == nil || [url isEqualToString:@""]) {
        //200000000472/1488178082_1.jpg
        NSString *path = [NSString stringWithFormat:@"%@/%lld_%d.jpg",self.cid,(long long)self.timestamp,order];
        url = [NSString stringWithFormat:@"https://www.jfgou.com/%@",path];
        
    }
    return url;
}

- (NSMutableArray *)msgImages
{
    
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {

        if (self.leftImageUrl == nil || ![self.leftImageUrl containsString:@"www.jfgou.com"]) {
            _msgImages = [[NSMutableArray alloc] initWithCapacity:3];
            [self addmsgImages:self.leftImageUrl];
            [self addmsgImages:self.centerImageUrl];
            [self addmsgImages:self.rightImageUrl];
        }
        
    }else{
        
        if (self.leftImageUrl == nil || [self.leftImageUrl containsString:@"www.jfgou.com"])
        {
            _msgImages = [[NSMutableArray alloc] initWithCapacity:3];
            
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
