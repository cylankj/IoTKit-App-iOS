//
//  HistoryDatePicker.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HistoryDatePickerDelegate;

@interface HistoryDatePicker : UIView
//标题
@property (nonatomic,copy)NSString *title;

//数据源
@property (nonatomic,strong)NSMutableArray <NSArray <NSString *> *>*dataArray;

//代理
@property (nonatomic,weak)id <HistoryDatePickerDelegate> delegate;

//背景图片（默认无)
@property (nonatomic,strong)UIImageView *bgImageView;

//创建方法（只能使用此方法创建）
+(instancetype)historyDatePicker;

//显示到屏幕上
-(void)show;

@end


@protocol HistoryDatePickerDelegate <NSObject>

//取消
-(void)cancel;

//选择
-(void)didSelectedItem:(NSString *)item indexPath:(NSIndexPath *)indexPath;

@end
