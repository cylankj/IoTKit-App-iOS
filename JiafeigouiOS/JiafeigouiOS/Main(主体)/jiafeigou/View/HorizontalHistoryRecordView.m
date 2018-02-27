//
//  HorizontalHistoryRecordView.m
//  HorizontalTableView
//
//  Created by 杨利 on 16/6/24.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "HorizontalHistoryRecordView.h"
#import "UIColor+HexColor.h"
#import <JFGSDK/JFGSDK.h>
#import "HorizontalHistoryRecordView+DataDeal.h"
#import "UIView+FLExtensionForFrame.h"
#import <JFGSDK/JFGSDKVideoView.h>
#import "JfgLanguage.h"
#import <JFGSDK/CylanJFGSDK.h>
@interface HorizontalHistoryRecordView()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate,JFGSDKPlayVideoDelegate>
{
    BOOL isScrolling;
    CGFloat currentOffset;
    NSInteger currentYear;
    NSInteger currentMounth;
    NSInteger currentDay;
    NSMutableArray *tempDataArray;
    dispatch_queue_t myVideoHistoryQueue;
    BOOL isWait;
}
@property (nonatomic,strong)UIButton *historyVideoBtn;

@property (nonatomic,strong)UIView *signView;

@property (nonatomic,strong)UIImageView *bottomLineImageView;

@property (nonatomic,assign)CGFloat currentOffset_y;

@property (nonatomic,strong)NSArray *historyRecordDays;

@end

@implementation HorizontalHistoryRecordView

-(instancetype)initWithFrame:(CGRect)frame forCid:(NSString *)cid
{
    if (self = [super initWithFrame:frame]) {
        self.viewType = ViewTypeSmallMode;
        self.cid = cid;
        [self addSubview:self.horizontalTableView];
        [self addSubview:self.historyVideoBtn];
        [self addSubview:self.signView];
        [self addSubview:self.bottomLineImageView];
        [self addNotifacation];
    }
    return self;
}

-(void)didMoveToSuperview
{
    self.clipsToBounds = YES;
    //防止多次添加
    
}



-(void)layoutSubviews
{
    //NSLog(@"layoutSubviews");
    self.signView.left = self.bounds.size.width*0.5-1;
    self.horizontalTableView.width = self.bounds.size.width-55;
    self.historyVideoBtn.right = self.bounds.size.width;
    self.horizontalTableView.tableFooterView = [self footerView];
    self.horizontalTableView.tableHeaderView = [self headerView];
    
}

-(void)addNotifacation
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onUpdateHistoryErrorCode:) name:@"JFGSDKOnUpdateHistoryErrorCodeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(onUpdateHistoryVideoList:) name:@"JFGSDKOnUpdateHistoryVideoListNotification" object:nil];

}

-(void)setViewType:(ViewType)viewType
{
    if (viewType == _viewType) {
        return;
    }
    
    UIView *rightLineView = [self.historyVideoBtn viewWithTag:10234];
    
    if (viewType == ViewTypeFullMode) {
        self.historyVideoBtn.backgroundColor = [UIColor clearColor];
        rightLineView.frame = CGRectMake(0, 5, 1, 40);
        rightLineView.backgroundColor = [UIColor colorWithHexString:@"#858585"];
    }else{
        self.historyVideoBtn.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
        rightLineView.frame = CGRectMake(0, 4, 1, 47);
        rightLineView.backgroundColor = [UIColor colorWithHexString:@"#ededed"];
    }
    self.horizontalTableView.tableFooterView = [self footerView];
    self.horizontalTableView.tableHeaderView = [self headerView];
    self.horizontalTableView.backgroundColor = self.historyVideoBtn.backgroundColor;
    
    _viewType = viewType;
    
    [self.horizontalTableView setContentOffset:CGPointMake(0, self.currentOffset_y)];
    
}

-(void)reloadData
{
    [self.horizontalTableView reloadData];
}

-(void)setIsSelectedHistory:(BOOL)isSelectedHistory
{
    self.historyVideoBtn.enabled = isSelectedHistory;
}

