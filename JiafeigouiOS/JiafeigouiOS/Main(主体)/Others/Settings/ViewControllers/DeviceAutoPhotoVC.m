//
//  DeviceAutoPhotoVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceAutoPhotoVC.h"
#import "BaseTableView.h"
#import "BaseTableViewCell.h"
#import "JfgTableViewCellKey.h"
#import "DeviceInfoViewModel.h"
#import "JfgMsgDefine.h"
#import "DeviceInfoFootView.h"
#import "LSAlertView.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "JFGDataPointValueAnalysis.h"
#import "JfgUserDefaultKey.h"
#import "ProgressHUD.h"

@interface DeviceAutoPhotoVC()<UIAlertViewDelegate>
{
    BOOL isHasSDCard;
    NSInteger sdCardErrorCode;
    BOOL isOpenWarn;
}
@property (strong, nonatomic) BaseTableView *autoPhotoTableView;
@property (strong, nonatomic) NSMutableArray *dataArray;
@property (assign, nonatomic) NSInteger selectedIndex;

@end

@implementation DeviceAutoPhotoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initNavigation];
    [self initView];
    [self initViewLayout];
    isHasSDCard = YES;
    isOpenWarn = YES;
    sdCardErrorCode = 0;
    self.selectedIndex = self.oldselectedIndex;
    [self getSDCard];
    [self warnSensitivity];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:isShowAutoPhotoRedDot(self.cid)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)getSDCard
{
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@(204)] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                JFGDeviceSDCardInfo *sdInfo = [JFGDataPointValueAnalysis dpFor204Msg:seg];
                isHasSDCard = sdInfo.isHaveCard;
                sdCardErrorCode = sdInfo.errorCode;
                if (!sdInfo.isHaveCard)
                {
                    self.selectedIndex = MotionDetectNone;
                }
                else if (sdInfo.errorCode != 0) {
                    self.selectedIndex = MotionDetectNever;
                }
                [self.autoPhotoTableView reloadData];
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}

#pragma mark- 获取安全防护数据
-(void)warnSensitivity
{
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@(dpMsgCamera_WarnEnable)] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                if (seg.msgId == dpMsgCamera_WarnEnable) {
                    //是否开启报警
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    if (obj && [obj isKindOfClass:[NSNumber class]]) {
                        if ([obj boolValue]) {
                            isOpenWarn = YES;
                        }else{
                            isOpenWarn = NO;
                        }
                        
                    }else{
                        isOpenWarn = YES;
                    }
                    
                    if (!isHasSDCard)
                    {
                        self.selectedIndex = MotionDetectNone;
                    }
                    else if (sdCardErrorCode !=0) {
                        self.selectedIndex = MotionDetectNever;
                    }
                    
                    [self.autoPhotoTableView reloadData];
                }
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}

#pragma mark view
- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SETTING_RECORD"];
}

- (void)initView
{
    [self.view addSubview:self.autoPhotoTableView];
}

- (void)initViewLayout
{
    [self.autoPhotoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
    }];
}

#pragma mark data

#pragma mark getter
- (BaseTableView *)autoPhotoTableView
{
    if (_autoPhotoTableView == nil)
    {
        _autoPhotoTableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _autoPhotoTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _autoPhotoTableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _autoPhotoTableView.delegate = self;
        _autoPhotoTableView.dataSource = self;
    }
    
    return _autoPhotoTableView;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
        
        DeviceInfoViewModel *deviceInfo = [[DeviceInfoViewModel alloc] init];
        deviceInfo.deviceInfoType = DeviceInfoTypeAutoPhoto;
        [_dataArray addObjectsFromArray:[deviceInfo dataArrayFromViewModelWithProductType:self.pType Cid:self.cid]];
    }
    
    return _dataArray;
}

#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    if (self.selectedIndex != self.oldselectedIndex && isHasSDCard)
    {
        if ([_delegate respondsToSelector:@selector(updateMotionDetection:)])
        {
            [_delegate updateMotionDetection:self.selectedIndex];
        }
        if ([_delegate respondsToSelector:@selector(updateWarnEnable:)])
        {
            [_delegate updateWarnEnable:isOpenWarn];
        }
    }
    [super leftButtonAction:sender];
}

#pragma mark tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"deviceAutoPhoto";
    
    NSDictionary *dataDict = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    BaseTableViewCell *autoPhotocell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!autoPhotocell)
    {
        autoPhotocell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    autoPhotocell.accessoryType = UITableViewCellAccessoryNone;
    
    autoPhotocell.textLabel.text = [dataDict objectForKey:cellTextKey];
    autoPhotocell.detailTextLabel.text = [dataDict objectForKey:cellDetailTextKey];
    
    
    switch (self.pType)
    {
        case productType_FreeCam:
        {
            switch (indexPath.section)
            {
                case 1:
                {
                    if (self.selectedIndex == MotionDetectNever)
                    {
                        autoPhotocell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                }
                    break;
                default:
                {
                    if (indexPath.section == self.selectedIndex)
                    {
                        autoPhotocell.accessoryType = UITableViewCellAccessoryCheckmark;
                    }
                }
                    break;
            }
            
        }
            break;
            
        default:
        {
            if (indexPath.section == self.selectedIndex)
            {
                autoPhotocell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
    }
    
    
    
    
    return autoPhotocell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.dataArray objectAtIndex:section];
    return [arr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        CGSize labelSize = CGSizeOfString([dataInfo objectForKey:cellFootViewTextKey], CGSizeMake(footLabelWidth, kheight), [UIFont systemFontOfSize:14.0f]);
        return labelSize.height + 8;
    }
    return 1.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        DeviceInfoFootView *footView =[[DeviceInfoFootView alloc] init];
        footView.footLabel.text = [dataInfo objectForKey:cellFootViewTextKey];
        return footView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (!isHasSDCard)
    {
        //没有sd卡
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"NO_SDCARD"]];
    }else if (sdCardErrorCode !=0)
    {
        //sd卡需要格式化
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"]];
    }
    else if (isOpenWarn == NO && indexPath.section == 0)
    {
        //没有开启移动侦测
        
        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"RECORD_ALARM_OPEN"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OPEN"] CancelBlock:^{
            
        } OKBlock:^{
            DataPointSeg *seg = [[DataPointSeg alloc]init];
            seg.version = 0;
            seg.msgId = dpMsgCamera_WarnEnable;
            seg.value =[MPMessagePackWriter writeObject:[NSNumber numberWithBool:YES] error:nil];
            
            [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.cid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
                isOpenWarn = YES;
                self.selectedIndex = MotionDetectAbnormal;
                [self.autoPhotoTableView reloadData];
                [JFGSDK refreshDeviceList];
            } failure:^(RobotDataRequestErrorType type) {
                isOpenWarn = NO;
            }];
            
        }];
        
    }else
    {
        [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:self.selectedIndex]].accessoryType = UITableViewCellAccessoryNone;
        
        if (self.pType == productType_FreeCam)
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    self.selectedIndex = MotionDetectAbnormal;
                }
                    break;
                case 1:
                {
                    self.selectedIndex = MotionDetectNever;
                }
                    break;
                default:
                    break;
            }
        }
        else
        {
            self.selectedIndex = indexPath.section;
        }
        
        
        [tableView reloadData];
    }   
}

@end
