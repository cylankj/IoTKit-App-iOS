//
//  DeviceAutoModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/7/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseModel.h"

@interface DeviceAutoModel : BaseModel

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, copy) NSString *selectedString;

@property (nonatomic, assign) BOOL isShowRecordRedDot;

@property (nonatomic, assign) BOOL isRecordWhenWatching;

@property (nonatomic, assign) int movetionDectrionType;
@property (nonatomic, assign) BOOL isOpenMovetionDection;

@property (nonatomic, assign) BOOL isWarnEnable;

// SDCard
@property (assign, nonatomic) BOOL isExistSDCard;
@property (assign, nonatomic) int sdCardError;

@end
