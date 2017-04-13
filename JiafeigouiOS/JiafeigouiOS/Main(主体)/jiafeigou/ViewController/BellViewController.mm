//
//  BellViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BellViewController.h"
#import "FLGlobal.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "DelButton.h"
#import "JfgLanguage.h"
#import "UILabel+FLExtension.h"
#import "UIButton+FLExtentsion.h"
#import "UIAlertView+FLExtension.h"
#import "DeviceSettingVC.h"
#import "doorBellTableView.h"
#import "DoorBellCell.h"
#import "DelButton.h"
#import "JfgConfig.h"
#import <Masonry.h>
#import "BellModel.h"
#import "JFGPicAlertView.h"
#import "PopAnimation.h"
#import "NetworkMonitor.h"
#import "DoorVideoVC.h"
#import "dataPointMsg.h"
#import "FLRefreshHeader.h"
#import "JfgMsgDefine.h"
#import <JFGSDK/JFGSDKDataPointModel.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/MPMessagePackReader.h>
#import "JfgTimeFormat.h"
#import <JFGSDK/JFGSDK.h>
#import <AVFoundation/AVFoundation.h>
#import "OemManager.h"
#import <UIImageView+WebCache.h>
#import "UIImageView+JFGImageView.h"
#import "ImageBrowser.h"
#import "CommonMethod.h"
#import "JfgCacheManager.h"
#import "JfgUserDefaultKey.h"
#import "LoginManager.h"
#import "JFGBoundDevicesMsg.h"

#define Edit_CancelBtnTag 233
#define Edit_SelAllBtnTag 234
#define Edit_DelBtnTag 235

#define LastIntoVCTime @"DoorBellLastIntoVcTime"

@interface BellViewController ()<UITableViewDelegate,UITableViewDataSource,doorBellTableViewDelegate,NetworkMonitorDelegate,JFGSDKCallbackDelegate,DoorBellCellTapDelegate>
{
    CGFloat topHeight;
    BOOL isEnableRefresh;
}
@property (strong, nonatomic) UILabel * titleLabel;
@property (strong, nonatomic) DelButton * exitBtn;
@property (strong, nonatomic) UIButton * settingBtn;
@property (strong, nonatomic) UIImageView * bgImageView;
@property (strong, nonatomic) UIImageView * bellImageView;
@property (strong, nonatomic) UIImageView * noNetImageView;
@property (strong, nonatomic) UILabel * refreshLabel;
@property (strong, nonatomic) UIImageView * loadingImageView;
@property (strong, nonatomic) UIButton * seeButton;
@property (strong, nonatomic) doorBellTableView * bellTableView;
@property (strong, nonatomic) UIView * editToolView;
@property (strong, nonatomic) UIView * noDataView;
@property (strong, nonatomic) FLRefreshHeader * refreshView;
@property (strong, nonatomic) AVAudioPlayer *avAudioPlayer;

@end

@implementation BellViewController




- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f9f9f9"];
    //self.view.backgroundColor = [UIColor redColor];
    topHeight = 270 * designHscale;
    
    [self initView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clearDoorBell) name:@"JFGClearDoorBellSuccess" object:nil];
    [JFGSDK addDelegate:self];
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delDeviceNotification:) name:JFGDeviceDelByOtherClientNotification object:nil];
    //[self setupPullToRefresh];
    
    NSArray *arr = [JfgCacheManager getDoorbellCallRecordWithCid:self.cid];
    if (arr) {
        self.bellTableView.tableModelArray = [[NSMutableArray alloc]initWithArray:arr];
        [self judgeHaveData];
    }else{
        self.bellTableView.tableModelArray= [NSMutableArray new];
    }
    

    [[dataPointMsg shared] packSingleDataPointMsg:@[@(dpMsgBase_Battery)] withCid:self.cid SuccessBlock:^(NSMutableDictionary *dic)
     {

     } FailBlock:^(RobotDataRequestErrorType error){
         
     }];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isEnableRefresh = YES;
    [[NetworkMonitor sharedManager]addDelegate:self];
    
    if ([NetworkMonitor sharedManager].currentNetworkStatu == NotReachable ) {
        [self noNet];
    }else{
        
        if (self.state == BellStateOffline) {
            [self offline];
        }else{
            [self online];
        }
        
        //[self offline];]
    }
}

-(void)delDeviceNotification:(NSNotification *)notification
{
    
}

