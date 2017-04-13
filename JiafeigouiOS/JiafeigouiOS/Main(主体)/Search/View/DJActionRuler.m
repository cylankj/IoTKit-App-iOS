//
//  DJActionRuler.m
//  DJActionRuler
//
//  Created by SghOmk on 16/6/27.
//  Copyright © 2016年 . All rights reserved.
//

#import "DJActionRuler.h"
#import "DateTools.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#define DJRULERVALUE 7.0f //刻度尺的宽度
#define BCOLOR [UIColor colorWithHex:0x36bdff] //有数据的颜色
#define WCOLOR [UIColor colorWithHex:0xdedede] //没数据的颜色
#define TCOLOR [UIColor colorWithHex:0x888888] //标尺上文字的颜色
#define LCOLOR [UIColor colorWithHex:0xe1e1e1] //边线的颜色
#define PCOLOR [UIColor colorWithHex:0xffffff] //tip上文字的颜色
#define GCOLOR [UIColor colorWithHex:0xf9f9f9] //TabView的背景色

static NSString *cellIdentifier =@"cell";

@interface DJActionRuler ()<UITableViewDelegate,UITableViewDataSource>

@property (retain, nonatomic) UILabel *tipLabel;

@property (retain, nonatomic) DJActionRulerTabView *tableView;

@property (retain, nonatomic) NSDateFormatter *m_formatter, *md_formatter, *ymd_formatter, *tip_formatter;

@property (assign, nonatomic) NSInteger days;

@property (retain, nonatomic) NSMutableArray *sourceArray;

@property (retain, nonatomic) NSMutableArray *dateModelArray;

@property (assign, nonatomic) CGPoint begainOffset;

@end

@implementation DJActionRuler

- (void)dealloc{
    [_tipLabel release];
    [_tableView release];
    [_m_formatter release];
    [_md_formatter release];
    [_ymd_formatter release];
    [_tip_formatter release];
    [_dateModelArray release];
    [_sourceArray release];
    
    [super dealloc];
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tipLabel];
        [self addSubview:self.tableView];
        [self drawBlueLayer];
    }
    return self;
}


- (UILabel *)tipLabel{
    if (nil ==_tipLabel) {
        //绘制指示的三角形
        CGMutablePathRef tipPath =CGPathCreateMutable();
        
        CAShapeLayer *tipLayer =[CAShapeLayer layer];
        tipLayer.strokeColor =BCOLOR.CGColor;
        tipLayer.fillColor =BCOLOR.CGColor;
        tipLayer.lineWidth =0.5f;
        tipLayer.lineCap =kCALineCapButt;
        
        CGPathMoveToPoint(tipPath, NULL, CGRectGetWidth(self.frame) /2 -8 , 17);
        CGPathAddLineToPoint(tipPath, NULL, CGRectGetWidth(self.frame) /2 -0.5, 22);
        CGPathAddLineToPoint(tipPath, NULL, CGRectGetWidth(self.frame) /2 +0.5, 22);
        CGPathAddLineToPoint(tipPath, NULL, CGRectGetWidth(self.frame) /2 +8, 17);
        
        tipLayer.path = tipPath;
        [self.layer addSublayer:tipLayer];
        
        //创建显示的Label
        _tipLabel =[[UILabel alloc] init];
        [_tipLabel setBounds:CGRectMake(0, 0, 80, 18)];
        [_tipLabel setCenter:CGPointMake(self.center.x, 18 /2)];
        [_tipLabel setBackgroundColor:BCOLOR];
        [_tipLabel setClipsToBounds:YES];
        [_tipLabel.layer setCornerRadius:2];
        [_tipLabel setFont:[UIFont fontWithName:@"PingFangSC-regular" size:12]];
        [_tipLabel setFont:[UIFont systemFontOfSize:12]];
        [_tipLabel setTextColor:PCOLOR];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _tipLabel;
}
/**
 *	@author dingjiong, 16-06-27
 *
 *	绘制蓝色的标尺线
 *	@since 1.0
 */
- (void)drawBlueLayer{
    CAShapeLayer *shapeLayerLine = [CAShapeLayer layer];
    shapeLayerLine.strokeColor = BCOLOR.CGColor;
    shapeLayerLine.lineWidth = 2.f;
    shapeLayerLine.lineCap = kCALineCapSquare;
    CGMutablePathRef pathLine = CGPathCreateMutable();
    CGPathMoveToPoint(pathLine, NULL, CGRectGetWidth([UIScreen mainScreen].bounds) / 2, 25);
    CGPathAddLineToPoint(pathLine, NULL, CGRectGetWidth([UIScreen mainScreen].bounds) / 2, CGRectGetHeight(self.frame) -0.5f);
    shapeLayerLine.path = pathLine;
    [self.layer addSublayer:shapeLayerLine];
}

- (DJActionRulerTabView *)tableView{
    if (_tableView ==nil) {
        _tableView =[[DJActionRulerTabView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), 50) style:UITableViewStylePlain];
        _tableView.center =CGPointMake(self.center.x, 24 +25);
        _tableView.delegate =self;
        _tableView.dataSource =self;
        _tableView.scrollsToTop =NO;
    }
    return _tableView;
}

