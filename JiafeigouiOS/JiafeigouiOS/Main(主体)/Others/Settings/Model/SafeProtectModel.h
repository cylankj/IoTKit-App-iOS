//
//  SafeProtectModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseModel.h"

@interface SafeProtectModel : BaseModel

/**
 *  是否 开启 移动侦测
 */
@property (assign, nonatomic) BOOL isWarnEnable;

//是否打开红外增强
@property (assign,nonatomic)BOOL isOpenInfraredStrengthen;

/**
 *  灵敏度
 */
@property (assign, nonatomic) NSInteger sensitive;
@property (copy, nonatomic) NSString *sensitiveStr;
/*
 *  AI 识别
 */
@property (strong, nonatomic) NSArray *aiRecognitions;
@property (copy, nonatomic) NSString *aiRecognitionStr;
@property (nonatomic, assign) BOOL isShowAIRedDot;
/**
 *  设备 提示音
 */
@property (assign, nonatomic) int soundType;
@property (copy, nonatomic) NSString *soundStr;

/*
 * 报警 时间间隔 单位：秒
 */
@property (assign, nonatomic) int alramDuration;
@property (nonatomic, copy) NSString *alramDurStr;

/**
 *  设备提示音提示时长
 */
@property (assign, nonatomic) int soundTime;

/**
 *  开始 时间
 */
@property (assign, nonatomic) int beginTime;
@property (copy, nonatomic) NSString *beginTimeStr;
/**
 *  结束时间
 */
@property (assign, nonatomic) int endTime;
@property (copy, nonatomic) NSString *endTimeStr;
/**
 *  重复 时间
 */
@property (assign, nonatomic) int repeat;
@property (copy, nonatomic) NSString *repeatStr;

/*
 * 自动 录像
 */
@property (nonatomic, assign) int autoPhotoType;

/*
 * SD卡
 */
@property (nonatomic, assign) BOOL isExistSDCard;

@end

#pragma mark
#pragma mark  == DeviceVoiceModel ===
@interface DeviceVoiceModel : BaseModel

@property (assign, nonatomic) int soundType;
/**
 *  静音 是否选择
 */
@property (assign, nonatomic) BOOL isMuteChecked;
/**
 *  汪汪声 是否选择
 */
@property (assign, nonatomic) BOOL isBarkChecked;
/**
 *  报警 是否选择
 */
@property (assign, nonatomic) BOOL isWarnChecked;
/**
 *  循环 播放 时间
 */
@property (assign, nonatomic) int voiceRepeatTime;
@property (copy,nonatomic) NSString *voiceRepeatStr;

@end

#pragma mark
#pragma mark  == DeviceRepeatModel ===
@interface DeviceRepeatModel : BaseModel

@property (assign, nonatomic) int repeatDate;

@property (assign, nonatomic) BOOL isMonChecked;
@property (assign, nonatomic) BOOL isTueChecked;
@property (assign, nonatomic) BOOL isWedChecked;
@property (assign, nonatomic) BOOL isThuChecked;
@property (assign, nonatomic) BOOL isFriChecked;
@property (assign, nonatomic) BOOL isSatChecked;
@property (assign, nonatomic) BOOL isSunChecked;

@end


