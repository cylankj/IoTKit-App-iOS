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
#import "DeviceInfoVC.h"

@interface MessageViewController ()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate,DJActionRulerDelegate>
{
    NSMutableArray *delCacheArray;
    BOOL isHasSDCard;
    NSInteger SDCardErrorType;//0表示正常使用
    BOOL isEditing;
    BOOL deleteAll;
    BOOL isEnableFooterRefresh;
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
@property(nonatomic, strong)DelButton * selectAllButton;
//编辑状态底部的删除按钮
@property(nonatomic, strong)DelButton * deleteButton;
//编辑状态底部的小线条
@property(nonatomic, strong)UILabel *bottomLineLabel;
//月日年时间格式
@property (nonatomic,strong)NSDateFormatter *YMDformatter;
//日期
@property (nonatomic,strong)NSDateFormatter *dateFormatter;

@property (nonatomic,strong)NSDateFormatter *ddhhDateFormatter;

@property (nonatomic, strong)NSMutableArray * dateArr;
@property (nonatomic, strong)NSMutableArray * contentArray;
@property (nonatomic,strong)DJActionRuler * ruler;
@property (strong, nonatomic)UIView * noDataView;
@end

@implementation MessageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor whiteColor]];

    isEnableFooterRefresh = YES;
    self.contentArray = [NSMutableArray arrayWithCapacity:0];
    [JFGSDK addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData) name:JFGExploreRefreshNotificationKey object:nil];
    [self initView];
    
    //清空未读数
    [self delCacheDelData];
    [self clearUnreadCount];
    [self loadLocalData];
    [self refreshData];
    
}

-(void)delCacheDelData
{
    NSArray *cacheArr = [JfgCacheManager getCacheForWarnPicForDelWithCid:self.cid];
    delCacheArray = [[NSMutableArray alloc]initWithArray:cacheArr];
    NSMutableArray *segList = [NSMutableArray new];
    
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        
        for (MessageModel *model in delCacheArray) {
            DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
            if (model.msgID == dpMsgCamera_WarnMsg) {
                seg.msgId = dpMsgCamera_WarnMsg;
                if (model.deviceVersion == 3) {
                    seg.msgId = dpMsgCamera_WarnMsgV3;
                }
                
            }else{
                seg.msgId = 222;
            }
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
    if (self.contentArray) {
        [JfgCacheManager cacheWarnPicMsgList:self.contentArray forCid:self.cid];
    }
    if (delCacheArray) {
        [JfgCacheManager cacheWarnPicForDelMsgList:delCacheArray forCid:self.cid];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getSDCard];
}



-(void)initView
{
    [self.view addSubview:self.topBgView];
    [self.view addSubview:self.topLineLabel];
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.contentTableView];
    [self stepRefresh];
    [self updateView];
}

- (void)updateView
{
    if (self.contentArray.count == 0)
    {
        self.topBgView.hidden = YES;
        self.topLineLabel.hidden = YES;
        self.noDataView.hidden = NO;
        self.contentTableView.hidden = YES;
        
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
        self.noDataView.hidden = YES;
        self.contentTableView.hidden = NO;
        self.contentTableView.mj_footer.hidden = NO;
    }
    [self.contentTableView reloadData];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication].delegate.window addSubview:self.ruler];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillDisappear:) name:@"JFGJumpingRootView" object:nil];
}


-(void)viewWillDisappear:(BOOL)animated{
    if (self.timeSelectButton.selected == YES) {
        [self selectDate:self.timeSelectButton];
    }
#warning 执行刷新列表干嘛？
    //[JFGSDK refreshDeviceList];
    [super viewWillDisappear:animated];
}