#pragma mark- tableViewDelegate
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyBarStartScroll)]) {
        
        [self.delegate historyBarStartScroll];
        
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    isScrolling = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setScrolling) object:nil];
    [self performSelector:@selector(setScrolling) withObject:nil afterDelay:2];
    
    CGFloat offset_y = scrollView.contentOffset.y;
    CGFloat driff;//一天时间的偏移量
    NSInteger index;//倒数第几天
    
    if (offset_y<_fristRowHeight) {
        
        driff = _fristRowHeight-offset_y;
        index = 0;
        
    }else{
        
        driff = offset_y - _fristRowHeight;
        index = driff/markImageWidth+1;
        driff = driff-(index-1)*markImageWidth;
        driff = markImageWidth - driff;
        
    }
    
    //防止越界取值
    if (index >= self.dataArray.count) {
        
        if (self.dataArray.count && self.dataArray.count > 0) {
            index = self.dataArray.count-1;
            driff = 0;
        }else{
            return;
        }
        
    }
    
    NSDate *tempDate = nil;
    
    NSArray *histroryDataModelList = [_dataArray objectAtIndex:index];
    CGFloat sForPx = (24*60*60)/markImageWidth;
    CGFloat allS = driff*sForPx;
    if (histroryDataModelList.count) {
        historyVideoDurationTimeModel *resultModel = [histroryDataModelList lastObject];
        NSInteger seconds = allS;
        //format of hour
        NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
        //format of minute
        NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
        //format of second
        NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
        NSCalendar *greCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *dateComponentsForDate = [[NSDateComponents alloc] init];
        [dateComponentsForDate setDay:resultModel.startDay];
        [dateComponentsForDate setMonth:resultModel.startMouth];
        [dateComponentsForDate setYear:resultModel.startYear];
        [dateComponentsForDate setHour:[str_hour integerValue]];
        [dateComponentsForDate setMinute:[str_minute integerValue]];
        [dateComponentsForDate setSecond:[str_second integerValue]];
        NSDate *startDate = [greCalendar dateFromComponents:dateComponentsForDate];
        tempDate = startDate;
        //NSLog(@"dateTime:%@",startDate);
        
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(scrollerDidScrollForHistoryVideoDate:)]) {
        [self.delegate scrollerDidScrollForHistoryVideoDate:tempDate];
    }
    
}

-(void)setScrolling
{
    isScrolling = NO;
    //NSLog(@"*********************NO*********************");
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offset_y = scrollView.contentOffset.y;
    [self calculatePositionWithOffset:offset_y];
    self.historyVideoBtn.enabled = YES;
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyBarEndScroll)]) {
        
        [self.delegate historyBarEndScroll];
        
    }
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    //NSLog(@"DidEndDragging");
    if (!decelerate) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idForCell = @"id";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idForCell];
    if (!cell) {
        
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idForCell];
        cell.transform = CGAffineTransformMakeRotation(-M_PI / 2);
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, markImageWidth, 55)];
        imageView.tag = 99999;
        imageView.image = [UIImage imageNamed:@"camera_Timeline"];
        imageView.userInteractionEnabled = NO;
        cell.clipsToBounds = YES;
        [cell.contentView addSubview:imageView];
        cell.backgroundColor = [UIColor clearColor];
        
        UIImageView *imageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, markImageWidth, 55)];
        imageView2.tag = 88888;
        imageView2.image = [UIImage imageNamed:@"camera_TXT"];
        imageView2.userInteractionEnabled = NO;
        [cell.contentView addSubview:imageView2];
        
    }
    
    UIImageView *bgImageView = [cell.contentView viewWithTag:99999];
    UIImageView *numberImageView = [cell.contentView viewWithTag:88888];
    
    //最多创建240个
    NSArray *histroryDataModelList = [_dataArray objectAtIndex:indexPath.row];
    
    for (int i=0;i<histroryDataModelList.count;i++) {
        
//        if (i>240) {
//            break;
//        }
        
        historyVideoDurationTimeModel *model = [histroryDataModelList objectAtIndex:i];
        
        UIImageView *selectedImageView = [bgImageView viewWithTag:i+10];
        if (!selectedImageView) {
            
            selectedImageView = [[UIImageView alloc]init];
            selectedImageView.tag = i+10;
            [bgImageView addSubview:selectedImageView];
            
        }
        if (self.viewType == ViewTypeFullMode) {
            selectedImageView.image = [UIImage imageNamed:@"full-screen_36bdff"];
        }else{
            //camera_selece_time
            selectedImageView.image = [UIImage imageNamed:@"camera_selece_time"];
        }
        selectedImageView.hidden = NO; 
        selectedImageView.frame = CGRectMake([model startPosition], 0, [model endPosition]-[model startPosition], 55);
        
    }

    if (self.viewType == ViewTypeFullMode) {
        
        if (bgImageView.height != 50) {
            bgImageView.image = [UIImage imageNamed:@"full-screen_timeline"];
            numberImageView.image = [UIImage imageNamed:@"full-screen_time"];
            bgImageView.height = 50;
            numberImageView.height = 50;
        }
        
        
    }else{
        
        if (bgImageView.height != 55) {
            bgImageView.image = [UIImage imageNamed:@"camera_Timeline"];
            numberImageView.image = [UIImage imageNamed:@"camera_TXT"];
            bgImageView.height = 55;
            numberImageView.height = 55;
        }
        
    }
    
    for (NSInteger i=histroryDataModelList.count; i<10000;i++ ) {
        
        UIImageView *selectedImageView = [bgImageView viewWithTag:i+10];
        if (selectedImageView) {
            selectedImageView.hidden = YES;
        }else{
            break;
        }
    }

    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        
        if (_dataArray.count) {
            
            NSArray *lastDayArr = [_dataArray objectAtIndex:0];
            if (lastDayArr.count) {
                
                id obj = lastDayArr[0];
                if ([obj isKindOfClass:[historyVideoDurationTimeModel class]]) {
                    
                    historyVideoDurationTimeModel *model = obj;
                    int diff = (int)model.endPosition % 70;
                    
                    if (diff >= 7*7) {
                        
                        diff = 70+23-diff;
                        
                    }else if (diff <= 3*7){
                        
                        diff = 3*7+2;
                        
                    }else{
                        
                        diff = 0;
                        
                    }
                    self.fristRowHeight = diff+model.endPosition;
                    return self.fristRowHeight;
                }
            }
        }
        return 0;
    }
    return markImageWidth;
}

