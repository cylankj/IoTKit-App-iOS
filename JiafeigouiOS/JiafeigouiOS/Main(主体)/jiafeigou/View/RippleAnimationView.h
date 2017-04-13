//
//  RippleAnimationView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/1.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RippleAnimationView : UIView<UIScrollViewDelegate>
{
    NSTimer *animationTimer;
}

@property (nonatomic,strong)UIScrollView *scrollerView1; //最下面的波浪
@property (nonatomic,strong)UIScrollView *scrollerView2; //最上面的波浪
@property (nonatomic,strong)UIScrollView *scrollerView3; //中间的波浪

//每0.2s 移动点位值
@property (nonatomic,assign)NSInteger speed1;//向左滚动，最上面的波浪
@property (nonatomic,assign)NSInteger speed2;//向左滚动，最下面的波浪
@property (nonatomic,assign)NSInteger speed3;//向右滚动，中间的波浪

@property (nonatomic, copy) NSString *topImage; //向左滚动，最上面的波浪
@property (nonatomic, copy) NSString *bottomImage; //向左滚动，最下面的波浪
@property (nonatomic, copy) NSString *centerImage; //向右滚动，中间的波浪

//波浪开始运动
-(void)startTimer;
//波浪停止运动
-(void)stopTimer;

@end
