//
//  FLRefreshHeader.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "UIView+FLExtensionForFrame.h"

NSString *const FLRefreshKeyPathContentOffset = @"contentOffset";

typedef enum{
    FLRefreshStateNormal,
    FLRefreshStatePulling,
    FLRefreshStateRefreshing,
}FLRefreshState;

typedef enum{
    
    FLRefreshShowTypeNormal,
    FLRefreshShowTypeGradually,
    FLRefreshShowTypeHolding,
    
}FLRefreshShowType;

@interface FLRefreshHeader : UIView

@property (nonatomic,assign)FLRefreshShowType showType;

/**
 *  父类scrollerView原始y轴偏移量
 */
@property (nonatomic,assign)CGFloat originOffset_y;

/**
 *  当前刷新状态
 */
@property (nonatomic,assign)FLRefreshState state;

/**
 *  拖拽开始刷新的高度
 */
@property (nonatomic,assign)CGFloat dragHeight;
/**
 *  原始内偏移，上
 */
@property (nonatomic, assign)CGFloat originalTopInset;

/**
 *  开始刷新
 */
-(void)startRefresh;

/**
 *  结束刷新
 */
-(void)endRefresh;

/**
 *  父类ScrollerView结束拖拽事件接受
 *  @note 在父类回调 scrollViewDidEndDragging: 的地方必须调用此方法，才能判断是否开始刷新状态
 *  @param scroller 父类ScrollerView
 */
-(void)scrollViewDidEndDrag:(UIScrollView *)scroller;

/** 
 *  设置回调对象和回调方法 
 */
- (void)setRefreshingTarget:(id)target refreshingAction:(SEL)action;

@end
