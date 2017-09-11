//
//  MessageViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "MessageViewController.h"
#import "FLGlobal.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "UILabel+FLExtension.h"
#import "MessageViewCell.h"
#import <Masonry.h>
#import "DJActionSheet.h"
#import "DJActionRuler.h"
#import "UITableView+ReloadData.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/MPMessagePackReader.h>
#import "VideoPlayViewController.h"
#import <SDWebImage/SDWebImageCompat.h>
#import "MessageModel.h"
#import "JfgTimeFormat.h"
#import "dataPointMsg.h"
#import "UIImageView+WebCache.h"
#import "JfgMsgDefine.h"
#import "JfgLanguage.h"
#import "UIButton+Click.h"
#import "JfgCacheManager.h"
#import "LoginManager.h"
#import "CommonMethod.h"
#import "JfgConfig.h"
#import "JFGDataPointValueAnalysis.h"
#import "UIImageView+JFGImageView.h"
#import <MJRefresh/MJRefresh.h>
#import "JFGRefreshLoadingHeader.h"
#import "DeviceSettingVC.h"
#import "MessageVCDateModel.h"
#import "JFGDatePickers.h"
#import "CamareMsgDataReq.h"
#import "BellMsgDataReq.h"
#import "jfgConfigManager.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate,JFGDatePickerDelegate,CamareMsgDataReqDelegate,BellMsgDataReqDelegate>
{
    NSMutableArray *delCacheArray;
    BOOL isHasSDCard;
    NSInteger SDCardErrorType;//0表示正常使用
    BOOL isEditing;
    BOOL deleteAll;
    BOOL isEnableFooterRefresh;
    MessageVCDateModel *currentDatePickerModel;
    BOOL isDoorBell;
    BOOL isShared;
    BOOL isJumpied;
}
//顶部白色背景View
@property(nonatomic, strong)UIView * topBgView;
//顶部的小线条
@property(nonatomic, strong)UILabel * topLineLabel;
//表
@property(nonatomic, strong)UITableView *contentTableView;

//编辑状态底部的背景View
@property(nonatomic, strong)UIView * bottomSelectView;
//编辑状态底部的全选按钮
@property(nonatomic, strong)DelButton *selectAllButton;
//编辑状态底部的删除按钮
@property(nonatomic, strong)DelButton *deleteButton;
//编辑状态底部的小线条
@property(nonatomic, strong)UILabel *bottomLineLabel;
//月日年时间格式
@property (nonatomic,strong)NSDateFormatter *YMDformatter;
//日期
@property (nonatomic,strong)NSDateFormatter *dateFormatter;

@property (nonatomic,strong)NSDateFormatter *ddhhDateFormatter;

@property (nonatomic,strong)NSMutableArray * contentArray;
@property (strong, nonatomic)UIView * noDataView;
@property (nonatomic,strong)NSMutableArray *messageDataArray;
@property (nonatomic,assign)BOOL isShowTimeselectedView;
@property (nonatomic,strong)JFGDatePickers *datePicker;

//获取摄像头数据
@property (nonatomic,strong)CamareMsgDataReq *camereMsgReq;

//获取门铃数据模型
@property (nonatomic,strong)BellMsgDataReq *bellMsgReq;

@end

@implementation MessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    if (self.devModel.shareState != DevShareStatuOther) {
        isShared = NO;//不是被分享设备
    }else{
        isShared = YES;//被分享设备
    }
    isEnableFooterRefresh = YES;
    isDoorBell = [jfgConfigManager devIsDoorBellForPid:self.devModel.pid];
    self.contentArray = [NSMutableArray arrayWithCapacity:0];
    [JFGSDK addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageVDelegate:) name:MessageVDelegateDataNotificationKey object:nil];
    [self initView];
    
    //删除缓存
    [self delCacheDelData];
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [self loadLocalData];
    }else{
        [self initDataModels];
    }
    
}