-(void)clearDoorBell
{
    [self.bellTableView.tableModelArray removeAllObjects];
    [self.bellTableView reloadData];
}


-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //在tableview添加后才能用这个
    //self.bellTableView.tableModelArray = [NSMutableArray array];
    [self initData];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGClearUnReadCount" object:self.cid];
    
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NetworkMonitor sharedManager]removeDelegate:self];
    [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:LastIntoVCTime];
    [JfgCacheManager cacheDoorbellCallRecordMsgList:self.bellTableView.tableModelArray forCid:self.cid];
    if (self.navigationController.viewControllers.count <=2 ) {
        [JFGSDK removeDelegate:self];
    }
    
}
-(void)initData
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        return;
    }
    DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
    seg.msgId = dpMsgBell_callMsg;
    
    DataPointIDVerSeg * seg2 = [[DataPointIDVerSeg alloc]init];
    seg2.msgId = dpMsgBell_callMsgV3;
    
    [[dataPointMsg shared] packMutableDataPointMsg:@[seg,seg2] withCid:self.cid isAsc:NO countLimit:100 SuccessArrBlock:^(NSMutableArray *arr) {
        if (arr.count > 0)
        {
            [self.bellTableView.tableModelArray removeAllObjects];
            for (NSArray * msgArr in arr) {
                for (NSDictionary * dic in msgArr) {
                    NSArray * vauleArr = [dic objectForKey:dpValueKey];
                    int64_t msgID = [[dic objectForKey:dpIdKey] longLongValue];
                    
                    BellModel * bell = [[BellModel alloc]init];
                    bell.version = [dic objectForKey:dpTimeKey];//服务器的时间
                    bell.isSelected = NO;
                    bell.isAnswered = [[vauleArr objectAtIndex:0] boolValue];
                    bell.bellDate = [JfgTimeFormat transToDate:[[vauleArr objectAtIndex:1] stringValue]];
                    bell.bellTime = [JfgTimeFormat transToHHmm2:[[vauleArr objectAtIndex:1] stringValue]];
                    
                    if (msgID == dpMsgBell_callMsgV3) {
                        bell.deviceVersion = 3;
                    }
                    
                    if (vauleArr.count>3) {
                        NSInteger flag = [[vauleArr objectAtIndex:3] integerValue];
                        bell.flag = (int)flag;
                        long long timestamp = [[vauleArr objectAtIndex:1] longLongValue];
                        bell.timestamp = timestamp;
                        NSString *headUrl2 = [JFGSDK getCloudUrlWithFlag:(int)flag fileName:[NSString stringWithFormat:@"/%@/%lld.jpg",self.cid,timestamp]];
                        ///cid/[vid]/[cid]/[timestamp]_[id].jpg
                        if (bell.deviceVersion == 3) {
                            headUrl2 = [JFGSDK getCloudUrlWithFlag:(int)flag fileName:[NSString stringWithFormat:@"/cid/%@/%@/%lld.jpg",[OemManager getOemVid],self.cid,timestamp]];
                        }
                        
                        ///[cid]/[timestamp].jpg
                        //NSString *headUrl2 = [JFGSDK getCloudUrlByType:JFGSDKGetCloudUrlTypeWarning flag:flag fileName:[NSString stringWithFormat:@"%lld.jpg",timestamp] cid:self.cid];
                        
                        bell.fileName = [NSString stringWithFormat:@"%lld.jpg",timestamp];
                        bell.headUrl = headUrl2;
                    }else{
                        bell.headUrl = nil;
                    }
                
                    [self.bellTableView.tableModelArray addObject:bell];
                }
            }
            
            if (self.bellTableView.tableModelArray.count >= 100) {
                BellModel * bell = [self.bellTableView.tableModelArray lastObject];
                [self getMoreMessageForTime:[bell.version longLongValue]];
            }
            
            [self judgeHaveData];
            [self.refreshView endRefresh];
            [self clearUnReadCount];
        }
    } FailBlock:^(RobotDataRequestErrorType error) {
        NSLog(@"门铃记录获取失败：%ld",(long)error);
        [self.refreshView endRefresh];
    }];
}


