//
//  MsgForAIViewController.m
//  JiafeigouiOS
//
//  Created by yangli on 2017/10/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//  AI摄像头消息页面

#import "MsgForAIViewController.h"
#import "FLGlobal.h"
#import "MessageViewCell.h"
#import "DelButton.h"
#import "UIImageView+JFGImageView.h"
#import "UIButton+Click.h"
#import <Masonry.h>
#import <MJRefresh/MJRefresh.h>
#import "DJActionSheet.h"
#import "MsgAIHeadPortraitView.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import <JFGSDK/MPMessagePackReader.h>
#import "VideoPlayViewController.h"
#import <SDWebImage/SDWebImageCompat.h>
#import "MessageModel.h"
#import "JfgTimeFormat.h"
#import "CamareMsgDataReq.h"
#import <MJRefresh/MJRefresh.h>
#import "JFGRefreshLoadingHeader.h"
#import "LoginManager.h"
#import "CommonMethod.h"
#import "DeviceSettingVC.h"
#import "JfgMsgDefine.h"
#import "MsgForAIRequest.h"
#import "MsgForAIModel.h"
#import "OemManager.h"
#import "JfgCacheManager.h"
#import "JFGRefreshLoadingHeader.h"


#define DateCellMsgID 12234

//是否陌生人不显示大图
//#define CLOSEBIGPIC 0

@interface MsgForAIViewController ()<UITableViewDelegate,UITableViewDataSource,MsgAIHeadPortraitViewDelegate,JFGSDKCallbackDelegate,CamareMsgDataReqDelegate,MsgForAIRequestDelegate,LoginManagerDelegate>
{
    NSMutableArray *delCacheArray;
    BOOL isHasSDCard;
    BOOL isRefresh;
    NSInteger SDCardErrorType;//0表示正常使用
    BOOL isEditing;
    BOOL deleteAll;
    BOOL isEnableFooterRefresh;
    BOOL isShared;
    BOOL hasNewMsg;
    BOOL isShowScrollerTopBtn;
    MessageVCDateModel *currentDatePickerModel;
    NSString *currentPerson;//当前显示数据
    NSString *currentPersonName;
}
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
//编辑按钮
@property (nonatomic,strong)DelButton *editButton;
//箭头按钮
@property (nonatomic,strong)UIButton *arrowButton;

@property (nonatomic,strong)UIButton *scrollerTopBtn;

@property (nonatomic,strong)UIButton *backForHeader;

@property (nonatomic,strong)UILabel *headerLabelForTime;

@property (nonatomic,strong)MsgAIHeadPortraitView *contentHeaderView;

@property (nonatomic,strong)UIView *noDataView;

//当前用于显示的数据
@property (nonatomic,strong)NSMutableArray *contentArray;

//所有数据
@property (nonatomic,strong)NSCache *allContentCache;

//单独存储“全部”选项的数据，因为NSCache会根据缓存先后，自动清空数据，防止“全部”选项数据被清空
@property (nonatomic,strong)NSMutableArray *allMsgArray;

//NSCache没有提供遍历方法，只能通过key查询，所以保存所有的key
@property (nonatomic,strong)NSMutableArray *allMsgKeyArray;

//获取摄像头数据
@property (nonatomic,strong)CamareMsgDataReq *camereMsgReq;

//根据face_id或者persopn_id获取数据
@property (nonatomic,strong)MsgForAIRequest *msgAIReq;

@end

@implementation MsgForAIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.cid = self.devModel.uuid;
    
    [self initModel];
    [self stepRefresh];
    [self.view addSubview:self.contentTableView];
    [self.view addSubview:self.scrollerTopBtn];
    self.contentTableView.tableHeaderView = self.contentHeaderView;
    
    // Do any additional setup after loading the view.
}



-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self getSDCard];
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        
        if (self.contentArray.count == 0) {
            self.contentTableView.mj_footer.hidden = YES;
        }else{
            self.contentTableView.mj_footer.hidden = NO;
        }
        self.contentTableView.mj_header.hidden = NO;
        
    }else{
        self.contentTableView.mj_header.hidden = YES;
        self.contentTableView.mj_footer.hidden = YES;
    }
    [[LoginManager sharedManager] addDelegate:self];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.navigationController.viewControllers.count<1) {
        [self cacheDataToDisk];
        [self.contentHeaderView cacheHeaderData];
        [[LoginManager sharedManager] removeDelegate:self];
    }
}

-(void)loginSuccess
{
    self.contentTableView.mj_header.hidden = NO;
    self.contentTableView.mj_footer.hidden = NO;
}

-(void)initModel
{
    if (self.devModel.shareState != DevShareStatuOther) {
        isShared = NO;//不是被分享设备
    }else{
        isShared = YES;//被分享设备
    }
    isEnableFooterRefresh = YES;
    currentPerson = @"all";
    self.contentArray = [NSMutableArray arrayWithCapacity:0];
    
    [JFGSDK addDelegate:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(registerFaceSuccess) name:@"AIFaceRegisterSuccess" object:nil];
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        
        [self reqAllDataWithTimestamp:0];
       
    }else{
        [self getCacheData];
    }
}

//取消编辑状态
-(void)cancelEditingState
{
    if (self.editButton.selected) {
        [self editButtonAction:self.editButton];
    }
}

-(void)hasNewMsgNotification
{
    [self.contentHeaderView hasNewMsgNotification];
    hasNewMsg = YES;
}