//来自720度图片显示页面的删除通知
-(void)messageVDelegate:(NSNotification *)notification
{
    if ([notification isKindOfClass:[NSNotification class]]) {
        NSIndexPath *indexPath = notification.object;
        NSInteger row = indexPath.row;
        if (self.contentArray.count > row) {
            MessageModel *model = [self.contentArray objectAtIndex:row];
            [self deleteServerData:@[model]];
        }
        [self.contentArray removeObjectAtIndex:indexPath.row];
        [_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [self updateView];
    }
    
}

-(void)initDataModels
{
    self.messageDataArray = [[NSMutableArray alloc]initWithArray:[self.camereMsgReq getDateModelsBefore15DayWithNow]];
    [self.camereMsgReq dateModelForCamareIsHasDataForDateModels:self.messageDataArray cid:self.devModel.uuid];
}



#pragma mark- 判断某天是否有数据
//请求当前时间点前15天，哪天有数据处理完成
-(void)dateModelIsHasDataDealSuccess
{
    [self getCurrentDayDataAndPicker];
}

//请求当前时间点前15天，哪天有数据处理失败
-(void)dateModelIsHasDataDealFailer
{
    
}

#pragma mark- 摄像头报警图片数据处理回调(delegate)
//数据请求成功
-(void)requestCamareSuccess:(NSArray <MessageModel *> *)dataList forCid:(NSString *)cid refresh:(BOOL)refresh
{
    if (currentDatePickerModel) {
        
        int64_t startVersion = currentDatePickerModel.startTimestamp;
        int64_t endVersion = startVersion + 24*60*60;
        
        if (endVersion > [[NSDate date] timeIntervalSince1970]) {
            endVersion = [[NSDate date] timeIntervalSince1970];
        }
        
        NSMutableArray *dealDatArr = [NSMutableArray new];
        
        for (MessageModel *messageModel in dataList) {
            
            if (messageModel.timestamp >= startVersion && messageModel.timestamp < endVersion) {
                
                if (messageModel.msgID == dpMsgBase_SDStatus) {
                    [dealDatArr addObject:messageModel];
                }else{
                    if (messageModel.msgImages.count>0) {
                        [dealDatArr addObject:messageModel];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refresh) {
                currentDatePickerModel.messageDataArr = [[NSMutableArray alloc]initWithArray:dealDatArr];
                [self.contentTableView.mj_header endRefreshing];
            }else{
                [currentDatePickerModel.messageDataArr addObjectsFromArray:dealDatArr];
                [self.contentTableView.mj_footer endRefreshing];
                if (!dealDatArr.count) {
                    [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            
            self.contentArray = [[NSMutableArray alloc]initWithArray:currentDatePickerModel.messageDataArr];
            [self updateView];
            [self.contentTableView reloadData];
            
        });
        
        
    }
}

//数据请求失败
-(void)requestCamareFailedForCid:(NSString *)cid refresh:(BOOL)refresh
{
    
}


#pragma mark- 门铃呼叫消息
-(void)requestBellSuccess:(NSArray<MessageModel *> *)dataList forCid:(NSString *)cid refresh:(BOOL)refresh
{
    if (currentDatePickerModel) {
        
        int64_t startVersion = currentDatePickerModel.startTimestamp;
        int64_t endVersion = startVersion + 24*60*60;
        
        if (endVersion > [[NSDate date] timeIntervalSince1970]) {
            endVersion = [[NSDate date] timeIntervalSince1970];
        }
        
        NSMutableArray *dealDatArr = [NSMutableArray new];
        
        for (MessageModel *messageModel in dataList) {
            
            if (messageModel.timestamp >= startVersion && messageModel.timestamp < endVersion) {
                
                if (messageModel.msgID == dpMsgBase_SDStatus) {
                    [dealDatArr addObject:messageModel];
                }else{
                    if (messageModel.msgImages.count>0) {
                        [dealDatArr addObject:messageModel];
                    }
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (refresh) {
                currentDatePickerModel.messageDataArr = [[NSMutableArray alloc]initWithArray:dealDatArr];
                [self.contentTableView.mj_header endRefreshing];
            }else{
                [currentDatePickerModel.messageDataArr addObjectsFromArray:dealDatArr];
                [self.contentTableView.mj_footer endRefreshing];
                if (!dealDatArr.count) {
                    [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
            
            self.contentArray = [[NSMutableArray alloc]initWithArray:currentDatePickerModel.messageDataArr];
            [self updateView];
            [self.contentTableView reloadData];
            
        });
        
        
    }
}

#pragma mark- 获取今天的数据，并且添加时间选择器到界面
-(void)getCurrentDayDataAndPicker
{
    //选中最近时间点
    for (MessageVCDateModel *model in self.messageDataArray) {
        
        if (model.isHasMessage) {
            
            model.isSelectedDate = YES;
            if (currentDatePickerModel) {
                currentDatePickerModel.isSelectedDate = NO;
            }
            currentDatePickerModel = model;
            NSInteger index = [self.messageDataArray indexOfObject:model];
            self.datePicker.selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            self.datePicker.monthLabel.text = [NSString stringWithFormat:@"%ld%@",(long)model.mounth, [JfgLanguage getLanTextStrByKey:@"MONTHS"]];
            [self.timeSelectButton setTitle:[self timeSelecedBtnTitleForTimestamp:model.startTimestamp] forState:UIControlStateNormal];
        }
    }
    if (currentDatePickerModel) {
        [self.camereMsgReq getDataForCid:self.devModel.uuid timestamp:currentDatePickerModel.lastestTimestamp isRefresh:YES];
    }else{
        [self updateView];
    }
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    self.datePicker.top = keyWindows.height;
    self.datePicker.hidden = YES;
    if (self.datePicker.superview == nil) {
        [keyWindows addSubview:self.datePicker];
    }
    
    [self.datePicker reloadData];
    [self isShowNoDataView];
    int64_t delayInSeconds = 1;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [self.datePicker scrollToEndItem];
        
    });
}

-(void)delCacheDelData
{
    NSArray *cacheArr = [JfgCacheManager getCacheForWarnPicForDelWithCid:self.cid];
    delCacheArray = [[NSMutableArray alloc]initWithArray:cacheArr];
    NSMutableArray *segList = [NSMutableArray new];
    
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        
        for (MessageModel *model in delCacheArray) {
            DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
            seg.msgId = model.realyMsgID;
            seg.version = model.timestamp*1000;
            [segList addObject:seg];
        }
        
        
        [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:self.cid queryDps:segList success:^(NSString *identity, int ret) {
            
            NSLog(@"identity:%@  ret:%d",identity,ret);
            [delCacheArray removeAllObjects];
            
        } failure:^(RobotDataRequestErrorType type) {
            
        }];
        
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self disMissDateRuler];
    if (self.navigationController.viewControllers.count <2) {
        if (self.messageDataArray) {
            [JfgCacheManager cacheWarnPicMsgList:self.messageDataArray forCid:self.cid];
        }
        if (delCacheArray) {
            [JfgCacheManager cacheWarnPicForDelMsgList:delCacheArray forCid:self.cid];
        }
        [self.datePicker removeFromSuperview];
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)initView
{
    [self.view addSubview:self.topBgView];
    [self.view addSubview:self.topLineLabel];
    [self.view addSubview:self.contentTableView];
    [self.contentTableView addSubview:self.noDataView];
    [self stepRefresh];
    [self updateView];
    [self getSDCard];
}

- (void)updateView
{
    if (!self.contentArray.count)
    {
        if (self.bottomSelectView != nil) {
            [UIView animateWithDuration:0.33f animations:^{
                [self.bottomSelectView setFrame:CGRectMake(0, self.view.frame.size.height, Kwidth, 50)];
                [self.contentTableView setEditing:NO];
                [self.contentTableView setFrame:CGRectMake(0, self.topLineLabel.bottom, Kwidth, kheight-64-44-0.5)];
            } completion:^(BOOL finished) {
                [self.bottomSelectView removeFromSuperview];
            }];
        }
    }else{
        self.topBgView.hidden = NO;
        self.topLineLabel.hidden = NO;
        self.contentTableView.hidden = NO;
        self.contentTableView.mj_footer.hidden = NO;
    }
    [self.contentTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillDisappear:) name:@"JFGJumpingRootView" object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    if (self.timeSelectButton.selected == YES) {
        [self selectDate:self.timeSelectButton];
    }
    [super viewWillDisappear:animated];
}


#pragma mark- 刷新与加载更多
-(void)stepRefresh
{
    __weak typeof(self) weakSelf = self;
    self.contentTableView.mj_header = [JFGRefreshLoadingHeader headerWithRefreshingBlock:^{
    
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            [weakSelf.contentTableView.mj_footer resetNoMoreData];
            
//            if (isDoorBell) {
//                [weakSelf.bellMsgReq getDataForCid:self.devModel.uuid timestamp:currentDatePickerModel.lastestTimestamp isRefresh:YES];
//            }else{
                [weakSelf.camereMsgReq getDataForCid:self.devModel.uuid timestamp:currentDatePickerModel.lastestTimestamp isRefresh:YES];
            //}
            
            //[weakSelf.camereMsgReq getDataForCid:self.devModel.uuid timestamp:currentDatePickerModel.lastestTimestamp isRefresh:YES];
            if (currentDatePickerModel == [self.messageDataArray lastObject]) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGClearUnReadCount" object:self.cid];
            }
            
        }else{
            [CommonMethod showNetDisconnectAlert];
            [weakSelf.contentTableView.mj_header endRefreshing];
        }
        
    }];
    
   
    self.contentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if (self.timeSelectButton.selected) {
            [self selectDate:self.timeSelectButton];
        }
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
            
            [weakSelf.contentTableView.mj_footer endRefreshing];
            [CommonMethod showNetDisconnectAlert];
            return ;
        }
        
        if (self.contentTableView.mj_footer.state != MJRefreshStateRefreshing) {
            if (!isEnableFooterRefresh) {
                [weakSelf.contentTableView.mj_footer endRefreshing];
                return;
            }
        }
        
        MessageModel *messageModel = [self.contentArray lastObject];
//        if (isDoorBell) {
//            [weakSelf.bellMsgReq getDataForCid:self.devModel.uuid timestamp:messageModel._version isRefresh:NO];
//        }else{
            [weakSelf.camereMsgReq getDataForCid:self.devModel.uuid timestamp:messageModel._version isRefresh:NO];
        //}
       
    }];
    
    MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.contentTableView.mj_footer;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    footer.automaticallyHidden = YES;
}

#pragma mark - 顶部时间选择按钮时间
-(void)selectDate:(UIButton *)button
{
    button.selected = !button.selected;
    if (button.selected == YES) {
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI);
            _timeSelectButton.imageView.transform = transform;
            [self showDateRuler];
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform transform= CGAffineTransformMakeRotation(2*M_PI);
            _timeSelectButton.imageView.transform = transform;
            [self disMissDateRuler];
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark- 编辑按钮事件
-(void)editButtonAction:(DelButton *)button
{
    [button setSelected:!button.isSelected];
    //禁止选择时间按钮
    [self.timeSelectButton setEnabled:!button.selected];
    if (button.isSelected) {
        isEditing = YES;
        [self hideRefreshController];
        [self.view addSubview:self.bottomSelectView];
        [UIView animateWithDuration:0.33f animations:^{
            [self.bottomSelectView setFrame:CGRectMake(0, self.view.frame.size.height-50, Kwidth, 50)];
            self.contentTableView.editing = YES;
            [self.contentTableView setFrame:CGRectMake(0, self.topLineLabel.bottom, Kwidth, kheight-64-44-0.5-50)];
        } completion:^(BOOL finished) {
            [self.contentTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }];
        if (self.timeSelectButton.selected) {
            [self selectDate:self.timeSelectButton];
        }

    }else{
        [self.contentTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        isEditing = NO;
        [self showRefreshController];
        self.selectAllButton.selected = NO;
        [UIView animateWithDuration:0.33f animations:^{
            [self.bottomSelectView setFrame:CGRectMake(0, self.view.frame.size.height, Kwidth, 50)];
            self.contentTableView.editing = NO;
            [self.contentTableView setFrame:CGRectMake(0, self.topLineLabel.bottom, Kwidth, kheight-64-44-0.5)];
        } completion:^(BOOL finished) {
            [self.bottomSelectView removeFromSuperview];
        }];
    }
}

-(void)hideRefreshController
{
    self.contentTableView.mj_header.hidden = YES;
    self.contentTableView.mj_footer.hidden = YES;
}

-(void)showRefreshController
{
    self.contentTableView.mj_header.hidden = NO;
    self.contentTableView.mj_footer.hidden = NO;
}


#pragma mark- 删除事件
-(void)deleteSingleCell:(NSArray <NSIndexPath *> *)indexPaths {
    __weak typeof(self) weakSelf = self;
    [DJActionSheet showDJActionSheetWithTitle:[JfgLanguage getLanTextStrByKey:@"Tips_SureDelete"] buttonTitleArray:@[[JfgLanguage getLanTextStrByKey:@"DELETE"],[JfgLanguage getLanTextStrByKey:@"CANCEL"]] actionType:actionTypeDelete defaultIndex:0 didSelectedBlock:^(NSInteger index) {
        if(index == 0) {
            NSInteger row = [indexPaths objectAtIndex:0].row;
            if (weakSelf.contentArray.count > row) {
                MessageModel *model = [self.contentArray objectAtIndex:row];
                [weakSelf deleteServerData:@[model]];
            }
            
            [weakSelf.contentArray removeObjectAtIndex:[indexPaths objectAtIndex:0].row];
            [_contentTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
            [weakSelf updateView];
            
        }
        
    } didDismissBlock:nil];
}

-(void)deleteServerData:(NSArray *)delList
{
    for (MessageModel *model in delList) {
        if (currentDatePickerModel) {
            for (MessageModel *_model in [currentDatePickerModel.messageDataArr copy]) {
                if (_model.timestamp == model.timestamp) {
                    [currentDatePickerModel.messageDataArr removeObject:_model];
                }
            }
        }
    }
    
    NSMutableArray *segList = [NSMutableArray new];
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        //离线中...
        if (delCacheArray == nil) {
            delCacheArray = [[NSMutableArray alloc]init];
        }
        [delCacheArray addObjectsFromArray:delList];
        
    }else{
        
        for (MessageModel *model in delList) {
            DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
            seg.msgId = model.realyMsgID;
            seg.version = model._version;
            [segList addObject:seg];
        }
        
        
        [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:self.cid queryDps:segList success:^(NSString *identity, int ret) {
            
            NSLog(@"identity:%@  ret:%d",identity,ret);
            
        } failure:^(RobotDataRequestErrorType type) {
            
        }];
        
    }
    
    
}

-(void)lookHistoryVideo:(UIButton *)sender
{
    NSLog(@"%@",[NSThread currentThread]);
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [CommonMethod showNetDisconnectAlert];
        return ;
    }
   
    NSLog(@"lookHistory");
    [self disMissDateRuler];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag-223 inSection:0];
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];

    if (messageModel.msgID == dpMsgBase_SDStatus) {
        //sd卡需要格式化，直接跳转设备详情
        
        DeviceSettingVC *deviceSetting = [DeviceSettingVC new];
        deviceSetting.cid = self.cid;
        deviceSetting.isShare = (self.devModel.shareState == DevShareStatuOther);
        deviceSetting.devModel = self.devModel;
        deviceSetting.pType = (productType)[self.devModel.pid intValue];
        
        if ([self.devModel.alias isEqualToString:@""]) {
            deviceSetting.alis = self.devModel.uuid;
        }else{
            deviceSetting.alis = self.devModel.alias;
        }
        [self.navigationController pushViewController:deviceSetting animated:YES];
        
    }else{
        
        sender.enabled = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(lookHistoryForTimestamp:)]) {
            MessageViewCell *cell = [_contentTableView cellForRowAtIndexPath:indexPath];
            [self.delegate lookHistoryForTimestamp:cell.timestamp];
        }
        //JFGLookHistoryVideo
        int64_t delayInSeconds = 1.5;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            sender.enabled = YES;
            
        });
    }
}

