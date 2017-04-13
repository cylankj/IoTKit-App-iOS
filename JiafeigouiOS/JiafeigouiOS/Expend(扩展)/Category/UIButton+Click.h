//
//  UIButton+Click.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/26.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Click)
+ (void)button:(UIButton *)button touchUpInSideHander:(void(^)(UIButton *button))hander;
@end