-(void)getMoreMessageForTime:(uint64_t)time
{
    DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
    seg.msgId = dpMsgBell_callMsg;
    seg.version = time;
    
    DataPointIDVerSeg * seg2 = [[DataPointIDVerSeg alloc]init];
    seg2.msgId = dpMsgBell_callMsgV3;
    seg2.version = time;
    
    [[dataPointMsg shared] packMutableDataPointMsg:@[seg,seg2] withCid:self.cid isAsc:NO countLimit:100 SuccessArrBlock:^(NSMutableArray *arr) {
        
        if (arr.count > 0)
        {

            for (NSArray * msgArr in arr) {
                for (NSDictionary * dic in msgArr) {
                    NSArray * vauleArr = [dic objectForKey:dpValueKey];
                    int64_t msgID = [[dic objectForKey:dpIdKey] longLongValue];
                    
                    BellModel * bell = [[BellModel alloc]init];
                    bell.version = [dic objectForKey:dpTimeKey];//服务器的时间
                    bell.isSelected = NO;
                    bell.isAnswered = [[vauleArr objectAtIndex:0] boolValue];
                    bell.bellDate = [JfgTimeFormat transToDate:[[vauleArr objectAtIndex:1] stringValue]];
                    bell.bellTime = [JfgTimeFormat transToHHmm2:[[vauleArr objectAtIndex:1] stringValue]];
                    
                    if (msgID == dpMsgBell_callMsgV3) {
                        bell.deviceVersion = 3;
                    }
                    
                    if (vauleArr.count>3) {
                        NSInteger flag = [[vauleArr objectAtIndex:3] integerValue];
                        bell.flag = (int)flag;
                        long long timestamp = [[vauleArr objectAtIndex:1] longLongValue];
                        bell.timestamp = timestamp;
                        NSString *headUrl2 = [JFGSDK getCloudUrlWithFlag:(int)flag fileName:[NSString stringWithFormat:@"/%@/%lld.jpg",self.cid,timestamp]];
                        ///cid/[vid]/[cid]/[timestamp]_[id].jpg
                        if (bell.deviceVersion == 3) {
                            headUrl2 = [JFGSDK getCloudUrlWithFlag:(int)flag fileName:[NSString stringWithFormat:@"/cid/%@/%@/%lld.jpg",company_vid,self.cid,timestamp]];
                        }
                        
                        ///[cid]/[timestamp].jpg
                        //NSString *headUrl2 = [JFGSDK getCloudUrlByType:JFGSDKGetCloudUrlTypeWarning flag:flag fileName:[NSString stringWithFormat:@"%lld.jpg",timestamp] cid:self.cid];
                        
                        bell.fileName = [NSString stringWithFormat:@"%lld.jpg",timestamp];
                        bell.headUrl = headUrl2;
                    }else{
                        bell.headUrl = nil;
                    }
                    
                    [self.bellTableView.tableModelArray addObject:bell];
                }
            }
            
            [self judgeHaveData];
            [self.refreshView endRefresh];
            [self clearUnReadCount];
        }
        
    } FailBlock:^(RobotDataRequestErrorType error) {
        NSLog(@"门铃记录获取失败：%ld",(long)error);
        [self.refreshView endRefresh];
    }];
}

//清空未接听呼叫记录
-(void)clearUnReadCount
{
    [[JFGSDKDataPoint sharedClient] robotCountDataClear:self.cid dpIDs:@[[NSNumber numberWithInt:401],[NSNumber numberWithInt:403]] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}

- (void)judgeHaveData
{
    if (self.bellTableView.tableModelArray.count == 0) {
        self.noDataView.hidden = NO;
        self.bellTableView.hidden = YES;
    }else{
        self.noDataView.hidden = YES;
        self.bellTableView.hidden = NO;
        [self.bellTableView reloadData];
    }
}
-(void)initView{
    [self.view addSubview:self.bgImageView];
    [self.view addSubview:self.exitBtn];
    [self.view addSubview:self.titleLabel];
    [self.view addSubview:self.settingBtn];
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.bellTableView];
    [self.view addSubview:self.editToolView];
    [_editToolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.bottom.equalTo(@50);
        make.width.mas_equalTo(CGRectGetWidth(self.view.frame));
        make.height.equalTo(@50);
    }];
    [self judgeHaveData];
    [self.bellTableView addSubview:self.refreshView];
    [self.refreshView setRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
}
//刷新事件
-(void)headerRereshing
{
    if (isEnableRefresh) {
        [self initData];
        isEnableRefresh = NO;
        [self performSelector:@selector(resetRefreshEnable) withObject:nil afterDelay:2];
    }else{
        [self.refreshView endRefresh];
    }
}