-(void)refreshTimeForTop
{
    if (self.contentArray.count>0) {
        MessageModel *messageModel = [self.contentArray objectAtIndex:0];
        NSString * time = [self timeSelecedBtnTitleForTimestamp:messageModel.timestamp];
        self.headerLabelForTime.text = time;
    }
}

-(void)registerFaceSuccess
{
    isRefresh = YES;
    [self reqAllDataWithTimestamp:0];
    [self.contentHeaderView reqData];//刷新头部
}

#pragma mark- 头部cell回调
//tableViewHeader 高度改变代理
-(void)msgAIHeadPortraitViewHeightChanged:(CGFloat)height
{
    UIView *headerView = self.contentTableView.tableHeaderView;
    headerView.height = height;
    //[self.contentTableView beginUpdates];
    [self.contentTableView setTableHeaderView:headerView];// 关键是这句话
    //[self.contentTableView endUpdates];
    if (self.contentHeaderView.isFamilyshow) {
        self.noDataView.top = (self.view.height-self.contentHeaderView.height-64)*0.14+height;
    }else{
        self.noDataView.top = (self.view.height-self.contentHeaderView.height-64)*0.14+height+44;
    }
    
}

-(void)msgAIHeadPortraitViewDidSelectedCellForModel:(MsgAIheaderModel *)model
{
    if (model.type == AIModelTypeAll) {
        
        if ([currentPerson isEqualToString:@"all"]) {
            return;
        }
        currentPerson = @"all";
        isRefresh = YES;
        self.contentArray = self.allMsgArray;
        [self.contentTableView reloadData];
        [self refreshTimeForTop];
        if (!self.allMsgArray.count || hasNewMsg) {
            if (hasNewMsg) {
                [self.contentHeaderView reqData];
            }
            [self reqAllDataWithTimestamp:0];
        }
        currentPersonName = nil;
        
#ifdef CLOSEBIGPIC
        self.contentTableView.mj_header.hidden = NO;
        self.contentTableView.mj_footer.hidden = NO;
#endif
        
    }else{
        
        NSString *access_id = @"";
        if (model.person_id && ![model.person_id isEqualToString:@""]) {
            access_id = model.person_id;
        }else{
            if (model.faceIDList.count) {
                access_id = model.faceIDList[0];
            }else{
                access_id = @"";
            }
        }
        
        if ([currentPerson isEqualToString:access_id]) {
            return;
        }
        currentPerson = access_id;
        
#ifdef CLOSEBIGPIC
        //坑爹的玩意，居然做好了，让我屏蔽，鬼知道下面有没有bug出现
        self.contentArray = [NSMutableArray new];
        [self.contentTableView reloadData];
        self.contentTableView.mj_header.hidden = YES;
        self.contentTableView.mj_footer.hidden = YES;
#else
        NSMutableArray *memoryCache = [self.allContentCache objectForKey:access_id];
        isRefresh = YES;
        self.contentArray = memoryCache;
        [self.contentTableView reloadData];
        [self refreshTimeForTop];
        if (!memoryCache.count) {
            int type = 0;
            if (self.contentHeaderView.isFamilyshow) {
                type = 2;
            }else{
                type = 1;
            }
            [self reqPersonDataWithType:type accessID:access_id timestamp:0];
            }
            if (model.name && ![model.name isEqualToString:@""]) {
                currentPersonName = model.name;
            }else{
                currentPersonName = nil;
            }
        
            BOOL isExist = NO;
            for (NSString *str in self.allMsgKeyArray) {
                if ([str isEqualToString:access_id]) {
                    isExist = YES;
                    break;
                }
            }
            if (!isExist) {
                [self.allMsgKeyArray addObject:access_id];
            }
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"AIForDidSelectedAccess_ID:%@",access_id]];
        
#endif
        

        
        
    }
    [self cancelEditingState];
}



-(void)msgAIHeadPortraitViewDidUnkonwItemHasData:(BOOL)hasData
{
    if (!hasData) {
        //如果陌生人没有数据，则清空数据
        NSMutableArray *arr = [NSMutableArray new];
        self.contentArray = arr;
        currentPerson = @"";
    }
    self.backForHeader.hidden = NO;
    [self.contentTableView reloadData];
    [self cancelEditingState];
}

-(void)msgAIHeadPortraitViewDelModel:(MsgAIheaderModel *)model isReloadModel:(MsgAIheaderModel *)reloadModel
{
    NSString *access_id = @"";
    BOOL isFamiliar = YES;
    
    if (model.person_id && ![model.person_id isEqualToString:@""]) {
        access_id = model.person_id;
        isFamiliar = YES;
    }else{
        if (model.faceIDList.count) {
            access_id = model.faceIDList[0];
        }
        isFamiliar = NO;
    }
    [self.msgAIReq reqMsgDelAccess:access_id isFamiliar:isFamiliar delMsgAndHeader:YES cid:self.cid];
    [self.allContentCache removeObjectForKey:access_id];
}