#pragma mark- 全选事件
-(void)selectAllCells:(DelButton *)button{
    [self enableBottomDelButton];
    button.selected = !button.selected;
    if (button.isSelected) {
        for (int i=0; i<self.contentArray.count; i++) {
            [self.contentTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        deleteAll = YES;
    }else{
        for (int i=0; i<self.contentArray.count; i++) {
            [self.contentTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES];
        }
        deleteAll = NO;
    }
}

#pragma mark- 删除选中cell
-(void)deleteSelectedCells
{
    for (MessageModel *model in self.contentArray) {
        if (currentDatePickerModel) {
            for (MessageModel *_model in [currentDatePickerModel.messageDataArr copy]) {
                if (_model.timestamp == model.timestamp) {
                    [currentDatePickerModel.messageDataArr removeObject:_model];
                }
            }
        }
    }
    if (deleteAll) {
        
        [self updateView];
        [self showRefreshController];
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
            //离线中...
            if (delCacheArray == nil) {
                delCacheArray = [[NSMutableArray alloc]init];
            }
            [delCacheArray addObjectsFromArray:self.contentArray];
            
        }else{
            NSMutableArray *segList = [[NSMutableArray alloc]init];
            for (MessageModel *model in self.contentArray) {
                DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
                seg.msgId = model.realyMsgID;
                seg.version = model.timestamp*1000;
                [segList addObject:seg];
            }
            
            
            [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:self.cid queryDps:segList success:^(NSString *identity, int ret) {
                
                NSLog(@"identity:%@  ret:%d",identity,ret);
                
            } failure:^(RobotDataRequestErrorType type) {
                
            }];
        }
        
        [self.contentArray removeAllObjects];
        [self.contentTableView reloadData];

        if (!self.editButton.selected) {
            self.editButton.selected = YES;
        }
        
        [self editButtonAction:self.editButton];
        self.contentTableView.mj_footer.hidden = YES;
        
        
    }else{
        NSArray *allSeletedIndexPath =[self.contentTableView indexPathsForSelectedRows];
        NSMutableArray *selectedArr = [NSMutableArray new];
        for (NSIndexPath *indexPath in allSeletedIndexPath) {
            MessageModel *model = [self.contentArray objectAtIndex:indexPath.row];
            [selectedArr addObject:model];
        }
        [self deleteServerData:selectedArr];
        [self.contentArray removeObjectsInArray:selectedArr];
        [_contentTableView deleteRowsAtIndexPaths:allSeletedIndexPath withRowAnimation:UITableViewRowAnimationTop];
        if (self.contentArray.count == 0) {
            [self showRefreshController];
            [self updateView];
        }
    }
}

-(void)enableBottomDelButton{
    [self.deleteButton setEnabled:YES];
}

-(void)disableBottomDelButton{
    [self.deleteButton setEnabled:NO];
}

#pragma mark- 从网络获取数据


#pragma mark- 网络数据处理
-(void)refreshDataDealForDataList:(NSArray *)dataList isRefresh:(BOOL)isRefresh
{
    if (currentDatePickerModel) {
        
        int64_t startVersion = currentDatePickerModel.startTimestamp;
        int64_t endVersion = startVersion + 24*60*60;
        
        if (endVersion > [[NSDate date] timeIntervalSince1970]) {
            endVersion = [[NSDate date] timeIntervalSince1970];
        }
        
        @try {
            
            NSMutableArray *dealDatArr = [NSMutableArray new];
            for (DataPointSeg *seg in dataList)
            {
                MessageModel *messageModel = [[MessageModel alloc] init];
                id obj =  [MPMessagePackReader readData:seg.value error:nil];
                
                switch (seg.msgId)
                {
                    case dpMsgCamera_WarnMsgV3:
                    case dpMsgCamera_WarnMsg:
                    {
                        messageModel.msgID = dpMsgCamera_WarnMsg;
                        messageModel.cid = self.cid;
                        messageModel._version = seg.version;
                        NSArray *values = [MPMessagePackReader readData:seg.value error:nil];
                        messageModel.timestamp = [[values objectAtIndex:0] doubleValue];
                        messageModel.flag = [[values objectAtIndex:3] intValue];
                        messageModel.imageNum = [[values objectAtIndex:2] intValue];
                        if (values.count>4) {
                            messageModel.tly = [values objectAtIndex:4];
                        }else{
                            messageModel.tly = @"1";
                        }
                        messageModel.realyMsgID =seg.msgId;
                        if (seg.msgId == dpMsgCamera_WarnMsgV3) {
                            messageModel.deviceVersion = 3;
                        }else{
                            messageModel.deviceVersion = 2;
                        }
                        
                    }
                        break;
                    case 222:
                    {
                        messageModel.msgID = dpMsgBase_SDStatus;
                        messageModel.cid = self.cid;
                        messageModel._version = seg.version;
                        messageModel.timestamp = seg.version/1000;
                        if (obj && [obj isKindOfClass:[NSArray class]]) {
                            
                            NSArray *objArr = obj;
                            if (objArr.count >= 2) {
                                id obj1 = [objArr objectAtIndex:0];
                                id obj2 = [objArr objectAtIndex:1];
                                if ([obj1 isKindOfClass:[NSNumber class]]) {
                                    messageModel.isSDCardOn = [obj1 boolValue];
                                }
                                if ([obj2 isKindOfClass:[NSNumber class]]) {
                                    messageModel.sdcardErrorCode = [obj2 intValue];
                                    if (messageModel.sdcardErrorCode != 0) {
                                        messageModel.isShowVideoBtn = YES;
                                    }else{
                                        messageModel.isShowVideoBtn = NO;
                                    }
                                }
                            }
                        }
                        
                    }
                        break;
                }
                
                NSLog(@"%lld  %f  %lld",startVersion,messageModel.timestamp,endVersion);
                
                if (messageModel.timestamp >= startVersion && messageModel.timestamp < endVersion) {
                    
                    if (messageModel.msgID == dpMsgBase_SDStatus) {
                        [dealDatArr addObject:messageModel];
                    }else{
                        if (messageModel.msgImages.count>0) {
                            [dealDatArr addObject:messageModel];
                        }
                    }
                }
                
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (isRefresh) {
                    currentDatePickerModel.messageDataArr = [[NSMutableArray alloc]initWithArray:dealDatArr];
                    [self.contentTableView.mj_header endRefreshing];
                }else{
                    [currentDatePickerModel.messageDataArr addObjectsFromArray:dealDatArr];
                    [self.contentTableView.mj_footer endRefreshing];
                    if (!dealDatArr.count) {
                        [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                    }
                }
                
                
                
                self.contentArray = [[NSMutableArray alloc]initWithArray:currentDatePickerModel.messageDataArr];
                [self updateView];
                [self.contentTableView reloadData];
                
            });
            
            
            
        } @catch (NSException *exception) {
            
        } @finally {
            
        }
        
    }
}


#pragma mark- JFGDatePickerDelegate
-(NSInteger)datePickersCollectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.messageDataArray.count;
}

