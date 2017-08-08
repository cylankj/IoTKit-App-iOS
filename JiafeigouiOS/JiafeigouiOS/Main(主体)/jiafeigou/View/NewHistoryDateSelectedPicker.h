//
//  NewHistoryDateSelectedPicker.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/7/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol NewHistoryDateSelectedPickerDelegate;

@interface NewHistoryDateSelectedPicker : UIView

//数据源
@property (nonatomic,strong)NSMutableArray <NSArray <NSString *> *>*dataArray;

@property (nonatomic,strong)NSMutableArray <NSNumber *>*widthForComponents;

@property (nonatomic,strong)UIView *maskView;
@property (nonatomic,strong)UIPickerView *_pickerView;
@property (nonatomic,strong)UIView *pickerBgView;
@property (nonatomic,strong)UIButton *dissMissBtn;
@property (nonatomic,strong)UIButton *doBtn;
@property (nonatomic,assign)BOOL isFullScreen;

//代理
@property (nonatomic,weak)id <NewHistoryDateSelectedPickerDelegate> delegate;

//创建方法（只能使用此方法创建）
+(instancetype)historyDatePicker;

//显示到屏幕上
-(void)show;

@end


@protocol NewHistoryDateSelectedPickerDelegate <NSObject>

//取消
-(void)cancel;

//选择
-(void)didSelectedYearString:(NSString *)year hour:(NSInteger)hour minute:(NSInteger)minute;



@end

@interface HistoryPickerDateModel : NSObject

@property (nonatomic,assign)int year;
@property (nonatomic,assign)int mounth;
@property (nonatomic,assign)int day;
@property (nonatomic,assign)uint64_t timestamp;

@end
