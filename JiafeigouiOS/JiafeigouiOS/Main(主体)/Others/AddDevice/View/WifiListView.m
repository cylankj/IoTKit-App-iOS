//
//  WifiListView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "WifiListView.h"
#import "FLGlobal.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "JFGDevTypeManager.h"
#import <JFGSDK/JFGSDK.h>
#import "JfgLanguage.h"
#import "CommonMethod.h"
#import "jfgConfigManager.h"
#import "JFGBoundDevicesMsg.h"

void (^aSelectedBlock) (id obj) =nil;

static WifiListView *wifi =nil;


#define GrayViewTag 888
#define WifiListTag 999
@interface WifiListView()<UITableViewDelegate,UITableViewDataSource,JFGSDKBindDeviceDelegate,JFGSDKCallbackDelegate>
{
    UITableView * _wifiTableView;
}

@property (nonatomic, strong) JFGSDKBindingDevice *bindDeviceSDK;
@property (nonatomic, strong) NSMutableArray * wifiArray;
@property (nonatomic, strong) NSMutableArray <NSString *>*bindedDevList;

@end


@implementation WifiListView

-(instancetype)initWithFrame:(CGRect)frame withType:(WifiListType)type
{
    if (self = [super initWithFrame:frame])
    {
        _wifiTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height) style:UITableViewStylePlain];
        _wifiTableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _wifiTableView.delegate = self;
        _wifiTableView.dataSource = self;
        _wifiTableView.backgroundColor = [UIColor colorWithHexString:@"#fafafa"];
        //_wifiTableView.showsVerticalScrollIndicator = NO;
        _wifiTableView.showsHorizontalScrollIndicator = NO;
        [self addSubview:_wifiTableView];
        self.listType = type;
        
        if (type == WifiListTypeWifiName) {
            [self.bindDeviceSDK scanWifi]; //扫描 wifi
        }else{
            [JFGSDK addDelegate:self];
            //fping获取设备信息
            [JFGSDK fping:@"255.255.255.255"];
            [JFGSDK fping:@"192.168.10.255"];
        }
        [JFGSDK appendStringToLogFile:@"startScanWifi"];
    }
    return self;
}

+(void)createWifiListViewForType:(WifiListType)type commplete:(void (^) (id obj))selectedBlock{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    WifiCoverView * grayView = [[WifiCoverView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
    grayView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    grayView.alpha = 0;
    grayView.tag = GrayViewTag;
    [window addSubview:grayView];
    WifiListView * list = [[WifiListView alloc]initWithFrame:CGRectMake(0, kheight, Kwidth, 244) withType:type];
    list.tag = WifiListTag;
    [window addSubview:list];
    
    
    [UIView animateWithDuration:0.35f animations:^{
        grayView.alpha = 0.6;
        [list setFrame:CGRectMake(0, kheight-244, Kwidth, 244)];
    }];
    aSelectedBlock =[selectedBlock copy];
}


-(void)closeWifiListAction
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    UIView * grayView = [window viewWithTag:GrayViewTag];

    [UIView animateWithDuration:0.35f animations:^{
        grayView.alpha = 0;
        [self setFrame:CGRectMake(0, kheight, Kwidth, 244)];
    } completion:^(BOOL finished) {
        [grayView removeFromSuperview];
        _wifiTableView.delegate = nil;
        _wifiTableView.dataSource = nil;
        [self removeFromSuperview];
        [self.wifiArray removeAllObjects];
    }];
    aSelectedBlock = nil;
}

#pragma mark JFG SDK Delegate
-(void)jfgScanWifiRespose:(JFGSDKUDPResposeScanWifi *)ask
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"scanWifiRsp:%@",ask.ssid]];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSArray *aps = [infoDictionary objectForKey:@"Jfgsdk_ap_prefix"];
    if ([aps isKindOfClass:[NSArray class]]) {
        for (NSString *ap in aps) {
            if ([ap isKindOfClass:[NSString class]]) {
                if ([[ask.ssid lowercaseString] hasPrefix:[ap lowercaseString]]) {
                    return;
                }
            }
        }
    }
    [self updateWifiTableView:ask];
}

-(void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    [self updateWifiTableView:ask];
}

