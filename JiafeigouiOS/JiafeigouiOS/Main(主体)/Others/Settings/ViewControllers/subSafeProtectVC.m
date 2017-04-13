//
//  subSafeProtectVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "subSafeProtectVC.h"
#import "subSafeProtectViewModel.h"
#import "JfgGlobal.h"
#import "DeviceSettingCell.h"
#import <AudioToolbox/AudioToolbox.h>
#import "JfgTableViewCellKey.h"
#import "HistoryDatePicker.h"

@interface subSafeProtectVC()<UITableViewDelegate, UITableViewDataSource, tableViewDelegate,HistoryDatePickerDelegate>

@property (nonatomic, strong) UITableView *subSafeTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) subSafeProtectViewModel *subSafeVM;

#pragma mark
#pragma mark  === 设备提示音 变量====
@property (assign, nonatomic) soundType voiceType;
@property (assign, nonatomic) int repeatTime;
@property (assign, nonatomic) SystemSoundID barkSound;
@property (assign, nonatomic) SystemSoundID warningSound;
#pragma mark
#pragma mark  === 重复 变量====
@property (assign, nonatomic) int repeatDate;

@end

@implementation subSafeProtectVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    [self initNavigation];
    [self initViewLayout];
    [self initData];
}

- (void)initView
{
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    [self.view addSubview:self.subSafeTableView];
}

- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    NSString *titleStr = @"";
    switch (self.protectType)
    {
        case SafeProtectTypeProtectTime:
            titleStr = [JfgLanguage getLanTextStrByKey:@"REPEAT"];
            break;
        case SafeProtectTypeDeviceVoice:
            titleStr = [JfgLanguage getLanTextStrByKey:@"SOUNDS"];
            break;
        default:
            break;
    }
    self.titleLabel.text = titleStr;
}

- (void)initViewLayout
{
    [self.subSafeTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
    }];
}

- (void)initData
{
    switch (self.protectType)
    {
        case SafeProtectTypeDeviceVoice:
        {
            self.voiceType = self.oldVoiceType;
            self.repeatTime = self.oldRepeatTime;
        }
            break;
        case  SafeProtectTypeProtectTime:
        {
            self.repeatDate = self.oldRepeatDate;
        }
            break;
        default:
            break;
    }
}

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
    
    switch (self.protectType)
    {
        case SafeProtectTypeDeviceVoice:
        {
            if (self.oldVoiceType != self.voiceType || self.repeatTime != self.oldRepeatTime)
            {
                if ([_myDelegate respondsToSelector:@selector(updateDeviceVoice:duration:)])
                {
                    [_myDelegate updateDeviceVoice:self.voiceType duration:self.repeatTime];
                }
            }
        }
            break;
        case SafeProtectTypeProtectTime:
        {
            if (self.oldRepeatDate != self.repeatDate)
            {
                if ([_myDelegate respondsToSelector:@selector(updateRepeatDate:)])
                {
                    [_myDelegate updateRepeatDate:self.repeatDate];
                }
            }
        }
            break;
        default:
            break;
    }
    
}

- (void)updateArray:(NSArray *)updateArray
{
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:updateArray];
    [self.subSafeTableView reloadData];
}

- (void)playSystemSound:(NSIndexPath *)indexPath
{
    switch (indexPath.row)
    {
        case 1:
        {
            AudioServicesPlaySystemSound(self.barkSound);
        }
            break;
        case 2:
        {
            AudioServicesPlaySystemSound(self.warningSound);
        }
            break;
        default:
            break;
    }
}

#pragma mark
#pragma mark  === VM Delegate ===
- (void)updatedDataArray:(NSArray *)updatedArray
{
    [self updateArray:updatedArray];
}


#pragma mark
#pragma mark  === tableView Delegate ===
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
    switch (self.protectType)
    {
        case SafeProtectTypeDeviceVoice:
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    [self playSystemSound:indexPath];
                    
                    if (self.voiceType == 0 && indexPath.row != 0) {
                        self.repeatTime = 1;
                    }
                    if (indexPath.row == 0 && self.voiceType !=0) {
                        self.repeatTime = 0;
                    }
                    
                    self.voiceType = (soundType)indexPath.row;
                }
                    break;
                case 1:
                {
                    //self.repeatTime = 0;
                    [self showSelectedPicker];
                }
                    break;
                default:
                    break;
            }
            
            [self.subSafeVM updatevoiceType:self.voiceType time:self.repeatTime];
        }
            break;
        case SafeProtectTypeProtectTime:
        {
            self.repeatDate = [self.subSafeVM updateDayChecked:indexPath];
        }
            break;
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

-(void)showSelectedPicker
{
    HistoryDatePicker *picker = [HistoryDatePicker historyDatePicker];
    NSMutableArray *dateList = [[NSMutableArray alloc]init];
    
    for (int i=1; i<16; i++) {
        [dateList addObject:[NSString stringWithFormat:@"%ds",i]];
    }
    picker.title = @"";
    picker.dataArray = (NSMutableArray *)[NSArray arrayWithObject:dateList];
    picker.delegate = self;
    [picker show];
}

//取消
-(void)cancel
{
    
}

//选择
-(void)didSelectedItem:(NSString *)item indexPath:(NSIndexPath *)indexPath
{
    self.repeatTime = indexPath.row+1;
    [self.subSafeVM updatevoiceType:self.voiceType time:self.repeatTime];
}

#pragma mark- pickerDelegate

#pragma mark
#pragma mark  === property ===
- (SystemSoundID)barkSound
{
    if (_barkSound == 0)
    {
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jfg_1" ofType:@"mp3"] isDirectory:NO], &_barkSound);
        if (error != kAudioServicesNoError) {
            JFGLog(@"error:汪汪 jfg-1.mp3");
        }
        
    }
    
    return _barkSound;
}

- (SystemSoundID)warningSound
{
    if (_warningSound == 0)
    {
        OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"jfg_2" ofType:@"wav"] isDirectory:NO], &_warningSound);
        if (error != kAudioServicesNoError) {
            JFGLog(@"error:警报 jfg-2.wav");
        }
    }
    
    return _warningSound;
}

- (UITableView *)subSafeTableView
{
    if (_subSafeTableView == nil)
    {
        _subSafeTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _subSafeTableView.delegate = self;
        _subSafeTableView.dataSource = self;
    }
    return _subSafeTableView;
}

- (subSafeProtectViewModel *)subSafeVM
{
    if (_subSafeVM == nil)
    {
        _subSafeVM = [[subSafeProtectViewModel alloc] init];
        _subSafeVM.myDelegate = self;
        _subSafeVM.cid = self.cid;
        _subSafeVM.safeProtectType = self.protectType;
        if (self.protectType == SafeProtectTypeDeviceVoice)
        {
            [_subSafeVM initDataWithSelected:self.oldVoiceType time:self.oldRepeatTime];
        }
        else
        {
            [_subSafeVM initRepeatModel:self.oldRepeatDate];
        }
        
    }
    return _subSafeVM;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithArray:[self.subSafeVM requestData]];
    }
    return _dataArray;
}

@end