#pragma mark- JFGSDKDelegate
-(void)onUpdateHistoryErrorCode:(NSNotification *)notification
{
    JFGSDKHistoryVideoErrorInfo *errorInfo = notification.object;
    NSLog(@"HistoryVideo Error:%d",errorInfo.code);
}

-(void)onUpdateHistoryVideoList:(NSNotification *)notification
{
    if (![notification isKindOfClass:[NSNotification class]]) {
        return;
    }
    
    @try {
       
        static NSLock *lock = nil;
        if (!lock) {
            lock = [[NSLock alloc] init];
        }
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            [lock lock];
            
            NSArray <JFGSDKHistoryVideoInfo *> *list = notification.object;
            
            if (tempDataArray == nil) {
                tempDataArray = [[NSMutableArray alloc]initWithArray:list];
            }else{
                [tempDataArray addObjectsFromArray:list];
            }
            
            NSArray *resultA = [self dataDeal:tempDataArray];
            self.dataArray = [[NSMutableArray alloc]initWithArray:resultA];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(historyDataFinished) object:nil];
                [self performSelector:@selector(historyDataFinished) withObject:nil afterDelay:1];
            });
            [lock unlock];
        });
        
    } @catch (NSException *exception) {
        
        [JFGSDK appendStringToLogFile:@"历史视频崩溃"];
        
    } @finally {
        

    }
}


-(void)historyDataFinished
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
    self.isLoadingData = NO;
    NSLog(@"historyFinished");
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyVideoDateLimits:)]) {
        
        NSArray *dat = [self historyVideoLimistForDayFromAllDataArr:self.dataArray];
        self.historyRecordDays = [[dat reverseObjectEnumerator] allObjects];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate historyVideoDateLimits:dat];
        });
        
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(historyVideoAllList:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate historyVideoAllList:[NSArray arrayWithArray:self.dataArray]];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (self.dataArray.count==0) {
            self.hidden = YES;
            return;
        }
        [self.horizontalTableView reloadData];
    });
}

#pragma mark- 数据处理
//设置偏移量从某天开始
-(void)startHistoryVideoFromDay:(HistoryVideoDayModel *)dayModel
{
    //self.historyVideoBtn.selected = YES;
    self.historyVideoBtn.enabled = YES;
    [self transDayFromTimeStamp:dayModel.timestamp];
    [self.horizontalTableView setContentOffset:CGPointMake(0, dayModel.startPosition) animated:NO];
    
}

-(void)transDayFromTimeStamp:(int64_t)timeStamp
{
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//设置成中国阳历
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    currentYear = [comps year];
    currentMounth = [comps month];
    currentDay = [comps day];
}


