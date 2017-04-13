//
//  SafeProtectTableView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseDeviceTableView.h"
#import "SafeProtectViewModel.h"

@protocol SafeProtectDelegate <NSObject>

@optional

- (void)tableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo;

//- (void)moveDectionChanged:(BOOL)isOpen repeatTime:(int)repeat begin:(int)begin end:(int)end;

//- (void)changeAutoPhoto:(NSInteger)type;

@end

@interface SafeProtectTableView : BaseDeviceTableView<UITableViewDelegate, UITableViewDataSource, tableViewDelegate>

@property (weak, nonatomic) id<SafeProtectDelegate> safeTableViewDelegate;

/**
 *  ViewModel
 */
@property (strong, nonatomic) SafeProtectViewModel *safeProtectVM;

#pragma mark == 重复 数据 ===
@property (assign, nonatomic) int beginTime;
@property (assign, nonatomic) int endTime;
@property (nonatomic, assign) int autoPhotoType;


@end
