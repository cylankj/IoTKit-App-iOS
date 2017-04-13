//
//  JFGDatePickers.m
//  Demo
//
//  Created by 杨利 on 2017/1/18.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import "JFGDatePickers.h"
#import "JFGDatePickerCollectionViewCell.h"
#import "UIColor+FLExtension.h"
#define DATELIMITS 30  //日期范围

@implementation DatePickerModel

@end


@interface JFGDatePickers()<UICollectionViewDelegate,UICollectionViewDataSource>
{
    NSIndexPath *selectedIndexPath;
}
@property (nonatomic,strong)UICollectionView *collectionView;
@property (nonatomic,strong)UILabel *monthLabel;
@property (nonatomic,strong)UIView *topLineView;
@property (nonatomic,strong)NSCalendar *calendar;
@property (nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation JFGDatePickers

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    selectedIndexPath = [NSIndexPath indexPathForRow:3 inSection:0];
    self.dataArray = [[NSMutableArray alloc]init];
    [self addSubview:self.collectionView];
    [self addSubview:self.monthLabel];
    [self addSubview:self.topLineView];
    self.monthLabel.text = [NSString stringWithFormat:@"%d月",[self compsForDate:[NSDate date]].month];
    self.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
    return self;
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self initData];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0] atScrollPosition:0 animated:NO];
}



-(void)initData
{
    //当前月份
    NSInteger currentMonth = [self compsForDate:[NSDate date]].month;
    //当前日期
    NSInteger currentDay = [self compsForDate:[NSDate date]].day;
    //当前年份
    NSInteger currentYear = [self compsForDate:[NSDate date]].year;
    //本月开始日期
    NSInteger currentStartDay = 0;
    
    if (currentDay < DATELIMITS) {
        //上个月日期
        NSDate *frontDate = [self frontMonthDate];
        //上个月天数
        NSInteger frontDays = [self getNumberOfDaysInMonth:frontDate];
        
        //上个月月份
        NSInteger frontMonth = [self compsForDate:frontDate].month;
        //上个月开始日期
        NSInteger frontStartDay = frontDays - (DATELIMITS - currentDay)+1;
        //上个月年份
        NSInteger frontYear = [self compsForDate:frontDate].year;
        
        for (int i=frontStartDay; i<= frontDays; i++) {
            
            DatePickerModel *model = [[DatePickerModel alloc]init];
            model.hasData = NO;
            model.month = frontMonth;
            model.day = i;
            model.year = frontYear;
            model.isSelectedDate = NO;//yyyy-MM-dd HH:mm:ss
            NSString *startStr = [NSString stringWithFormat:@"%4d-%2d-%2d 00:00:00",frontYear,frontMonth,i];
            NSString *lastestStr = [NSString stringWithFormat:@"%4d-%2d-%2d 23:59:59",frontYear,frontMonth,i];
            model.startTimestamp = [self timestampFromDate:[self dateFromString:startStr]];
            model.lastestTimestamp = [self timestampFromDate:[self dateFromString:lastestStr]];
            [self.dataArray addObject:model];
        }
        
        currentStartDay = 1;
        
    }else{
        currentStartDay = currentDay - DATELIMITS + 1;
    }
    
    
    for (int i= currentStartDay; i<=currentDay; i++) {
        
        DatePickerModel *model = [[DatePickerModel alloc]init];
        model.hasData = NO;
        model.month = currentMonth;
        model.day = i;
        model.year = currentYear;
        model.isSelectedDate = NO;//yyyy-MM-dd HH:mm:ss
        NSString *startStr = [NSString stringWithFormat:@"%4d-%2d-%2d 00:00:00",currentYear,currentMonth,i];
        NSString *lastestStr = [NSString stringWithFormat:@"%4d-%2d-%2d 23:59:59",currentYear,currentMonth,i];
        model.startTimestamp = [self timestampFromDate:[self dateFromString:startStr]];
        model.lastestTimestamp = [self timestampFromDate:[self dateFromString:lastestStr]];
        [self.dataArray addObject:model];
        
    }
    [self.collectionView reloadData];
    [self.collectionView setContentOffset:CGPointMake(self.collectionView.contentSize.width-self.bounds.size.width, 0)];
}


//返回分区个数
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

//返回每个分区的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