-(UICollectionViewCell *)datePickersCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    JFGDatePickerCollectionViewCell *cell  = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellid" forIndexPath:indexPath];
    MessageVCDateModel *model = self.messageDataArray[indexPath.row];
    if (model.isSelectedDate) {
        cell.viewMode = pickerViewModeSelected;
    }else{
        if (model.isHasMessage) {
            cell.viewMode = pickerViewModeHasData;
        }else{
            cell.viewMode = pickerViewModeNotData;
        }
    }
    cell.contentLabel.text = [NSString stringWithFormat:@"%ld",(long)model.day];
    
    return cell;
}

-(void)datePickersCollectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MessageVCDateModel *model = self.messageDataArray[indexPath.row];
    if (model.isHasMessage && currentDatePickerModel != model) {
        
        JFGDatePickerCollectionViewCell *cell  = (JFGDatePickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:self.datePicker.selectedIndexPath];
        
        JFGDatePickerCollectionViewCell *cell2  = (JFGDatePickerCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        
        MessageVCDateModel *oldModel = [self.messageDataArray objectAtIndex:self.datePicker.selectedIndexPath.row];
        oldModel.isSelectedDate = NO;
        
        if (cell) {
            cell.viewMode = pickerViewModeHasData;
        }
        cell2.viewMode = pickerViewModeSelected;
        self.datePicker.selectedIndexPath = indexPath;
        
        self.datePicker.monthLabel.text = [NSString stringWithFormat:@"%ld月",(long)model.mounth];
        model.isSelectedDate = YES;
        currentDatePickerModel = model;
        
        self.datePicker.monthLabel.text = [NSString stringWithFormat:@"%ld%@",(long)model.mounth, [JfgLanguage getLanTextStrByKey:@"MONTHS"]];
        [self.timeSelectButton setTitle:[self timeSelecedBtnTitleForTimestamp:model.startTimestamp] forState:UIControlStateNormal];
        [self.contentTableView.mj_footer resetNoMoreData];
        [self.contentTableView.mj_footer endRefreshing];
        if (!currentDatePickerModel.messageDataArr.count) {
            [self.contentTableView.mj_header beginRefreshing];
//            [self.camereMsgReq getDataForCid:self.devModel.uuid timestamp:currentDatePickerModel.lastestTimestamp isRefresh:YES];
            
//            if (isDoorBell) {
//                [self.bellMsgReq getDataForCid:self.devModel.uuid timestamp:currentDatePickerModel.lastestTimestamp isRefresh:YES];
//            }else{
                [self.camereMsgReq getDataForCid:self.devModel.uuid timestamp:currentDatePickerModel.lastestTimestamp isRefresh:YES];
            //}
        }else{
            [self.contentTableView.mj_header endRefreshing];
            self.contentArray = [[NSMutableArray alloc]initWithArray:currentDatePickerModel.messageDataArr];
            [self.contentTableView reloadData];
        }
    }
}