#pragma mark - 将数据处理放入异步线程

- (void)handleDateArray:(NSMutableArray *)array andString:(NSString *)dateString{
    __block typeof(self)blockSelf =self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(self){
            NSArray *sortedArray =[array sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSComparisonResult result = [obj1 compare:obj2];
                return result;
            }];
            NSLog(@"handleDateThread:%@",[NSThread currentThread]);
            
            NSString *minString =[sortedArray firstObject];
            
            NSString *maxString =[sortedArray lastObject];
            
            NSDate *minDate =[blockSelf.ymd_formatter dateFromString:minString];
            
            NSDate *maxDate =[blockSelf.ymd_formatter dateFromString:maxString];
            
            //根据最小时间和最大时间,计算出中间的所有时间
            DTTimePeriod *period =[DTTimePeriod timePeriodWithStartDate:minDate endDate:maxDate];
            //获取到的总共的天数
            _days =[period durationInDays];
            
            if (_dateModelArray ==nil) {
                _dateModelArray =[[NSMutableArray alloc] init];
            }
            [_dateModelArray removeAllObjects];
            
            for (int i =0; i <=_days; i ++) {
                DJActionRulerModel *aModel =[[DJActionRulerModel alloc] init];
                aModel.date =[minDate dateByAddingDays:i];
                [_dateModelArray addObject:aModel];
                [aModel release];
            }
            if (_sourceArray ==nil) {
                _sourceArray =[[NSMutableArray alloc] init];
            }
            [_sourceArray removeAllObjects];
            
            for (int i =0; i <[sortedArray count]; i ++) {
                NSString *aString =[sortedArray objectAtIndex:i];
                
                NSDate *date = [blockSelf.ymd_formatter dateFromString:aString];
                if (date) {
                    [_sourceArray addObject:date];
                }
                
            }
            
            NSInteger _markedIndex =0;
            
            for (DJActionRulerModel *aModel in _dateModelArray) {
                if ([[blockSelf.ymd_formatter dateFromString:dateString] isSameDay:aModel.date]) {
                    _markedIndex =[_dateModelArray indexOfObject:aModel] +1;
                    break;
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [blockSelf.tableView reloadData];
                [blockSelf scrollToOffsetWithIndex:_markedIndex forScrollView:blockSelf.tableView];
            });
        }
    });
}

- (void)loadDateStringArray:(NSMutableArray *)array markedDateString:(NSString *)dateString{
    [self.tipLabel setText:[self.tip_formatter stringFromDate:[self.ymd_formatter dateFromString:dateString]]];
    [self handleDateArray:array andString:dateString];
}

-(void)scrollToRowForDate:(NSDate *)date
{
    //NSLog(@"inputDate:%@",[date description]);
    for (DJActionRulerModel *aModel in [self.dateModelArray copy]) {
        
        //NSLog(@"rulerDate:%@",[aModel.date description]);
        if ([self compreDate:aModel.date sameYYRDate:date]) {
            
            NSInteger row = [self.dateModelArray indexOfObject:aModel];
            [self scrollToOffsetWithIndex:row+1 forScrollView:self.tableView];
            break;
            
        }
    }
}


-(BOOL)compreDate:(NSDate *)aDate sameYYRDate:(NSDate *)bDate
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    comps = [calendar components:unitFlags fromDate:aDate];
    NSInteger aYear = [comps year];
    NSInteger aMonth = [comps month];
    NSInteger aDay = [comps day];
    
    comps = [calendar components:unitFlags fromDate:bDate];
    NSInteger bYear = [comps year];
    NSInteger bMonth = [comps month];
    NSInteger bDay = [comps day];
    
    if (aYear == bYear && aMonth == bMonth && aDay == bDay) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - UIScrollViewDelegate