-(void)msgAIHeadExpand:(BOOL)isExpand
{
    if (isExpand) {
        [self.contentTableView setContentOffset:CGPointMake(0, 0)];
        self.contentTableView.scrollEnabled = NO;
    }else{
        self.contentTableView.scrollEnabled = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.contentArray.count==0)
    {
        if (self.bottomSelectView.superview) {
            [UIView animateWithDuration:0.33f animations:^{
                [self.bottomSelectView setFrame:CGRectMake(0, self.view.frame.size.height, Kwidth, 50)];
            } completion:^(BOOL finished) {
                [self.bottomSelectView removeFromSuperview];
            }];
        }
        CGFloat headerHeight = self.contentTableView.tableHeaderView.height;
        if (self.contentHeaderView.isFamilyshow) {
            self.noDataView.top = (self.view.height-self.contentHeaderView.height-64)*0.14+headerHeight;
        }else{
            self.noDataView.top = (self.view.height-self.contentHeaderView.height-64)*0.14+headerHeight+44;
        }
        
        self.noDataView.hidden = NO;
        self.editButton.hidden = YES;
        self.headerLabelForTime.hidden = YES;

    }else{
        self.noDataView.hidden = YES;
        self.editButton.hidden = NO;
        self.headerLabelForTime.hidden = NO;
        
    }
    return self.contentArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (!self.contentArray.count && self.contentHeaderView.isFamilyshow) {
        return 1;
    }
    return 44;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( !self.contentArray.count  && self.contentHeaderView.isFamilyshow) {
        [self.editButton removeFromSuperview];
        //[self.arrowButton removeFromSuperview];
        [self.backForHeader removeFromSuperview];
        [self.headerLabelForTime removeFromSuperview];
        UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 1)];
        headView.backgroundColor = [UIColor colorWithHexString:@"e8e8e8"];
        return headView;
    }
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
    headView.backgroundColor = [UIColor whiteColor];
    
    [headView addSubview:self.headerLabelForTime];
    
    UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 1)];
    line1.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
    [headView addSubview:line1];
    
    UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 43, self.view.width, 1)];
    line2.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
    [headView addSubview:line2];
    
    [headView addSubview:self.editButton];
    [headView addSubview:self.backForHeader];
    //[headView addSubview:self.arrowButton];
    return headView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    if (messageModel.msgID == dpMsgBase_SDStatus || messageModel.msgID == 527) {
        return [self sdCardTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if(messageModel.msgID == dpMsgCamera_WarnMsg || messageModel.msgID == dpMsgCamera_WarnMsgV3 || messageModel.msgID == 401 || messageModel.msgID == 403){
        return [self warnPicTableView:tableView cellForRowAtIndexPath:indexPath];
    }else if (messageModel.msgID == DateCellMsgID){
        
        static NSString *cellIDForDate = @"_cellIDForDate";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIDForDate];
        if (!cell) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIDForDate];
            cell.textLabel.text = @"";
            cell.detailTextLabel.text = @"";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
            label.font = [UIFont systemFontOfSize:15];
            label.textColor = [UIColor colorWithHexString:@"#888888"];
            label.text = [self timeSelecedBtnTitleForTimestamp:[[NSDate date] timeIntervalSince1970]];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = 10001;
            [cell.contentView addSubview:label];
            
            UIView *line1 = [[UIView alloc]initWithFrame:CGRectMake(0, -0.5, self.view.width, 1)];
            line1.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
            [cell.contentView addSubview:line1];
            
            UIView *line2 = [[UIView alloc]initWithFrame:CGRectMake(0, 43.5, self.view.width, 1)];
            line2.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
            [cell.contentView addSubview:line2];
            
        }
        UILabel *timeLabel = [cell.contentView viewWithTag:10001];
        timeLabel.text = [self timeSelecedBtnTitleForTimestamp:messageModel.timestamp];
        return cell;
        
    }
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"good"];
    return cell;
}

- (UITableViewCell *)warnPicTableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    messageModel.cid = self.devModel.uuid;
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
//
//        if (messageModel.manNum != 0) {
//
//            NSMutableAttributedString *hintString=[[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ (%@%d个人)",messageModel.topString,[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"],messageModel.manNum]];
//
//            //[UIColor colorWithHexString:@"#666666"]
//            //获取要调整颜色的文字位置,调整颜色
//            NSRange range1 = [[hintString string]rangeOfString:messageModel.topString];
//            [hintString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#666666"] range:range1];
//
//            NSRange range2=[[hintString string]rangeOfString:[NSString stringWithFormat:@" (%@%d个人)",[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"],messageModel.manNum]];
//            [hintString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range2];
//
//            cell.label.attributedText = hintString;
//        }
        cell.label.text = [self cellTextWithModel:messageModel];
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
        cell.deleteBtn.alpha = 0;
        return cell;
        
    }else if (messageModel.msgImages.count >= 2){
        MessageViewCell2 *cell =[tableView dequeueReusableCellWithIdentifier:cell2ID];;
        cell.deleteBtn.hidden = YES;
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
        cell.label.text = [self cellTextWithModel:messageModel];
        
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
        cell.deleteBtn.alpha = 0;
        return cell;
    }else if (messageModel.msgImages.count >= 1){
        
        MessageViewCell3 *cell =[tableView dequeueReusableCellWithIdentifier:cell3ID];
        if (!cell) {
            cell = [[MessageViewCell3 alloc]initForAIWithStyle:UITableViewCellStyleDefault reuseIdentifier:cell3ID];
            cell.moreBtn.hidden = YES;
            //NSLog(@"创建新的Cell");
        }
        
        if (messageModel.aiImageUrl == nil) {
            messageModel.aiImageUrl = [self imageUrlForTImestamp:(int)messageModel.timestamp flag:messageModel.flag];
            //NSLog(@"imageUrl:%@",messageModel.aiImageUrl);
        }
        
        cell.imgv1.url = messageModel.aiImageUrl;
        [cell.imgv1 jfg_setImageWithURL:[NSURL URLWithString:messageModel.aiImageUrl] placeholderImage:[UIImage imageNamed:@"picMoren"]];
        //cell.imgv1.image = [UIImage imageNamed:@"picMoren"];
        NSString *account = [LoginManager sharedManager].currentLoginedAcount;
        JFGSDKAcount *acm = [[LoginManager sharedManager] accountCache];
        if (acm) {
            account = acm.account;
        }
        NSString *fileName = [NSString stringWithFormat:@"/7day/%@/AI/%@/%d.jpg",account,self.devModel.uuid,(int)messageModel.timestamp];
        cell.imgv1.fileName = fileName;
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
        cell.deleteBtn.hidden = messageModel.isShowVideoBtn;
        cell.hiddenSubviews =tableView.isEditing;
        cell.timestamp = messageModel.timestamp;
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
        cell.deleteBtn.alpha = 0;
        
        NSString *aiMsg = [self cellTextWithModel:messageModel];
        aiMsg = [aiMsg stringByReplacingOccurrencesOfString:messageModel.timeString withString:@""];
        cell.aiName = aiMsg;
        cell.label.text = [self cellTextWithModel:messageModel];
        //文字超过这个范围，显示全部按钮
        CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 104;
        CGSize size = [cell.label.text sizeWithFont:cell.label.font];
        if (size.width>maxWidth) {
            cell.moreBtn.hidden = NO;
        }else{
            cell.moreBtn.hidden = YES;
        }
        //NSLog(@"index:%ld strWidth:%f labelWidth:%f",(long)indexPath.row,size.width,maxWidth);
        return cell;
        
    }else{
        
        MessageViewCell3 *cell =[tableView dequeueReusableCellWithIdentifier:cell3ID];
        return cell;
        
    }
    
}


