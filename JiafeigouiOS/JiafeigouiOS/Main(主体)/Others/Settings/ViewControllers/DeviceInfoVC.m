//
//  DeviceInfoVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceInfoVC.h"
#import "JfgGlobal.h"
#import "DeviceInfoViewModel.h"
#import "SettingSearchVC.h"
#import "JfgTableViewCellKey.h"
#import "BaseTableViewCell.h"
#import "DeviceInfoFootView.h"
#import "SetDeviceNameVC.h"
#import "JfgConstKey.h"
#import "UpgradeDeviceVC.h"
#import "LSAlertView.h"
#import "JfgMsgDefine.h"
#import "MicroSDCardVC.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "CommonMethod.h"
#import "ProgressHUD.h"


@interface DeviceInfoVC()<tableViewDelegate, settingSearchVCDelegate,UIAlertViewDelegate>

@property (strong, nonatomic) UITableView *deviceInfoTableView;
/**
 *  数据 数组
 */
@property (strong ,nonatomic) NSMutableArray *dataArray;

/**
 *  ViewModel
 */
@property (strong, nonatomic) DeviceInfoViewModel *deviceInfoVM;

@end

@implementation DeviceInfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nickNameReset:) name:updateAliasNotification object:nil];
    [self initView];
    
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [LSAlertView disMiss];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
//    [self.deviceInfoVM removeDataPointReq];
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}
#pragma mark view
- (void)initNavigation
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_INFO"];
}

- (void)initView
{
    [self.view addSubview:self.deviceInfoTableView];
    
    [self initViewLayout];
    [self initNavigation];
}

- (void)initViewLayout
{
    [self.deviceInfoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(64.0f);
        make.left.equalTo(self.view).offset(0);
        make.right.equalTo(self.view).offset(0);
        make.bottom.equalTo(self.view).offset(0);
    }];
}

#pragma mark  数据获取 

-(void)updateData:(NSArray *)updateArray
{
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:updateArray];
    [self.deviceInfoTableView reloadData];
}

- (void)fetchDataArray:(NSArray *)fetchArray
{
    [self updateData:fetchArray];
}
- (void)updatedDataArray:(NSArray *)updatedArray
{
    [self updateData:updatedArray];
}
#pragma mark getter
- (UITableView *)deviceInfoTableView
{
    if (_deviceInfoTableView == nil)
    {
        _deviceInfoTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _deviceInfoTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _deviceInfoTableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _deviceInfoTableView.delegate = self;
        _deviceInfoTableView.dataSource = self;
    }
    return _deviceInfoTableView;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
        self.deviceInfoVM.alias = self.alis;
    }
    return _dataArray;
}

-(void)nickNameReset:(NSNotification *)notification
{
    NSString *nickName = notification.object;
    
    if (nickName != nil)
    {
        NSMutableDictionary *dataDict = [[self.dataArray objectAtIndex:0] objectAtIndex:0];
        [dataDict removeObjectForKey:cellDetailTextKey];
        [dataDict setObject:nickName forKey:cellDetailTextKey];
        [self.deviceInfoTableView reloadData];
    }
    
}

- (DeviceInfoViewModel *)deviceInfoVM
{
    if (_deviceInfoVM == nil)
    {
        _deviceInfoVM = [[DeviceInfoViewModel alloc] init];
        _deviceInfoVM.deviceInfoType = DeviceInfoTypeInfo;
        _deviceInfoVM.myDelegate = self;
        _deviceInfoVM.isShare = self.isShare;
        [_deviceInfoVM dataArrayFromViewModelWithProductType:self.pType Cid:self.cid];
    }
    
    return _deviceInfoVM;
}

#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
    
}