-(void)resetRefreshEnable
{
    isEnableRefresh = YES;
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    NSLog(@"offset:%f",scrollView.contentOffset.y);
    if (self.refreshView.state != FLRefreshStateRefreshing) {
        [self.refreshView scrollViewDidEndDrag:scrollView];
    }
}
#pragma mark - JFGSDK



#pragma mark - BellState
-(void)offline{
    self.state = BellStateOffline;
    [self.bgImageView setImage:[UIImage imageNamed:@"doorbell_no-network_bg-1"]];
    [self.noNetImageView setHidden:YES];
    [self.bellImageView setHidden:NO];
    [self.refreshLabel setHidden:YES];
    [self.seeButton setHidden:NO];
    //self.seeButton.enabled = NO;
}

-(void)noNet{
    self.state = BellStateNonet;
    [self.bgImageView setImage:[UIImage imageNamed:@"doorbell_no-network_bg-1"]];
    [self.seeButton setHidden:YES];
    [self.bellImageView setHidden:YES];
    [self.noNetImageView setHidden:NO];
    [self.refreshLabel setHidden:NO];
}

-(void)online{
    self.state = BellStateOnline;
    [self.bgImageView setImage:[UIImage imageNamed:@"doorbell_offline_top-bar"]];
    [self.seeButton setHidden:NO];
    [self.bellImageView setHidden:NO];
    [self.noNetImageView setHidden:YES];
    [self.refreshLabel setHidden:YES];
}

#pragma mark -JFGSDK
- (void)jfgOtherClientAnswerDoorbellCall
{
    [self initData];
}

-(void)jfgAccountOnline:(BOOL)online
{
    if (online) {
        [self initData];
    }
}

#pragma mark - NetworkDalegate

-(void)networkChanged:(NetworkStatus)statu{
    switch (self.state) {
        case BellStateOnline:{
            if (statu==NotReachable) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self noNet];
                });
            }
        }
            break;
        case BellStateOffline:{
            if (statu==NotReachable) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self noNet];
                });
            }
        }
            break;
        case BellStateNonet:{
            if (statu != NotReachable) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self online];//[self offline];
                });
            }
        }
            break;
        case BellStateRefreshing:{
            if (statu != NotReachable) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self stopLoadingAnimation];
                    [self online];//[self offline];
                });
            }
        }
            break;
            
        default:
            break;
    }
}

-(void)jfgDeviceList:(NSArray<JFGSDKDevice *> *)deviceList
{
    BOOL isExist = NO;
    for (JFGSDKDevice *dev in deviceList) {
        if ([dev.uuid isEqualToString:self.cid]) {
            isExist = YES;
            break;
        }
    }
    if (!isExist) {
        
        NSArray *delCidArr =  [JFGBoundDevicesMsg sharedDeciceMsg].delDeviceList;
        for (NSString *cid in delCidArr) {
            if ([cid isEqualToString:self.cid]) {
                return;
            }
        }
        
        NSString *str = @"";
        if ([self.devModel isKindOfClass:[JiafeigouDevStatuModel class]]) {
            if (self.devModel.shareState == DevShareStatuOther) {
                //取消分享
                str = [JfgLanguage getLanTextStrByKey:@"Tap1_shareDevice_canceledshare"];
            }else{
                //删除设备
                str = [JfgLanguage getLanTextStrByKey:@"Tap1_device_deleted"];
            }
        }else{
            str = [JfgLanguage getLanTextStrByKey:@"Tap1_device_deleted"];
        }
        JFGSDKDevice *_dev = [deviceList lastObject];
        self.cid = _dev.uuid;
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:str delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } otherDelegate:nil];
        
    }
}


