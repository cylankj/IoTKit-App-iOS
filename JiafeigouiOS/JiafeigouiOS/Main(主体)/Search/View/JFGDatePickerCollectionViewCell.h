//
//  JFGDatePickerCollectionViewCell.h
//  Demo
//
//  Created by 杨利 on 2017/1/18.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,pickerViewMode){
    pickerViewModeNotData,//当前时间没有数据显示灰色
    pickerViewModeHasData,//当前日期有数据但是未被选择
    pickerViewModeSelected,//当前日期被选择
};

@interface JFGDatePickerCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (nonatomic,assign)pickerViewMode viewMode;

@end