#pragma mark tableview dataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"deviceInfo";
    NSDictionary *dataDict = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    BaseTableViewCell *infoCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!infoCell)
    {
        infoCell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    
    NSString *cellText = [dataDict objectForKey:cellTextKey];
    NSString *cellDetailText = [dataDict objectForKey:cellDetailTextKey];
    NSNumber *cellAccessory = [dataDict objectForKey:cellAccessoryKey];
    UIColor *detailColor = [dataDict objectForKey:detailTextColorKey];
    
    if (![cellAccessory isKindOfClass:[NSNumber class]]) {
        cellAccessory = @0;
    }
    if (![cellText isKindOfClass:[NSString class]]) {
        cellText = @"";
    }
    if (![cellDetailText isKindOfClass:[NSString class]]) {
        cellDetailText = @"";
    }
    
    infoCell.textLabel.text = cellText;
    infoCell.detailTextLabel.text = cellDetailText;
    if (detailColor != nil)
    {
        infoCell.detailTextLabel.textColor = detailColor;
    }
    infoCell.accessoryType = (UITableViewCellAccessoryType)[cellAccessory intValue];
    infoCell.redDot.hidden = ![[dataDict objectForKey:cellRedDotInRight] boolValue];
    return infoCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr =[self.dataArray objectAtIndex:section];
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

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
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
    
    NSDictionary *dataDict = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    NSString *cellID = [dataDict objectForKey:cellUniqueID];
    
    if ([cellID isEqualToString:deviceName])
    {
        [self pushToSetDevNameVC:dataDict];
    }
    else if ([cellID isEqualToString:timeZone])
    {
        [self pushToTimeZoneSearchVC:dataDict];
    }
    else if ([cellID isEqualToString:devUpgrade])
    {
        [self pushToUpgradeVC];
    }
    
    /*
    switch (self.pType) {
        case productType_Mag:
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    SetDeviceNameVC *setDeviceName = [[SetDeviceNameVC alloc] init];
                    setDeviceName.deviceName = [dataDict objectForKey:cellDetailTextKey];
                    [self.navigationController pushViewController:setDeviceName animated:YES];
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
        case productType_DoorBell:
        case productType_CesBell:
        case productType_CesBell_V2:
        case productType_CatEye:
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    SetDeviceNameVC *setDeviceName = [[SetDeviceNameVC alloc] init];
                    setDeviceName.cid = self.cid;
                    setDeviceName.deviceName = [dataDict objectForKey:cellDetailTextKey];
                    [self.navigationController pushViewController:setDeviceName animated:YES];
                }
                    break;
                case 2:
                {
                    if (!self.isShare)
                    {
                        UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
                        upgradeDevice.cid = self.cid;
                        upgradeDevice.pType = self.pType;
                        [self.navigationController pushViewController:upgradeDevice animated:YES];
                    }
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case productType_720:
        case productType_720p:
        {
            switch (indexPath.section)
            {
                case 0:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            SetDeviceNameVC *setDeviceName = [[SetDeviceNameVC alloc] init];
                            setDeviceName.cid = self.deviceInfoVM.cid;
                            setDeviceName.deviceNameVCType =  DeviceNameVCTypeSelf;
                            setDeviceName.deviceName = [dataDict objectForKey:cellDetailTextKey];
                            [self.navigationController pushViewController:setDeviceName animated:YES];
                        }
                            break;
                        case 1:
                        {
                            
                        }
                        default:
                            break;
                    }
                }
                    break;
                case 1:
                {
                    int sdCardType = [[dataDict objectForKey:cellHiddenText] intValue];
                    // 未插卡 和 正常使用 不需要提示
                    
                    switch (sdCardType)
                    {
                        case SDCardType_Using:
                        {
                            MicroSDCardVC *microSDcard = [[MicroSDCardVC alloc] init];
                            microSDcard.cid = self.cid;
                            microSDcard.isShare = self.isShare;
                            microSDcard.pType = self.pType;
                            [self.navigationController pushViewController:microSDcard animated:YES];
                        }
                            break;
                        case SDCardType_Error:
                        {
                            if ([self.deviceInfoVM isClearingSDCard])
                            {
                                return;
                            }
                            //格式化sd卡wwwwwwww
                            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"SD_INIT"] CancelBlock:^{
                            } OKBlock:^{
                                [self.deviceInfoVM clearSDCard];
                            }];
                        }
                        default:
                            break;
                    }
                }
                    break;
                case 2:
                {
                    UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
                    upgradeDevice.cid = self.cid;
                    upgradeDevice.pType = self.pType;
                    [self.navigationController pushViewController:upgradeDevice animated:YES];
                }
                default:
                    break;
            }
        }
            break;
        default:
            switch (indexPath.section)
            {
                case 0:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            SetDeviceNameVC *setDeviceName = [[SetDeviceNameVC alloc] init];
                            setDeviceName.cid = self.deviceInfoVM.cid;
                            setDeviceName.deviceNameVCType =  DeviceNameVCTypeSelf;
                            setDeviceName.deviceName = [dataDict objectForKey:cellDetailTextKey];
                            [self.navigationController pushViewController:setDeviceName animated:YES];
                        }
                            break;
                        case 1:
                        {
                            
                        }
                        default:
                            break;
                    }
                }
                    break;
                case 1:
                {
                    switch (indexPath.row)
                    {
                        case 0:
                        {
                            if (self.isShare == NO)
                            {
                                SettingSearchVC * searchVC = [SettingSearchVC new];
                                searchVC.delegate  = self;
                                searchVC.cid = self.cid;
                                searchVC.oldZoneStr = [dataDict objectForKey:cellHiddenText];
                                [self.navigationController pushViewController:searchVC animated:YES];
                            }
                            
                        }
                            break;
                            
                        default:
                            break;
                    }
                }
                    break;
                case 2:{
                    if (self.isShare == NO)
                    {
                        int sdCardType = [[dataDict objectForKey:cellHiddenText] intValue];
                        // 未插卡 和 正常使用 不需要提示
                        
                        switch (sdCardType)
                        {
                            case SDCardType_Using:
                            {
                                MicroSDCardVC *microSDcard = [[MicroSDCardVC alloc] init];
                                microSDcard.cid = self.cid;
                                microSDcard.isShare = self.isShare;
                                microSDcard.pType = self.pType;
                                [self.navigationController pushViewController:microSDcard animated:YES];
                            }
                                break;
                            case SDCardType_Error:
                            {
                                if ([self.deviceInfoVM isClearingSDCard])
                                {
                                    return;
                                }
                                //格式化sd卡
                                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"SD_INIT"] CancelBlock:^{
                                } OKBlock:^{
                                    [self.deviceInfoVM clearSDCard];
                                }];
                            }
                            default:
                                break;
                        }
                    }
                }
                    break;
                case 3:
                {
                    if (![CommonMethod isPanoCameraWithType:self.pType] && self.pType != productType_RS_120 && self.pType != productType_RS_180) // 全景不升级
                    {
                        if (self.isShare == NO)
                        {
                            UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
                            upgradeDevice.cid = self.cid;
                            upgradeDevice.pType = self.pType;
                            [self.navigationController pushViewController:upgradeDevice animated:YES];
                        }
                    }
                    
                    
                }
                default:
                    break;
            }
            break;
    }
    */
}

