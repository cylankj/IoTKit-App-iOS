//
//  FullScreenHistoryDatePicker.h
//  HeaderRotation
//
//  Created by 杨利 on 16/6/29.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol FullScreenHistoryDatePickerDelegate;

@interface FullScreenHistoryDatePicker : UIView

@property (nonatomic,weak)id <FullScreenHistoryDatePickerDelegate>delegate;

@property (nonatomic,strong)NSArray *dataArray;

+(instancetype)fullScreenHistoryDatePicker;

-(void)show;

@end

@protocol FullScreenHistoryDatePickerDelegate <NSObject>

-(void)selectedItem:(NSString *)item index:(NSInteger)index;

@end