- (NSInteger)indexOfScroll:(UIScrollView *)scrollView{
    CGFloat index_float = (scrollView.contentOffset.y +self.frame.size.width /2) /DJRULERVALUE;
    
    return [[NSNumber numberWithFloat:index_float] integerValue];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _begainOffset =scrollView.contentOffset;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self animationRebounds:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if (!decelerate) {
        [self animationRebounds:scrollView];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSInteger offsetIndex =[self indexOfScroll:scrollView];
    
    if (offsetIndex <1 ||offsetIndex >_days +1) return;
    
    NSInteger index =offsetIndex -1;
    
    DJActionRulerModel *aModel =[_dateModelArray objectAtIndex:index];
    
    [self.tipLabel setText:[self.tip_formatter stringFromDate:aModel.date]];
    
    /**
     *	@author dingjiong, 16-06-27
     *
     *	添加代理
     *	@since 1.0
     */
    
    if (_rulerDelegate &&[_rulerDelegate respondsToSelector:@selector(actionRuler:willSelectedDateString:)]) {
        [_rulerDelegate actionRuler:self willSelectedDateString:[self.ymd_formatter stringFromDate:aModel.date]];
    }
}

#pragma mark - tool method

- (void)animationRebounds:(UIScrollView *)scrollView{
    
    NSInteger offsetIndex =[self indexOfScroll:scrollView];
    
    if (offsetIndex <1) {
        [self scrollToOffsetWithIndex:1 forScrollView:scrollView];
        
        [self delegateDidSelectedDateStringWithIndex:0];
        return;
    }
    
    if (offsetIndex >_days +1) return;
    
    /**
     *	@author dingjiong, 16-06-27
     *
     *	下面的代码开始代理,以及吸附效果
     *	@since 1.0
     */
    
    NSInteger index =offsetIndex -1;
    
    DJActionRulerModel *aModel =[_dateModelArray objectAtIndex:index];
    
    if (aModel.isMark) {
        [self scrollToOffsetWithIndex:index +1 forScrollView:scrollView];
        
        /**
         *	@author dingjiong, 16-06-28
         *
         *	添加代理
         *	@since 1.0
         */
        [self delegateDidSelectedDateStringWithIndex:index];
        
    }else{
        CGPoint endOffset =scrollView.contentOffset;
        
        if (endOffset.y -_begainOffset.y >0) {
            for (NSInteger i =index; i <[_dateModelArray count]; i ++) {
                DJActionRulerModel *model =[_dateModelArray objectAtIndex:i];
                if (model.isMark) {
                    [self scrollToOffsetWithIndex:i +1 forScrollView:scrollView];
                    
                    /**
                     *	@author dingjiong, 16-06-28
                     *
                     *	添加代理
                     *	@since 1.0
                     */
                    
                    [self delegateDidSelectedDateStringWithIndex:i];
                    
                    break;
                }
            }
        }else{
            for (NSInteger i =index; i >=0; i --) {
                DJActionRulerModel *model =[_dateModelArray objectAtIndex:i];
                if (model.isMark) {
                    [self scrollToOffsetWithIndex:i +1 forScrollView:scrollView];
                    
                    /**
                     *	@author dingjiong, 16-06-28
                     *
                     *	添加代理
                     *	@since 1.0
                     */
                    [self delegateDidSelectedDateStringWithIndex:i];
                    
                    break;
                }
            }
        }
    }
}

-(void)delegateDidSelectedDateStringWithIndex:(NSInteger)index{
    if (_rulerDelegate &&[_rulerDelegate respondsToSelector:@selector(actionRuler:didSelectedDateString:)]) {
        
        DJActionRulerModel *aModel =[_dateModelArray objectAtIndex:index];
        if (aModel.isMark) {
            for (NSInteger i =([_sourceArray count] -1); i >=0; i --) {
                NSDate *date =[_sourceArray objectAtIndex:i];
                if ([aModel.date isSameDay:date]) {
                    [_rulerDelegate actionRuler:self didSelectedDateString:[self.ymd_formatter stringFromDate:date]];
                    break;
                }
            }
        }
    }
}

/**
 *	@author dingjiong, 16-06-27
 *
 *	根据需要指向的index处理偏移量
 *	@param index	索引
 *	@param scrollView	需要滚动的UIScrollView
 *	@since 1.0
 */
- (void)scrollToOffsetWithIndex:(NSInteger)index forScrollView:(UIScrollView *)scrollView{
    CGFloat offSetY =index * DJRULERVALUE -self.frame.size.width /2;
    [UIView animateWithDuration:.2f animations:^{
        scrollView.contentOffset = CGPointMake(0, offSetY);
    }];
}

-(NSDateFormatter *)m_formatter{
    if (_m_formatter ==nil) {
        _m_formatter =[[NSDateFormatter alloc] init];
        [_m_formatter setDateFormat:[NSString stringWithFormat:@"M%@",[JfgLanguage getLanTextStrByKey:@"MONTHS"]]];
    }
    return _m_formatter;
}

-(NSDateFormatter *)md_formatter{
    if (_md_formatter ==nil) {
        _md_formatter =[[NSDateFormatter alloc] init];
        [_md_formatter setDateFormat:[NSString stringWithFormat:@"M%@d%@",[JfgLanguage getLanTextStrByKey:@"MONTHS"],[JfgLanguage getLanTextStrByKey:@"SUN_2"]]];
    }
    return _md_formatter;
}

-(NSDateFormatter *)ymd_formatter{
    if (_ymd_formatter ==nil) {
        _ymd_formatter =[[NSDateFormatter alloc] init];
        [_ymd_formatter setDateFormat:@"yyyyMMddHHmmss"];
    }
    return _ymd_formatter;
}

-(NSDateFormatter *)tip_formatter{
    if (_tip_formatter ==nil) {
        _tip_formatter =[[NSDateFormatter alloc] init];
        [_tip_formatter setDateFormat:@"yyyy-MM-dd"];
    }
    return _tip_formatter;
}

#pragma mark - UITableViewDelegate &UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    @synchronized(self){
        return [_dateModelArray count];
    }
}