#pragma mark 

- (void)pushToTimeZoneSearchVC:(NSDictionary *)dataDict
{
    SettingSearchVC * searchVC = [SettingSearchVC new];
    searchVC.delegate  = self;
    searchVC.cid = self.cid;
    searchVC.oldZoneStr = [dataDict objectForKey:cellHiddenText];
    [self.navigationController pushViewController:searchVC animated:YES];
}

//- (void)sdCardClear:(NSDictionary *)dataDict
//{
//    int sdCardType = [[dataDict objectForKey:cellHiddenText] intValue];
//    // 未插卡 和 正常使用 不需要提示
//    
//    switch (sdCardType)
//    {
//        case SDCardType_Using:
//        {
//            MicroSDCardVC *microSDcard = [[MicroSDCardVC alloc] init];
//            microSDcard.cid = self.cid;
//            microSDcard.isShare = self.isShare;
//            microSDcard.pType = self.pType;
//            [self.navigationController pushViewController:microSDcard animated:YES];
//        }
//            break;
//        case SDCardType_Error:
//        {
//            if ([self.deviceInfoVM isClearingSDCard])
//            {
//                return;
//            }
//            //格式化sd卡wwwwwwww
//            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"SD_INIT"] CancelBlock:^{
//            } OKBlock:^{
//                [self.deviceInfoVM clearSDCard];
//            }];
//        }
//        default:
//            break;
//    }
//}

- (void)pushToUpgradeVC
{
    if (self.isShare == NO)
    {
        UpgradeDeviceVC *upgradeDevice = [[UpgradeDeviceVC alloc] init];
        upgradeDevice.cid = self.cid;
        upgradeDevice.pType = self.pType;
        [self.navigationController pushViewController:upgradeDevice animated:YES];
    }
}


- (void)pushToSetDevNameVC:(NSDictionary *)dataDict
{
    SetDeviceNameVC *setDeviceName = [[SetDeviceNameVC alloc] init];
    setDeviceName.cid = self.deviceInfoVM.cid;
    setDeviceName.deviceNameVCType =  DeviceNameVCTypeSelf;
    setDeviceName.deviceName = [dataDict objectForKey:cellDetailTextKey];
    [self.navigationController pushViewController:setDeviceName animated:YES];
}

#pragma mark 更改时区
- (void)timeZoneChanged:(NSString *)zoneID timeZone:(int)timeZone
{
    [self.deviceInfoVM updateTimeZone:zoneID timeZone:timeZone];
}

-(void)dissmissProgressHUD
{
    int64_t delayInSeconds = 1.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [ProgressHUD dismiss];
        
    });
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.deviceInfoVM.myDelegate = nil;
    
}

@end
