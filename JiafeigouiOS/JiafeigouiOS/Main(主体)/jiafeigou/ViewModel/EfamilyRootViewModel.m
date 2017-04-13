//
//  EfamilyRootViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "EfamilyRootViewModel.h"
#import "JfgTableViewCellKey.h"
#import "EfamilyRootVC.h"
#import "JfgGlobal.h"

@interface EfamilyRootViewModel()

@property (strong, nonatomic) NSMutableArray *groupArray;

@end

@implementation EfamilyRootViewModel


- (NSArray *)requestDataWithCid:(NSString *)cid
{
    return [self createData];
}

- (NSArray *)createData
{
    [self.groupArray removeAllObjects];
    
    [self.groupArray addObjectsFromArray:[NSArray arrayWithObjects:
                                          [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(cellTypeLeaveMsg), dataCellType,
                                           @"8″",dataDuration,
                                           @"07-06 11:14", dataTimeBegin,
                                           @"", dataUrl,
                                           @(5), dataRequestID,
                                           @(0), dataFileState, nil],
                                          [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(cellTypeClientCall), dataCellType,
                                           @"00：08",dataDuration,
                                           @"07-05 11:15", dataTimeBegin,
                                           @"", dataUrl,
                                           @(5), dataRequestID,
                                           @(0), dataFileState, nil],
                                          [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(cellTypeClientCall), dataCellType,
                                           @"00:10",dataDuration,
                                           @"07-06 11:14", dataTimeBegin,
                                           @"", dataUrl,
                                           @(5), dataRequestID,
                                           @(0), dataFileState,
                                           @1, dataIsOK,nil],
                                          [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(cellTypeEfamilyCall), dataCellType,
                                           @"10″",dataDuration,
                                           @"07-03 11:14", dataTimeBegin,
                                           @"", dataUrl,
                                           @(5), dataRequestID,
                                           @(0), dataFileState,
                                           @0, dataIsOK,nil],
                                          [NSDictionary dictionaryWithObjectsAndKeys:
                                           @(cellTypeEfamilyCall), dataCellType,
                                           @"10″",dataDuration,
                                           @"07-03 11:14", dataTimeBegin,
                                           @"", dataUrl,
                                           @(5), dataRequestID,
                                           @(0), dataFileState,
                                           @0, dataIsOK,nil],
                                          
                                          nil]];
//    [self.groupArray addObject:[NSArray arrayWithObjects:
//                                [NSDictionary dictionaryWithObjectsAndKeys:
//                                                          @(cellTypeLeaveMsg), dataCellType,
//                                                          @"8″",dataDuration,
//                                                          @"07-06 11:14", dataTimeBegin,
//                                                          @"", dataUrl,
//                                                          @(5), dataRequestID,
//                                                          @(0), dataFileState, nil],
//                                [NSDictionary dictionaryWithObjectsAndKeys:
//                                                         @(cellTypeClientCall), dataCellType,
//                                                         @"00：08",dataDuration,
//                                                         @"07-05 11:15", dataTimeBegin,
//                                                         @"", dataUrl,
//                                                         @(5), dataRequestID,
//                                                         @(0), dataFileState, nil],
//                                [NSDictionary dictionaryWithObjectsAndKeys:
//                                                         @(cellTypeClientCall), dataCellType,
//                                                         @"00:10",dataDuration,
//                                                         @"07-06 11:14", dataTimeBegin,
//                                                         @"", dataUrl,
//                                                         @(5), dataRequestID,
//                                                         @(0), dataFileState,
//                                                         @1, dataIsOK,nil],
//                                [NSDictionary dictionaryWithObjectsAndKeys:
//                                                         @(cellTypeEfamilyCall), dataCellType,
//                                                         @"10″",dataDuration,
//                                                         @"07-03 11:14", dataTimeBegin,
//                                                         @"", dataUrl,
//                                                         @(5), dataRequestID,
//                                                         @(0), dataFileState,
//                                                         @0, dataIsOK,nil],
//                                [NSDictionary dictionaryWithObjectsAndKeys:
//                                 @(cellTypeEfamilyCall), dataCellType,
//                                 @"10″",dataDuration,
//                                 @"07-03 11:14", dataTimeBegin,
//                                 @"", dataUrl,
//                                 @(5), dataRequestID,
//                                 @(0), dataFileState,
//                                 @0, dataIsOK,nil],
//                                
//                                nil]];
    
    
    
    return self.groupArray;
}

#pragma mark getter
- (NSMutableArray *)groupArray
{
    if (_groupArray == nil)
    {
        _groupArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _groupArray;
}

@end