#pragma mark - DateRuler
-(void)showDateRuler
{
    self.datePicker.hidden = NO;
    [UIView animateWithDuration:0.3 animations:^{
        self.datePicker.bottom = self.view.height+64;
    }];
    self.editButton.enabled = NO;
}

-(void)disMissDateRuler
{
    if (self.datePicker.hidden) {
        return;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.datePicker.top = self.view.height+64;
    } completion:^(BOOL finished) {
        self.datePicker.hidden = YES;
    }];
    self.editButton.enabled = YES;
}


//清空未读数
-(void)clearUnreadCount
{
    
}

//判断sd卡是否存在
-(void)getSDCard
{
    DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
    seg.msgId = 222;
    seg.version = 0;
    
    
    [[JFGSDKDataPoint sharedClient] robotGetDataByTimeWithPeer:self.cid msgIds:@[seg] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                id obj = [MPMessagePackReader readData:seg.value error:nil];
                if (seg.msgId == 204) {
                    if (obj && [obj isKindOfClass:[NSArray class]]) {
                        
                        NSArray *objArr = obj;
                        if (objArr.count == 4) {
                            id obj1 = [objArr objectAtIndex:2];
                            id obj2 = [objArr objectAtIndex:3];
                            if ([obj2 isKindOfClass:[NSNumber class]]) {
                                isHasSDCard = [obj2 boolValue];
                            }
                            if ([obj1 isKindOfClass:[NSNumber class]]) {
                                SDCardErrorType = [obj1 intValue];
                                if (SDCardErrorType != 0) {
                                    
                                }else{
                                    
                                }
                            }
                        }
                        
                    }
                    
                    [self.contentTableView reloadData];
                }else if (seg.msgId == 222){
                    
                    if ([obj isKindOfClass:[NSArray class]]) {
                        NSArray *sourceArr = obj;
                        if (sourceArr.count>1) {
                            
                            @try {
                                BOOL ishasSDCard = [sourceArr[0] boolValue];
                                int errorType = [sourceArr[1] intValue];
                                isHasSDCard = ishasSDCard;
                                SDCardErrorType = errorType;
                            } @catch (NSException *exception) {
                                
                            } @finally {
                                
                            }
                            
                        }
                    }
                    
                    
                }
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
    
}

-(void)loadLocalData
{
    [JFGSDK appendStringToLogFile:@"505开始请求本地数据"];
    NSArray *cacheArr = [JfgCacheManager getCacheForWarnPicWithCid:self.cid];
    self.messageDataArray = [[NSMutableArray alloc]initWithArray:cacheArr];
    //选中最近时间点
    for (MessageVCDateModel *model in self.messageDataArray) {
        
        if (model.isHasMessage) {
            
            model.isSelectedDate = YES;
            if (currentDatePickerModel) {
                currentDatePickerModel.isSelectedDate = NO;
            }
            currentDatePickerModel = model;
            NSInteger index = [self.messageDataArray indexOfObject:model];
            self.datePicker.selectedIndexPath = [NSIndexPath indexPathForRow:index inSection:0];
            self.datePicker.monthLabel.text = [NSString stringWithFormat:@"%ld%@",(long)model.mounth, [JfgLanguage getLanTextStrByKey:@"MONTHS"]];
            [self.timeSelectButton setTitle:[self timeSelecedBtnTitleForTimestamp:model.startTimestamp] forState:UIControlStateNormal];
            
        }
        
    }
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    self.datePicker.top = keyWindows.height;
    self.datePicker.hidden = YES;
    if (self.datePicker.superview == nil) {
        [keyWindows addSubview:self.datePicker];
    }
    self.contentArray = [[NSMutableArray alloc]initWithArray:currentDatePickerModel.messageDataArr];
    [self.contentTableView reloadData];
    [self.datePicker reloadData];
    [self isShowNoDataView];
    [self updateView];
}


//无数据显示
-(void)isShowNoDataView
{
    for (MessageVCDateModel *model in self.messageDataArray){
        if (model.isHasMessage) {
            return;
        }
    }
    self.topBgView.hidden = YES;
    self.topLineLabel.hidden = YES;
    //self.contentTableView.hidden = YES;
    self.contentTableView.scrollEnabled = NO;
    self.noDataView.hidden = NO;
    self.noDataView.y = self.contentTableView.height * 0.5;
    if (self.bottomSelectView != nil) {
        [UIView animateWithDuration:0.33f animations:^{
            [self.bottomSelectView setFrame:CGRectMake(0, self.view.frame.size.height, Kwidth, 50)];
            [self.contentTableView setEditing:NO];
            [self.contentTableView setFrame:CGRectMake(0, self.topLineLabel.bottom, Kwidth, kheight-64-44-0.5)];
        } completion:^(BOOL finished) {
            [self.bottomSelectView removeFromSuperview];
        }];
    }
}

#pragma mark - JFGSDK



-(NSString *)timeSelecedBtnTitleForTimestamp:(int64_t)timestamp
{
    int64_t currentTimestamp = [[NSDate date] timeIntervalSince1970];
    if (timestamp > currentTimestamp) {
        return @"";
    }
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDate *date2 = [NSDate date];
    
    unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;
    NSDateComponents* comp1 = [calendar components:unitFlags fromDate:date1];
    NSDateComponents* comp2 = [calendar components:unitFlags fromDate:date2];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    NSString *timestr;
    if ([comp2 day] == [comp1 day] &&
        [comp1 month] == [comp2 month] &&
        [comp1 year]  == [comp2 year]) {
        //今天
        [dateFormatter setDateFormat:@"MM/dd"];
        timestr = [NSString stringWithFormat:@"%@(%@)",[dateFormatter stringFromDate:date1],[JfgLanguage getLanTextStrByKey:@"DOOR_TODAY"]];
        
    }else if ([comp1 year]  == [comp2 year]){
        //同一年
        [dateFormatter setDateFormat:@"MM/dd"];
        timestr = [dateFormatter stringFromDate:date1];
    }else{
        //去年
        [dateFormatter setDateFormat:@"yyyy/MM/dd"];
        timestr = [dateFormatter stringFromDate:date1];
    }
    return timestr;
}


- (NSString *)transToyyyyMMddhhmmss:(NSString *)timsp {
    
    NSTimeInterval time=[timsp doubleValue];//如果不使用本地时区,因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    
    //实例化一个NSDateFormatter对象
    
    NSString *currentDateStr = [self.ddhhDateFormatter stringFromDate: detaildate];
    
    return currentDateStr;
}

-(NSDateFormatter *)ddhhDateFormatter
{
    if (_ddhhDateFormatter == nil) {
        _ddhhDateFormatter = [[NSDateFormatter alloc] init];
        [_ddhhDateFormatter setTimeZone:[NSTimeZone localTimeZone]];//设置本地时区
        //设定时间格式,这里可以设置成自己需要的格式
        [_ddhhDateFormatter setDateFormat:@"yyyyMMddhhmmss"];
    }
    return _ddhhDateFormatter;
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.contentArray.count) {
        if (!self.timeSelectButton.selected) {
            self.editButton.enabled = YES;
        }
        self.noDataView.hidden = YES;
    }else{
        self.editButton.enabled = NO;
        self.noDataView.hidden = NO;
    }
    return self.contentArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    if (messageModel.msgID == dpMsgBase_SDStatus) {
        return [self sdCardTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if(messageModel.msgID == dpMsgCamera_WarnMsg || messageModel.msgID == dpMsgCamera_WarnMsgV3 || messageModel.msgID == 401 || messageModel.msgID == 403){
        return [self warnPicTableView:tableView cellForRowAtIndexPath:indexPath];
    }
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"good"];
    return cell;
}

- (UITableViewCell *)warnPicTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    static NSString *cell1ID = @"cell1Identifier";
    static NSString *cell2ID = @"cell2Identifier";
    static NSString *cell3ID = @"cell3Identifier";
    BOOL isCanShowVideoBtn = NO;
    
    if (!isShared) {//被分享设备不显示查看历史视频功能按钮
        
        NSTimeInterval nowTime = [[NSDate date] timeIntervalSince1970];
        if ((nowTime - messageModel.timestamp > 60*30) && messageModel.is_record) {
            isCanShowVideoBtn = YES;
        }
        
        if (messageModel.realyMsgID == 401 || messageModel.realyMsgID == 403) {
            
            NSArray *osArr = @[@52,@17,@27,@50,@42];
            for (NSNumber *os in osArr) {
                
                if ([os integerValue] == [self.devModel.pid integerValue]) {
                    isCanShowVideoBtn = messageModel.is_record;
                    break;
                }
                
            }
            
        }
    }
    
    //720设置暂时不显示历史视频按钮
    if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeEyeCamera) {
        isCanShowVideoBtn = NO;
    }
    
    __weak typeof(self) weakSelf = self;
    if (messageModel.msgImages.count>=3) {
        MessageViewCell1 *cell =[tableView dequeueReusableCellWithIdentifier:cell1ID];;
        if (!cell) {
            cell = [[MessageViewCell1 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell1ID];
        }
        cell.deleteBtn.hidden = messageModel.isShowVideoBtn;
        cell.imgv1.url = [messageModel.msgImages objectAtIndex:0];
        cell.imgv2.url = [messageModel.msgImages objectAtIndex:1];
        cell.imgv3.url = [messageModel.msgImages objectAtIndex:2];
        cell.imgv1.fileName = [NSString stringWithFormat:@"%.0f_1.jpg",messageModel.timestamp];
        cell.imgv2.fileName = [NSString stringWithFormat:@"%.0f_2.jpg",messageModel.timestamp];
        cell.imgv3.fileName = [NSString stringWithFormat:@"%.0f_3.jpg",messageModel.timestamp];
        cell.imgv1.deviceVersion = cell.imgv2.deviceVersion = cell.imgv3.deviceVersion = messageModel.deviceVersion;
        cell.imgv1.selectedIndexPath = cell.imgv2.selectedIndexPath = cell.imgv3.selectedIndexPath = indexPath;
        if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeSinglefisheyeCamera || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360 || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeEyeCamera) {
            
            cell.imgv1.isPanorama =  cell.imgv2.isPanorama = cell.imgv3.isPanorama = YES;
            
        }
        
        [cell.imgv1 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        [cell.imgv2 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:1] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        [cell.imgv3 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:2] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        cell.imgv1.regionType = cell.imgv2.regionType = cell.imgv3.regionType = messageModel.flag;

        if ([messageModel.tly isKindOfClass:[NSString class]]) {
            cell.imgv1.tly = cell.imgv2.tly = cell.imgv3.tly = [messageModel.tly intValue];
        }
        
        cell.imgv1.cid = cell.imgv2.cid = cell.imgv3.cid = self.cid;
        cell.imgv2.pid = cell.imgv1.pid = self.devModel.pid;
        cell.label.text = messageModel.topString;
        
        if (messageModel.manNum != 0) {
            
            NSMutableAttributedString *hintString=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ (%@%d个人)",messageModel.topString,[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"],messageModel.manNum]];
            
            //[UIColor colorWithHexString:@"#666666"]
            //获取要调整颜色的文字位置,调整颜色
            NSRange range1 = [[hintString string]rangeOfString:messageModel.topString];
            [hintString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#666666"] range:range1];
            
            NSRange range2=[[hintString string]rangeOfString:[NSString stringWithFormat:@" (%@%d个人)",[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"],messageModel.manNum]];
            [hintString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range2];
            
            cell.label.attributedText = hintString;
        }
        
        cell.hiddenSubviews =tableView.isEditing;
        cell.avBtn.hidden = YES;
        [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
            [weakSelf deleteSingleCell:@[indexPath]];
        }];
        cell.timestamp = messageModel._version;
        cell.avBtn.tag = indexPath.row+223;
        [cell.avBtn removeTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess || !isHasSDCard || !isCanShowVideoBtn || SDCardErrorType !=0) {
            
            cell.avBtn.hidden = YES;
            //NSLog(@"该隐藏");
        }else{
            
            cell.avBtn.hidden = NO;
            if (self.isDeviceOffline) {
                cell.avBtn.enabled = NO;
            }else{
                cell.avBtn.enabled = YES;
            }
            
        }
        cell.hiddenAvBtn = cell.avBtn.hidden;
        if (isShared) {
            cell.deleteBtn.alpha = 0;
        }else{
            cell.deleteBtn.alpha = 1;
        }
        return cell;
        
    }else if (messageModel.msgImages.count >= 2){
        MessageViewCell2 *cell =[tableView dequeueReusableCellWithIdentifier:cell2ID];;
        
        if (!cell) {
            cell = [[MessageViewCell2 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell2ID];
        }
        
        cell.hiddenSubviews =tableView.isEditing;
        cell.deleteBtn.hidden = messageModel.isShowVideoBtn;
        cell.imgv1.url = [messageModel.msgImages objectAtIndex:0];
        cell.imgv2.url = [messageModel.msgImages objectAtIndex:1];
        
        cell.imgv1.fileName = [NSString stringWithFormat:@"%.0f_1.jpg",messageModel.timestamp];
        cell.imgv2.fileName = [NSString stringWithFormat:@"%.0f_2.jpg",messageModel.timestamp];
        cell.imgv1.regionType = cell.imgv2.regionType = messageModel.flag;
        cell.imgv1.cid = cell.imgv2.cid = self.cid;
        cell.imgv2.pid = cell.imgv1.pid = self.devModel.pid;
        cell.imgv1.selectedIndexPath = cell.imgv2.selectedIndexPath = indexPath;
        cell.imgv1.deviceVersion = cell.imgv2.deviceVersion = messageModel.deviceVersion;
        if ([messageModel.tly isKindOfClass:[NSString class]]) {
            cell.imgv1.tly = cell.imgv2.tly = [messageModel.tly intValue];
        }
        cell.timestamp = messageModel._version;
        
        if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeSinglefisheyeCamera || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360 || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeEyeCamera) {
            
            cell.imgv1.isPanorama =  cell.imgv2.isPanorama = YES;
            
        }
        
        [cell.imgv1 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        [cell.imgv2 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:1] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        cell.label.text = messageModel.topString;
        
        [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
            
            [weakSelf deleteSingleCell:@[indexPath]];
        }];
        cell.avBtn.tag = indexPath.row+223;
        [cell.avBtn removeTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess || !isHasSDCard || !isCanShowVideoBtn || SDCardErrorType != 0) {
            cell.avBtn.hidden = YES;
        }else{
            cell.avBtn.hidden = NO;
            if (self.isDeviceOffline) {
                cell.avBtn.enabled = NO;
            }else{
                cell.avBtn.enabled = YES;
            }
        }
        cell.hiddenAvBtn = cell.avBtn.hidden;
        if (isShared) {
            cell.deleteBtn.alpha = 0;
        }else{
            cell.deleteBtn.alpha = 1;
        }
        return cell;
    }else if (messageModel.msgImages.count >= 1){
        MessageViewCell3 *cell =[tableView dequeueReusableCellWithIdentifier:cell3ID];;
        if (!cell) {
            cell = [[MessageViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell3ID];
        }
        cell.imgv1.url = [messageModel.msgImages objectAtIndex:0];
        [cell.imgv1 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        cell.imgv1.fileName = [NSString stringWithFormat:@"%.0f_1.jpg",messageModel.timestamp];
        
        //兼容以前门铃图片
        if (messageModel.imageNum == 0) {
            cell.imgv1.fileName = [NSString stringWithFormat:@"%.0f.jpg",messageModel.timestamp];
        }
        
        cell.imgv1.regionType = messageModel.flag;
        if ([messageModel.tly isKindOfClass:[NSString class]]) {
            cell.imgv1.tly = [messageModel.tly intValue];
        }
        if ([CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeSinglefisheyeCamera || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigType360 || [CommonMethod devBigTypeForOS:self.devModel.pid] == JFGDevBigTypeEyeCamera) {
            
            cell.imgv1.isPanorama = YES;
            
        }
        cell.imgv1.cid = self.cid;
        cell.imgv1.pid = self.devModel.pid;
        cell.imgv1.selectedIndexPath = indexPath;
        cell.imgv1.deviceVersion = messageModel.deviceVersion;
        cell.label.text = messageModel.topString;
        cell.deleteBtn.hidden = messageModel.isShowVideoBtn;
        cell.hiddenSubviews =tableView.isEditing;
        cell.timestamp = messageModel._version;
        [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
            
            [weakSelf deleteSingleCell:@[indexPath]];
        }];
        cell.avBtn.tag = indexPath.row+223;
        [cell.avBtn removeTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess || !isHasSDCard || !isCanShowVideoBtn || SDCardErrorType != 0) {
            cell.avBtn.hidden = YES;
        }else{
            cell.avBtn.hidden = NO;
            if (self.isDeviceOffline) {
                cell.avBtn.enabled = NO;
            }else{
                cell.avBtn.enabled = YES;
            }
        }
        cell.hiddenAvBtn = cell.avBtn.hidden;
        if (isShared) {
            cell.deleteBtn.alpha = 0;
        }else{
            cell.deleteBtn.alpha = 1;
        }
        return cell;
    }else{
        MessageViewCell3 *cell =[tableView dequeueReusableCellWithIdentifier:cell3ID];
        return cell;
    }
    
}

- (UITableViewCell *)sdCardTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    static NSString *cell4ID = @"cell4Identifier";
    MessageViewCell4 *cell =[tableView dequeueReusableCellWithIdentifier:cell4ID];
    
    if (!cell) {
        cell = [[MessageViewCell4 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell4ID];
    }
    
    cell.hiddenSubviews =tableView.isEditing;
    cell.label.text = messageModel.timeString;
    cell.timestamp = messageModel.timestamp;
    
    if (messageModel.isSDCardOn) {
        if (messageModel.sdcardErrorCode != 0) {
            cell.contentLabel.text = [JfgLanguage getLanTextStrByKey:@"VIDEO_SD_DESC"];
            cell.hiddenAvBtn = NO;
            cell.avBtn.hidden = NO;
            //NSLog(@"cellShow");
        }else{
            cell.contentLabel.text = messageModel.textString;
            cell.hiddenAvBtn = YES;
            cell.avBtn.hidden = YES;
            // NSLog(@"cellShow");
        }
        
    }else{
        cell.contentLabel.text = messageModel.textString;
        cell.hiddenAvBtn = YES;
        cell.avBtn.hidden = YES;
        //NSLog(@"cellShow");
    }
    
    if (isShared) {
        cell.avBtn.hidden = YES;
        cell.deleteBtn.alpha = 0;
    }else{
        cell.deleteBtn.alpha = 1;
    }
    //cell.contentLabel.text = @"测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字";

    __weak typeof(self) weakSelf = self;
    [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
        
        [weakSelf deleteSingleCell:@[indexPath]];
    }];
    
    cell.avBtn.tag = indexPath.row+223;
    [cell.avBtn removeTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
    [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 94*designWscale;
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
//    if (messageModel.msgID != dpMsgBase_SDStatus && messageModel.msgID != dpMsgCamera_WarnMsg &&  messageModel.msgID != dpMsgCamera_WarnMsgV3) {
//        return 1;
//    }
    
    if (messageModel.msgID == dpMsgBase_SDStatus) {
        return height;
    }
    
    switch (messageModel.msgImages.count)
    {
        case 1: //一张
        {
            height = 234*designWscale;
        }
            break;
        case 2: //二张
        {
            height = 269*designWscale;
        }
            break;
        case 3: //三张
        {
            height = 214*designWscale;
        }
            break;
        default:
            break;
    }
    
    
    return height;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self enableBottomDelButton];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (deleteAll) {
        deleteAll = NO;
        self.selectAllButton.selected = NO;
    }
}

#pragma mark - 控件
-(JFGDatePickers *)datePicker
{
    if (!_datePicker) {
        _datePicker = [[JFGDatePickers alloc]initWithFrame:CGRectMake(0, self.view.height, self.view.width, 176*0.5)];
        _datePicker.delegate = self;
    }
    return _datePicker;
}


-(UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.contentTableView.height)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-140)/2.0, 0.2*kheight, 140, 140)];
        iconImageView.image = [UIImage imageNamed:@"png-no-message"];
        [_noDataView addSubview:iconImageView];
        
        UILabel * noShareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImageView.bottom+20, Kwidth, 15)];
        noShareLabel.font = [UIFont systemFontOfSize:15];
        noShareLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        noShareLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_CONTENTS_1"];
        noShareLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:noShareLabel];
        _noDataView.hidden = YES;
    }
    return _noDataView;
}
-(UIView *)topBgView{
    if (!_topBgView) {
        _topBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, 44)];
        _topBgView.backgroundColor = [UIColor whiteColor];
        [_topBgView addSubview:self.timeSelectButton];
        
        if (!isShared) {
            [_topBgView addSubview:self.editButton];
        }
        
    }
    return _topBgView;
}


