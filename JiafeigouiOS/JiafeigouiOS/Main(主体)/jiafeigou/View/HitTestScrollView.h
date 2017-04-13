//
//  HitTestScrollView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/1/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HitTestScrollView : UIScrollView

@property (nonatomic,assign)BOOL isIntercept;//是否拦截触控事件
@property (nonatomic,assign)CGFloat interceptLimits;//拦截范围

@end