-(NSString *)imageUrlForTImestamp:(int)timestamp flag:(int)flag
{
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    JFGSDKAcount *acm = [[LoginManager sharedManager] accountCache];
    if (acm) {
        account = acm.account;
    }
    NSString *fileName = [NSString stringWithFormat:@"/7day/%@/AI/%@/%d.jpg",account,self.devModel.uuid,timestamp];
    return [JFGSDK getCloudUrlWithFlag:flag fileName:fileName];
}

-(NSString *)cellTextWithModel:(MessageModel *)model
{
    if (model.aiMsg && ![model.aiMsg isEqualToString:@""]) {
        return model.aiMsg;
    }
    NSString *str = @"";
    if ([model.person_name isKindOfClass:[NSString class]] && ![model.person_name isEqualToString:@""]) {
        str = model.person_name;
    }
    
    if ([str isEqualToString:@""]) {
        if (currentPersonName) {
            str = [NSMutableString stringWithFormat:@"%@%@",[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"],currentPersonName];
        }else{
            str = [NSMutableString stringWithFormat:@"%@%@",[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"],[JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_STRANGER"]];
        }
    }else{
        str = [NSMutableString stringWithFormat:@"%@%@",[JfgLanguage getLanTextStrByKey:@"DETECTED_AI"],str];
    }
    
    str = [NSMutableString stringWithFormat:@"%@ %@",model.timeString,str];
    model.aiMsg = str;
    return str;
    
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
    
    if (messageModel.msgID == 527) {
        
        cell.contentLabel.text = messageModel.textString;
        cell.hiddenAvBtn = YES;
        cell.avBtn.hidden = YES;
        cell.deleteBtn.alpha = 0;
        __weak typeof(self) weakSelf = self;
        [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
            
            [weakSelf deleteSingleCell:@[indexPath]];
        }];
        
    }else{
        
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
        
        __weak typeof(self) weakSelf = self;
        [UIButton button:cell.deleteBtn touchUpInSideHander:^(UIButton *button) {
            
            [weakSelf deleteSingleCell:@[indexPath]];
        }];
        
        cell.avBtn.tag = indexPath.row+223;
        [cell.avBtn removeTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.avBtn addTarget:self action:@selector(lookHistoryVideo:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat height = 94*designWscale;
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    if (messageModel.msgID == dpMsgBase_SDStatus) {
        return height;
    }else if(messageModel.msgID == DateCellMsgID){
        return 44;
    }else if (messageModel.msgID == 527){
        return 70;
    }
    
    switch (messageModel.msgImages.count)
    {
        case 1: //一张
        {
            height = 218;
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
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    if (messageModel.msgID == DateCellMsgID){
        return NO;
    }
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

//根据滚动位置设置时间
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self scrollViewDidEndDecelerating:scrollView];
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSArray *cells = [self.contentTableView visibleCells];
    if (cells.count) {
        MessageViewCell *cell = (MessageViewCell *)cells[0];
        if ([cell isKindOfClass:[MessageViewCell class]]) {
            NSString *time = [self timeSelecedBtnTitleForTimestamp:cell.timestamp];
            self.headerLabelForTime.text = time;
        }
    }
    
    if (scrollView.contentOffset.y >= self.contentHeaderView.height && self.contentArray.count) {
        
        if (self.scrollerTopBtn.alpha == 0) {
            self.scrollerTopBtn.alpha = 1;
            isShowScrollerTopBtn = YES;
            [UIView animateWithDuration:0.3 animations:^{
                if (isEditing) {
                    self.scrollerTopBtn.bottom = self.bottomSelectView.top-20;
                }else{
                    self.scrollerTopBtn.bottom = self.view.height-20;
                }
                
            }];
        }
    }else{
        
        if (self.scrollerTopBtn.alpha == 1) {
            
            isShowScrollerTopBtn = NO;
            [UIView animateWithDuration:0.3 animations:^{
                self.scrollerTopBtn.top = self.view.height;
            } completion:^(BOOL finished) {
                self.scrollerTopBtn.alpha = 0;
            }];
        }
    }
}

-(void)scrollerToTop
{
    [self.contentTableView setContentOffset:CGPointMake(0, 0) animated:YES];
    if (self.scrollerTopBtn.alpha == 1) {
        
        isShowScrollerTopBtn = NO;
        [UIView animateWithDuration:0.3 animations:^{
            
            self.scrollerTopBtn.top = self.view.height;
        } completion:^(BOOL finished) {
            self.scrollerTopBtn.alpha = 0;
        }];
    }
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

-(void)scrollViewDidScrollToTop:(UIScrollView *)scrollView
{
    if (self.contentArray.count) {
        MessageModel *messageModel = [self.contentArray objectAtIndex:0];
        NSString *time = [self timeSelecedBtnTitleForTimestamp:messageModel._version];
        self.headerLabelForTime.text = time;
    }
    if (self.scrollerTopBtn.alpha == 1) {
        
        isShowScrollerTopBtn = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.scrollerTopBtn.top = self.view.height;
        } completion:^(BOOL finished) {
            self.scrollerTopBtn.alpha = 0;
        }];
    }
}

-(void)enableBottomDelButton
{
    [self.deleteButton setEnabled:YES];
}

-(void)disableBottomDelButton{
    [self.deleteButton setEnabled:NO];
}

-(void)editButtonAction:(DelButton *)button
{
    [button setSelected:!button.isSelected];
    if (button.isSelected) {
        isEditing = YES;
        [self hideRefreshController];
        [self.view addSubview:self.bottomSelectView];
        [UIView animateWithDuration:0.33f animations:^{
            [self.bottomSelectView setFrame:CGRectMake(0, self.view.frame.size.height-50, Kwidth, 50)];
            self.contentTableView.editing = YES;
            [self.contentTableView setFrame:CGRectMake(0, 0, Kwidth, kheight-50-64)];
            if (isShowScrollerTopBtn) {
                self.scrollerTopBtn.bottom = self.bottomSelectView.top - 20;
            }
        } completion:^(BOOL finished) {
            [self.contentTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        }];
        
    }else{
        [self.contentTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
        isEditing = NO;
        [self showRefreshController];
        self.selectAllButton.selected = NO;
        [UIView animateWithDuration:0.33f animations:^{
            [self.bottomSelectView setFrame:CGRectMake(0, self.view.frame.size.height, Kwidth, 50)];
            self.contentTableView.editing = NO;
            [self.contentTableView setFrame:CGRectMake(0, 0, Kwidth, kheight-64)];
            if (isShowScrollerTopBtn) {
                self.scrollerTopBtn.bottom = self.view.height-20;
            }
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

-(void)arrowAction:(UIButton *)btn
{
    if (btn.selected) {
        
        [self.contentTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        
    }else{
        
        [self.contentTableView setContentOffset:CGPointMake(0, self.contentHeaderView.height) animated:YES];
    }
    btn.selected = !btn.selected;
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
            [weakSelf.contentTableView reloadData];
            
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
            seg.msgId = model.realyMsgID;
            seg.version = model._version;
            [segList addObject:seg];
        }
        
        __weak typeof(self) weakSelf= self;
        [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:self.devModel.uuid queryDps:segList success:^(NSString *identity, int ret) {
            
            NSLog(@"identity:%@  ret:%d",identity,ret);
             [weakSelf.contentHeaderView refreshAccessCountForAccessID:currentPerson];
            
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
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:sender.tag-223 inSection:0];
    MessageModel *messageModel = [self.contentArray objectAtIndex:indexPath.row];
    
    if (messageModel.msgID == dpMsgBase_SDStatus) {
        //sd卡需要格式化，直接跳转设备详情
        
        DeviceSettingVC *deviceSetting = [DeviceSettingVC new];
        deviceSetting.cid = self.devModel.uuid;
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
    if (deleteAll) {
        
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
            
            __weak typeof(self) weakSelf = self;
            [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:self.devModel.uuid queryDps:segList success:^(NSString *identity, int ret) {
                
                NSLog(@"identity:%@  ret:%d",identity,ret);
                [weakSelf.contentHeaderView refreshAccessCountForAccessID:currentPerson];
                
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
        [self.contentTableView deleteRowsAtIndexPaths:allSeletedIndexPath withRowAnimation:UITableViewRowAnimationTop];
        if (self.contentArray.count == 0) {
            [self cancelEditingState];
            [self showRefreshController];
            [self.contentTableView reloadData];
        }
    }
}


-(void)backHeaderAction
{
    [self.contentHeaderView backFamily];
    self.backForHeader.hidden = YES;
    [self.contentTableView reloadData];
}

#pragma mark- 请求数据
//请求全部数据
-(void)reqAllDataWithTimestamp:(uint64_t)timestamp
{
    hasNewMsg = NO;
    [self.msgAIReq reqMsgForType:3 accessID:@"all" cid:self.devModel.uuid timestamp:timestamp];
}

//根据face_id或者person_id获取数据
-(void)reqPersonDataWithType:(int)type accessID:(NSString *)accessID timestamp:(int64_t)timestamp
{
    [self.msgAIReq reqMsgForType:type accessID:accessID cid:self.devModel.uuid timestamp:timestamp];
}

//数据请求成功
-(void)requestCamareSuccess:(NSArray <MessageModel *> *)dataList forCid:(NSString *)cid refresh:(BOOL)refresh
{
    if ([cid isEqualToString:self.devModel.uuid]) {
        
        if (refresh) {
            [self.allMsgArray removeAllObjects];
        }
        [self.allMsgArray addObjectsFromArray:dataList];
        if ([currentPerson isEqualToString:@"all"]) {
            
            self.allMsgArray = [[NSMutableArray alloc]initWithArray:[self msgDataAddDateModelWithDataList:self.allMsgArray]];
            self.contentArray = self.allMsgArray;
            [self refreshTimeForTop];
            [self.contentTableView reloadData];
            if (refresh) {
                [self.contentTableView.mj_header endRefreshing];
            }else{
                [self.contentTableView.mj_footer endRefreshing];
                
                if (self.contentArray.count == 0) {
                    self.contentTableView.mj_footer.hidden = YES;
                }else{
                    if (dataList.count == 0) {
                        [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                    }else{
                        self.contentTableView.mj_footer.hidden = NO;
                    }
                }
                
            }
        }
    }
}

//排序规则
NSComparator cmptr = ^(MessageModel *obj1, MessageModel *obj2){
    if (obj1.timestamp < obj2.timestamp) {
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if (obj1.timestamp > obj2.timestamp) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};


NSComparator cmptrForTimestamp = ^(NSString *obj1, NSString *obj2){
    if ([obj1 floatValue] < [obj2 floatValue]) {
        
//        NSLog(@"")
        
        return (NSComparisonResult)NSOrderedDescending;
    }
    
    if ([obj1 floatValue] > [obj2 floatValue]) {
        return (NSComparisonResult)NSOrderedAscending;
    }
    return (NSComparisonResult)NSOrderedSame;
};

-(NSArray *)msgDataAddDateModelWithDataList:(NSArray *)dataList
{
    //去除旧的时间cell数据
    NSMutableArray *cpData = [NSMutableArray new];
    for (MessageModel *obj in dataList) {
        if ([obj isKindOfClass:[MessageModel class]] ) {
            if (obj.msgID != DateCellMsgID) {
                [cpData addObject:obj];
            }
        }
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    
    //对数据分组
    NSMutableDictionary *groupDict = [NSMutableDictionary new];
    for (MessageModel *model in cpData) {
        
        NSDate *dateForModel = [NSDate dateWithTimeIntervalSince1970:model.timestamp];
        NSString *dateString = [dateFormatter stringFromDate:dateForModel];
        NSMutableArray *arr = [groupDict objectForKey:dateString];
        if (!arr) {
            arr = [[NSMutableArray alloc]init];
            [arr addObject:model];
            [groupDict setObject:arr forKey:dateString];
        }else{
            [arr addObject:model];
        }
        
    }
    
    NSMutableArray *dataarr = [NSMutableArray new];
    for (NSString *key in groupDict.allKeys) {
        
        NSMutableArray *groupArr = [groupDict objectForKey:key];
        
        if (groupArr.count) {
            MessageModel *msgModel = [groupArr objectAtIndex:0];
            MessageModel *model1 = [[MessageModel alloc]init];
            model1.timestamp = msgModel.timestamp+1;
            model1._version = msgModel.timestamp*1000;
            model1.msgID = DateCellMsgID;
            [groupArr insertObject:model1 atIndex:0];
        }
        
        [dataarr addObjectsFromArray:groupArr];
    }
    
    //去重
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    for (MessageModel *msgModel in dataarr) {
        NSDate *dateForModel = [NSDate dateWithTimeIntervalSince1970:msgModel.timestamp];
        NSString *dateString = [dateFormatter stringFromDate:dateForModel];
        [dict setObject:msgModel forKey:dateString];
    }
    [dataarr removeAllObjects];
    
    for (NSString *key in dict.allKeys) {
        MessageModel *msgModel = dict[key];
        [dataarr addObject:msgModel];
    }

    NSArray *sorArray = [dataarr sortedArrayUsingComparator:cmptr];
    dataarr = [[NSMutableArray alloc]initWithArray:sorArray];
    
    //移除第一个
    if (dataarr.count>0) {
        MessageModel *fristModel = [dataarr objectAtIndex:0];
        if (fristModel.msgID == DateCellMsgID) {
            [dataarr removeObject:fristModel];
        }
    }
    return dataarr;
}


//数据请求失败
-(void)requestCamareFailedForCid:(NSString *)cid refresh:(BOOL)refresh
{
    if (refresh) {
        [self.contentTableView.mj_header endRefreshing];
    }else{
        [self.contentTableView.mj_footer endRefreshing];
    }
}

-(void)msgForAIAllMsg:(NSArray<MessageModel *> *)msgList cid:(NSString *)cid access_id:(NSString *)access_id type:(int)type
{
    if ([cid isEqualToString:self.devModel.uuid]) {
    
        if ([access_id isEqualToString:@"all"]) {
            
            if (isRefresh) {
                [self.allMsgArray removeAllObjects];
            }
            [self.allMsgArray addObjectsFromArray:msgList];
            
            if ([currentPerson isEqualToString:@"all"]) {
                
                NSLog(@"数据开始处理:%@",[NSDate date]);
                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                    
                    self.allMsgArray = [[NSMutableArray alloc]initWithArray:[self msgDataAddDateModelWithDataList:self.allMsgArray]];
                    //NSLog(@"数据处理2:%@",[NSDate date]);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        self.contentArray = self.allMsgArray;
                        [self refreshTimeForTop];
                        [self.contentTableView reloadData];
                        
                        if (isRefresh) {
                            [self.contentTableView.mj_header endRefreshing];
                        }else{
                            [self.contentTableView.mj_footer endRefreshing];
                            if (self.contentArray.count == 0) {
                            
                               self.contentTableView.mj_footer.hidden = YES;
                            }else{
                                if (msgList.count == 0) {
                                    [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                                }else{
                                
                                    self.contentTableView.mj_footer.hidden = NO;
                                }
                            }
                            
                        }
                        //NSLog(@"数据处理结束:%@",[NSDate date]);
                    });
                });
                
            }
            
        }else{
            
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                NSMutableArray *memoryCache = [self.allContentCache objectForKey:access_id];
                if (memoryCache == nil) {
                    memoryCache = [NSMutableArray new];
                }
                if (isRefresh) {
                    [memoryCache removeAllObjects];
                }
                [memoryCache addObjectsFromArray:msgList];
                memoryCache = [[NSMutableArray alloc]initWithArray:[self msgDataAddDateModelWithDataList:memoryCache]];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    [self.allContentCache removeObjectForKey:access_id];
                    [self.allContentCache setObject:memoryCache forKey:access_id];
                    
                    if ([currentPerson isEqualToString:access_id]) {
                        
                        self.contentArray = memoryCache;
                        [self refreshTimeForTop];
                        [self.contentTableView reloadData];
                        if (isRefresh) {
                            [self.contentTableView.mj_header endRefreshing];
                        }else{
                            [self.contentTableView.mj_footer endRefreshing];
                            if (self.contentArray.count == 0) {
                                self.contentTableView.mj_footer.hidden = YES;
                            }else{
                                if (msgList.count == 0) {
                                    [self.contentTableView.mj_footer endRefreshingWithNoMoreData];
                                }else{
                                    self.contentTableView.mj_footer.hidden = NO;
                                }
                            }
                        }
                    }
                    
                });
            });
            
            
            
        }
        
        
    }
}

-(void)msgForAIDelMsgWithCid:(NSString *)cid access_id:(NSString *)access_id ret:(int)ret
{
    if ([cid isEqualToString:self.cid]) {
        
        
        
    }
}

//判断sd卡是否存在
-(void)getSDCard
{
    DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
    seg.msgId = 222;
    seg.version = 0;
    
    [[JFGSDKDataPoint sharedClient] robotGetDataByTimeWithPeer:self.devModel.uuid msgIds:@[seg] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
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

#pragma mark- 刷新与加载更多
-(void)stepRefresh
{
    self.contentTableView.estimatedRowHeight = 0;
    self.contentTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshAction)];
    //self.contentTableView.mj_footer.automaticallyHidden = YES;
    JFGRefreshLoadingHeader *header = [JFGRefreshLoadingHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshAcion)];
    self.contentTableView.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.contentTableView.mj_footer;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    footer.automaticallyHidden = YES;
}

-(void)footerRefreshAction
{
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
    
    isRefresh = NO;
    MessageModel *messageModel = [self.contentArray lastObject];
    if ([currentPerson isEqualToString:@"all"]) {
        [self reqAllDataWithTimestamp:messageModel._version];
//        [self.camereMsgReq getDataForCid:self.devModel.uuid timestamp:messageModel._version isRefresh:NO];
    }else{
        int type = 1;
        if (self.contentHeaderView.isFamilyshow) {
            type = 2;
        }else{
            type = 1;
        }
        [self reqPersonDataWithType:type accessID:currentPerson timestamp:messageModel._version];
    }

}

-(void)headerRefreshAcion
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        
        [self.contentTableView.mj_footer resetNoMoreData];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"JFGClearUnReadCount" object:self.devModel.uuid];
        isRefresh = YES;
        if ([currentPerson isEqualToString:@"all"]) {
            //[self.camereMsgReq getDataForCid:self.devModel.uuid timestamp:0 isRefresh:YES];
            [self reqAllDataWithTimestamp:0];
            [self.contentHeaderView reqData];//刷新头部
        }else{
            int type = 1;
            if (self.contentHeaderView.isFamilyshow) {
                type = 2;
            }else{
                type = 1;
            }
            if (![currentPerson isEqualToString:@""]) {
                [self reqPersonDataWithType:type accessID:currentPerson timestamp:0];
                [self.contentHeaderView refreshAccessCountForAccessID:currentPerson];
            }else{
                [self.contentTableView.mj_header endRefreshing];
            }
            
            
        }
    }else{
        [CommonMethod showNetDisconnectAlert];
        [self.contentTableView.mj_header endRefreshing];
    }
}


-(UITableView *)contentTableView{
    if (!_contentTableView) {
        _contentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight-64) style:UITableViewStylePlain];
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
        self.noDataView.x = _contentTableView.width*0.5;
        self.noDataView.y = _contentTableView.height*0.5;
        [_contentTableView addSubview:self.noDataView];
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

-(DelButton *)selectAllButton
{
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

-(DelButton *)editButton{
    if (!_editButton) {
        _editButton = [DelButton buttonWithType:UIButtonTypeCustom];
        [_editButton setFrame:CGRectMake(Kwidth-7-44, 0, 44, 44)];
        _editButton.right = self.view.width-15; _editButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        _editButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _editButton.backgroundColor = [UIColor clearColor];
        _editButton.titleLabel.font = [UIFont systemFontOfSize:14];
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

-(MsgAIHeadPortraitView *)contentHeaderView
{
    if (!_contentHeaderView) {
        _contentHeaderView = [[MsgAIHeadPortraitView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 255) cid:self.devModel.uuid];
        _contentHeaderView.backgroundColor = [UIColor whiteColor];
        _contentHeaderView.delegate = self;
    }
    return _contentHeaderView;
}

-(UIButton *)backForHeader
{
    if (!_backForHeader) {
        _backForHeader = [UIButton buttonWithType:UIButtonTypeCustom];
        _backForHeader.frame = CGRectMake(5, 12, 50, 20);
        [_backForHeader setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        _backForHeader.titleLabel.font = [UIFont systemFontOfSize:14];
        _backForHeader.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_backForHeader setTitle:[JfgLanguage getLanTextStrByKey:@"BACK"] forState:UIControlStateNormal];
        _backForHeader.hidden = YES;
        [_backForHeader addTarget:self action:@selector(backHeaderAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backForHeader;
}

-(UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 140, 140+40)];
        _noDataView.top = self.view.height*0.14;
        _noDataView.y = (self.view.height-64)*0.5+64*0.5;
        UIImageView *imagev = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 140, 140)];
        imagev.image = [UIImage imageNamed:@"png-no-message"];
        [_noDataView addSubview:imagev];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 160, 140, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        label.text = [JfgLanguage getLanTextStrByKey:@"NO_CONTENTS_1"];
        label.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:label];
        
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

-(CamareMsgDataReq *)camereMsgReq
{
    if (!_camereMsgReq) {
        _camereMsgReq = [[CamareMsgDataReq alloc]init];
        _camereMsgReq.delegate = self;
    }
    return _camereMsgReq;
}

-(UILabel *)headerLabelForTime
{
    if (!_headerLabelForTime) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 44)];
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor colorWithHexString:@"#888888"];
        label.text = [self timeSelecedBtnTitleForTimestamp:[[NSDate date] timeIntervalSince1970]];
        label.textAlignment = NSTextAlignmentCenter;
        _headerLabelForTime = label;
    }
    return _headerLabelForTime;
}

-(NSString *)timeSelecedBtnTitleForTimestamp:(int64_t)timestamp
{
    int64_t _timestamp = timestamp;
    if (_timestamp > 10000000000) {
        _timestamp = _timestamp/1000;
    }
    int64_t currentTimestamp = [[NSDate date] timeIntervalSince1970];
    if (_timestamp > currentTimestamp) {
        return @"";
    }
    NSCalendar* calendar = [NSCalendar currentCalendar];
    
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:_timestamp];
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

-(NSCache *)allContentCache
{
    if (!_allContentCache) {
        _allContentCache = [[NSCache alloc]init];
        _allContentCache.totalCostLimit = 5 * 1024 * 1024;
    }
    return _allContentCache;
}

-(MsgForAIRequest *)msgAIReq
{
    if (!_msgAIReq) {
        _msgAIReq = [[MsgForAIRequest alloc]init];
        [_msgAIReq addJfgDelegate];
        _msgAIReq.delegate = self;
    }
    return _msgAIReq;
}

-(UIButton *)arrowButton
{
    if (!_arrowButton) {
        _arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowButton.frame = CGRectMake(0, 10, 26, 26);
        _arrowButton.right = self.view.width-13;
        [_arrowButton setImage:[UIImage imageNamed:@"btn_unfolded"] forState:UIControlStateNormal];
        [_arrowButton setImage:[UIImage imageNamed:@"btn_put_away"] forState:UIControlStateSelected];
        [_arrowButton addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _arrowButton;
}

-(NSMutableArray *)allMsgArray
{
    if (!_allMsgArray) {
        _allMsgArray = [NSMutableArray new];
    }
    return _allMsgArray;
}

-(NSMutableArray *)allMsgKeyArray
{
    if (!_allMsgKeyArray) {
        _allMsgKeyArray = [NSMutableArray new];
    }
    return _allMsgKeyArray;
}

-(UIButton *)scrollerTopBtn
{
    if (!_scrollerTopBtn) {
        _scrollerTopBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _scrollerTopBtn.frame = CGRectMake(0, 0, 45, 45);
        _scrollerTopBtn.top = self.view.height;
        _scrollerTopBtn.right = self.view.width-12;
        [_scrollerTopBtn setImage:[UIImage imageNamed:@"icon_stick_to_the_top"] forState:UIControlStateNormal];
        [_scrollerTopBtn addTarget:self action:@selector(scrollerToTop) forControlEvents:UIControlEventTouchUpInside];
        _scrollerTopBtn.alpha = 0;
    }
    return _scrollerTopBtn;
}

#pragma mark- Cache
-(void)cacheDataToDisk
{
    NSMutableDictionary *dataDict = [NSMutableDictionary new];
    
#ifdef CLOSEBIGPIC

#else
    for (NSString *msgKey in self.allMsgKeyArray) {
        NSArray *msgArr = [self.allContentCache objectForKey:msgKey];
        if ([msgArr isKindOfClass:[NSArray class]]) {
            [dataDict setObject:msgArr forKey:msgKey];
        }
    }
#endif
    [dataDict setObject:self.allMsgArray forKey:@"all"];
    [JfgCacheManager cacheMsgForAIDataCache:dataDict cid:self.devModel.uuid];
    
}

-(void)getCacheData
{
    NSDictionary *cacheDict = [JfgCacheManager getCacheForAIMsgWithCid:self.devModel.uuid];
    for (NSString *key in cacheDict.allKeys) {
        
        NSArray *allData = [cacheDict objectForKey:key];
        if (allData) {
            if ([key isEqualToString:@"all"]) {
                self.allMsgArray = [[NSMutableArray alloc]initWithArray:allData];
            }else{
                [self.allContentCache setObject:allData forKey:key];
            }
        }
        
    }
    if ([currentPerson isEqualToString:@"all"]) {
        self.contentArray = self.allMsgArray;
        [self.contentTableView reloadData];
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
