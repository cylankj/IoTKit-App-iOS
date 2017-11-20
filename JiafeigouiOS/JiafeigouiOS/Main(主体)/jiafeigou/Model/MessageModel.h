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

//门铃信息相关
@property (nonatomic,assign)int isAnswer;//是否接听
@property (nonatomic,assign)int timeDuration;//结束时间点，单位秒
@property (nonatomic,assign)BOOL is_record;//是否在录像中

@property (nonatomic,strong)NSArray *objects;//检测到的物体类型。人1，猫2，狗3，车辆4。例子，检测到人和猫：[1,2]。

@property (nonatomic,assign)int manNum;

@property (nonatomic,strong)NSArray *face_idList;
@property (nonatomic,strong)NSString *aiMsg;
@property (nonatomic,copy)NSString *aiImageUrl;

@end
