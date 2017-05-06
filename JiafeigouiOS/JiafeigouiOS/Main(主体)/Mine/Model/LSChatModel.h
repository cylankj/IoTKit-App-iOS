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

typedef NS_ENUM(NSInteger,LSSendStatue) {
    LSSendStatueSuccess,//发送成功
    LSSendStatueFailed,//发送失败
    LSSendStatueSending,//发送中...
};

@interface LSChatModel : NSObject

/**
 *  内容
 */
@property   (strong, nonatomic)NSString *msg;
/**
 *  时间
 */
@property   (strong, nonatomic)NSString * msgDate;
/**
 *  上一条数据的时间时间
 */
@property   (strong, nonatomic)NSString * lastMsgDate;


@property (assign,nonatomic)uint64_t timestamp;
/**
 *  类型（消息发送方）
 */
@property   (assign, nonatomic)LSModelType modelType;
/**
 *  cell的高度
 */
@property   (assign, nonatomic)CGFloat cellHeight;
/**
 *   允许显示时间label
 */
@property   (assign, nonatomic)BOOL enableDateLabel;

@property (assign,nonatomic)LSSendStatue sendStatue;
@property (assign,nonatomic)BOOL isUplog;



@end
