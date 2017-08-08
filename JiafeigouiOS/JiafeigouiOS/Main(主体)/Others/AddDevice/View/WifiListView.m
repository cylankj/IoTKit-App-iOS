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
#import <JFGSDK/JFGSDKBindingDevice.h>
#import <JFGSDK/JFGSDK.h>
#import "JfgLanguage.h"
#import "CommonMethod.h"
#import "jfgConfigManager.h"

void (^aSelectedBlock) (NSString *wifiNameString) =nil;

static WifiListView *wifi =nil;


#define GrayViewTag 888
#define WifiListTag 999
@interface WifiListView()<UITableViewDelegate,UITableViewDataSource,JFGSDKBindDeviceDelegate>
{
    UITableView * _wifiTableView;
}

@property (nonatomic, strong) JFGSDKBindingDevice *bindDeviceSDK;
@property (nonatomic, strong) NSMutableArray * wifiArray;

@end


@implementation WifiListView

-(instancetype)initWithFrame:(CGRect)frame
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
        
        [self.bindDeviceSDK scanWifi]; //扫描 wifi

        [JFGSDK appendStringToLogFile:@"startScanWifi"];
    }
    return self;
}

+(void)createWifiListView:(void (^)(NSString *))selectedBlock{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    WifiCoverView * grayView = [[WifiCoverView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
    grayView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    grayView.alpha = 0;
    grayView.tag = GrayViewTag;
    [window addSubview:grayView];
    WifiListView * list = [[WifiListView alloc]initWithFrame:CGRectMake(0, kheight, Kwidth, 244)];
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

- (void)updateWifiTableView:(NSString *)wifiName
{
    if (wifiName && ![self.wifiArray containsObject:wifiName])
    {
        [self.wifiArray addObject:wifiName];
        [_wifiTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.wifiArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
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
    cell.textLabel.text = [_wifiArray objectAtIndex:indexPath.row];

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
    NSString *wifiNameString =[_wifiArray objectAtIndex:indexPath.row];
    if (aSelectedBlock !=nil) {
        aSelectedBlock(wifiNameString);
        [self closeWifiListAction];
    }

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
//    if ([ask.ssid containsString:@"DOG"] ||[ask.ssid containsString:@"Dog"]) {
//        return;
//    }
    [self updateWifiTableView:ask.ssid];
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

@end
@implementation WifiCoverView

#pragma mark -touchesMethod
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    WifiListView * list = (WifiListView *)[window viewWithTag:WifiListTag];
    [list closeWifiListAction];
}
@end
