//
//  LSChatModel.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,LSModelType) {
    LSModelTypeMe = 0,
    LSModelTypeOther
};

@interface LSChatModel : NSObject
/**
 *  内容
 */
@property   (strong, nonatomic)                             NSString *msg;
/**
 *  时间
 */
@property   (strong, nonatomic)                             NSString * msgDate;
/**
 *  上一条数据的时间时间
 */
@property   (strong, nonatomic)                             NSString * lastMsgDate;
/**
 *  类型（消息发送方）
 */
@property   (assign, nonatomic)                             LSModelType modelType;
/**
 *  cell的高度
 */
@property   (assign, nonatomic)                             CGFloat cellHeight;
/**
 *   允许显示时间label
 */
@property   (assign, nonatomic)                             BOOL enableDateLabel;

/** 获取聊天数据*/
+ (NSArray <LSChatModel *> *)allMsgModel;

/** 创建一个聊天的model
*   msg :信息
*   lastMsgDate :上一条数据时间
*   modelType :发送方
**/
+ (LSChatModel *)creatModel:(NSDictionary *)dic;



@end
