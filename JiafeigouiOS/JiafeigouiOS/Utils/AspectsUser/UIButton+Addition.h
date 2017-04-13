//
//  UIButton+Addition.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/1/10.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Addition)

//按钮事件是否关联网络
@property (nonatomic,assign)BOOL isRelatingNetwork;

@property (nonatomic,assign)BOOL isRelatingTouchEvent;

@end