-(void)stepRefresh
{
    self.contentTableView.mj_header = [JFGRefreshLoadingHeader headerWithRefreshingBlock:^{
        
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            [self.contentTableView.mj_footer resetNoMoreData];
            [self refreshData];
        }else{
            [CommonMethod showNetDisconnectAlert];
            [self.contentTableView.mj_header endRefreshing];
        }
        
        
    }];
    
    
    self.contentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
            
            [self.contentTableView.mj_footer endRefreshing];
            [CommonMethod showNetDisconnectAlert];
            return ;
        }
        
        if (self.contentTableView.mj_footer.state != MJRefreshStateRefreshing) {
            if (!isEnableFooterRefresh) {
                [self.contentTableView.mj_footer endRefreshing];
                return;
            }
        }
        
        MessageModel *messageModel = [self.contentArray lastObject];
        
        
        __weak typeof(self)weakSelf = self;
        [[dataPointMsg shared] packMixDataPoint:self.cid version:messageModel._version dps:@[@(dpMsgCamera_WarnMsg),@(222),@(dpMsgCamera_WarnMsgV3)] asc:NO success:^(NSMutableArray *arr) {
            
            [weakSelf.contentTableView.mj_footer endRefreshing];
            if (!arr) {
                [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
                return ;
            }
            
            BOOL isExistData = NO;
            for (NSArray *subArr in arr) {
                if (subArr.count != 0) {
                    isExistData = YES;
                    break;
                }
            }
            if (!isExistData) {
                [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
                return;
            }
            
            
            //NSLog(@"%@",arr);
            
            [weakSelf initModel:arr];
            [weakSelf updateView];
            //NSLog(@"时间%@",self.dateArr);
            [weakSelf.ruler loadDateStringArray:weakSelf.dateArr markedDateString:[weakSelf.dateArr firstObject]];
            
            if (self.selectAllButton.isSelected) {
                for (int i=0; i<self.contentArray.count; i++) {
                    [self.contentTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
            }
            isEnableFooterRefresh = NO;
            int64_t delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                
                isEnableFooterRefresh = YES;
                
            });
            
        } failed:^(RobotDataRequestErrorType error) {
            [weakSelf.contentTableView.mj_footer endRefreshing];
        }];

    }];
    
    MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.contentTableView.mj_footer;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    footer.automaticallyHidden = YES;
    //LOADING
}

