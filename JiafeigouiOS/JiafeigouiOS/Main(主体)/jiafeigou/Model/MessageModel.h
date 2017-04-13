//
//  MessageModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/9/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseModel.h"

@interface MessageModel : BaseModel

/**
 *  设备 标识
 */
@property (nonatomic, assign) int flag;

//@property 

/**
 *  顶部 字符串
 */
@property (nonatomic, copy) NSString *topString; // 合并的String
@property (nonatomic, copy) NSString *timeString; 
@property (nonatomic, copy) NSString *textString;

/**
 *  三张 图片
 */
@property (nonatomic, assign) NSTimeInterval timestamp; // 时间戳
@property (nonatomic,assign) int64_t _version;
@property (nonatomic, assign) int imageNum; //  记录多少张图片
@property (nonatomic, strong) NSMutableArray *msgImages; // 图片数组

/**
 *  是否显示 “查看视频” 按钮
 */
@property (nonatomic, assign) BOOL isShowVideoBtn;

/**
 *  SD卡 是否 拔出
 */
@property (nonatomic, assign) BOOL isSDCardOn;

@property (nonatomic,assign)int sdcardErrorCode;

@property (nonatomic,assign)int deviceVersion;

@property (nonatomic,copy)NSString *tly;
@end
