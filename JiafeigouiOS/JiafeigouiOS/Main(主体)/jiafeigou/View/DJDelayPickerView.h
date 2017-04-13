//
//  DJDatePickerView.h
//  DJActionRuler
//
//  Created by SghOmk on 16/6/30.
//  Copyright © 2016年 SHENZHEN BITHEALTH TECHNOLOGY CO.,LTD. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol DJDelayPickerViewDelegate;

@interface DJDelayPickerView : UIView
//
////标题
//@property (nonatomic,copy)NSString *title;
//
////背景图片（默认无)
//@property (nonatomic,strong)UIImageView *bgImageView;

@property (nonatomic,assign)id <DJDelayPickerViewDelegate> delegate;

+ (instancetype)delayPickerView;

- (void)show;

@end


@protocol DJDelayPickerViewDelegate <NSObject>

//取消
-(void)cancelPick;
//点击确定的代理     pickView                            time选中的时间             isBegainNow是否立即开始   
-(void)delayPickerView:(DJDelayPickerView *)pickView didSelectTime:(NSDate *)time isBegainNow:(BOOL)isBegainNow;


@end