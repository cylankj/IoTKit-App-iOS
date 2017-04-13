//
//  DateRulerView.h
//  ShowIng
//
//  Created by SghOmk on 16/5/31.
//  Copyright © 2016年 cylan Tec All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HexColor.h"


#define DISTANCELEFTANDRIGHT 0.f // 标尺左右距离
#define DISTANCEVALUE 7.f // 每隔刻度实际长度7个点
#define DISTANCETIPSHEIGHT 18.f //上部分tipLabel的高度

#define DISTANCETIPSCOLOR [UIColor colorWithHex:0x36bdff]

@class RulerScrollView;

@protocol DateRulerViewDelegate;

@interface DateRulerView : UIView <UIScrollViewDelegate>

@property (assign, nonatomic) id<DateRulerViewDelegate>delegate;
@property (retain, nonatomic) RulerScrollView * rulerScrollView;

/** 调用这个标尺的时候,只需要给入排好序(yyyyMMddHHmmss格式的时间字符串)数组,和当前需要指示的时间(yyyyMMddHHmmss格式)*/
- (void)showRulerScrollViewWithDateArray:(NSArray *)dateArray currentIndicateDate:(NSString *)currentDateString;

@end

@protocol DateRulerViewDelegate <NSObject>

@optional

/** 中途拖动的时候选择的时间*/
- (void)dateRulerView:(DateRulerView *)rulerView didShowDateString:(NSString *)aDateString;

/** 最后选中的时间*/
- (void)dateRulerView:(DateRulerView *)rulerView didSelectedDateString:(NSString *)aDateString;

@end

@interface RulerModel : NSObject

/** 时间*/
@property (copy, nonatomic)                         NSString *date;
/** 是否有数据*/
@property (assign, nonatomic, getter=isHaveDate)    BOOL haveDate;

@end

@interface RulerScrollView : UIScrollView

@property (retain, nonatomic) NSMutableArray *drawDateArray;

- (void)drawRuler:(NSArray <RulerModel *> *)dateArray currentIndicateDate:(NSString *)currentDateString;

@end

