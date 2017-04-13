//
//  EfamilyRootViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"
/**
 *  cell type 类型
 */
NSString *const dataCellType = @"_dataCellType";
/**
 *  持续 时间
 */
NSString *const dataDuration = @"_dataDuration";
/**
 *  开始时间
 */
NSString *const dataTimeBegin = @"_dataTimeBegin";
/**
 *  文件路径
 */
NSString *const dataUrl = @"_dataUrl";
/**
 *  http 返回的 请求ID
 */
NSString *const dataRequestID = @"_dataRequestID";
/**
 *  文件状态， 已发送，发送中，失败
 */
NSString *const dataFileState = @"_dataFileState";
/**
 *  是否 呼通/已读
 */
NSString *const dataIsOK = @"_dataIsOK";


@protocol efamilyRootDelegate <NSObject>

- (void)updatedDataArray:(NSArray *)updatedArray;
- (void)addDataWithArray:(NSArray *)addArray;

@end


@interface EfamilyRootViewModel : BaseViewModel

@property (weak, nonatomic) id<efamilyRootDelegate> efamilyRootDelegate;

- (NSArray *)requestDataWithCid:(NSString *)cid;

@end