- (void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray<DataPointSeg *> *)msgList
{
    @try {
        if ([peer isEqualToString:self.cid] && self.navigationController.visibleViewController == self)
        {
            for (DataPointSeg *seg in msgList)
            {
                NSError *error = nil;
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (error == nil)
                {
                    switch (seg.msgId)
                    {
                        case dpMsgBase_Battery:
                        {
                            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"cid[%@]'s battery %@",self.cid, obj]];
                            NSUserDefaults *stdDefault = [NSUserDefaults standardUserDefaults];
                            BOOL isAreadyShow = [stdDefault boolForKey:areadyShowLowBatteryView(self.cid)];
                            int battery = [obj intValue];
                            
                            if (battery < 20 && !isAreadyShow)
                            {
                                [JFGPicAlertView showAlertWithImage:[UIImage imageNamed:@"doorbell_lowpower"] Title:[JfgLanguage getLanTextStrByKey:@"DOOR_LOWBETTERY"] Message:[JfgLanguage getLanTextStrByKey:@"DOOR_BETTERYMESG"] cofirmButtonTitle:[JfgLanguage getLanTextStrByKey:@"SURE"] didDismissBlock:^{
                                    
                                }];
                                
                                [stdDefault setBool:YES forKey:areadyShowLowBatteryView(self.cid)];
                            }
                            else
                            {
                                if (battery > 20)
                                {
                                    [stdDefault setBool:NO forKey:areadyShowLowBatteryView(self.cid)];
                                }
                                
                            }
                            [stdDefault synchronize];
                        }
                            break;
                    }
                }
            }
        }
        
        
    } @catch (NSException *exception) {
        
    } @finally {
        
    }
}

#pragma mark - circleAnimation
-(void)startLodingAnimation{
    if (self.refreshLabel.isHidden) return;
    [self.noNetImageView setImage:[UIImage imageNamed:@"doorbell_loading"]];
    [self.refreshLabel setHidden:YES];
    //创建旋转动画
    POPBasicAnimation *baseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    //线性动画
    baseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];//kCAMediaTimingFunctionLinear;
    //间隔时间
    baseAnimation.duration = 25;
    //开始角度
    baseAnimation.fromValue =@(0);
    //结束角度
    baseAnimation.toValue = @(360);
    //是否永远循环执行
    baseAnimation.repeatForever = NO;
    //次数
    baseAnimation.repeatCount = 1;
    //添加动画
    [self.noNetImageView.layer pop_addAnimation:baseAnimation forKey:@"rotation"];
    
    self.state = BellStateRefreshing;
    
    [baseAnimation setCompletionBlock:^(POPAnimation *, BOOL) {
        //把图片旋转回初始状态
        [self stopLoadingAnimation];
    }];
}

-(void)stopLoadingAnimation{
    if (self.noNetImageView.hidden == YES) {
        return;
    }
    [self.noNetImageView setImage:[UIImage imageNamed:@"doorbell_no-network"]];
    [self.refreshLabel setHidden:NO];
    [self.noNetImageView.layer pop_removeAnimationForKey:@"rotation"];
    CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI*0);
    self.noNetImageView.transform = transform;
}

