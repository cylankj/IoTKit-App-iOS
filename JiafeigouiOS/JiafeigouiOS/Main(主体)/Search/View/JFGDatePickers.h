//
//  JFGDatePickers.h
//  Demo
//
//  Created by 杨利 on 2017/1/18.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JFGDatePickerCollectionViewCell.h"

@interface DatePickerModel : NSObject

@property (nonatomic,assign)NSInteger month;//月份
@property (nonatomic,assign)NSInteger day;//日期
@property (nonatomic,assign)NSInteger year;
@property (nonatomic,assign)int64_t startTimestamp;//该日期开始时间戳
@property (nonatomic,assign)int64_t lastestTimestamp;//结束时间戳
@property (nonatomic,assign)BOOL hasData;//该日期的数据
@property (nonatomic,assign)BOOL isSelectedDate;
@property (nonatomic,strong)NSMutableArray *dataList;

@end

@protocol JFGDatePickerDelegate <NSObject>

-(NSInteger)datePickersCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section;

-(UICollectionViewCell *)datePickersCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;

-(void)datePickersCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface JFGDatePickers : UIView

@property (nonatomic,weak)id <JFGDatePickerDelegate>delegate;
@property (nonatomic,readonly)NSMutableArray *dataArray;
@property (nonatomic,strong)UILabel *monthLabel;
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;

-(void)reloadData;
-(void)scrollToEndItem;

@end
