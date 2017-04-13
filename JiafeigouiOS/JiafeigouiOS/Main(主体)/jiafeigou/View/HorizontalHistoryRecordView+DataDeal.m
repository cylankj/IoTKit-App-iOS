//
//  HorizontalHistoryRecordView+DataDeal.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "HorizontalHistoryRecordView+DataDeal.h"
#import <JFGSDK/JFGSDK.h>
#import "historyVideoDurationTimeModel.h"
#import "HistoryVideoDayModel.h"

@implementation HorizontalHistoryRecordView (DataDeal)

-(NSArray *)dataDeal:(NSArray<JFGSDKHistoryVideoInfo *> *)list
{
    NSMutableArray *dataArr = [[NSMutableArray alloc]init];
    
    for (JFGSDKHistoryVideoInfo *info in list) {
        
        historyVideoDurationTimeModel *model = [[historyVideoDurationTimeModel alloc]init];
        model.startTimestamp = (int)info.beginTime;
        model.duration = info.duration;
        [dataArr addObject:model];
        
    }
    //根据时间排序
    NSArray *resultArr = [self taxisForTime:dataArr];
    //倒序
    resultArr = [[resultArr reverseObjectEnumerator] allObjects];
    //根据日期分组
    resultArr = [self groupingForDayWithDataArry:resultArr];


    return resultArr;

}

//将每天的数据添加到一个数组中
-(NSArray *)groupingForDayWithDataArry:(NSArray *)sourceArr
{
    NSMutableArray *resultArr = [NSMutableArray new];
    NSInteger count = -1;

    //相同日期份的数据归到一组
    for (historyVideoDurationTimeModel *model in sourceArr) {
        if (count ==-1 || count!=[model startDay]) {

            NSMutableArray *tempArr = [[NSMutableArray alloc]init];
            [tempArr addObject:model];
            [resultArr addObject:tempArr];

        }else{

            NSMutableArray *tempArr = [resultArr lastObject];
            [tempArr addObject:model];

        }
        count = [model startDay];
    }
    
    return resultArr;
}

-(NSArray <HistoryVideoDayModel *>*)historyVideoLimistForDayFromAllDataArr:(NSArray <NSArray <historyVideoDurationTimeModel *> *> *)list
{
    
    __block NSMutableArray *dataArr = [NSMutableArray new];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    [list enumerateObjectsUsingBlock:^(NSArray *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.count > 0) {
            
            historyVideoDurationTimeModel *videoModel = [obj lastObject];
            
            NSDate *date = [NSDate dateWithTimeIntervalSince1970:videoModel.startTimestamp];
            NSString *dateStr = [dateFormatter stringFromDate:date];
            
            CGFloat offset ;
            if (idx == 0) {
                offset = self.fristRowHeight-videoModel.startPosition;
            }else{
                offset = self.fristRowHeight+(markImageWidth - videoModel.startPosition)+(idx-1)*markImageWidth;
            }
            HistoryVideoDayModel *dayModel = [HistoryVideoDayModel new];
            dayModel.startPosition = offset;
            dayModel.timeStr = dateStr;
            dayModel.timestamp = videoModel.startTimestamp;
            [dataArr addObject:dayModel];
        }
        
    }];
    return dataArr;
}



-(historyVideoDurationTimeModel *)rightNearestHistoryModel:(CGFloat)diff mouthList:(NSArray <historyVideoDurationTimeModel *>*)mouthList
{
    CGFloat driff = 9999999;
    historyVideoDurationTimeModel *resultModel;
    
    for (historyVideoDurationTimeModel *model in mouthList) {
        
        CGFloat driff2 = 0;
        
        if (diff>=[model startPosition] && diff<= [model endPosition]) {
            
            return model;
            
        }
        
        if ([model startPosition] > diff) {
            //left
            driff2 = [model startPosition] - diff;
            
        }
        
        if (driff2<driff) {
            
            resultModel = model;
            driff = driff2;
            
        }
    }
    return resultModel;
}


-(historyVideoDurationTimeModel *)nearestHistoryModel:(CGFloat)diff mouthList:(NSArray <historyVideoDurationTimeModel *>*)mouthList
{
    CGFloat driff = 9999999;
    historyVideoDurationTimeModel *resultModel;
    
    for (historyVideoDurationTimeModel *model in mouthList) {
        
        CGFloat driff2;
        
        
        if (diff >= [model endPosition]) {
            //left
            driff2 = diff - [model endPosition];
        }else{
            //right
            driff2 = [model startPosition]-diff;
        }
        
        if (driff2<driff) {
            
            resultModel = model;
            driff = driff2;
            
        }
    }
    return resultModel;
}

