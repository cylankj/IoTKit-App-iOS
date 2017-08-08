//
//  BaseModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JfgTypeDefine.h"

@interface BaseModel : NSObject

/**
 *  cid 串号，设备唯一标识
 */
@property (copy, nonatomic) NSString *cid;
/**
 *  dp消息id
 */
@property (assign, nonatomic) int msgID;


/**
 *  new dpId
 */
@property (assign, nonatomic) uint64_t realyMsgID;


/**
 *  dp消息时间（服务器时间）
 */
@property (copy, nonatomic)     NSString * version;

/*
 *  product Type
 */
@property (nonatomic, assign) productType pType;

@property (nonatomic, assign) BOOL isShare;

@end
