//
//  BindProgressAnimationView.h
//  HeaderRotation
//
//  Created by 杨利 on 16/6/16.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BindResetBlock) (void);

@interface BindProgressAnimationView : UIView

/**
 *  重新开始按钮事件回调Block
 */
@property (assign,nonatomic)BindResetBlock bindResetBlock;


/**
 *  开始进度动画(从0开始)
 */
-(void)starAnimation;


/**
 *  绑定失败调用此方法
 *  停止所有动画，显示提示语与按钮
 */
-(void)failedAnimation;


/**
 *  绑定成功调用此方法
 *
 *  @param completionBlock 完成进度动画后回调
 */
-(void)successAnimationWithCompletionBlock:(void(^)(void))completionBlock;

@end