- (DJActionRulerCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    @synchronized(self){
        
        
        DJActionRulerCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        DJActionRulerModel *aModel =[_dateModelArray objectAtIndex:indexPath.row];
        
        NSString *dayString =[[self.ymd_formatter stringFromDate:aModel.date] substringWithRange:NSMakeRange(6, 2)];
        
        if (1 ==[dayString integerValue] || 15 ==[dayString integerValue]){
            [cell.titleLabel setText:[NSString stringWithFormat:@"%@", 1 ==[dayString integerValue] ?[self.m_formatter stringFromDate:aModel.date]:[self.md_formatter stringFromDate:aModel.date]]];
            [cell.titleLabel setHidden:NO];
            [cell setIsLong:YES];
        }else{
            [cell.titleLabel setText:nil];
            [cell.titleLabel setHidden:YES];
            [cell setIsLong:NO];
        }
        [cell setIsMark:aModel.isMark];
        
        return cell;
    }
    
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    @synchronized(self){
        DJActionRulerModel *aModel =[_dateModelArray objectAtIndex:indexPath.row];
        for (NSDate *date in _sourceArray) {
            if ([aModel.date isSameDay:date]) {
                [aModel setMark:YES];
                break;
            }
        }
        return DJRULERVALUE;
    }
}
@end

@implementation DJActionRulerTabView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self =[super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width) style:style]) {
        self.transform =CGAffineTransformMakeRotation(- M_PI /2);
        self.showsVerticalScrollIndicator =NO;
        self.showsHorizontalScrollIndicator =NO;
        [self setContentInset:UIEdgeInsetsMake(CGRectGetWidth(frame) /2.f, 0, CGRectGetWidth(frame) /2.f, 0)];
        [self registerClass:[DJActionRulerCell class] forCellReuseIdentifier:cellIdentifier];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setDecelerationRate:0.9f];
        [self.layer setBorderColor:LCOLOR.CGColor];
        [self.layer setBorderWidth:0.5f];
        [self setBackgroundColor:GCOLOR];
    }
    return self;
}

@end

@interface DJActionRulerCell ()

@property (retain, nonatomic) UILabel *lineLabel;

@end

@implementation DJActionRulerCell

- (void)dealloc{
    [_titleLabel release];
    [_lineLabel release];
    
    [super dealloc];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(-15-6, 3, 47+25, 20)];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setTextColor:TCOLOR];
        [_titleLabel setFont:[UIFont fontWithName:@"PingFangSC-bold" size:12]];
        [_titleLabel setFont:[UIFont boldSystemFontOfSize:12]];
        [self.contentView addSubview:_titleLabel];
        
        _lineLabel =[[UILabel alloc] init];
        [self.contentView addSubview:_lineLabel];
        
        [self setTransform:CGAffineTransformMakeRotation(M_PI /2)];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}


-(void)setIsMark:(BOOL)isMark{
    _isMark =isMark;
    if (_isMark) {
        [_lineLabel setBackgroundColor:BCOLOR];
    }else{
        [_lineLabel setBackgroundColor:WCOLOR];
    }
}

- (void)setIsLong:(BOOL)isLong{
    _isLong =isLong;
    if (isLong) {
        [_lineLabel setFrame:CGRectMake(6, 32, 2, 18)];
    }else{
        [_lineLabel setFrame:CGRectMake(6, 41, 2, 9)];
    }
}

@end


@implementation DJActionRulerModel

- (void)dealloc{
    [_date release];
    
    [super dealloc];
}

@end