#pragma mark - ButtonAction
-(void)TapRefresh:(UITapGestureRecognizer *)tap{
    [self startLodingAnimation];
}
-(void)editToolViewAction:(UIButton *)btn
{
    
    switch (btn.tag) {
        case Edit_CancelBtnTag:{
            
            for (BellModel * model in self.bellTableView.tableModelArray) {
                model.isSelected = NO;
            }
            [self.bellTableView reloadData];
            self.bellTableView.isEditingView = NO;
            [UIView animateWithDuration:0.2 animations:^{
                [_editToolView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.equalTo(@50);
                }];
            }];
        }
            break;
        case Edit_SelAllBtnTag:{
            for (BellModel * model in self.bellTableView.tableModelArray) {
                if (model.isSelected == NO) {
                    model.isSelected = YES;
                }
            }
            [self.bellTableView reloadData];
        }
            break;
        case Edit_DelBtnTag:{
            
            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
                
                [CommonMethod showNetDisconnectAlert];
                return;
            }
            
            NSMutableIndexSet * delIndexSets = [NSMutableIndexSet indexSet];
            NSMutableArray * delIndexs = [NSMutableArray array];
            NSMutableArray * delVersions = [NSMutableArray array];
            for (int i = 0; i<self.bellTableView.tableModelArray.count; i++) {
                BellModel * model = [self.bellTableView.tableModelArray objectAtIndex:i];
                if (model.isSelected) {
                    NSInteger path = [self.bellTableView.tableModelArray indexOfObject:model];
                    [delIndexSets addIndex:path];
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:path inSection:0];
                    [delIndexs addObject:indexPath];
                    [delVersions addObject:model.version];
                }
            }

            
            [self.bellTableView.tableModelArray removeObjectsAtIndexes:delIndexSets];
            [self.bellTableView deleteRowsAtIndexPaths:delIndexs withRowAnimation:UITableViewRowAnimationTop];
            //删除服务器的
            NSMutableArray * segs = [NSMutableArray array];
            for (int i = 0; i<delVersions.count; i++) {
                DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
                seg.msgId = dpMsgBell_callMsg;
                seg.version = (int64_t)[[delVersions objectAtIndex:i] longLongValue];
                [segs addObject:seg];
            }

            [[JFGSDKDataPoint sharedClient]robotDelDataWithPeer:self.cid queryDps:segs success:^(NSString *identity, int ret) {
                if (ret == 0) {
                    [self judgeHaveData];
                }
            } failure:^(RobotDataRequestErrorType type) {
            }];
            
            UIButton *cancelBtn = [self.editToolView viewWithTag:Edit_CancelBtnTag];
            [self editToolViewAction:cancelBtn];
            
        }
            break;
        default:
            break;
    }
}
#pragma mark - UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.bellTableView.tableModelArray count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"doorBellCell";
    DoorBellCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[DoorBellCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    //不加下面一行有时候居然崩溃，这里代码逻辑需要检查
    if (self.bellTableView.tableModelArray.count <= indexPath.row) {
        return cell;
    }
    
    cell.bell.isShared = self.isShare;
    
    BellModel * model = [self.bellTableView.tableModelArray objectAtIndex:indexPath.row];
    cell.bell.isSelected = model.isSelected;
    cell.bell.dateLabel.text = model.bellDate;
    cell.bell.timeLabel.text = model.bellTime;
    cell.delegate = self;
    cell.indexPath = indexPath;
    if (model.headUrl) {
        [cell.bell.headerImageView jfg_setImageWithURL:[NSURL URLWithString:model.headUrl] placeholderImage:[UIImage imageNamed:@"friends_head"]];
    }else{
        cell.bell.headerImageView.image = [UIImage imageNamed:@"friends_head"];
    }

    cell.bell.isAnswered = model.isAnswered;
    
    NSDate *dat = [[NSUserDefaults standardUserDefaults] objectForKey:LastIntoVCTime];
    if (dat) {
       
        NSTimeInterval timesp = [dat timeIntervalSince1970];
        if (timesp > model.timestamp) {
            cell.bell.redDot.hidden = YES;
        }else{
            if (!cell.bell.isAnswered) {
                cell.bell.redDot.hidden = NO;
            }else{
                cell.bell.redDot.hidden = YES;
            }
        }
        
    }else{
        
        if (!cell.bell.isAnswered) {
            cell.bell.redDot.hidden = NO;
        }else{
            cell.bell.redDot.hidden = YES;
        }
        
    }
    
    
    return cell;
}


-(void)doorBellCellTap:(UITapGestureRecognizer *)tap indexPath:(NSIndexPath *)indexPath
{
    BellModel * model = [self.bellTableView.tableModelArray objectAtIndex:indexPath.row];
    
    
    int64_t timestamp = model.timestamp;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    
    NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
    [formatter setDateFormat:@"yyyy"];
    NSInteger msgYear = [[formatter stringFromDate:msgDate] integerValue];
    NSInteger currentYear = [[formatter stringFromDate:[NSDate date]] integerValue];
    
    if (msgYear == currentYear) {
        [formatter setDateFormat:@"MM.dd-HH:mm"];
    }else{
        [formatter setDateFormat:@"yyyy.MM.dd-HH:mm"];
    }
    
    NSString *title = [formatter stringFromDate:msgDate];
    
    UIImageView *imageView = (UIImageView *)tap.view;
    
    
    ImageBrowser * bro = [[ImageBrowser alloc]initWithImageView:@[imageView] Title:title currentImageIndex:0 isExpore:NO];
    bro.imagesUrl = [[NSMutableArray alloc]initWithObjects:model.headUrl, nil];
    bro.cid = self.cid;
    bro.deviceVersion = model.deviceVersion;
//    ImageBrowser *bro = [[ImageBrowser alloc]initAllAnglePicViewWithImageView:@[imageView] Title:title currentImageIndex:0];
    bro.imageNumber = 1;
    bro.cid = self.cid;
    bro.fileName = model.fileName;
    bro.url = model.headUrl;
    bro.regionType = model.flag;
    
//    NSRange range = [model.fileName rangeOfString:@".jpg"];
//    NSString *times = [model.fileName substringToIndex:range.location];

    bro.timestamp = timestamp;
    [bro showCurrentImageViewIndex:0];//调用方法
}

