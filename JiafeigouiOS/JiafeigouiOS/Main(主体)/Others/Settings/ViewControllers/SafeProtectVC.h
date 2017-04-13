//
//  SafeProtectVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//
/**
 *  安全防护
 */


#import "BaseViewController.h"
#import "SafeProtectTableView.h"
#import "subSafeProtectViewModel.h"

@protocol safeDelegate <NSObject>

- (void)moveDectionChanged:(BOOL)isOpen repeatTime:(int)repeat begin:(int)beginTime end:(int)endTime;

- (void)warnRelativeAutoPhoto:(NSInteger)autoPhotoType;

@end

@interface SafeProtectVC : BaseViewController<SafeProtectDelegate>

@property (nonatomic, weak) id<safeDelegate> delegate;

@end
