//
//  UISwitch+Clicked.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/26.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UISwitch (Clicked)

- (void)addValueChangedBlockAcion:(void(^)(UISwitch *_switch))hander;

@end