- (void)updateWifiTableView:(id)obj
{
    if (obj)
    {
        if ([obj isKindOfClass:[JFGSDKUDPResposeFping class]]) {
            
            BOOL isExist = NO;
            JFGSDKUDPResposeFping *fp = obj;
            NSLog(@"fping:cid:%@ os:%d",fp.cid,fp.os);
            for (JFGSDKUDPResposeFping *_fp in self.wifiArray) {
                
                if ([_fp.cid isEqualToString:fp.cid]) {
                    isExist = YES;
                    break;
                }
            }
            
            //屏蔽已绑定设备
            for (NSString *bindedCid in self.bindedDevList) {
                
                if ([bindedCid isEqualToString:fp.cid]) {
                    isExist = YES;
                    break;
                }
                
            }

            //只支持有线绑定设备
            if (!isExist && [JFGDevTypeManager devIsType:JFGDevFctTypeWired forPid:fp.os]) {
                 [self.wifiArray addObject:fp];
            }
            
            
        }else if ([obj isKindOfClass:[JFGSDKUDPResposeScanWifi class]]){
            
            BOOL isExist = NO;
            JFGSDKUDPResposeScanWifi *wifi = obj;
            for (JFGSDKUDPResposeScanWifi *_wifi in self.wifiArray) {
                
                if ([_wifi.ssid isEqualToString:wifi.ssid]) {
                    isExist = YES;
                    break;
                }
            }
            if (!isExist) {
                [self.wifiArray addObject:wifi];
            }
            
        }
       
        [_wifiTableView reloadData];
    }
    
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _wifiArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString * cell0 = @"cell0";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cell0];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell0];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CellSelectedColor;
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    
    id obj = [_wifiArray objectAtIndex:indexPath.row];
    NSString *wifiName = @"";
    if ([obj isKindOfClass:[JFGSDKUDPResposeScanWifi class]]) {
        JFGSDKUDPResposeScanWifi *wifi = obj;
        wifiName = wifi.ssid;
    }else if ([obj isKindOfClass:[JFGSDKUDPResposeFping class]]){
        JFGSDKUDPResposeFping *fp = obj;
        wifiName = fp.cid;
    }
    cell.textLabel.text = wifiName;

    return cell;
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44.0;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50.0;
}



-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, 44)];
    vi.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    UILabel * header = [[UILabel alloc]initWithFrame:CGRectMake(0, (44-16)/2, Kwidth, 16)];
    header.font = [UIFont systemFontOfSize:16];
    header.textAlignment = NSTextAlignmentCenter;
    header.textColor = [UIColor colorWithHexString:@"#888888"];
    header.text = [JfgLanguage getLanTextStrByKey:@"CHOOSE_WIFI"];
    
    if (self.listType == WifiListTypeCid) {
        header.text = [JfgLanguage getLanTextStrByKey:@"WIRED_SELECT_DEVICE_CID"];
    }
    
    [vi addSubview:header];
    UIButton * closeBtn = [[UIButton alloc]initWithFrame:CGRectMake(vi.right-6-30, 7, 30, 30)];
    [closeBtn setImage:[UIImage imageNamed:@"add_btn_wifiList_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeWifiListAction) forControlEvents:UIControlEventTouchUpInside];
    [vi addSubview:closeBtn];
    UILabel * line = [[UILabel alloc]initWithFrame:CGRectMake(0, 43.5, Kwidth, 0.5)];
    line.backgroundColor = [UIColor colorWithHexString:@"#d9d9d9"];
    [vi addSubview:line];
    return vi;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    JFGSDKUDPResposeScanWifi *wifiNameString =[_wifiArray objectAtIndex:indexPath.row];
    if (aSelectedBlock !=nil) {
        aSelectedBlock(wifiNameString);
        [self closeWifiListAction];
    }

}


#pragma mark property

- (JFGSDKBindingDevice *)bindDeviceSDK
{
    if (_bindDeviceSDK == nil)
    {
        _bindDeviceSDK = [[JFGSDKBindingDevice alloc] init];
        _bindDeviceSDK.delegate = self;
    }
    return _bindDeviceSDK;
}

- (NSMutableArray *)wifiArray
{
    if (_wifiArray == nil)
    {
        _wifiArray = [NSMutableArray array];
    }
    return _wifiArray;
}

-(NSMutableArray *)bindedDevList
{
    if (!_bindedDevList) {
        _bindedDevList = [NSMutableArray new];
        NSMutableArray *devModels = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
        for (JiafeigouDevStatuModel *model in devModels) {
            [_bindedDevList addObject:model.uuid];
        }
    }
    return _bindedDevList;
}

@end

@implementation WifiCoverView

#pragma mark -touchesMethod
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    WifiListView * list = (WifiListView *)[window viewWithTag:WifiListTag];
    [list closeWifiListAction];
}
@end