//偏移量转时间
-(void)calculatePositionWithOffset:(CGFloat)offset_y
{
    CGFloat driff;//一天时间的偏移量
    NSInteger index;//倒数第几天
    
    if (offset_y<_fristRowHeight) {
        
        driff = _fristRowHeight-offset_y;
        index = 0;
        
    }else{
        
        driff = offset_y - _fristRowHeight;
        index = driff/markImageWidth+1;
        driff = driff-(index-1)*markImageWidth;
        driff = markImageWidth - driff;
        
    }
    
    //int hour = driff/70;
    //int min = (driff-hour*70)/7.0*6;
    //NSLog(@"hour:%d,min:%d",hour,min);
    
    //防止越界取值
    if (index >= self.dataArray.count) {
        
        if (self.dataArray.count && self.dataArray.count > 0) {
            index = self.dataArray.count-1;
            driff = 0;
        }else{
            return;
        }
        
    }
    
    historyVideoDurationTimeModel *resultModel = [self rightNearestHistoryModel:driff mouthList:self.dataArray[index]];
    //resultModel == self.currentHistoryVideoModel &&
    if ( driff>=[resultModel startPosition] && driff <= [resultModel endPosition]) {
        
        //偏移点距离开始位置多远
        CGFloat df = driff-[resultModel startPosition];
        //每个像素点代表多少秒
        CGFloat sForPx = (24*60*60)/markImageWidth;
        NSDate *historyStartDate = [NSDate dateWithTimeIntervalSince1970:resultModel.startTimestamp];
        NSDate *playstartDate = [NSDate dateWithTimeInterval:df*sForPx sinceDate:historyStartDate];
        
        NSInteger playStartstamp = [playstartDate timeIntervalSince1970];
        resultModel.startPlayTimestamp = playStartstamp;
        
        
    }else{
        
        resultModel.startPlayTimestamp = resultModel.startTimestamp;
        self.currentHistoryVideoModel = resultModel;
        
        CGFloat offset;
        
        if (index==0) {
            offset = _fristRowHeight-resultModel.startPosition;
        }else{
            offset = _fristRowHeight+(markImageWidth - resultModel.startPosition)+(index-1)*markImageWidth;
        }
        
        [self.horizontalTableView setContentOffset:CGPointMake(0, offset) animated:YES];
        _currentOffset_y = offset;
        
    }


    if (self.delegate && [self.delegate respondsToSelector:@selector(currentHistoryVideoModel:)]) {
        [self.delegate currentHistoryVideoModel:resultModel];
    }
    
    [self transDayFromTimeStamp:resultModel.startPlayTimestamp];
}



-(CGFloat)offsetFromHour:(NSInteger)hour min:(CGFloat)min index:(NSInteger)index
{
    CGFloat offset_y = index*markImageWidth;
    offset_y = offset_y+hour*70+(min/6.0)*7;
    return offset_y;
}

-(void)requestData
{
    if (!self.cid) {
        return;
    }
    [CylanJFGSDK getHistoryVideoListForCid:self.cid];
    //[CylanJFGSDK getHistoryVideoListV2:self.cid searchWay:1 timeEnd:1 searchRange:1];
    self.isLoadHistoryData = YES;
    self.isLoadingData = YES;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqTimeout) object:nil];
    [self performSelector:@selector(reqTimeout) withObject:nil afterDelay:30];
}

-(void)reqTimeout
{
    self.isLoadingData = NO;
}

-(CGFloat)offsetFromeTimeStamp:(int64_t)timestamp
{
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    float offset_y = dateComponent.hour*70+(dateComponent.minute/6.0)*7;
    return offset_y;
}

-(BOOL)setHistoryTableViewOffsetByTimeStamp:(int64_t)timeStamp
{
    if (isScrolling) {
        return NO;
    }
    
    if (!_dataArray.count) {
        return NO;
    }
    
    NSDate *now = [NSDate dateWithTimeIntervalSince1970:timeStamp];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//设置成中国阳历
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:now];
    NSInteger year = [comps year];
    NSInteger mouth = [comps month];
    NSInteger day = [comps day];
    NSInteger hour = [comps hour];
    NSInteger min = [comps minute];
    