#pragma mark- 数据排序
//把数组按年份排序
-(NSArray *)taxisForYears:(NSArray <historyVideoDurationTimeModel *>*)sourseArr
{
    NSComparator cmptr = ^(historyVideoDurationTimeModel *obj1, historyVideoDurationTimeModel * obj2){

        if ([obj1 startYear] > [obj2 startYear]) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if ([obj1 startYear] < [obj2 startYear]) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    };
    
    NSArray *resultArr = [sourseArr sortedArrayUsingComparator:cmptr];
    
    return resultArr;
    
}


//按时间排序
-(NSArray *)taxisForTime:(NSArray <historyVideoDurationTimeModel *>*)sourseArr
{
    NSComparator cmptr = ^(historyVideoDurationTimeModel *obj1, historyVideoDurationTimeModel * obj2){
        
        NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:obj1.startTimestamp];
        NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:obj2.startTimestamp];
        
        NSComparisonResult result = [date1 compare:date2];
        return result;
    };
    
    NSArray *resultArr = [sourseArr sortedArrayUsingComparator:cmptr];
    
    return resultArr;
}

#pragma mark- sb代码
//    NSArray *years = [self taxisForYears:dataArr];
//
//    NSMutableArray *yearArr = [NSMutableArray new];
//    NSInteger count = -1;
//
//    //相同年份的数据归到一组
//    for (historyVideoDurationTimeModel *model in years) {
//        if (count ==-1 || count!=[model startYear]) {
//
//            NSMutableArray *tempArr = [[NSMutableArray alloc]init];
//            [tempArr addObject:model];
//            [yearArr addObject:tempArr];
//
//        }else{
//
//            NSMutableArray *tempArr = [yearArr lastObject];
//            [tempArr addObject:model];
//
//        }
//        count = [model startYear];
//    }
//
//    //按月份进行排序
//    for (NSArray *mouths in [yearArr copy]) {
//
//        NSArray *newYear = [self taxisForMouths:mouths];
//        [yearArr replaceObjectAtIndex:[yearArr indexOfObject:mouths] withObject:newYear];
//
//    }
//
//    //按月份分组
//    for (NSArray *mouths in [yearArr copy]) {
//
//        NSMutableArray *mouthArr = [NSMutableArray new];
//        NSInteger count = -1;
//
//        //相同月份的数据归到一组
//        for (historyVideoDurationTimeModel *model in mouths) {
//            if (count ==-1 || count!=[model startMouth]) {
//
//
//                if (mouthArr.count>0) {
//                    //按日期排序
//                    NSArray *temp = [mouthArr lastObject];
//                    NSArray *resultArr = [self taxisForDays:temp];
//                    [mouthArr replaceObjectAtIndex:mouthArr.count-1 withObject:resultArr];
//                }
//
//                NSMutableArray *tempArr = [[NSMutableArray alloc]init];
//                [tempArr addObject:model];
//                [mouthArr addObject:tempArr];
//
//
//
//            }else{
//
//                NSMutableArray *tempArr = [mouthArr lastObject];
//                [tempArr addObject:model];
//
//            }
//            count = [model startMouth];
//        }
//
//        [yearArr replaceObjectAtIndex:[yearArr indexOfObject:mouths] withObject:mouthArr];
//    }
//
//    NSMutableArray *resultArr = [[NSMutableArray alloc]init];
//
//    for (id obj1 in yearArr) {
//
//        if ([obj1 isKindOfClass:[NSArray class]]) {
//
//            NSArray *mouthArr = obj1;
//            for (id obj2 in mouthArr) {
//
//                if ([obj2 isKindOfClass:[NSArray class]]) {
//
//                    NSArray *daysArr = obj2;
//
//                    for (id obj3 in daysArr) {
//                        if ([obj3 isKindOfClass:[historyVideoDurationTimeModel class]]) {
//
//                            historyVideoDurationTimeModel *model = obj3;
//                            [resultArr addObject:model];
//                            NSLog(@"\nyear:%d mouth:%d day:%d",[model startYear],[model startMouth],[model startDay]);
//
//                        }
//                    }
//                }
//
//            }
//
//        }
//
//    }
//NSLog(@"%@",yearArr);

@end
