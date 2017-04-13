//
//  CusDatePickerView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol cusDatePickerDelegate <NSObject>

- (void)okButtonclicked:(UIDatePicker *)datePicker;

- (void)cancelButtonclicked:(UIDatePicker *)datePicker;

- (void)datePickerDidChanged:(UIDatePicker *)datePicker;

@end

@interface CusDatePickerView : UIView

@property (strong, nonatomic) UIDatePicker *datePicker;

@property(weak, nonatomic) id<cusDatePickerDelegate> delegate;

- (instancetype)initWitinitWithTitle:(NSString *)title OkButtonTitle:(NSString *)oktitle cancelButtonTitle:(NSString *)cancelTitle;

- (void)show;

- (void)dismiss;

-(void)setDate:(nonnull NSDate *)date animated:(BOOL)animated;

@end
