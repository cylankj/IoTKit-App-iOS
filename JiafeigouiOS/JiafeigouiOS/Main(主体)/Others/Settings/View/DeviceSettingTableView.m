//
//  DeviceSettingTableView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/22.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceSettingTableView.h"
#import "DeviceSettingCell.h"
#import "JfgTableViewCellKey.h"
#import "DeviceInfoFootView.h"
#import "JfgGlobal.h"
#import "UISwitch+Clicked.h"
#import <JFGSDK/JFGSDK.h>
#import "ProgressHUD.h"
#import "LoginManager.h"
#import "CommonMethod.h"
#import "JfgConfig.h"
#import "JfgConstKey.h"
#import "JFGBoundDevicesMsg.h"

////设置门磁推送开关
//class MsgClientSetMagWarnReq:public MsgHeader{
//    
//public:
//    MSGPACK_DEFINE(mId, mCaller, mCallee,mSeq,warn);
//    MsgClientSetMagWarnReq() : MsgHeader(16920) {
//        
//    }
//    int warn;
//};

@interface DeviceSettingTableView()<UIAlertViewDelegate,JFGSDKCallbackDelegate>
{
    NSString *fileSize;
    int64_t rqed;
}
@property (strong, nonatomic) NSMutableArray *dataArray;


@end


@implementation DeviceSettingTableView

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


-(void)didMoveToSuperview
{
    [self initView];
    [JFGSDK addDelegate:self];
    rqed = 0;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark- 设置门磁 主动推送开关 状态
-(void)setMagWarn
{
   // BOOL currentStatue = [[NSUserDefaults standardUserDefaults] boolForKey:@"JFGMagWarnStatue"];
    
//    //服务器主动推送的
//    MsgClientSetMagWarnReq req1;
//    req1.mId = 16920;
//    req1.mCallee = [self.cid UTF8String];
//    req1.mCaller = "";
//    req1.warn = currentStatue?0:1;
    
   // std::string reqData1 = getBuff(req1);
   // NSData *data1 = [NSData dataWithBytes:reqData1.c_str() length:reqData1.length()];
   // [JFGSDK sendEfamilyMsgData:data1];
    
   // [ProgressHUD showProgress:nil];
}


-(void)jfgEfamilyMsg:(id)msg
{
    if ([msg isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = msg;
        if(sourceArr.count >=5){
            
            int msgid = [sourceArr[0] intValue];
            if (msgid == 16921) {
                
                int64_t _rqed = [sourceArr[3] longLongValue];
                if (rqed == _rqed) {
                    return;
                }
                rqed = _rqed;
                
                BOOL old = [[NSUserDefaults standardUserDefaults] boolForKey:@"JFGMagWarnStatue"];
                int error = [sourceArr[4] boolValue];
                
                if (error != 0) {
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"NO_NETWORK_4"]];
                }else{
                    //SCENE_SAVED
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"JFGMagWarnStatue"];
                    [[NSUserDefaults standardUserDefaults] setBool:!old forKey:@"JFGMagWarnStatue"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
               
                int64_t delayInSeconds = 1.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    
                    [ProgressHUD dismiss];
                    
                });
                
            }
            
        }
    }
}

#pragma mark  view

- (void)initView
{
    if(self.pType == productType_Mag || self.pType == productType_Mine)
    {
        self.tableFooterView = nil;
        
        if (self.pType == productType_Mine) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                NSInteger diskSize = [[SDImageCache sharedImageCache] getSize];
                NSString *cacheStr = [NSString stringWithFormat:@"%.1fM",diskSize/1024.0/1024.0];
                fileSize = cacheStr;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self reloadData];
                });
                
            });
        }
        
    }
    else
    {
        self.tableFooterView = self.footView;
    }
}

- (void)initViewLayout
{
    
}

-(void)refreshData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSInteger diskSize = [[SDImageCache sharedImageCache] getSize];
        NSString *cacheStr = [NSString stringWithFormat:@"%.1fM",diskSize/1024.0/1024.0];
        fileSize = cacheStr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadData];
        });
    });
    
    [self.deviceSettingVM updateSettingsWithType:self.pType cid:self.cid];
}

- (void)initData
{
    [self.deviceSettingVM dataArrayFromViewModelWithProductType:self.pType Cid:self.cid];
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


- (DeviceSettingViewModel *)deviceSettingVM
{
    if (_deviceSettingVM == nil)
    {
        _deviceSettingVM = [[DeviceSettingViewModel alloc] init];
        _deviceSettingVM.delegate = self;
        _deviceSettingVM.pType = self.pType;
        _deviceSettingVM.isShare = self.isShare;
        _deviceSettingVM.cid = self.cid;
        _deviceSettingVM.alias = self.alias;
    }
    
    return _deviceSettingVM;
}


- (settingFootView *)footView
{
    if (_footView == nil)
    {
        _footView = [[settingFootView alloc] initWithFrame:CGRectMake(-1, 0, Kwidth, 119.0f)]; // 设计 描边癖 像素+1
        [_footView.deleteButton addTarget:self action:@selector(deleteDevice) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return _footView;
}

-(void)deleteDevice
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess)
    {
        [CommonMethod showNetDisconnectAlert];
        return ;
    }
    
    NSString *message = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"SURE_DELETE_1"],self.cid];
    
    if (self.alias) {
        message = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"SURE_DELETE_1"],self.alias];
    }
    
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:message message:@"" delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"OK"], nil];
    alert.tag = 12352;
    [alert show];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 12352) {
        if (buttonIndex==1) {
            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
                [CommonMethod showNetDisconnectAlert];
                return;
            }
            [[JFGBoundDevicesMsg sharedDeciceMsg] addDelDeviceCid:self.cid];
            [ProgressHUD showProgress:nil];
            [JFGSDK unBindDev:self.cid];
        }
    }
}

