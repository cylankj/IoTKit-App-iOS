//
//  BaseModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseModel : NSObject

/**
 *  cid 串号，设备唯一标识
 */
@property (copy, nonatomic)     NSString *cid;
/**
 *  dp消息id
 */
@property (assign, nonatomic)   int msgID;
/**
 *  dp消息时间（服务器时间）
 */
@property (copy, nonatomic)     NSString * version;
@end
