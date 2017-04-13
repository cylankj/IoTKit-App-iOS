//
//  JFGDataPointValueModel.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/9.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JFGDataPointValueModel : NSObject

@end


//204消息 获取设备sd卡信息
@interface JFGDeviceSDCardInfo : NSObject

@property (nonatomic,assign)int64_t storage;//卡容量 单位byte
@property (nonatomic,assign)int64_t storage_used;//已用空间 单位byte
@property (nonatomic,assign)NSInteger errorCode;//错误号。0 正常； 非0错误，需要格式化
@property (nonatomic,assign)BOOL isHaveCard;//是否有卡

@end
