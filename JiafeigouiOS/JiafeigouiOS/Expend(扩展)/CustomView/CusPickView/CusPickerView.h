//
//  CusPickerView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/2.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CusPickerViewDelegate <NSObject>

- (void)didComfirmItem:(NSInteger)selectValue pickerView:(UIPickerView *)pickerView;

- (void)didCancelPickerView:(UIPickerView *)pickerView;

- (void)didChangedItem:(NSInteger)changedValue pickerView:(UIPickerView *)pickerView;

@end


@interface CusPickerView : UIView

@property (nonatomic, assign) id<CusPickerViewDelegate> delegate;

- (instancetype)initWitinitWithTitle:(NSString *)title OkButtonTitle:(NSString *)oktitle cancelButtonTitle:(NSString *)cancelTitle;

- (void)setData:(NSInteger )originData;

- (void)show;

- (void)dismiss;

@end
