//
//  SafeProtectTableView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SafeProtectTableView.h"
#import "DeviceSettingCell.h"
#import "JfgTableViewCellKey.h"
#import "CusDatePickerView.h"
#import "DJActionSheet.h"
#import "LSAlertView.h"
#import "DeviceSettingViewModel.h"
#import "UISwitch+Clicked.h"
#import "JfgTimeFormat.h"

typedef NS_ENUM(NSInteger, pickerTag) {
    pickerTag_beginTime = 1000, // 1000 开始
    pickerTag_endTime,
};

@interface SafeProtectTableView()<cusDatePickerDelegate>
/**
 *  数据
 */
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation SafeProtectTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.dataSource = self;
        self.delegate = self;
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self initView];
    [self initData];
}


#pragma mark  view

- (void)initView
{
}

- (void)initViewLayout
{
    
}

- (void)initData
{
    [self.safeProtectVM requestDataWithCid:self.cid];
}




#pragma mark  getter
- (NSArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _dataArray;
}


- (SafeProtectViewModel *)safeProtectVM
{
    if (_safeProtectVM == nil)
    {
        _safeProtectVM = [[SafeProtectViewModel alloc] init];
        _safeProtectVM.delegate = self;
        _safeProtectVM.pType = self.pType;
        _safeProtectVM.cid = self.cid;
    }
    
    return _safeProtectVM;
}


#pragma mark  data
- (void)tableViewData:(NSArray *)data
{
    if (self.dataArray != data)
    {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:data];
        [self reloadData];
    }
}


#pragma mark  tableView delegate
- (void)datePickerDidChanged:(UIDatePicker *)datePicker
{
    
    NSDate *selectTime = [datePicker date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"]; //@"yyyy-MM-dd HH:mm:ss zzz"    zzz表示时区信息=
    
    switch (datePicker.tag)
    {
        case pickerTag_beginTime:
        {
            NSString *beginTimeStr = [dateFormatter stringFromDate:selectTime];
            self.beginTime = [[beginTimeStr substringToIndex:2] integerValue]<<8 | [[beginTimeStr substringFromIndex:3] integerValue];
        }
            break;
        case pickerTag_endTime:
        {
            NSString *endTimeStr = [dateFormatter stringFromDate:selectTime];
            self.endTime = [[endTimeStr substringToIndex:2] integerValue]<<8 | [[endTimeStr substringFromIndex:3] integerValue];
        }
            break;
        default:
            break;
    }
    
}

- (void)okButtonclicked:(UIDatePicker *)datePicker
{
    [self.safeProtectVM updatebeginTime:self.beginTime endTime:self.endTime];
}

- (void)cancelButtonclicked:(UIDatePicker *)datePicker
{
    
}

#pragma mark  tableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierStr = @"settingCell";
    
    DeviceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    
    if (!cell)
    {
        cell = [[DeviceSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierStr];
        cell.detailTextLabel.text = nil;
    }
    
    NSDictionary *dataDict = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [dataDict objectForKey:cellTextKey];
    cell.settingSwitch.hidden = ![[dataDict objectForKey:cellshowSwitchKey] boolValue];
    cell.settingSwitch.on = [[dataDict objectForKey:isCellSwitchOn] boolValue];
    cell.accessoryType = (UITableViewCellAccessoryType)[[dataDict objectForKey:cellAccessoryKey] intValue];
    cell.cusDetailLabel.text = (cell.settingSwitch.hidden == YES)?[dataDict objectForKey:cellDetailTextKey]:nil;
    cell.imageView.image = [UIImage imageNamed:[dataDict objectForKey:cellIconImageKey]];
    
    [cell.settingSwitch addValueChangedBlockAcion:^(UISwitch *_switch)
    {
        if (_switch.on == NO && self.safeProtectVM.isMotionDetectAbnormal)
        {
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_MotionDetection_OffTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
            } OKBlock:^{
                [self.safeProtectVM updateMoveDection:_switch.on];
                self.autoPhotoType = MotionDetectNever;
                /*
                if (_safeTableViewDelegate != nil && [_safeTableViewDelegate respondsToSelector:@selector(moveDectionChanged:repeatTime:begin:end:)])
                {
                    [_safeTableViewDelegate moveDectionChanged:_switch.on repeatTime:self.safeProtectVM.repeat begin:self.beginTime end:self.endTime];
                    
                }*/
                
            }];
            
        }
        else
        {
            [self.safeProtectVM updateMoveDection:_switch.on];
            
            /*if (_safeTableViewDelegate != nil && [_safeTableViewDelegate respondsToSelector:@selector(moveDectionChanged:repeatTime:begin:end:)])
            {
                [_safeTableViewDelegate moveDectionChanged:_switch.on repeatTime:self.safeProtectVM.repeat begin:self.beginTime end:self.endTime];
            }*/
        }
        
        
    }];
    
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.dataArray count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 1:
                {
                    [DJActionSheet showDJActionSheetWithTitle:[JfgLanguage getLanTextStrByKey:@"SECURE_SENSITIVITY"] buttonTitleArray:@[[JfgLanguage getLanTextStrByKey:@"SENSITIVI_LOW"], [JfgLanguage getLanTextStrByKey:@"SENSITIVI_STANDARD"], [JfgLanguage getLanTextStrByKey:@"SENSITIVI_HIGHT"]] actionType:actionTypeSelect defaultIndex:[[dataInfo objectForKey:cellHiddenText] intValue] didSelectedBlock:^(NSInteger index) {
                        
                        [self.safeProtectVM updateSensitive:index];
                    } didDismissBlock:^{
                        
                    }];
                    
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (self.pType == productType_FreeCam)
            {
                [self showDatePickerView:indexPath.row];
            }
        }
            break;
        case 2:
        {
            [self showDatePickerView:indexPath.row];
        }
            break;
        default:
            break;
    }
    
    if ([self.safeTableViewDelegate respondsToSelector:@selector(tableViewDidSelect:withData:)])
    {
        [self.safeTableViewDelegate tableViewDidSelect:indexPath withData:dataInfo];
    }
}

- (void)showDatePickerView:(NSInteger)row
{
    switch (row)
    {
        case 0:
        {
            CusDatePickerView *datePicker = [[CusDatePickerView alloc] initWitinitWithTitle:@"" OkButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"]];
            datePicker.datePicker.tag = pickerTag_beginTime;
            [datePicker setDate:[JfgTimeFormat formatTime:self.beginTime] animated:NO];
            datePicker.delegate = self;
            [datePicker show];
            
        }
            break;
        case 1:
        {
            CusDatePickerView *datePicker = [[CusDatePickerView alloc] initWitinitWithTitle:@"" OkButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"]];
            datePicker.datePicker.tag = pickerTag_endTime;
            [datePicker setDate:[JfgTimeFormat formatTime:self.endTime] animated:NO];
            datePicker.delegate = self;
            [datePicker show];
            
        }
            break;
        case 2:
        {
            
        }
            break;
            
        default:
            break;
    }
}

- (void)fetchDataArray:(NSArray *)fetchArray
{
    [self tableViewData:fetchArray];
    [self initBeginEndTime];
}

- (void)updatedDataArray:(NSArray *)updatedArray
{
    [self tableViewData:updatedArray];
    [self initBeginEndTime];
}


- (void)initBeginEndTime
{
    self.beginTime = self.safeProtectVM.beginTime;
    self.endTime = self.safeProtectVM.endTime;
}


@end
