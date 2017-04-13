//
//  subSafeProtectViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "subSafeProtectViewModel.h"
#import "JfgLanguage.h"
#import "JfgTableViewCellKey.h"
#import "SafeProtectModel.h"
#import "JfgMsgDefine.h"
#import "dataPointMsg.h"
#import "ProgressHUD.h"

@interface subSafeProtectViewModel()

@property (strong, nonatomic) NSMutableArray *groupArray;

@property (strong, nonatomic) DeviceVoiceModel *deviceVoiceModel;

@property (strong, nonatomic) DeviceRepeatModel *deviceRepeatModel;

#pragma mark
#pragma mark  ==== 重复 ====
@property (assign, nonatomic) int repeatDateCache;

@end

@implementation subSafeProtectViewModel

#pragma mark
#pragma mark  public function

- (NSArray *)requestData
{
    return [self createData];
}

#pragma mark
#pragma mark  ==== 设备提示音====
- (void)initDataWithSelected:(int)soundType time:(int)voiceRepeatTime
{
    self.deviceVoiceModel.soundType = soundType;
    self.deviceVoiceModel.voiceRepeatTime = voiceRepeatTime;
    self.deviceVoiceModel.voiceRepeatStr = [NSString stringWithFormat:@"%ds",voiceRepeatTime];
    [self update];
}
- (void)updatevoiceType:(int)soundType time:(int)repeatTime
{
    [self initDataWithSelected:soundType time:repeatTime];
}

#pragma mark
#pragma mark  ==== 重复 ====
- (void)initRepeatModel:(int)repeatDate
{
    self.deviceRepeatModel.repeatDate = repeatDate;
}

- (int)updateDayChecked:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 0:
        {
            if (self.deviceRepeatModel.isMonChecked)
            {
                 self.repeatDateCache &= ~(0x1<<(6-(int)indexPath.row));
            }
            else
            {
                self.repeatDateCache |= 0x1<<(6-(int)indexPath.row);
            }
            
        }
            break;
        case 1:
        {
            if (self.deviceRepeatModel.isTueChecked)
            {
                self.repeatDateCache &= ~(0x1<<(6-(int)indexPath.row));
            }
            else
            {
                self.repeatDateCache |= 0x1<<(6-(int)indexPath.row);
            }
        }
            break;
        case 2:
        {
            if (self.deviceRepeatModel.isWedChecked)
            {
                self.repeatDateCache &= ~(0x1<<(6-(int)indexPath.row));
            }
            else
            {
                self.repeatDateCache |= 0x1<<(6-(int)indexPath.row);
            }
        }
            break;
        case 3:
        {
            if (self.deviceRepeatModel.isThuChecked)
            {
                self.repeatDateCache &= ~(0x1<<(6-(int)indexPath.row));
            }
            else
            {
                self.repeatDateCache |= 0x1<<(6-(int)indexPath.row);
            }
        }
            break;
        case 4:
        {
            if (self.deviceRepeatModel.isFriChecked)
            {
                self.repeatDateCache &= ~(0x1<<(6-(int)indexPath.row));
            }
            else
            {
                self.repeatDateCache |= 0x1<<(6-(int)indexPath.row);
            }
        }
            break;
        case 5:
        {
            if (self.deviceRepeatModel.isSatChecked)
            {
                self.repeatDateCache &= ~(0x1<<(6-(int)indexPath.row));
            }
            else
            {
                self.repeatDateCache |= 0x1<<(6-(int)indexPath.row);
            }
        }
            break;
        case 6:
        {
            if (self.deviceRepeatModel.isSunChecked)
            {
                self.repeatDateCache &= ~(0x1<<(6-(int)indexPath.row));
            }
            else
            {
                self.repeatDateCache |= 0x1<<(6-(int)indexPath.row);
            }
        }
            break;
        default:
            break;
    }
    
    if (self.repeatDateCache > 0)
    {
        self.deviceRepeatModel.repeatDate = self.repeatDateCache;
        [self update];
    }
    return self.deviceRepeatModel.repeatDate;
}

- (int)repeatDateCache
{
    if (_repeatDateCache == 0)
    {
        _repeatDateCache = self.deviceRepeatModel.repeatDate;
    }
    
    return _repeatDateCache;
}

#pragma mark
#pragma mark common

- (void)update
{
    if ([_myDelegate respondsToSelector:@selector(updatedDataArray:)])
    {
        [_myDelegate updatedDataArray:[self createData]];
    }
}

- (void)initModel:(NSDictionary *)dict
{
    switch (self.safeProtectType)
    {
        case SafeProtectTypeDeviceVoice:
        {
            
        }
            break;
        case SafeProtectTypeProtectTime:
        {
            
        }
            break;
        default:
            break;
    }
}


- (NSMutableArray *)createData
{
    [self.groupArray removeAllObjects];
    
    switch (self.safeProtectType)
    {
        case SafeProtectTypeDeviceVoice:
        {
            [self.groupArray addObject:[NSArray arrayWithObjects:
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"MUTE"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceVoiceModel.isMuteChecked? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"BARKING"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceVoiceModel.isBarkChecked? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"ALARM"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceVoiceModel.isWarnChecked? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        nil]];
            if (self.deviceVoiceModel.soundType != soundTypeMute)
            {
                [self.groupArray addObject:[NSArray arrayWithObjects:
                                            [NSDictionary dictionaryWithObjectsAndKeys:
                                             @"",cellIconImageKey,
                                             [JfgLanguage getLanTextStrByKey:@"REPEAT_PLAY"],cellTextKey,
                                             self.deviceVoiceModel.voiceRepeatStr,cellDetailTextKey,
                                             @(self.deviceVoiceModel.voiceRepeatTime), cellHiddenText,
                                             @0,cellshowSwitchKey,
                                             @(UITableViewCellAccessoryDisclosureIndicator),cellAccessoryKey,
                                             nil], nil]];
            }
            
        }
            break;
        case SafeProtectTypeProtectTime:
        {
            [self.groupArray addObject:[NSArray arrayWithObjects:
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"MON"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceRepeatModel.isMonChecked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"TUE"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceRepeatModel.isTueChecked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"WED"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceRepeatModel.isWedChecked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"THU"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceRepeatModel.isThuChecked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"FRI"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceRepeatModel.isFriChecked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"SAT"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceRepeatModel.isSatChecked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        [NSDictionary dictionaryWithObjectsAndKeys:
                                         @"",cellIconImageKey,
                                         [JfgLanguage getLanTextStrByKey:@"SUN"],cellTextKey,
                                         [JfgLanguage getLanTextStrByKey:@""],cellDetailTextKey,
                                         @0,cellshowSwitchKey,
                                         @(self.deviceRepeatModel.isSunChecked?UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone),cellAccessoryKey,
                                         nil],
                                        nil]];
        }
            break;
        default:
            break;
    }
    return self.groupArray;
}

#pragma mark
#pragma mark property
- (NSMutableArray *)groupArray
{
    if (_groupArray == nil)
    {
        _groupArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _groupArray;
}

- (DeviceVoiceModel *)deviceVoiceModel
{
    if (_deviceVoiceModel == nil)
    {
        _deviceVoiceModel = [[DeviceVoiceModel alloc] init];
    }
    return _deviceVoiceModel;
}

- (DeviceRepeatModel *)deviceRepeatModel
{
    if (_deviceRepeatModel == nil)
    {
        _deviceRepeatModel = [[DeviceRepeatModel alloc] init];
    }
    return _deviceRepeatModel;
}

@end
