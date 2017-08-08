//
//  AIRecognitionVIewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AIRecognitionVIewModel.h"
#import "AIRecognitionModel.h"
#import "dataPointMsg.h"
#import <JFGSDK/JFGSDK.h>
#import "JfgGlobal.h"

@interface AIRecognitionVIewModel()

@property (nonatomic, strong) AIRecognitionModel *aiModel;

@property (nonatomic, strong) NSMutableArray *groupArray;

@property (nonatomic, strong) NSArray *dpsArr;

@property (nonatomic, strong) NSArray *originAITypes;   // 记录 服务器的 AI值 用来 判断 是否变化

@end

@implementation AIRecognitionVIewModel

- (void)requestFromServer
{
    JFG_WS(weakSelf);
    
    [[dataPointMsg shared] packSingleDataPointMsg:self.dpsArr withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic) {
        if (dic)
        {
            [weakSelf initModel:dic];
            [weakSelf update];
        }
    } FailBlock:^(RobotDataRequestErrorType error) {
        
    }];
    
    [self fetch];
}

- (void)initModel:(NSDictionary *)info
{
    @try {
        self.aiModel.aiRecognitions = [info objectForKey:dpMsgCameraAIRecgnitionKey];
        self.originAITypes = [[NSArray alloc] initWithArray:self.aiModel.aiRecognitions];
    } @catch (NSException *exception) {
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"AIRecoginitonVM exception :%@", exception]];
    } @finally {
        
    }
    
}

- (BOOL)isSelectedItem:(AIRecType)aiType
{
    if (self.aiModel.aiRecognitions.count > 0)
    {
        if ([self.aiModel.aiRecognitions containsObject:@((int)aiType)])
        {
            return YES;
        }
    }
    return NO;
}

#pragma mark 数据 更新 获取

- (NSMutableArray *)getModelData
{
    [self.groupArray removeAllObjects];
    
    [self.groupArray addObject:[NSArray arrayWithObjects:
                                [NSDictionary dictionaryWithObjectsAndKeys:[JfgLanguage getLanTextStrByKey:@"AI_HUMAN"],titleKey, @"icon_man", normalImageKey, @"icon_man_hl.png", selectedImageKey,@([self isSelectedItem:AIRecType_Person]), isSelectedItemKey, @(AIRecType_Person), aiTypeKey, nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:[JfgLanguage getLanTextStrByKey:@"AI_CAT"],titleKey, @"icon_cat", normalImageKey, @"icon_cat_hl", selectedImageKey, @([self isSelectedItem:AIRecType_Cat]), isSelectedItemKey, @(AIRecType_Cat), aiTypeKey, nil],
                                [NSDictionary dictionaryWithObjectsAndKeys:[JfgLanguage getLanTextStrByKey:@"AI_DOG"],titleKey, @"icon_dog", normalImageKey, @"icon_dog_hl", selectedImageKey, @([self isSelectedItem:AIRecType_Dog]), isSelectedItemKey, @(AIRecType_Dog), aiTypeKey,nil], nil]];
    
    [self.groupArray addObject:[NSArray arrayWithObjects:
                                                           [NSDictionary dictionaryWithObjectsAndKeys:[JfgLanguage getLanTextStrByKey:@"AI_VEHICLE"],titleKey, @"icon_car", normalImageKey, @"icon_car_hl.png", selectedImageKey,@([self isSelectedItem:AIRecType_Car]), isSelectedItemKey,@(AIRecType_Car), aiTypeKey, nil],
                                                           @{},
                                                           @{}, nil]];
    return self.groupArray;
}

- (void)fetch
{
    if ([_delegate respondsToSelector:@selector(fetchDataArray:)])
    {
        [_delegate fetchDataArray:[self getModelData]];
    }
}

- (void)update
{
    if ([_delegate respondsToSelector:@selector(updatedDataArray:)])
    {
        [_delegate updatedDataArray:[self getModelData]];
    }
}

#pragma mark public func
- (void)selectedItem:(NSInteger)aiType
{
    NSNumber *aiTypeNum = @(aiType);
    
    if ([self.aiModel.aiRecognitions containsObject:aiTypeNum])
    {
        [self.aiModel.aiRecognitions removeObject:aiTypeNum];
    }
    else
    {
        [self.aiModel.aiRecognitions addObject:aiTypeNum];
    }
    
    [self update];
}

- (NSArray *)aiRecgnitions
{
    if ([self.originAITypes isEqualToArray:self.aiModel.aiRecognitions])
    {
        return nil;
    }

    return self.aiModel.aiRecognitions;
}

#pragma mark getter
- (AIRecognitionModel *)aiModel
{
    if (_aiModel == nil)
    {
        _aiModel = [[AIRecognitionModel alloc] init];
        _aiModel.cid = self.cid;
        _aiModel.pType = self.pType;
    }
    return _aiModel;
}

- (NSArray *)dpsArr
{
    if (_dpsArr == nil)
    {
        _dpsArr = [[NSArray alloc] initWithObjects:@(dpMsgCamera_AIRecgnition), nil];
    }
    return _dpsArr;
}


- (NSMutableArray *)groupArray
{
    if (_groupArray == nil)
    {
        _groupArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _groupArray;
}

@end
