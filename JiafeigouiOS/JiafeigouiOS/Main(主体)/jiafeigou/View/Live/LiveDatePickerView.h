//
//  LiveDatePickerView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/7.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol LiveDatePickerDelegate <NSObject>

-(void)pickerSelectedDate:(NSDate *)date;

@optional

-(void)pickerCancel;

@end

@interface LiveDatePickerView : UIView

@property (nonatomic) UIDatePickerMode datePickerMode;
@property (nonatomic,strong) NSDate *minimumDate;
@property (nonatomic,strong) NSDate *maximumDate;

//初始化
-(instancetype)initWithDelegate:(id<LiveDatePickerDelegate>) delegate;
-(void)show;


//不推荐使用一下方法初始化
-(instancetype)init NS_UNAVAILABLE;
-(instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end
