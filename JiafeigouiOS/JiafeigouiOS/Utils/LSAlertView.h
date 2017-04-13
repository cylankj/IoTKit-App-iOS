//
//  LSAlertView.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LSAlertView : UIView
/**
 *  弹出提示框
 *
 *  @param title       标题
 *  @param msg         内容
 *  @param cancelTitle 取消
 *  @param otherTitle  其他
 *  @param cancel      取消按钮回调
 *  @param ok          确定（其他）按钮回调
 */
+ (void)showAlertWithTitle:(NSString *)title Message:(NSString *)msg CancelButtonTitle:(NSString *)cancelTitle OtherButtonTitle:(NSString *)otherTitle CancelBlock:(void(^)(void))cancel OKBlock:(void(^)(void))ok;

//旋转90度
+ (void)showAlertForTransformRotateWithTitle:(NSString *)title Message:(NSString *)msg CancelButtonTitle:(NSString *)cancelTitle OtherButtonTitle:(NSString *)otherTitle CancelBlock:(void(^)(void))cancel OKBlock:(void(^)(void))ok;

+ (LSAlertView *)shared;

+ (void)disMiss;
@end
