//
//  FLTipsBaseView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTipsBaseView : UIView
/**
 *  获取实例
 *
 *  @return FLTipsBaseView实例对象
 */
+(FLTipsBaseView *)tipBaseView;

/**
 *  添加引导内容视图（按添加先后顺序,通过点击屏幕依次显示）
 *
 *  @param view 引导内容视图
 */
-(void)addTipView:(UIView *)view;

/**
 *  显示到屏幕上
 */
-(void)show;

/**
 *  从屏幕移除视图
 */
-(void)dismiss;

// 从windows上移除所有此类型视图
+(void)dismissAll;

@end
