//
//  DateRulerView.m
//  ShowIng
//
//  Created by SghOmk on 16/5/31.
//  Copyright © 2016年 cylan Tec All rights reserved.
//

#import "DateRulerView.h"
#import "DateTools.h"

@interface DateRulerView ()

@property (retain, nonatomic) UILabel *tipLabel;

@end

@implementation DateRulerView {
    CGPoint begainOffset;
}

- (void)dealloc{
    [_rulerScrollView release];
    [_tipLabel release];
    
    [super dealloc];
}

- (UILabel *)tipLabel{
    if (nil ==_tipLabel) {
        //标尺上方的横线
        CGMutablePathRef linePath =CGPathCreateMutable();
        
        CAShapeLayer *lineLayer =[CAShapeLayer layer];
        lineLayer.strokeColor =[UIColor colorWithHex:0xd2d2d2].CGColor;
        lineLayer.fillColor =[UIColor colorWithHex:0xd2d2d2].CGColor;
        lineLayer.lineWidth =0.5f;
        lineLayer.lineCap =kCALineCapButt;
        
        CGPathMoveToPoint(linePath, NULL, 0, 24);
        CGPathAddLineToPoint(linePath, NULL, CGRectGetWidth(self.frame), 24);
        
        lineLayer.path = linePath;
        [self.layer addSublayer:lineLayer];
        //创建显示的Label
        _tipLabel =[[UILabel alloc] init];
        [_tipLabel setBounds:CGRectMake(0, 0, 80, DISTANCETIPSHEIGHT)];
        [_tipLabel setCenter:CGPointMake(self.center.x, DISTANCETIPSHEIGHT /2)];
        [_tipLabel setBackgroundColor:DISTANCETIPSCOLOR];
        [_tipLabel setClipsToBounds:YES];
        [_tipLabel.layer setCornerRadius:2];
        [_tipLabel setFont:[UIFont fontWithName:@"PingFangSC-reglure" size:12]];
        [_tipLabel setFont:[UIFont systemFontOfSize:12]];
        [_tipLabel setTextColor:[UIColor colorWithHex:0xffffff]];
        [_tipLabel setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:_tipLabel];
        //绘制指示的三角形
        CGMutablePathRef tipPath =CGPathCreateMutable();
        
        CAShapeLayer *tipLayer =[CAShapeLayer layer];
        tipLayer.strokeColor =DISTANCETIPSCOLOR.CGColor;
        tipLayer.fillColor =DISTANCETIPSCOLOR.CGColor;
        tipLayer.lineWidth =0.5f;
        tipLayer.lineCap =kCALineCapButt;
        
        CGPathMoveToPoint(tipPath, NULL, CGRectGetWidth(self.frame) /2 -8 , 17);
        CGPathAddLineToPoint(tipPath, NULL, CGRectGetWidth(self.frame) /2 -0.5, 22);
        CGPathAddLineToPoint(tipPath, NULL, CGRectGetWidth(self.frame) /2 +0.5, 22);
        CGPathAddLineToPoint(tipPath, NULL, CGRectGetWidth(self.frame) /2 +8, 17);
        
        tipLayer.path = tipPath;
        [self.layer addSublayer:tipLayer];
    }
    return _tipLabel;
}


- (void)showRulerScrollViewWithDateArray:(NSArray *)dateArray currentIndicateDate:(NSString *)currentDateString{
    
    NSArray *sortedArray =[dateArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSComparisonResult result = [obj1 compare:obj2];
        return result;
    }];
    
    NSMutableArray *modelArray =[NSMutableArray array];
    for (NSInteger i =0; i <[sortedArray count]; i ++) {
        RulerModel *aModel =[[RulerModel alloc] init];
        aModel.date =[sortedArray objectAtIndex:i];
        aModel.haveDate =YES;
        [modelArray addObject:aModel];
        [aModel release];
    }
    [self.rulerScrollView drawRuler:modelArray currentIndicateDate:currentDateString];
}

