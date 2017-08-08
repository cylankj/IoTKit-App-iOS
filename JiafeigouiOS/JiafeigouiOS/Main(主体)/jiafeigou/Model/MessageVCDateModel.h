//
//  MessageVCDateModel.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/24.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageVCDateModel : NSObject

@property (nonatomic,assign)int64_t startTimestamp;
@property (nonatomic,assign)int64_t lastestTimestamp;//结束时间戳
@property (nonatomic,assign)NSInteger year;
@property (nonatomic,assign)NSInteger mounth;
@property (nonatomic,assign)NSInteger day;
@property (nonatomic,assign)BOOL isHasMessage;
@property (nonatomic,assign)BOOL isSelectedDate;
@property (nonatomic,strong)NSMutableArray *messageDataArr;


//获取给定时间下一天零点时间戳
+(NSTimeInterval)timestampsAfter1DayWithTimestamp:(UInt64)timestamp;

//获取给定时间起往前15天零点时间戳
+(NSArray *)timestampsBefore15DayWithTimestamp:(UInt64)timestamp;

+(NSInteger)yearFromTimestamp:(NSTimeInterval)timestamp;

+(NSInteger)monthFromTimestamp:(NSTimeInterval)timestamp;

+(NSInteger)dayFromTimestamp:(NSTimeInterval)timestamp;

@end