#pragma mark- 解除绑定结果
-(void)jfgDeviceUnBind:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        
        [ProgressHUD dismiss];
        UIViewController *vc = [CommonMethod viewControllerForView:self];
        if (vc && vc.navigationController) {
            [vc.navigationController popToRootViewControllerAnimated:YES];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:deleteDeviceNotification object:self.cid];
        }
        [JFGSDK refreshDeviceList];
       
    }else{
        [[JFGBoundDevicesMsg sharedDeciceMsg] removeDelDeviceCid:self.cid];
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"NO_NETWORK_4"]];
    }
   
    
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

#pragma mark  delegate

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
    BOOL isShowSwitch = [[dataDict objectForKey:cellshowSwitchKey] boolValue];
    UIColor *detailTextColor = [dataDict objectForKey:detailTextColorKey];
    
    cell.cusLabel.text = [dataDict objectForKey:cellTextKey];
    
    cell.settingSwitch.hidden = !isShowSwitch;
    cell.canClickCell = [[dataDict objectForKey:canClickCellKey] boolValue];
    
    if (isShowSwitch == YES)
    {
        
        if (self.pType == productType_Mine) {
            BOOL isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"JFGAccountIsOpnePush"];
            UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
            if (UIUserNotificationTypeNone == setting.types) {
                isOpen = NO;
            }
            cell.settingSwitch.on = isOpen;
        }else{
            
            cell.settingSwitch.on = [[dataDict objectForKey:isCellSwitchOn] boolValue];
        }
        
       
        [cell.settingSwitch addValueChangedBlockAcion:^(UISwitch *_switch) {
            
            
            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess ) {
                [CommonMethod showNetDisconnectAlert];
                _switch.on = !_switch.on;
                return ;
            }
            if (self.pType == productType_Mag) {
                [self setMagWarn];
            }else{
               [self.deviceSettingVM updateDataWithIndexPath:indexPath changedValue:@(_switch.on)]; 
            }
            
        }];
    }
    
    if([dataDict objectForKey:cellAccessoryKey] == nil)
    {
        cell.accessoryType = (cell.settingSwitch.hidden == YES)?UITableViewCellAccessoryDisclosureIndicator:UITableViewCellAccessoryNone;
    }
    else
    {
        cell.accessoryType = (UITableViewCellAccessoryType)[[dataDict objectForKey:cellAccessoryKey] intValue];
    }
    
    if (detailTextColor != nil)
    {
        cell.cusDetailLabel.textColor = detailTextColor;
    }
    
    if (self.pType == productType_Mine && fileSize && indexPath.section==1 && indexPath.row == 0) {
        
        cell.cusDetailLabel.text = fileSize;
        
    }else{
        
        cell.cusDetailLabel.text = (cell.settingSwitch.hidden == YES)?[dataDict objectForKey:cellDetailTextKey]:nil;
    }
    
    cell.cusImageVIew.image = [UIImage imageNamed:[dataDict objectForKey:cellIconImageKey]];
    cell.redDot.hidden = ![[dataDict objectForKey:cellRedDotInRight] boolValue];
    [cell layoutAgain];//这里调用用来掉整下cell的布局,因为有些是没有图片的
    return cell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.dataArray objectAtIndex:section];
    return [arr count];
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
    CGFloat stanrdSpace = 20.0f;
    
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        CGSize labelSize = CGSizeOfString([dataInfo objectForKey:cellFootViewTextKey], CGSizeMake(footLabelWidth, kheight), [UIFont systemFontOfSize:14.0f]);
        return labelSize.height + stanrdSpace;
    }
    
    if (section == [self.dataArray count] - 1)
    {
        return stanrdSpace;
    }
    
    return 1.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        DeviceInfoFootView *footView =[[DeviceInfoFootView alloc] init];
        footView.footLabel.text = [dataInfo objectForKey:cellFootViewTextKey];
        footView.footLabel.font = [UIFont systemFontOfSize:12.0f];
        return footView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    
    if ([self.settingDelegate respondsToSelector:@selector(deviceSettingTableViewDidSelect:withData:)])
    {
        [self.settingDelegate deviceSettingTableViewDidSelect:indexPath withData:dataInfo];
    }
    
    if (self.pType == productType_Mine) {
        if (indexPath.section ==1 && indexPath.row == 0) {
            [self reloadData];
        }
    }
    
}

- (void)fetchDataArray:(NSArray *)fetchArray
{
    [self tableViewData:fetchArray];
}

- (void)updatedDataArray:(NSArray *)updatedArray
{
    [self tableViewData:updatedArray];
}

@end
