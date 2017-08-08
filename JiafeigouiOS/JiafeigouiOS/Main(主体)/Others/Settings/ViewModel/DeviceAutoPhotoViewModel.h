//
//  DeviceAutoPhotoViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/7/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"
#import "tableViewDelegate.h"

@interface DeviceAutoPhotoViewModel : BaseViewModel<tableViewDelegate>

@property (nonatomic, assign) id<tableViewDelegate> delegate;

- (NSMutableArray *)fetchData;

- (void)updateSwitchWithCellID:(NSString *)cellID changedValue:(id)changedValue;

@end