#pragma mark - Button Action
-(void)selectDate:(UIButton *)button{
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
            [self.contentTableView setEditing:!self.contentTableView.isEditing];
            [self.contentTableView setFrame:CGRectMake(0, self.topLineLabel.bottom, Kwidth, kheight-64-44-0.5-50)];
        } completion:^(BOOL finished) {
            //[self.contentTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }];
    }else{
        //[self.contentTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        isEditing = NO;
        [self showRefreshController];
        self.selectAllButton.selected = NO;
        [UIView animateWithDuration:0.33f animations:^{
            [self.bottomSelectView setFrame:CGRectMake(0, self.view.frame.size.height, Kwidth, 50)];
            [self.contentTableView setEditing:!self.contentTableView.isEditing];
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

-(void)deleteSingleCell:(NSArray <NSIndexPath *> *)indexPaths {
    [DJActionSheet showDJActionSheetWithTitle:[JfgLanguage getLanTextStrByKey:@"Tips_SureDelete"] buttonTitleArray:@[[JfgLanguage getLanTextStrByKey:@"DELETE"],[JfgLanguage getLanTextStrByKey:@"CANCEL"]] actionType:actionTypeDelete defaultIndex:0 didSelectedBlock:^(NSInteger index) {
        if(index == 0) {
            NSInteger row = [indexPaths objectAtIndex:0].row;
            if (self.contentArray.count > row) {
                MessageModel *model = [self.contentArray objectAtIndex:row];
                [self deleteServerData:@[model]];
            }
            [self.contentArray removeObjectAtIndex:[indexPaths objectAtIndex:0].row];
            [_contentTableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationBottom];
            [self updateView];
            
        }
        
    } didDismissBlock:nil];
}

-(void)deleteServerData:(NSArray *)delList
{
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
            if (model.msgID == dpMsgCamera_WarnMsg) {
                seg.msgId = dpMsgCamera_WarnMsg;
                if (model.deviceVersion == 3) {
                    seg.msgId = dpMsgCamera_WarnMsgV3;
                }
            }else{
                seg.msgId = 222;
            }
            seg.version = model.timestamp*1000;
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
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [CommonMethod showNetDisconnectAlert];
        return ;
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag-223 inSection:0];
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];

    if (messageModel.msgID == dpMsgBase_SDStatus) {
        //sd卡需要格式化，直接跳转设备详情
        DeviceInfoVC * infoVC = [[DeviceInfoVC alloc]init];
        infoVC.cid = self.cid;
        if (self.devModel.deviceType == JFGDeviceTypeCameraWifi) {
            infoVC.pType = productType_WIFI;
        }else{
            infoVC.pType = productType_3G;
        }
        if ([self.devModel.alias isEqualToString:@""]) {
            infoVC.alis = self.devModel.uuid;
        }else{
            infoVC.alis = self.devModel.alias;
        }
        [self.navigationController pushViewController:infoVC animated:YES];
        
    }else{
        
        sender.enabled = NO;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(lookHistoryForTimestamp:)]) {
            MessageViewCell *cell = [_contentTableView cellForRowAtIndexPath:indexPath];
            [self.delegate lookHistoryForTimestamp:cell.timestamp];
        }
        //JFGLookHistoryVideo
        int64_t delayInSeconds = 1.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            sender.enabled = YES;
            
        });
    }
    
   
    //NSLog(@"%@",cell.label.text);
}
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
            for (int i=0; i<2; i++) {
                DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
                if (i == 0) {
                    seg.msgId = dpMsgCamera_WarnMsg;
                }else{
                    seg.msgId = 222;
                }
                seg.version = -1;
                [segList addObject:seg];
            }
            [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:self.cid queryDps:segList success:^(NSString *identity, int ret) {
                
                NSLog(@"identity:%@  ret:%d",identity,ret);
                
            } failure:^(RobotDataRequestErrorType type) {
                
            }];
        }
        
        [self.contentArray removeAllObjects];
        [self.contentTableView reloadData];

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
#pragma mark - DateRuler
-(void)showDateRuler{
    [self.ruler setFrame:CGRectMake(0, kheight-74, Kwidth, 74)];
    self.editButton.enabled = NO;
}
-(void)disMissDateRuler{
    [self.ruler setFrame:CGRectMake(0, kheight, Kwidth, 74)];
    self.editButton.enabled = YES;
}
#pragma mark actionRuler
-(void)actionRuler:(DJActionRuler *)actionRuler willSelectedDateString:(NSString *)aDateString{
    //NSLog(@"willSelectedDateString");
    
}
-(void)actionRuler:(DJActionRuler *)actionRuler didSelectedDateString:(NSString *)aDateString
{   
    for (int i = 0; i < self.contentArray.count; i++)
    {
        MessageModel *m = [self.contentArray objectAtIndex:i];
        NSString *mDateStr = [JfgTimeFormat transToyyyyMMddhhmmssWithTime:m.timestamp];
        if ([mDateStr isEqualToString:aDateString])
        {
            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
    
    NSDate *showDate =[self.dateFormatter dateFromString:aDateString];
    int64_t timestamp = [showDate timeIntervalSince1970];
    NSString *titleStr = [self timeSelecedBtnTitleForTimestamp:timestamp];
    
    //NSString *dayString =[self.YMDformatter stringFromDate:showDate];
    [self.timeSelectButton setTitle:titleStr forState:UIControlStateNormal];
    
}

//清空未读数
-(void)clearUnreadCount
{
    
}

//判断sd卡是否存在
-(void)getSDCard
{
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@(204)] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                if (seg.msgId == 204) {
                    id obj = [MPMessagePackReader readData:seg.value error:nil];
                    
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
    self.contentArray = [[NSMutableArray alloc]initWithArray:cacheArr];
    [self.dateArr removeAllObjects];
    
    for (MessageModel *messageModel in self.contentArray) {
        
        if(messageModel.timestamp <= [[NSDate date] timeIntervalSince1970]) {
            [self.dateArr addObject:[self transToyyyyMMddhhmmss:[NSString stringWithFormat:@"%d",(int)messageModel.timestamp]]];
        }
    }
    MessageModel * lastM= [self.contentArray firstObject];
    if (lastM.timestamp > [[NSDate date] timeIntervalSince1970]) {
        for (MessageModel * _last in self.contentArray) {
            
            if (_last.timestamp <= [[NSDate date] timeIntervalSince1970]) {
                lastM = _last;
                break;
            }
        }
    }
    [self.timeSelectButton setTitle:[self timeSelecedBtnTitleForTimestamp:lastM.timestamp] forState:UIControlStateNormal];
    [self.ruler loadDateStringArray:self.dateArr markedDateString:[self.dateArr firstObject]];
    [self.contentTableView reloadData];
    [self updateView];
}

#pragma mark - JFGSDK
-(void)refreshData
{
    [JFGSDK appendStringToLogFile:@"505开始请求网络数据"];
    __weak typeof(self)weakSelf = self;
    [[dataPointMsg shared] packMixDataPoint:self.cid version:0 dps:@[@(dpMsgCamera_WarnMsg),@(222),@(dpMsgCamera_WarnMsgV3)] asc:NO success:^(NSMutableArray *arr) {
        
        [self.contentTableView.mj_header endRefreshing];
        if (!arr) {
            [JFGSDK appendStringToLogFile:@"505网络请求没有数据"];
            return ;
        }else{
            [JFGSDK appendStringToLogFile:@"505网络请求有数据"];
        }
        //NSLog(@"%@",arr);

        [self.contentArray removeAllObjects];
        [self.dateArr removeAllObjects];
        
        [weakSelf initModel:arr];
        [weakSelf updateView];
        //NSLog(@"时间%@",self.dateArr);
        [weakSelf.ruler loadDateStringArray:weakSelf.dateArr markedDateString:[weakSelf.dateArr firstObject]];
        
        if (isEditing) {
            [self editButtonAction:self.editButton];
        }
        

    } failed:^(RobotDataRequestErrorType error) {
        [self.contentTableView.mj_header endRefreshing];
    }];

}


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

- (void)initModel:(NSMutableArray *)array
{
    @try
    {
        NSArray *dataArray = [array firstObject];
        
//        if (delCacheArray.count) {
//            
//            NSMutableArray *copyData = [[NSMutableArray alloc]initWithArray:dataArray];
//            for (NSDictionary *dataDict in dataArray){
//                
//                for (MessageModel *model in delCacheArray) {
//                    
//                    NSTimeInterval timestamp = 0;
//                    switch ([[dataDict objectForKey:dpIdKey] intValue]){
//                            
//                        case dpMsgCamera_WarnMsgV3:
//                        case dpMsgCamera_WarnMsg:{
//                            NSArray *values = [dataDict objectForKey:dpValueKey];
//                            timestamp = [[values objectAtIndex:0] doubleValue];
//                            
//                        }
//                            break;
//                        case dpMsgBase_SDStatus:{
//                            timestamp = [[dataDict objectForKey:dpTimeKey] longLongValue];
//                        }
//                            break;
//
//                            
//                    }
//                    
//                    if (timestamp == 0) {
//                        [copyData removeObject:dataDict];
//                        break;
//                    }
//                    
//                    if (model.timestamp == timestamp) {
//                        [copyData removeObject:dataDict];
//                        break;
//                    }
//                    
//                   
//                   
//                    
//                }
//                
//            }
//            
//            dataArray = [[NSArray alloc]initWithArray:copyData];
//            
//        }
        
        for (NSDictionary *dataDict in dataArray)
        {
            MessageModel *messageModel = [[MessageModel alloc] init];
            
            switch ([[dataDict objectForKey:dpIdKey] intValue])
            {
                case dpMsgCamera_WarnMsgV3:
                case dpMsgCamera_WarnMsg:
                {
                    messageModel.msgID = dpMsgCamera_WarnMsg;
                    messageModel.cid = self.cid;
                    messageModel._version = [[dataDict objectForKey:dpTimeKey] longLongValue];
                    NSArray *values = [dataDict objectForKey:dpValueKey];
                    messageModel.timestamp = [[values objectAtIndex:0] doubleValue];
                    messageModel.flag = [[values objectAtIndex:3] intValue];
                    messageModel.imageNum = [[values objectAtIndex:2] intValue];
                    if (values.count>4) {
                        messageModel.tly = [values objectAtIndex:4];
                    }else{
                        messageModel.tly = @"1";
                    }
                    if ([[dataDict objectForKey:dpIdKey] intValue] == dpMsgCamera_WarnMsgV3) {
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
                    messageModel._version = [[dataDict objectForKey:dpTimeKey] longLongValue];
                    messageModel.timestamp = [[dataDict objectForKey:dpTimeKey] doubleValue]/1000;
                    
                    id obj = [dataDict objectForKey:dpValueKey];
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
                        
//                        if (objArr.count == 4) {
//                            id obj1 = [objArr objectAtIndex:2];
//                            id obj2 = [objArr objectAtIndex:3];
//                            if ([obj2 isKindOfClass:[NSNumber class]]) {
//                                messageModel.isSDCardOn = [obj2 boolValue];
//                            }
//                            if ([obj1 isKindOfClass:[NSNumber class]]) {
//                                messageModel.sdcardErrorCode = [obj1 intValue];
//                                if (messageModel.sdcardErrorCode != 0) {
//                                    messageModel.isShowVideoBtn = YES;
//                                }else{
//                                    messageModel.isShowVideoBtn = NO;
//                                }
//                            }
//                            
//                            
//                        }
                        
                    }
                    
                    
                }
                    break;
            }
            
            //过滤掉比当前大的时间
            if(messageModel.timestamp <= [[NSDate date] timeIntervalSince1970] && messageModel.timestamp > 10000) {
                [self.dateArr addObject:[self transToyyyyMMddhhmmss:[NSString stringWithFormat:@"%d",(int)messageModel.timestamp]]];
                if ([[dataDict objectForKey:dpIdKey] intValue] == dpMsgCamera_WarnMsg) {
                    if (messageModel.msgImages.count > 0) {
                        [self.contentArray addObject:messageModel];
                    }
                }else{
                    [self.contentArray addObject:messageModel];
                }
            }
            
            
            

        }
        MessageModel * lastM= [self.contentArray firstObject];
        if (lastM.timestamp > [[NSDate date] timeIntervalSince1970]) {
            for (MessageModel * _last in self.contentArray) {
                
                if (_last.timestamp <= [[NSDate date] timeIntervalSince1970]) {
                    lastM = _last;
                    break;
                }
            }
            
        }
        
        NSString *title = [self timeSelecedBtnTitleForTimestamp:lastM.timestamp];
        NSLog(@"timeee:%@",title);
        [self.timeSelectButton setTitle:title forState:UIControlStateNormal];
        
    }
    @catch (NSException *exception)
    {
        
    }
    @finally
    {
        
    }
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self updateTimeSelectedText];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self updateTimeSelectedText];
    }
}