//    
//    if (year != currentYear || mouth != currentMounth || day != currentDay) {
//        return YES;
//    }
    
    
    __block HistoryVideoDayModel *resultModel;
    __block NSInteger index = 0;
    
    [self.historyRecordDays enumerateObjectsUsingBlock:^(HistoryVideoDayModel *dayModel, NSUInteger idx, BOOL * _Nonnull stop) {

        NSDate *hisDate = [NSDate dateWithTimeIntervalSince1970:dayModel.timestamp];
        NSDateComponents *comps2 = [calendar components:unitFlags fromDate:hisDate];
        NSInteger _year = [comps2 year];
        NSInteger _mouth = [comps2 month];
        NSInteger _day = [comps2 day];
        if (day == _day && _mouth == mouth && _year == year) {
            
            resultModel = dayModel;
            index = idx;
            *stop = YES;
            
        }

    }];
    
    //CGFloat sMin = second/60.00;
    //
    
    index = self.historyRecordDays.count-index-1;
    CGFloat offset_y;
    if (index > 0) {
        offset_y = (index-1)*markImageWidth+_fristRowHeight+(markImageWidth-(hour*70+(min/6.0)*7));
    }else{
        offset_y = _fristRowHeight-(hour*70+(min/6.0)*7);
    }
    

    
//    offset_y = [self offsetFromHour:hour min:min index:self.historyRecordDays.count-index-1];
    //NSLog(@"%@",resultModel.timeStr);
    //NSLog(@"%f",offset_y);
    [self.horizontalTableView setContentOffset:CGPointMake(0, offset_y) animated:NO];
    self.historyVideoBtn.enabled = YES;
    return NO;
}



#pragma mark- header footerView
-(UIView *)footerView
{
    UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    footerView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    footerView.frame= CGRectMake(0, 0, 55, self.bounds.size.width*0.5);
    footerView.backgroundColor = self.historyVideoBtn.backgroundColor;
    
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(footerView.bounds.size.width-13-2, footerView.bounds.size.height-8.5-5, 13, 8.5)];
    imageView.image = [UIImage imageNamed:@"00"];
    [footerView addSubview:imageView];
    
    return footerView;
}


-(UIView *)headerView
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    headerView.transform = CGAffineTransformMakeRotation(-M_PI / 2);
    headerView.frame= CGRectMake(0, 0, 55, self.bounds.size.width*0.5-55);
    headerView.backgroundColor = self.historyVideoBtn.backgroundColor;
    return headerView;
}


#pragma mark- getter
-(UITableView *)horizontalTableView
{
    if (!_horizontalTableView) {
        UITableView * _tableView = [[UITableView alloc]initWithFrame:self.bounds style:UITableViewStylePlain];
        _tableView.transform = CGAffineTransformMakeRotation(M_PI / 2);
        _tableView.frame = CGRectMake(0, 0, self.bounds.size.width-55, 58);
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.showsVerticalScrollIndicator = NO;
        _tableView.dataSource = self;
        _tableView.backgroundColor = self.historyVideoBtn.backgroundColor;
    
        _horizontalTableView = _tableView;
    }
    return _horizontalTableView;
}

-(UIButton *)historyVideoBtn
{
    if (!_historyVideoBtn) {
        
        _historyVideoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _historyVideoBtn.frame = CGRectMake(self.bounds.size.width-55, 0, 55, 55);

        [_historyVideoBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_VideoLive"] forState:UIControlStateNormal];
        [_historyVideoBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_VideoLive"] forState:UIControlStateDisabled];

        [_historyVideoBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_historyVideoBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateSelected];
        _historyVideoBtn.enabled = NO;
        _historyVideoBtn.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
        [_historyVideoBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        _historyVideoBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_historyVideoBtn addTarget:self action:@selector(historyAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 4, 1, 47)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#ededed"];
        //_historyVideoBtn.selected = NO;
        lineView.tag = 10234;
        [_historyVideoBtn addSubview:lineView];
    }
    return _historyVideoBtn;
}

-(void)historyAction:(UIButton *)sender
{
    sender.enabled = NO;
    if (self.delegate && [self.delegate respondsToSelector:@selector(transionHistoryVideo:)]) {
        [self.delegate transionHistoryVideo:NO];
    }
}


-(UIView *)signView
{
    if (!_signView) {
        _signView = [[UIView alloc]initWithFrame:CGRectMake(self.bounds.size.width*0.5-1, 0, 2, 55)];
        _signView.backgroundColor = [UIColor colorWithHexString:@"#36bdff"];
    }
    return _signView;
}

-(UIImageView *)bottomLineImageView
{
    if (!_bottomLineImageView) {
        UIImageView *imageView0 = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height-1, self.bounds.size.width, 1)];
        imageView0.image = [UIImage imageNamed:@"camera_line"];
        imageView0.userInteractionEnabled = NO;
        _bottomLineImageView = imageView0;
    }
    return _bottomLineImageView;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    NSLog(@"historyView dealloc");
}

@end