#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 159*designHscale;
}
-(void)isEditingView:(BOOL)isEditing{
    if (isEditing) {
        //弹出编辑bar
        [UIView animateWithDuration:0.2 animations:^{
            [_editToolView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@0);
            }];
        }];
    }else{
        //qu消编辑bar
        [UIView animateWithDuration:0.2 animations:^{
            [_editToolView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(@50);
            }];
        }];
    }
}
#pragma mark - 界面
-(UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, topHeight, self.view.width, self.view.height-topHeight)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-140)/2.0, 0.1*kheight, 140, 140)];
        iconImageView.image = [UIImage imageNamed:@"png-no-message"];
        [_noDataView addSubview:iconImageView];
        UILabel * noShareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImageView.bottom+20, Kwidth, 15)];
        noShareLabel.font = [UIFont systemFontOfSize:15];
        noShareLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        noShareLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_MESSAGE"];
        noShareLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:noShareLabel];
    }
    return _noDataView;
}
-(doorBellTableView *)bellTableView
{
    if (!_bellTableView) {
        _bellTableView = [[doorBellTableView alloc]initWithFrame:CGRectMake(0, topHeight+17, Kwidth, 263*designHscale+9) style:UITableViewStylePlain];
        _bellTableView.center =CGPointMake(self.view.center.x, topHeight+17+263*designHscale/2.0);
        _bellTableView.isEditingView = NO;
        _bellTableView.delegate = self;
        _bellTableView.viewDelegate = self;
        _bellTableView.dataSource = self;
    }
    return _bellTableView;
}
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel initWithFrame:CGRectMake((self.view.width-200.0)/2.0, 34*designHscale, 200, 17) text:self.alias font:FontNameHelvetica size:17.0 color:[UIColor whiteColor] alignment:NSTextAlignmentCenter lines:1];
        [_titleLabel setFont:[UIFont systemFontOfSize:17]];
    }
    return _titleLabel;
}
-(DelButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [UIButton initWithFrame:CGRectMake(10, 27*designHscale, 30, 30) image:[UIImage imageNamed:@"qr_backbutton_normal"] highlightedImage:nil cornerRadius:0 handerForTouchUpInside:^(UIButton *button) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _exitBtn;
}
-(UIButton *)settingBtn{
    if (!_settingBtn) {
        _settingBtn = [UIButton initWithFrame:CGRectMake(self.view.width-44-5, 20*designHscale, 44, 44) image:[UIImage imageNamed:@"camera_ico_install"] highlightedImage:nil cornerRadius:0 handerForTouchUpInside:^(UIButton *button) {
            DeviceSettingVC *deviceSetting = [DeviceSettingVC new];
            deviceSetting.pType = productType_DoorBell;
            deviceSetting.cid = self.cid;
            deviceSetting.alis = self.alias;
            deviceSetting.isShare = self.isShare;
            [self.navigationController pushViewController:deviceSetting animated:YES];
        }];
    }
    return _settingBtn;
}
-(UIImageView *)bellImageView{
    if (!_bellImageView) {
        UIImage * image = [UIImage imageNamed:@"doorbell"];
        _bellImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-190*designHscale)/2.0, 66*designHscale, 190*designHscale, 190*designHscale)];
        [_bellImageView setImage:image];
    }
    return _bellImageView;
}
-(UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, topHeight)];
        [_bgImageView setImage:[UIImage imageNamed:@"doorbell_offline_top-bar"]];
        _bgImageView.userInteractionEnabled = YES;
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.clipsToBounds = YES;
        