- (RulerScrollView *)rulerScrollView {
    if ( nil ==_rulerScrollView) {
        _rulerScrollView =[[RulerScrollView alloc] init];
        [_rulerScrollView setFrame:CGRectMake(0, 24, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) -24)];
        _rulerScrollView.delegate = self;
        _rulerScrollView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_rulerScrollView];
        [self drawRacAndLine];
    }
    return _rulerScrollView;
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(RulerScrollView *)scrollView {
    CGFloat offSetX = scrollView.contentOffset.x + self.frame.size.width / 2 - DISTANCELEFTANDRIGHT;
    CGFloat ruleValue = (offSetX / DISTANCEVALUE) * 0.1;
    
    if (ruleValue < 0.f) return;
    
    NSNumber *index =[NSNumber numberWithFloat:ruleValue *10];
    
    NSInteger aIndex =[index integerValue];
    
    if (aIndex >= [scrollView.drawDateArray count]) return;
    //设置tipLabel的显示的日期
    RulerModel *aModel =[scrollView.drawDateArray objectAtIndex:aIndex];
    
    NSDateFormatter *YMDformatter =[[NSDateFormatter alloc] init];
    [YMDformatter setDateFormat:@"yyyy-MM-dd"];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    NSDate *aDate =[dateFormatter dateFromString:aModel.date];
    //更新tip的显示
    [self.tipLabel setText:[YMDformatter stringFromDate:aDate]];
    //传出时间 外部 使用
    if (_delegate &&[_delegate respondsToSelector:@selector(dateRulerView:didShowDateString:)]){
        [_delegate dateRulerView:self didShowDateString:aModel.date];
    }
    [YMDformatter release];
    [dateFormatter release];
}

- (void)scrollViewDidEndDecelerating:(RulerScrollView *)scrollView {
    [self animationRebound:scrollView];
}

