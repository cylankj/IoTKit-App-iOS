//
//  JFGEfamilyData.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/9/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGEfamilyDataManager.h"
#import <UIKit/UIKit.h>
#import "LoginManager.h"

@interface JFGEfamilyDataManager()
{
    NSMutableArray *dataArray;
}
@end


@implementation JFGEfamilyDataManager

-(id)init
{
    self = [super init];
    
    //程序后台或者退出自动存储数据到本地
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationWillTerminateNotification object:nil];
    
    
    
    return self;
}

+(instancetype)defaultEfamilyManager
{
    static JFGEfamilyDataManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[JFGEfamilyDataManager alloc]init];
    });
    return manager;
}


-(NSArray *)getEfamilyMsgList
{
    if (!dataArray || dataArray.count==0) {
        //取缓存
        NSArray *dat = [self getCacheData];
        dataArray = [[NSMutableArray alloc]initWithArray:dat];
    }
    NSArray *tempArr = [[NSArray alloc]initWithArray:dataArray];
    return tempArr;
}

-(NSArray <JFGEfamilyDataModel *>*)getEfamilyMsgListForCid:(NSString *)cid
{
    if (!dataArray || dataArray.count==0) {
        //取缓存
        NSArray *dat = [self getCacheData];
        dataArray = [[NSMutableArray alloc]initWithArray:dat];
    }

    NSMutableArray *resultArr = [NSMutableArray new];
    for (JFGEfamilyDataModel *model in dataArray) {
        if ([model.cid isEqualToString:cid]) {
            [resultArr addObject:model];
        }
    }
    
    return resultArr;
}

-(void)deleteEfamilyMsgListForCid:(NSString *)cid
{
    NSArray *dataArr = [self getEfamilyMsgList];
    for (JFGEfamilyDataModel *model in dataArr) {
        
        if ([model.cid isEqualToString:cid]) {
            [dataArray removeObject:model];
        }
    }
    [self saveData:dataArray];
    
}

-(void)addEfamilyMsg:(JFGEfamilyDataModel *)msgModel
{
    if (!dataArray) {
        [self getEfamilyMsgList];
    }
    BOOL isExist = NO;
    for (JFGEfamilyDataModel *md in dataArray) {
        
        if (md.timestamp == msgModel.timestamp && [md.cid isEqualToString:msgModel.cid]) {
            isExist = YES;
            break;
        }
        
    }
    
    if (isExist == NO) {
        [dataArray addObject:msgModel];
    }
}

//模型数组归档
-(void)saveData:(NSArray <JFGEfamilyDataModel *>*)deviceList
{
    if (!deviceList) {
        return;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    //创建归档辅助类
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    //编码
    [archiver encodeObject:deviceList forKey:@"list"];
    //结束编码
    [archiver finishEncoding];
    //写入
    [data writeToFile:[self filePath] atomically:YES];
    //NSLog(@"%d",success);
}


-(NSArray *)getCacheData
{
    NSData *_data = [NSData dataWithContentsOfFile:[self filePath]];
    if (_data == nil) {
        return [NSArray new];
    }
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:_data];
    //解档出数据模型Student
    //解码并解档出model
    NSArray *list = [unarchiver decodeObjectForKey:@"list"];
    //关闭解档
    [unarchiver finishDecoding];
    return list;
}



-(void)applicationDidEnterBackground
{
    [self saveData:dataArray];
}

-(NSString *)filePath
{
    NSString *account ;
    
    JFGSDKAcount *acc = [LoginManager sharedManager].accountCache;
    account = acc.account;
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_efamilyData.db",account]];
    return path;
}


@end

@implementation JFGEfamilyDataModel

MJCodingImplementation

+ (NSArray *)mj_ignoredCodingPropertyNames
{
    return @[@"isPlaying",@"indexPath"];
}

@end
