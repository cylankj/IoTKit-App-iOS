//
//  JFGEfamilyData.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/9/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>
@class JFGEfamilyDataModel;

typedef NS_ENUM(NSInteger,JFGEfamilyMsgType) {
    JFGEfamilyMsgTypeVoice,//音频
    JFGEfamilyMsgTypeVideo,//视频
};

@interface JFGEfamilyDataManager : NSObject
/**
 *  实例
 *
 *  @return 实例对象
 */
+(instancetype)defaultEfamilyManager;


/**
 *  获取所有中控消息列表
 *
 *  @return 消息列表
 */
-(NSArray *)getEfamilyMsgList;


/**
 *  获取某个中控消息
 *
 *  @param cid 中控标示
 *
 *  @return 消息列表
 */
-(NSArray <JFGEfamilyDataModel *>*)getEfamilyMsgListForCid:(NSString *)cid;


/**
 *  删除某个中控所有消息
 *
 *  @param cid 设备标示
 */
-(void)deleteEfamilyMsgListForCid:(NSString *)cid;


/**
 *  添加中控消息
 *
 *  @param msgModel 中控消息模型
 */
-(void)addEfamilyMsg:(JFGEfamilyDataModel *)msgModel;

@end



@interface JFGEfamilyDataModel : NSObject

@property (nonatomic,assign)BOOL isFromSelf;
@property (nonatomic,copy)NSString *cid;
@property (nonatomic,assign)JFGEfamilyMsgType msgType;
@property (nonatomic,assign)BOOL acceptSuccess;
@property (nonatomic,  copy)NSString *resourceUrl;
@property (nonatomic,assign)int64_t timeLength;
@property (nonatomic,assign)int64_t timestamp;
@property (nonatomic,assign)BOOL isPlaying;
@property (nonatomic,strong)NSIndexPath *indexPath;
@end
