//
//  DeviceAutoPhotoVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

/**
 *
 *  自动录像 VC
 *
 */


#import "BaseViewController.h"

@protocol autoPhotoVCDelegate <NSObject>

@optional

- (void)updateMotionDetection:(NSInteger)motionType;

- (void)updateWarnEnable:(BOOL)isOpen;

@end


@interface DeviceAutoPhotoVC : BaseViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) NSInteger oldselectedIndex; //原 选中标记

@property (nonatomic, assign) id<autoPhotoVCDelegate> delegate;

@end