- (void)updateTimeSelectedText {
    
    NSArray * cells =[self.contentTableView visibleCells];
    
    if (!cells.count) {
        return;
    }
    
    UITableViewCell * cell = [cells objectAtIndex:0];
    NSIndexPath * indexPath = [self.contentTableView indexPathForCell:cell];
    
    if (self.dateArr.count > indexPath.row) {
        NSString * time = [self.dateArr objectAtIndex:indexPath.row];
        NSDate *showDate =[self.dateFormatter dateFromString:time];
        [self.ruler scrollToRowForDate:showDate];
    }
    
    if (self.contentArray.count > indexPath.row) {
        MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
        //NSDate *confromTimesp = [NSDate dateWithTimeIntervalSince1970:messageModel.timestamp];
        
        
        //    NSString *dayString =[self.YMDformatter stringFromDate:showDate];
        //
        //    NSDate *showDate =[self.dateFormatter dateFromString:aDateString];
        //int64_t timestamp = [showDate timeIntervalSince1970];
        NSString *titleStr = [self timeSelecedBtnTitleForTimestamp:messageModel.timestamp];
        if (titleStr) {
            [self.timeSelectButton setTitle:titleStr forState:UIControlStateNormal];
        }
    }
    
   
    
}


#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.contentArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    if (messageModel.msgID == dpMsgBase_SDStatus) {
        return [self sdCardTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if(messageModel.msgID == dpMsgCamera_WarnMsg || messageModel.msgID == dpMsgCamera_WarnMsgV3){
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
    BOOL is30Min = NO;
    NSTimeInterval c = [[NSDate dateWithTimeIntervalSince1970:messageModel.timestamp] timeIntervalSinceNow];
    if (30*60 > fabs(c)) {
        is30Min = YES;
    }
    
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
        if ([self.devModel.pid intValue] == 18 || [self.devModel.pid intValue] == 19 ||[self.devModel.pid intValue] == 20 ||[self.devModel.pid intValue] == 21) {
            
            cell.imgv1.isPanorama =  cell.imgv2.isPanorama = cell.imgv3.isPanorama = YES;
            
        }
        
        [cell.imgv1 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        [cell.imgv2 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:1] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        [cell.imgv3 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:2] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        cell.imgv1.regionType = messageModel.flag;
        cell.imgv2.regionType = messageModel.flag;
        cell.imgv3.regionType = messageModel.flag;
        
        if ([messageModel.tly isKindOfClass:[NSString class]]) {
            cell.imgv1.tly = cell.imgv2.tly = cell.imgv3.tly = [messageModel.tly intValue];
        }
        
        cell.imgv1.cid = self.cid;
        cell.imgv2.cid = self.cid;
        cell.imgv3.cid = self.cid;
        cell.label.text = messageModel.topString;
        cell.hiddenSubviews =tableView.isEditing;
        cell.avBtn.hidden = YES;
        [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
            [self deleteSingleCell:@[indexPath]];
        }];
        cell.timestamp = messageModel._version;
        cell.avBtn.tag = indexPath.row+223;
        [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess || !isHasSDCard || is30Min || SDCardErrorType !=0) {
            
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
        cell.imgv1.regionType = messageModel.flag;
        cell.imgv2.regionType = messageModel.flag;
        cell.imgv1.cid = self.cid;
        cell.imgv2.cid = self.cid;
        cell.imgv1.deviceVersion = cell.imgv2.deviceVersion = messageModel.deviceVersion;
        if ([messageModel.tly isKindOfClass:[NSString class]]) {
            cell.imgv1.tly = cell.imgv2.tly = [messageModel.tly intValue];
        }
        cell.timestamp = messageModel._version;
        
        if ([self.devModel.pid intValue] == 18 || [self.devModel.pid intValue] == 19 ||[self.devModel.pid intValue] == 20 ||[self.devModel.pid intValue] == 21) {
            
            cell.imgv1.isPanorama =  cell.imgv2.isPanorama = YES;
            
        }
        
        [cell.imgv1 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        [cell.imgv2 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:1] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        cell.label.text = messageModel.topString;
        [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
            
            [self deleteSingleCell:@[indexPath]];
        }];
        cell.avBtn.tag = indexPath.row+223;
        [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess || !isHasSDCard || is30Min || SDCardErrorType != 0) {
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
        return cell;
    }else if (messageModel.msgImages.count >= 1){
        MessageViewCell3 *cell =[tableView dequeueReusableCellWithIdentifier:cell3ID];;
        if (!cell) {
            cell = [[MessageViewCell3 alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell3ID];
        }
        cell.imgv1.url = [messageModel.msgImages objectAtIndex:0];
        [cell.imgv1 jfg_setImageWithURL:[messageModel.msgImages objectAtIndex:0] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        cell.imgv1.fileName = [NSString stringWithFormat:@"%.0f_1.jpg",messageModel.timestamp];
        cell.imgv1.regionType = messageModel.flag;
        if ([messageModel.tly isKindOfClass:[NSString class]]) {
            cell.imgv1.tly = [messageModel.tly intValue];
        }
        if ([self.devModel.pid intValue] == 18 || [self.devModel.pid intValue] == 19 ||[self.devModel.pid intValue] == 20 ||[self.devModel.pid intValue] == 21) {
            
            cell.imgv1.isPanorama = YES;
            
        }
        cell.imgv1.cid = self.cid;
        cell.imgv1.deviceVersion = messageModel.deviceVersion;
        cell.label.text = messageModel.topString;
        cell.deleteBtn.hidden = messageModel.isShowVideoBtn;
        cell.hiddenSubviews =tableView.isEditing;
        cell.timestamp = messageModel._version;
        [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
            
            [self deleteSingleCell:@[indexPath]];
        }];
        cell.avBtn.tag = indexPath.row+223;
        [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess || !isHasSDCard || is30Min || SDCardErrorType != 0) {
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
        return cell;
    }
    return nil;
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
    //cell.contentLabel.text = @"测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字测试文字";
    
    [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
        
        [self deleteSingleCell:@[indexPath]];
    }];
    
    cell.avBtn.tag = indexPath.row+223;
    [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 94*designWscale;
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    if (messageModel.msgID != dpMsgBase_SDStatus && messageModel.msgID != dpMsgCamera_WarnMsg &&  messageModel.msgID != dpMsgCamera_WarnMsgV3) {
        
        return 1;
        
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

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
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

-(UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-64)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-140)/2.0, 0.25*kheight, 140, 140)];
        iconImageView.image = [UIImage imageNamed:@"png-no-message"];
        [_noDataView addSubview:iconImageView];
        UILabel * noShareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImageView.bottom+20, Kwidth, 15)];
        noShareLabel.font = [UIFont systemFontOfSize:15];
        noShareLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        noShareLabel.text = [JfgLanguage getLanTextStrByKey:@"NO_CONTENTS_1"];
        noShareLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:noShareLabel];
    }
    return _noDataView;
}
-(UIView *)topBgView{
    if (!_topBgView) {
        _topBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, 44)];
        _topBgView.backgroundColor = [UIColor whiteColor];
        [_topBgView addSubview:self.timeSelectButton];
        [_topBgView addSubview:self.editButton];
        
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
        [_selectAllButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@30);
            make.top.mas_equalTo(@17.5);
            make.width.mas_greaterThanOrEqualTo(@30);
            make.height.equalTo(@15);
        }];

        [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
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
//-(DateRulerView *)dateRulerView{
//    if (!_dateRulerView) {
//        _dateRulerView = [[DateRulerView alloc]initWithFrame:CGRectMake(0, kheight, Kwidth, 74)];
//        _dateRulerView.delegate = self;
//    }
//    return _dateRulerView;
//}
-(DJActionRuler *)ruler{
    if (!_ruler) {
        _ruler = [[DJActionRuler alloc]initWithFrame:CGRectMake(0, kheight, Kwidth, 74)];
        _ruler.rulerDelegate = self;
    }
    return _ruler;
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

- (NSMutableArray *)dateArr
{
    if (_dateArr == nil)
    {
        _dateArr = [[NSMutableArray alloc] init];
    }
    return _dateArr;
}

#pragma mark - tapGestureRecognizer
-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.timeSelectButton.selected == YES) {
        [self disMissDateRuler];
        self.timeSelectButton.selected = NO;
    }
}
#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