//        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(TapRefresh:)];
//        tap.numberOfTapsRequired = 1;
//        [_bgImageView addGestureRecognizer:tap];
        
        [_bgImageView addSubview:self.seeButton];
        [_bgImageView addSubview:self.bellImageView];
        [_bgImageView addSubview:self.noNetImageView];
        [_bgImageView addSubview:self.refreshLabel];
    }
    return _bgImageView;
}
-(UIButton *)seeButton{
    if (!_seeButton) {
        _seeButton = [UIButton initWithFrame:CGRectMake((self.view.width-106.0*designHscale)/2.0, self.bellImageView.bottom-41*designHscale, 106.0*designHscale, 46*designHscale) backgroundImage:[UIImage imageNamed:@"doorbell_look_btn"] highlightedImage:[UIImage imageNamed:@"doorbell_look_btn-press"] title:[JfgLanguage getLanTextStrByKey:@"DOOR_BELL_LOOK"] font:[UIFont systemFontOfSize:15*designHscale] titleColor:[UIColor colorWithHexString:@"#788291"] cornerRadius:0 handerForTouchUpInside:^(UIButton *button)
        {
            
            BellModel * model = [self.bellTableView.tableModelArray firstObject];
            DoorVideoVC *doorVideo = [[DoorVideoVC alloc] init];
            doorVideo.pType = (productType)[self.devModel.pid intValue];
            doorVideo.cid = self.cid;
            doorVideo.nickName = self.alias;
            doorVideo.imageUrl = model.headUrl;
            doorVideo.actionType = doorActionTypeActive;
            [self.navigationController pushViewController:doorVideo animated:YES];
        }];

        
    }
    return _seeButton;
}

-(UIImageView *)noNetImageView{
    if (!_noNetImageView) {
        _noNetImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-77*designHscale)/2, 106*designHscale, 77*designHscale, 77*designHscale)];
        [_noNetImageView setImage:[UIImage imageNamed:@"doorbell_no-network"]];
    }
    return _noNetImageView;
}
-(UILabel *)refreshLabel{
    if (!_refreshLabel) {
        _refreshLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.noNetImageView.bottom+7, self.view.width, 15*designHscale)];
        [_refreshLabel setTextColor:[UIColor whiteColor]];
        [_refreshLabel setTextAlignment:NSTextAlignmentCenter];
        [_refreshLabel setFont:[UIFont systemFontOfSize:15*designHscale]];
        [_refreshLabel setText:[JfgLanguage getLanTextStrByKey:@"OFFLINE_ERR_1"]];
    }
    return _refreshLabel;
}
-(UIView *)editToolView{
    if (!_editToolView) {
        _editToolView = [[UIView alloc]init];
        UIView * line = [[UIView alloc]init];
        line.backgroundColor = TableSeparatorColor;
        [_editToolView addSubview:line];
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@0);
            make.left.equalTo(@0);
            make.width.mas_equalTo(_editToolView.mas_width);
            make.height.equalTo(@0.5);
        }];
        DelButton * cancelBtn = [DelButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [cancelBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor colorWithHexString:@"#aaaaaa"]];
        cancelBtn.tag = Edit_CancelBtnTag;
        [cancelBtn addTarget:self action:@selector(editToolViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editToolView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@30);
            make.centerY.mas_equalTo(_editToolView.mas_centerY);
            make.width.greaterThanOrEqualTo(@30);
            make.height.equalTo(@15);
        }];
        
        DelButton * selAllBtn = [DelButton buttonWithType:UIButtonTypeCustom];
        [selAllBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [selAllBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SELECT_ALL"] forState:UIControlStateNormal];
        [selAllBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"]];
        selAllBtn.tag = Edit_SelAllBtnTag;
        [selAllBtn addTarget:self action:@selector(editToolViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editToolView addSubview:selAllBtn];
        [selAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(_editToolView.mas_centerX);
            make.centerY.mas_equalTo(_editToolView.mas_centerY);
            make.width.greaterThanOrEqualTo(@30);
            make.height.equalTo(@15);
        }];
        
        DelButton * DelBtn = [DelButton buttonWithType:UIButtonTypeCustom];
        [DelBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [DelBtn setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
        [DelBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"]];
        DelBtn.tag = Edit_DelBtnTag;
        [DelBtn addTarget:self action:@selector(editToolViewAction:) forControlEvents:UIControlEventTouchUpInside];
        [_editToolView addSubview:DelBtn];
        [DelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@-30);
            make.centerY.mas_equalTo(_editToolView.mas_centerY);
            make.width.greaterThanOrEqualTo(@30);
            make.height.equalTo(@15);
        }];
    }
    return _editToolView;
}
-(FLRefreshHeader *)refreshView
{
    if (!_refreshView) {
        _refreshView = [[FLRefreshHeader alloc]initWithFrame:CGRectMake(0, -46, 263*designHscale+9, 23)];
        _refreshView.originOffset_y = -31;
        _refreshView.originalTopInset = 9;
        _refreshView.showType = FLRefreshShowTypeHolding;
        
    }
    return _refreshView;
}

-(UIImage*)createImageWithColor:(UIColor*)color size:(CGSize)size
{
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width , size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
