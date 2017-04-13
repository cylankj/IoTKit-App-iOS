//
//  HistoryVideoDayModel.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HistoryVideoDayModel : NSObject

//时间戳
@property (nonatomic,assign)int timestamp;

//开始位移
@property (nonatomic,assign)float startPosition;

//时间字符串（yyyy-MM-dd）
@property (nonatomic,strong)NSString *timeStr;

@end