- (void)scrollViewDidEndDragging:(RulerScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    scrollView.decelerationRate = 0.9;
    if (!decelerate) {
        [self animationRebound:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    begainOffset =scrollView.contentOffset;
}

- (void)animationRebound:(RulerScrollView *)scrollView {
    CGFloat offSetX = scrollView.contentOffset.x + self.frame.size.width / 2 - DISTANCELEFTANDRIGHT;
    CGFloat oX = (offSetX / DISTANCEVALUE) * 0.1;
    if ([self valueIsInteger:@0.1]) {
        oX = [self notRounding:oX afterPoint:0];
    }else{
        oX = [self notRounding:oX afterPoint:1];
    }
    if (oX < 0.f) return;
        
    //在这进行判断,如果最后选中的index是没有数据的index,就将contentOffset跳转到最近的(最初滑动方向)有数据的一天
    NSNumber *index =[NSNumber numberWithFloat:oX *10];
    
    NSInteger aIndex =[index integerValue];
    
    if (aIndex >=[scrollView.drawDateArray count]) return;
    //最后的偏移值
    CGFloat offsetX =0;
    
    RulerModel *aModel =[scrollView.drawDateArray objectAtIndex:aIndex];
    if (aModel.isHaveDate) {
        if (_delegate &&[_delegate respondsToSelector:@selector(dateRulerView:didSelectedDateString:)]) {
            [_delegate dateRulerView:self didSelectedDateString:aModel.date];
        }
        offsetX = (CGFloat)aIndex /10;
    }else{//如果停止下来的点没有数据
        CGPoint endOffset =scrollView.contentOffset;;
        CGFloat offset =endOffset.x -begainOffset.x;
        if (offset >0) {
            for (NSInteger i =aIndex; i <[scrollView.drawDateArray count]; i ++) {
                RulerModel *model =[scrollView.drawDateArray objectAtIndex:i];
                if (model.isHaveDate) {
                    if (_delegate &&[_delegate respondsToSelector:@selector(dateRulerView:didSelectedDateString:)]) {
                        [_delegate dateRulerView:self didSelectedDateString:model.date];
                    }
                    offsetX = (CGFloat)i /10;
                    break;
                }
            }
        }else{
            for (NSInteger i =aIndex; i >=0; i --) {
                RulerModel *model =[scrollView.drawDateArray objectAtIndex:i];
                if (model.isHaveDate) {
                    if (_delegate &&[_delegate respondsToSelector:@selector(dateRulerView:didSelectedDateString:)]) {
                        [_delegate dateRulerView:self didSelectedDateString:model.date];
                    }
                    offsetX = (CGFloat)i /10;
                    break;
                }
            }
        }
    }
    CGFloat offX = (offsetX / (0.1)) * DISTANCEVALUE + DISTANCELEFTANDRIGHT - self.frame.size.width / 2;
    [UIView animateWithDuration:.2f animations:^{
        scrollView.contentOffset = CGPointMake(offX, 0);
    }];
}

- (void)drawRacAndLine{//绘制蓝色的标尺线
    CAShapeLayer *shapeLayerLine = [CAShapeLayer layer];
    shapeLayerLine.strokeColor = DISTANCETIPSCOLOR.CGColor;
    shapeLayerLine.lineWidth = 2.f;
    shapeLayerLine.lineCap = kCALineCapSquare;
    CGMutablePathRef pathLine = CGPathCreateMutable();
    CGPathMoveToPoint(pathLine, NULL, CGRectGetWidth([UIScreen mainScreen].bounds) / 2, 25);
    CGPathAddLineToPoint(pathLine, NULL, CGRectGetWidth([UIScreen mainScreen].bounds) / 2, CGRectGetHeight(self.frame));
    
    shapeLayerLine.path = pathLine;
    [self.layer addSublayer:shapeLayerLine];
}

#pragma mark - tool method
- (CGFloat)notRounding:(CGFloat)price afterPoint:(NSInteger)position {
    NSDecimalNumberHandler*roundingBehavior = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:position raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    NSDecimalNumber*ouncesDecimal;
    NSDecimalNumber*roundedOunces;
    ouncesDecimal = [[NSDecimalNumber alloc]initWithFloat:price];
    roundedOunces = [ouncesDecimal decimalNumberByRoundingAccordingToBehavior:roundingBehavior];
    return [roundedOunces floatValue];
}

- (BOOL)valueIsInteger:(NSNumber *)number {
    NSString *value = [NSString stringWithFormat:@"%f",[number floatValue]];
    if (value != nil) {
        NSString *valueEnd = [[value componentsSeparatedByString:@"."] objectAtIndex:1];
        NSString *temp = nil;
        for(int i =0; i < [valueEnd length]; i++)
        {
            temp = [valueEnd substringWithRange:NSMakeRange(i, 1)];
            if (![temp isEqualToString:@"0"]) {
                return NO;
            }
        }
    }
    return YES;
}

@end

@implementation RulerModel

- (void)dealloc{
    [_date release];
    
    [super dealloc];
}

@end

@implementation RulerScrollView

- (void)dealloc{
    [_drawDateArray release];
    
    [super dealloc];
}

/**
 根据传入的数据组装DataArray
 */
- (NSMutableArray *)handleDateArray:(NSArray<RulerModel *> *)dateArray{
    //中间处理的数据
    NSMutableArray *middleArray =[[NSMutableArray alloc] initWithArray:dateArray];
    //这里是传过来的时间格式
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddHHmmss"];
    //取出起始时间(最小时间)
    RulerModel *minModel =[middleArray firstObject];
    NSDate *mindate =[formatter dateFromString:minModel.date];
    //取出结束时间(最大时间)
    RulerModel *maxModel =[middleArray lastObject];
    NSDate *maxDate =[formatter dateFromString:maxModel.date];
    //根据最小时间和最大时间,计算出中间的所有时间
    DTTimePeriod *period =[DTTimePeriod timePeriodWithStartDate:mindate endDate:maxDate];
    //获取到的总共的天数
    NSInteger days =[period durationInDays];
    
    //这个数值里面装的是整个时间段的时间
    for (NSInteger i =0; i <=days; i ++) {
        NSDate *middleDates =[mindate dateByAddingDays:i];
        RulerModel *model =[[RulerModel alloc] init];
        model.date =[formatter stringFromDate:middleDates];
        [middleArray addObject:model];
        [model release];
    }
    
    NSArray *sortedArray =[middleArray sortedArrayUsingComparator:^NSComparisonResult(RulerModel *obj1, RulerModel *obj2) {
        NSComparisonResult result = [obj1.date compare:obj2.date];
        return result;
    }];
    
    NSMutableArray *mutableArray =[NSMutableArray arrayWithArray:sortedArray];
    
    for (int i =0; i <[mutableArray count] -1; i ++) {
        RulerModel *lastModel =[mutableArray objectAtIndex:i];
        RulerModel *nextModel =[mutableArray objectAtIndex:i +1];
        if ([[formatter dateFromString:lastModel.date] isSameDay:[formatter dateFromString:nextModel.date]]) {
            if (lastModel.haveDate) {
                [mutableArray removeObject:nextModel];
            }else if (nextModel.haveDate){
                [mutableArray removeObject:lastModel];
            }
            i =i -1;
        }
    }
    [formatter release];
    return mutableArray;
}

/**
 绘制标尺
 */
- (void)drawRuler:(NSArray<RulerModel *> *)dateArray currentIndicateDate:(NSString *)currentDateString{
    //这里是全部的时间,并且标识这有没有数据
    self.drawDateArray =[self handleDateArray:dateArray];
    //初始点的位置
    CGFloat currnetIndex =[self.drawDateArray count] -1;
    
    for (RulerModel *aModel in self.drawDateArray) {
        if ([aModel.date isEqualToString:currentDateString]) {
            currnetIndex =[self.drawDateArray indexOfObject:aModel];
            break;
        }
    }
    //设置标尺背景色
    [self setBackgroundColor:[UIColor colorWithHex:0xf9f9f9]];
    //scroll的宽度
    CGFloat frameWidth =CGRectGetWidth(self.frame);
    CGFloat frameHeight =CGRectGetHeight(self.frame);
    //有数据的路径
    CGMutablePathRef havaDatePath =CGPathCreateMutable();
    
    CAShapeLayer *haveShapeLayer =[CAShapeLayer layer];
    haveShapeLayer.strokeColor =DISTANCETIPSCOLOR.CGColor;
    haveShapeLayer.fillColor =[UIColor clearColor].CGColor;
    haveShapeLayer.lineWidth =2.f;
    haveShapeLayer.lineCap =kCALineCapButt;
    
    //没有数据的路径
    CGMutablePathRef notHaveDatePath =CGPathCreateMutable();
    
    CAShapeLayer *notHaveShapeLayer =[CAShapeLayer layer];
    notHaveShapeLayer.strokeColor =[UIColor colorWithHex:0xdedede].CGColor;
    notHaveShapeLayer.fillColor =[UIColor clearColor].CGColor;
    notHaveShapeLayer.lineWidth =2.f;
    notHaveShapeLayer.lineCap =kCALineCapButt;
    
    //初始化一个显示月初和月中的formatter
    NSDateFormatter *startFormatter =[[NSDateFormatter alloc] init];
    [startFormatter setDateFormat:@"M月"];
    NSDateFormatter *middleFormatter =[[NSDateFormatter alloc] init];
    [middleFormatter setDateFormat:@"M月d日"];
    NSDateFormatter *dateFormatter =[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    
    //定义长线的短线的长度
    CGFloat startY_long =32;
    CGFloat startY_short =41;
    //开始画图,并给上标附上值
    for (NSInteger i = 0; i <[self.drawDateArray count]; i++) {
        //取出一个对象
        RulerModel *aModel =[self.drawDateArray objectAtIndex:i];
        
        NSDate *aDate =[dateFormatter dateFromString:aModel.date];
        NSString *dayString =[aModel.date substringWithRange:NSMakeRange(6, 2)];
        //判断是否是月初和月中 yyyyMMddHHmmss
        if (1 ==[dayString integerValue] || 15 ==[dayString integerValue]) {//画长线,并且标上上标
            
            UILabel *dateTitle =[[UILabel alloc] init];
            [dateTitle setTextColor:[UIColor colorWithHex:0x888888]];
            [dateTitle setFont:[UIFont fontWithName:@"PingFangSC-bold" size:12]];
            [dateTitle setFont:[UIFont systemFontOfSize:12]];
            [dateTitle setText:[NSString stringWithFormat:@"%@", 1 ==[dayString integerValue] ==1 ?[startFormatter stringFromDate:aDate]:[middleFormatter stringFromDate:aDate]]];
            //获取到文字的大小
            CGSize textSize = [dateTitle.text sizeWithAttributes:@{ NSFontAttributeName : dateTitle.font }];
            [dateTitle setFrame:CGRectMake(DISTANCELEFTANDRIGHT + DISTANCEVALUE * i - textSize.width / 2, 6, 70, 11)];
            [self addSubview:dateTitle];
            [dateTitle release];
            
            if (aModel.isHaveDate){//画蓝线
                CGPathMoveToPoint(havaDatePath, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , startY_long);
                CGPathAddLineToPoint(havaDatePath, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, frameHeight);
            }else{//画灰白线
                CGPathMoveToPoint(notHaveDatePath, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , startY_long);
                CGPathAddLineToPoint(notHaveDatePath, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, frameHeight);
            }
        }else{//画短线
            if (aModel.isHaveDate) {
                CGPathMoveToPoint(havaDatePath, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , startY_short);
                CGPathAddLineToPoint(havaDatePath, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, frameHeight);
            }else{
                CGPathMoveToPoint(notHaveDatePath, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i , startY_short);
                CGPathAddLineToPoint(notHaveDatePath, NULL, DISTANCELEFTANDRIGHT + DISTANCEVALUE * i, frameHeight);
            }
        }
    }
    [startFormatter release];
    [middleFormatter release];
    [dateFormatter release];

    haveShapeLayer.path = havaDatePath;
    notHaveShapeLayer.path = notHaveDatePath;
    [self.layer addSublayer:haveShapeLayer];
    [self.layer addSublayer:notHaveShapeLayer];
    
    // 开启最小模式
    UIEdgeInsets edge =UIEdgeInsetsMake(0, frameWidth / 2.f - DISTANCELEFTANDRIGHT, 0, frameWidth / 2.f - DISTANCELEFTANDRIGHT);
    self.contentInset =edge;
    self.contentOffset =CGPointMake(DISTANCEVALUE * currnetIndex  - frameWidth + (frameWidth / 2.f + DISTANCELEFTANDRIGHT), 0);
    self.contentSize =CGSizeMake(([self.drawDateArray count] -1) * DISTANCEVALUE + DISTANCELEFTANDRIGHT * 2.f, 0);
}
@end