//返回每个item
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JFGDatePickerCollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    
    DatePickerModel *model = self.dataArray[indexPath.row];
    if (model.isSelectedDate) {
        cell.viewMode = pickerViewModeSelected;
    }else{
        if (model.hasData) {
            cell.viewMode = pickerViewModeHasData;
        }else{
            cell.viewMode = pickerViewModeNotData;
        }
    }
    cell.contentLabel.text = [NSString stringWithFormat:@"%d",model.day];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DatePickerModel *model = self.dataArray[indexPath.row];
    if (model.hasData && indexPath.row != selectedIndexPath.row) {
        
        JFGDatePickerCollectionViewCell *cell  = (JFGDatePickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:selectedIndexPath];
        JFGDatePickerCollectionViewCell *cell2  = (JFGDatePickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        DatePickerModel *oldModel = [self.dataArray objectAtIndex:selectedIndexPath.row];
        oldModel.isSelectedDate = NO;
        
        if (cell) {
            cell.viewMode = pickerViewModeHasData;
        }
        cell2.viewMode = pickerViewModeSelected;
        selectedIndexPath = indexPath;
    
        self.monthLabel.text = [NSString stringWithFormat:@"%d月",model.month];
        model.isSelectedDate = YES;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectedRowForIndexPath:)]) {
            [self.delegate didSelectedRowForIndexPath:indexPath];
        }
        
    }
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%d",indexPath.row);
}



-(void)reloadData
{
    [self.collectionView reloadData];
}


#pragma mark -日期处理
//获取当前时间上个月的日期
-(NSDate *)frontMonthDate
{
    NSDateComponents *components = [self.calendar components:(NSCalendarUnitWeekday | NSCalendarUnitMonth |NSCalendarUnitYear | NSCalendarUnitDay) fromDate:[NSDate date]];
    if ([components month] == 1) {
        [components setMonth:12];
        [components setYear:[components year] - 1];
    } else {
        [components setMonth:[components month] - 1];
    }
    NSDate *lastMonth = [self.calendar dateFromComponents:components];
    return lastMonth;
}

//获取某个日期当月有多少天
- (NSInteger)getNumberOfDaysInMonth:(NSDate *)date
{
    // 只要个时间给日历,就会帮你计算出来。这里的时间取当前的时间。
    NSRange range = [self.calendar rangeOfUnit:NSDayCalendarUnit
                                   inUnit:NSMonthCalendarUnit
                                  forDate:date];
    return range.length;
}

-(NSDateComponents *)compsForDate:(NSDate *)date
{
     // 指定日历的算法 NSCalendarIdentifierGregorian,NSGregorianCalendar
    // NSDateComponent 可以获得日期的详细信息，即日期的组成
    NSDateComponents *comps = [self.calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:date];
    return comps;
}


-(NSDate *)dateFromString:(NSString *)dateStr
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];//时间方式
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; // 年-月-日 时:分:秒
    [formatter setLocale:[NSLocale currentLocale]];
    NSDate * date = [formatter dateFromString:dateStr];
    return date;
}

-(int64_t)timestampFromDate:(NSDate *)date
{
    return [date timeIntervalSince1970];
}

#pragma mark- getter
-(NSCalendar *)calendar
{
    if (!_calendar) {
        NSCalendar *calendar = [NSCalendar currentCalendar];
        _calendar = calendar;
    }
    return _calendar;
}


-(UICollectionView *)collectionView
{
    if (!_collectionView) {
        //创建一个layout布局类
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc]init];
        //设置布局方向为垂直流布局
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        //设置每个item的大小为100*100
        layout.itemSize = CGSizeMake(47, 47);
        layout.minimumInteritemSpacing = 0;
        layout.minimumLineSpacing = 0;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-47, self.bounds.size.width, 47) collectionViewLayout:layout];
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
        [_collectionView registerNib:[UINib nibWithNibName:@"JFGDatePickerCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"cellid"];
    }
    return _collectionView;
}

-(UILabel *)monthLabel
{
    if (!_monthLabel) {
        _monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - self.collectionView.bounds.size.height)];
        _monthLabel.textAlignment = NSTextAlignmentCenter;
        _monthLabel.backgroundColor = [UIColor clearColor];
        _monthLabel.font = [UIFont systemFontOfSize:16];
        _monthLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    return _monthLabel;
}

-(UIView *)topLineView
{
    if (!_topLineView) {
        _topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 0.5)];
        _topLineView.backgroundColor = [UIColor colorWithHexString:@"#dde0e5"];
    }
    return _topLineView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