-(UIButton *)timeSelectButton{
    if (!_timeSelectButton) {
        _timeSelectButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeSelectButton.frame = CGRectMake((Kwidth-126.0)/2.0, 0, 126, 44);
        _timeSelectButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        _timeSelectButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _timeSelectButton.backgroundColor = [UIColor clearColor];
        _timeSelectButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
        _timeSelectButton.titleLabel.font = [UIFont systemFontOfSize:15];
    
        _timeSelectButton.adjustsImageWhenHighlighted =NO;
        [_timeSelectButton setImage:[UIImage imageNamed:@"btn_selectTime_down"] forState:UIControlStateNormal];
        [_timeSelectButton setTitleColor:RGBACOLOR(136, 136, 136, 1) forState:UIControlStateNormal];
        [_timeSelectButton setImageEdgeInsets:UIEdgeInsetsMake(0, 96, 0, 0)];
        [_timeSelectButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -28, 0, 0)];
        [_timeSelectButton addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
        _timeSelectButton.selected = NO;

    }
    return _timeSelectButton;
}
-(DelButton *)editButton{
    if (!_editButton) {
        _editButton = [DelButton buttonWithType:UIButtonTypeCustom];
        [_editButton setFrame:CGRectMake(Kwidth-7-44, 0, 44, 44)];
        _editButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        _editButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _editButton.backgroundColor = [UIColor clearColor];
        _editButton.titleLabel.font = [UIFont fontWithName:@"PingFang SC" size:15];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:15];
        _editButton.adjustsImageWhenHighlighted =NO;
        [_editButton setTitleColor:RGBACOLOR(75, 159, 213, 1) forState:UIControlStateNormal];
        [_editButton setTitleColor:[UIColor colorWithHexString:@"#aaaaaa"] forState:UIControlStateDisabled];
        [_editButton setTitle:[JfgLanguage getLanTextStrByKey:@"EDIT_THEME"] forState:UIControlStateNormal];
        [_editButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
        [_editButton addTarget:self action:@selector(editButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _editButton.selected = NO;

    }
    return _editButton;
}
-(UILabel *)topLineLabel{
    if (!_topLineLabel) {
        _topLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.topBgView.bottom, Kwidth, 0.5)];
        _topLineLabel.backgroundColor = TableSeparatorColor;
    }
    return _topLineLabel;
}
-(UITableView *)contentTableView{
    if (!_contentTableView) {
        _contentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, self.topLineLabel.bottom, Kwidth, kheight-64-44-0.5) style:UITableViewStylePlain];
        _contentTableView.dataSource = self;
        _contentTableView.delegate = self;
        _contentTableView.editing = NO;
        _contentTableView.showsVerticalScrollIndicator = NO;
        _contentTableView.showsHorizontalScrollIndicator = NO;
        [_contentTableView setSeparatorColor:TableSeparatorColor];
        _contentTableView.backgroundColor = [UIColor whiteColor];
        [_contentTableView setSeparatorInset:UIEdgeInsetsMake(0, 37, 0, 0)];
        [_contentTableView setAllowsMultipleSelectionDuringEditing:YES];
        _contentTableView.decelerationRate = 1;
        [_contentTableView registerClass:[MessageViewCell1 class] forCellReuseIdentifier:@"cell1"];
        [_contentTableView registerClass:[MessageViewCell2 class] forCellReuseIdentifier:@"cell2"];
        [_contentTableView registerClass:[MessageViewCell3 class] forCellReuseIdentifier:@"cell3"];
        [_contentTableView registerClass:[MessageViewCell4 class] forCellReuseIdentifier:@"cell4"];
        _contentTableView.tableFooterView = [UIView new];
    }
    return _contentTableView;
}
-(UIView *)bottomSelectView{
    if (!_bottomSelectView) {
        _bottomSelectView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, Kwidth, 50)];
        [_bottomSelectView setBackgroundColor:[UIColor redColor]];
        [_bottomSelectView setBackgroundColor:[UIColor colorWithHexString:@"#f7f8fa"]];
        [_bottomSelectView addSubview:self.selectAllButton];
        [_bottomSelectView addSubview:self.deleteButton];
        [self.selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@30);
            make.top.mas_equalTo(@17.5);
            make.width.mas_greaterThanOrEqualTo(@30);
            make.height.equalTo(@15);
        }];

        [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(@(-30));
            make.top.mas_equalTo(@17.5);
            make.width.mas_greaterThanOrEqualTo(@30);
            make.height.equalTo(@15);
        }];
        [_bottomSelectView addSubview:self.bottomLineLabel];
    }
    return _bottomSelectView;
}
-(DelButton *)selectAllButton{
    if (!_selectAllButton) {
        _selectAllButton = [DelButton buttonWithType:UIButtonTypeCustom];
        [_selectAllButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_selectAllButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_selectAllButton setTitle:[JfgLanguage getLanTextStrByKey:@"SELECT_ALL"] forState:UIControlStateNormal];
        [_selectAllButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
        _selectAllButton.selected = NO;
        [_selectAllButton addTarget:self action:@selector(selectAllCells:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectAllButton;
}
-(DelButton *)deleteButton{
    if (!_deleteButton) {
        _deleteButton = [DelButton buttonWithType:UIButtonTypeCustom];
        [_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_deleteButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor colorWithHexString:@"#e1e1e1"] forState:UIControlStateDisabled];
        [_deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteSelectedCells) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.enabled = NO;
    }
    return _deleteButton;
}
-(UILabel *)bottomLineLabel{
    if (!_bottomLineLabel) {
        _bottomLineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, Kwidth, 0.5)];
        [_bottomLineLabel setBackgroundColor:[UIColor colorWithHexString:@"#dde0e5"]];
    }
    return _bottomLineLabel;
}

-(CamareMsgDataReq *)camereMsgReq
{
    if (!_camereMsgReq) {
        _camereMsgReq = [[CamareMsgDataReq alloc]init];
        _camereMsgReq.delegate = self;
    }
    return _camereMsgReq;
}

-(BellMsgDataReq *)bellMsgReq
{
    if (!_bellMsgReq) {
        _bellMsgReq = [[BellMsgDataReq alloc]init];
        _bellMsgReq.delegate = self;
    }
    return _bellMsgReq;
}

-(NSDateFormatter *)YMDformatter
{
    if (!_YMDformatter) {
        _YMDformatter =[[NSDateFormatter alloc] init];
        [_YMDformatter setDateFormat:@"yyyy.MM.dd"];
    }
    return _YMDformatter;
}
-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter =[[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
    }
    return _dateFormatter;
}



#pragma mark - tapGestureRecognizer
-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.timeSelectButton.selected == YES) {
        [self disMissDateRuler];
        self.timeSelectButton.selected = NO;
    }
}

-(void)dealloc
{
    NSLog(@"msgv dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
