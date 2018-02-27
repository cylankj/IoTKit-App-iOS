//
//  MsgAIHeadPortraitView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "MsgAIHeadPortraitView.h"
#import "MsgAIHeaderCollectionViewCell.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "CommonMethod.h"
#import "FaceMsgViewController.h"
#import "DDCollectionViewHorizontalLayout.h"
#import "FaceCreateViewController.h"
#import "FaceAddressBookVC.h"
#import "UIAlertView+FLExtension.h"
#import "JfgTimeFormat.h"
#import "OemManager.h"
#import "LoginManager.h"
#import "SDWebImageCacheHelper.h"
#import "UIImageView+JFGImageView.h"
#import "AIRobotRequest.h"
#import "ProgressHUD.h"
#import "JfgCacheManager.h"
#import "LoginManager.h"
#import "FLLog.h"
#import "GestureCollection.h"
#import <MJRefresh.h>
#import "JFGRefreshLoadingHeader.h"
#import "CommentFrameButton.h"
#import <Masonry.h>
#import "JKAlertDialog.h"
#import "AddFaceViewController.h"
#import "BaseNavgationViewController.h"

#define collectionViewHeight 210
#define collectionViewCellHeight 105
#define selfHeight 260

@interface MsgAIHeadPortraitView()<UICollectionViewDelegate,UICollectionViewDataSource,MsgAIHeaderCollectionViewCellDelegate,UIAlertViewDelegate,MsgForAIRequestDelegate,FaceAddressBookVCDelegate,FaceCreateVCDelegate>
{
    NSIndexPath *cellSelectedIndexPath;
    NSInteger familiyAllCount;//熟人总数
    NSInteger strangerAllCount;//陌生人总数
    BOOL familyIsDoubleLine;
    BOOL msrIsDoubleLine;
    BOOL hasNewMsg;
    int allVisitCount;//今日来访数
    int yesterdayVisitCount;//昨日来访数

    BOOL isExpand;
    BOOL isRefresh;
}
@property (nonatomic,strong)GestureCollection *headCollectionView;
@property (nonatomic,strong)MsgForAIRequest *msgRequest;
@property (nonatomic,strong)UILabel *pageLabel;//页数记录
@property (nonatomic,strong)UILabel *visitCountLabel;//访问次数
@property (nonatomic,strong)NSMutableArray *familyArray;//熟人
@property (nonatomic,strong)NSMutableArray *unKnowArray;//陌生人
@property (nonatomic,strong)NSMutableArray *dataArray;//总体展示用
@property (nonatomic,strong)UIButton *arrowButton;
@property (nonatomic,strong)UIButton *visitDetailBtn;

@end

@implementation MsgAIHeadPortraitView


-(instancetype)initWithFrame:(CGRect)frame cid:(NSString *)cid
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, selfHeight)];
    self.clipsToBounds = YES;
    self.isFamilyshow = YES;
    isRefresh = YES;
    msrIsDoubleLine = NO;
    familyIsDoubleLine = NO;
    yesterdayVisitCount = 0;
    cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.dataArray = self.familyArray;
    self.cid = cid;
    [self reqData];
    [self initView];
    
    return self;
}

//有新的推送消息产生
-(void)hasNewMsgNotification
{
    hasNewMsg = YES;
    if (self.dataArray.count) {
        
        MsgAIheaderModel *aiModel = self.dataArray[0];
        if (aiModel.type == AIModelTypeAll) {
            MsgAIHeaderCollectionViewCell *cell = (MsgAIHeaderCollectionViewCell *)[self.headCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            if (cell) {
                UIView *redPoint = [cell.contentView viewWithTag:200001];
                if (redPoint) {
                    redPoint.hidden = NO;
                }
            }
        }
    }
}


-(void)refreshAccessCountForAccessID:(NSString *)accessID
{
    if ([accessID isEqualToString:@"all"]) {
        [self.msgRequest reqAccessCountForType:5 accessID:@"all" cid:self.cid];
    }else{
        if (self.isFamilyshow) {
            [self.msgRequest reqAccessCountForType:2 accessID:accessID cid:self.cid];
        }else{
            [self.msgRequest reqAccessCountForType:1 accessID:accessID cid:self.cid];
        }
    }
   
}

-(void)reqData
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        
        isRefresh = YES;
        [self.msgRequest reqFamiliarPersonsForCid:self.cid timestamp:0];
        [self.msgRequest reqStrangerListForCid:self.cid timestamp:0];
        [self.msgRequest reqAccessCountForType:5 accessID:@"all" cid:self.cid];
        [self reqYestedayVisitCount];
        hasNewMsg = NO;
        if (self.dataArray.count) {
            
            MsgAIheaderModel *aiModel = self.dataArray[0];
            if (aiModel.type == AIModelTypeAll) {
                MsgAIHeaderCollectionViewCell *cell = (MsgAIHeaderCollectionViewCell *)[self.headCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if (cell) {
                    UIView *redPoint = [cell.contentView viewWithTag:200001];
                    if (redPoint) {
                        redPoint.hidden = YES;
                    }
                }
            }
        }
        
    }else{
        
        NSArray *familiarArr = [JfgCacheManager getCacheMsgForAIIsFamiliarHeader:YES cid:self.cid];
        NSArray *unfamiliarArr = [JfgCacheManager getCacheMsgForAIIsFamiliarHeader:NO cid:self.cid];
        self.familyArray = [[NSMutableArray alloc]initWithArray:familiarArr];
        self.unKnowArray = [[NSMutableArray alloc]initWithArray:unfamiliarArr];
        
        NSInteger realUnKnowCount = 0;
        for (MsgAIheaderModel *model in self.unKnowArray) {
            if (model.type == AIModelTypeUnRegister) {
                realUnKnowCount ++;
            }
        }
        
        NSInteger realfamiliarCount = 0;
        for (MsgAIheaderModel *model in self.familyArray) {
            if (model.type == AIModelTypeRegister) {
                realfamiliarCount ++;
            }
        }
        
        if (realUnKnowCount<=3) {
            msrIsDoubleLine = NO;
        }else{
            msrIsDoubleLine = YES;
        }
        if (realfamiliarCount>3) {
            familyIsDoubleLine = YES;
        }else{
            familyIsDoubleLine = NO;
        }
        self.dataArray = self.familyArray;
        [self resetPageCount];
        [self updataLayout];
    }
    
    [self.headCollectionView reloadData];
}

-(void)reqYestedayVisitCount
{
    NSDate * date = [NSDate date];//当前时间
    NSDate *lastDay = [NSDate dateWithTimeInterval:-24*60*60 sinceDate:date];//前一天
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];//设置成中国阳历
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;//这句我也不明白具体时用来做什么。。。
    comps = [calendar components:unitFlags fromDate:date];
    long endDay=[comps day];//获取日期对应的长整形字符串
    long endYear=[comps year];//获取年对应的长整形字符串
    long endMonth=[comps month];//
    
    comps = [calendar components:unitFlags fromDate:lastDay];
    long startDay=[comps day];//获取日期对应的长整形字符串
    long startYear=[comps year];//获取年对应的长整形字符串
    long startMonth=[comps month];//
    
    int startTimestamp = [self timestampForYear:startYear month:startMonth day:startDay];
    int endTimestamp = [self timestampForYear:endYear month:endMonth day:endDay];
    [self.msgRequest reqVisitCountForCid:self.cid begintime:startTimestamp endTime:endTimestamp-1];
}

-(void)cacheHeaderData
{
    [JfgCacheManager cacheMsgForAIIsFamiliarHeader:YES data:self.familyArray cid:self.cid];
    [JfgCacheManager cacheMsgForAIIsFamiliarHeader:NO data:self.unKnowArray cid:self.cid];
}

-(void)arrowAction:(UIButton *)sender
{
    sender.selected = !sender.selected;
    isExpand = sender.selected;
    if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadExpand:)]) {
        [self.delegate msgAIHeadExpand:sender.selected];
    }
    
    if (sender.selected) {
        //展开
        
        [UIView animateWithDuration:0.3 animations:^{
            
            [self updataLayout];
            
        } completion:^(BOOL finished) {
            
            self.headCollectionView.pagingEnabled = NO;
            self.headCollectionView.mj_header.hidden = NO;
            self.headCollectionView.mj_footer.hidden = NO;
            [self.headCollectionView.mj_footer resetNoMoreData];
            
        }];
        
    }else{
        
        
        //收缩
        [self.headCollectionView.mj_footer endRefreshing];
        [self.headCollectionView.mj_header endRefreshing];
        self.headCollectionView.mj_footer.hidden = YES;
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.headCollectionView.height = collectionViewHeight;
            [self updataLayout];
            
        } completion:^(BOOL finished) {
            if (cellSelectedIndexPath && cellSelectedIndexPath.row<self.dataArray.count) {
                [self.headCollectionView scrollToItemAtIndexPath:cellSelectedIndexPath atScrollPosition:UICollectionViewScrollPositionTop animated:YES];
            }
            
            self.headCollectionView.mj_header.hidden = YES;
            self.headCollectionView.mj_footer.hidden = YES;
        }];
        self.headCollectionView.pagingEnabled = YES;
        
    }
}

-(void)visitCountTap
{
    if (self.visitDetailBtn.hidden == NO) {
        [self visitDetailAction];
    }
}

//访客数详情弹窗
-(void)visitDetailAction
{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 270, 166)];
    //bgView.backgroundColor = [UIColor orangeColor];
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 14, 210, 24)];
    titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    titleLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_ANALYSIS"];
    [bgView addSubview:titleLabel];
    
    NSArray *titles = @[[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_TADAY_VISIT"],[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_YESTERDAY_VISIT"],[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_NEW_VISIT"]];
    
    [titles enumerateObjectsUsingBlock:^(NSString *t, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UILabel *dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(30, 52+idx*33, 120, 21)];
        dayLabel.font = [UIFont systemFontOfSize:15];
        dayLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        dayLabel.text = t;
        [bgView addSubview:dayLabel];
        
        UILabel *dayCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, 85, 24)];
        dayCountLabel.y = dayLabel.y;
        dayCountLabel.textAlignment = NSTextAlignmentRight;
        dayCountLabel.right = bgView.width-30;
        [bgView addSubview:dayCountLabel];
        
        if (idx == 0) {
            dayCountLabel.attributedText = [self attributedTextForVisitCount:allVisitCount isAdd:NO];
        }else if (idx == 1){
            dayCountLabel.attributedText = [self attributedTextForVisitCount:yesterdayVisitCount isAdd:NO];
        }else if (idx == 2){
            dayCountLabel.attributedText = [self attributedTextForVisitCount:allVisitCount-yesterdayVisitCount isAdd:YES];
        }
        
    }];
    
    JKAlertDialog *alert = [[JKAlertDialog alloc]initWithTitle:@"" message:@""];
    alert.contentView = bgView;
    [alert addButton:Button_CANCEL withTitle:[JfgLanguage getLanTextStrByKey:@"CLOSE_BUTTON"] handler:^(JKAlertDialogItem *item) {
        
    }];
    [alert show];
    
}

-(NSMutableAttributedString *)attributedTextForVisitCount:(int)visitCount isAdd:(BOOL)isAdd
{
    NSString *txt1 = [NSString stringWithFormat:@"%d%@",visitCount,[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_PEOPLE"]];
    
    if (isAdd) {
        
        if (visitCount>=0) {
            txt1 = [NSString stringWithFormat:@"+%d%@",visitCount,[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_PEOPLE"]];
        }
        
    }
    
    NSRange txt1Range1 = [txt1 rangeOfString:[NSString stringWithFormat:@"%d",visitCount]];
    
    if (isAdd) {
        if (visitCount>=0) {
            txt1Range1 = [txt1 rangeOfString:[NSString stringWithFormat:@"+%d",visitCount]];
        }
//
    }
    NSRange txt1Range2 = [txt1 rangeOfString:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_PEOPLE"]];
    
    NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:txt1];
    
    [str2 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17] range:txt1Range1];
    if (isAdd) {
        if (visitCount>=0) {
            [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#F43531"] range:txt1Range1];
        }else{
            [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#459C17"] range:txt1Range1];
        }
        
    }else{
        [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#333333"] range:txt1Range1];
    }
    
    [str2 addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:txt1Range2];
    [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#666666"] range:txt1Range2];
    return str2;
}

#pragma mark- 陌生人数据
//陌生人
-(void)msgForAIStranger:(NSArray<StrangerModel *> *)models total:(int)total
{
    [self.headCollectionView.mj_footer endRefreshing];
    [self.headCollectionView.mj_header endRefreshing];
    if (models.count == 0 && !isRefresh) {
        [self.headCollectionView.mj_footer endRefreshingWithNoMoreData];
    }
    if (isRefresh) {
        [self.unKnowArray removeAllObjects];
        cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    for (StrangerModel *model in models) {
        MsgAIheaderModel *aiModel = [MsgAIheaderModel new];
        aiModel.faceIDList = [[NSMutableArray alloc]initWithObjects:model.face_id, nil];
        aiModel.last_time = model.last_time;
        aiModel.person_id = @"";
        aiModel.visitCount = -1;
        aiModel.faceImageUrl = model.faceImageUrl;
        aiModel.type = AIModelTypeUnRegister;
        aiModel.originImageUrl = model.originImageUrl;
        aiModel.flag = model.flag;
        [self.unKnowArray addObject:aiModel];
    }
    
    if (self.unKnowArray.count<=3) {
        msrIsDoubleLine = NO;
    }else{
        msrIsDoubleLine = YES;
    }

    if (!self.isFamilyshow) {
        
        self.dataArray = self.unKnowArray;
        [self resetPageCount];
        [self updataLayout];
        [self.headCollectionView reloadData];
        if (self.dataArray.count && isRefresh) {
             MsgAIheaderModel *aiModel = self.dataArray[0];
             [self.msgRequest reqAccessCountForType:1 accessID:aiModel.faceIDList[0] cid:self.cid];
        }
        if (self.dataArray.count>cellSelectedIndexPath.row && isRefresh) {
        
            MsgAIheaderModel *model = [self.dataArray objectAtIndex:cellSelectedIndexPath.row];
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidSelectedCellForModel:)]) {
                [self.delegate msgAIHeadPortraitViewDidSelectedCellForModel:model];
            }
            
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqMsgTimeout) object:nil];
}

-(void)dataDeal
{
    if (self.isFamilyshow) {
        if (self.dataArray.count>3) {
            familyIsDoubleLine = YES;
        }else{
            familyIsDoubleLine = NO;
        }
    }else{
        if (self.dataArray.count<=3) {
            msrIsDoubleLine = NO;
        }else{
            msrIsDoubleLine = YES;
        }
    }
    
}

#pragma mark- 熟人数据
//熟人
-(void)msgForAIFamiliarPersons:(NSArray<FamiliarPersonsModel *> *)models total:(int)total
{
    [self.headCollectionView.mj_footer endRefreshing];
    [self.headCollectionView.mj_header endRefreshing];
    
    if (models.count == 0 && !isRefresh) {
        [self.headCollectionView.mj_footer endRefreshingWithNoMoreData];
    }
    if (isRefresh) {
        [self.familyArray removeAllObjects];
        cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        MsgAIheaderModel *allModel = [MsgAIheaderModel new];
        allModel.type = AIModelTypeAll;
        
        MsgAIheaderModel *msrModel = [MsgAIheaderModel new];
        msrModel.type = AIModelTypeUnknow;
        
        MsgAIheaderModel *addModel = [MsgAIheaderModel new];
        addModel.type = AIModelTypeAddFace;
        
        [self.familyArray addObject:allModel];
        [self.familyArray addObject:msrModel];
        [self.familyArray addObject:addModel];
    }
    
    for (FamiliarPersonsModel *model in models) {
        MsgAIheaderModel *aiModel = [MsgAIheaderModel new];
        aiModel.faceIDList = [[NSMutableArray alloc] initWithArray:model.face_id];
        //人1，猫2，狗3，车辆4
        aiModel.type = AIModelTypeRegister;
        aiModel.last_time = model.last_time;
        aiModel.person_id = model.person_id;
        aiModel.name = model.person_name;
        aiModel.faceMsgList = [[NSArray alloc] initWithArray:model.strangerArr];
        aiModel.visitCount = -1;
        if (model.strangerArr.count) {
            StrangerModel *smodel = model.strangerArr[0];
            aiModel.faceImageUrl = smodel.faceImageUrl;
            [self.familyArray addObject:aiModel];
        }
        
    }
    
    if (self.familyArray.count>3) {
        familyIsDoubleLine = YES;
    }else{
        familyIsDoubleLine = NO;
    }
    
    if (self.isFamilyshow) {
        self.dataArray = self.familyArray;
        [self resetPageCount];
        [self updataLayout];
        [self.headCollectionView reloadData];
        if (self.dataArray.count>cellSelectedIndexPath.row && isRefresh) {
            MsgAIheaderModel *model = [self.dataArray objectAtIndex:cellSelectedIndexPath.row];
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidSelectedCellForModel:)]) {
                [self.delegate msgAIHeadPortraitViewDidSelectedCellForModel:model];
            }
        }
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(reqMsgTimeout) object:nil];
}

-(void)resetPageCount
{
//    NSInteger allPage = 0;
//    if (self.dataArray.count%6 == 0) {
//        allPage = self.dataArray.count/6;
//    }else{
//        allPage = self.dataArray.count/6+1;
//    }
}

-(void)msgForAIAccessCount:(int)count face_id:(NSString *)face_id cid:(NSString *)cid
{
    if (![self.cid isEqualToString:cid]) {
        return;
    }
    for (int i=0; i<self.dataArray.count; i++) {
        
        MsgAIheaderModel *model = self.dataArray[i];
        if (self.isFamilyshow) {
            
            if ([model.person_id isEqualToString:face_id]) {
                
                model.visitCount = count;
                if (cellSelectedIndexPath.row == i) {
                    [self setVisitCountText:count isAllType:NO];
                }
                break;
                
            }else if ([face_id isEqualToString:@"all"]){
                
                allVisitCount = count;
                
                if (model.type == AIModelTypeAll) {
                
                    model.visitCount = count;
                    if (cellSelectedIndexPath.row == i) {
                        
                        [self setVisitCountText:count isAllType:YES];
                    }
                }
            }
            
        }else{
            
            if (model.faceIDList.count && [model.faceIDList[0] isEqualToString:face_id]) {
                model.visitCount = count;
                if (cellSelectedIndexPath.row == i) {
            
                    [self setVisitCountText:count isAllType:NO];
                }
                break;
            }
        }
    }
}

-(void)msgForAIVisitCountForCid:(NSString *)cid startTime:(int)startTimestamp endTime:(int)endTimestamp visitModel:(NSArray <visitCountModel *>*)visits
{
    
    if ([cid isEqualToString:self.cid]) {
        
        for (visitCountModel *model in visits) {
            
            yesterdayVisitCount = model.visitCount;
            
        }
        
    }
    
}

-(void)faceAddressSelectedPersonForIndex:(NSIndexPath *)indexPath
{
    if (cellSelectedIndexPath.row == indexPath.row) {
        cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self reqData];
}

-(void)faceCreateSuccessForIndex:(NSIndexPath *)indexPath
{
    if (cellSelectedIndexPath.row == indexPath.row) {
        cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self reqData];
}

-(void)initView
{
    [self updataLayout];
    [self addSubview:self.headCollectionView];
    [self addSubview:self.arrowButton];
    [self addSubview:self.visitCountLabel];
    [self addSubview:self.visitDetailBtn];
    self.visitCountLabel.hidden = NO;
    [self setVisitCountText:0 isAllType:YES];
    [self stepRefresh];
    self.headCollectionView.mj_footer.hidden = YES;
    self.headCollectionView.mj_header.hidden = YES;
    
    [self.visitDetailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.visitCountLabel.mas_top).with.offset(-3);
        make.left.equalTo(self.visitCountLabel.mas_right).with.offset(6);
            make.height.equalTo(@(22));
            make.width.equalTo(@(22));
        
    }];
}

-(void)backFamily
{
    cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.dataArray = self.familyArray;
    self.isFamilyshow = YES;
    [self updataLayout];
    [self resetPageCount];
    [self.headCollectionView reloadData];
    [self.headCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    self.visitCountLabel.hidden = NO;

    if (self.dataArray.count>cellSelectedIndexPath.row) {
        MsgAIheaderModel *model = [self.dataArray objectAtIndex:cellSelectedIndexPath.row];
        if (model.type == AIModelTypeAll) {
            model.visitCount = allVisitCount;
            [self setVisitCountText:allVisitCount isAllType:YES];
        }else
        {
            [self setVisitCountText:model.visitCount isAllType:NO];
        }
        //self.visitCountLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_SUM"],[NSString stringWithFormat:@"%d",model.visitCount]];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidSelectedCellForModel:)]) {
            [self.delegate msgAIHeadPortraitViewDidSelectedCellForModel:model];
        }
    }
}

-(void)updataLayout
{
    if (isExpand) {
        
        self.height = [UIScreen mainScreen].bounds.size.height-64;
        self.headCollectionView.height = self.height-50-20;
        self.visitCountLabel.bottom = self.height-17;
        self.arrowButton.bottom = self.height-12;
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewHeightChanged:)]) {
            [self.delegate msgAIHeadPortraitViewHeightChanged:self.height];
        }
        return;
    }
    
    if (self.dataArray.count == 0) {
        
        self.height = 0;
        self.visitCountLabel.bottom = self.height-12;
        self.arrowButton.y = self.visitCountLabel.y;
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewHeightChanged:)]) {
            [self.delegate msgAIHeadPortraitViewHeightChanged:self.height];
        }
        self.arrowButton.hidden = YES;
        return;
        
    }
    
    
    BOOL isDoubleLine = YES;
    if (self.isFamilyshow) {
        isDoubleLine = familyIsDoubleLine;
        if (isDoubleLine) {
            self.arrowButton.hidden = NO;
        }else{
            self.arrowButton.hidden = YES;
        }
    }else{
        isDoubleLine = msrIsDoubleLine;
        self.arrowButton.hidden = NO;
    }
    
    if (isDoubleLine) {
        if (self.height != selfHeight) {
            self.height = selfHeight;
            self.visitCountLabel.bottom = self.height-12;
            self.arrowButton.y = self.visitCountLabel.y;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewHeightChanged:)]) {
            [self.delegate msgAIHeadPortraitViewHeightChanged:self.height];
        }
        
    }else{
        CGFloat newHeight = selfHeight-collectionViewCellHeight;
        if (newHeight != self.height) {
            self.height = newHeight;
            self.visitCountLabel.bottom = self.height-12;
            self.arrowButton.y = self.visitCountLabel.y;
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewHeightChanged:)]) {
                [self.delegate msgAIHeadPortraitViewHeightChanged:self.height];
            }
        }
    }
    
    //[self scrollViewDidEndDecelerating:self.headCollectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MsgAIHeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MsgAIHeaderCell" forIndexPath:indexPath];
    UIView *redPoint = [cell.contentView viewWithTag:200001];
    if (!redPoint) {
        
        redPoint = [[UIView alloc]initWithFrame:CGRectMake(self.width/6+22.4, 9.6, 8, 8)];
        redPoint.tag = 200001;
        redPoint.layer.masksToBounds = YES;
        redPoint.layer.cornerRadius = 4;
        redPoint.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:redPoint];
    }
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.nameLabel.textAlignment = NSTextAlignmentCenter;

    if (self.dataArray.count>indexPath.row) {
        
        MsgAIheaderModel *model = self.dataArray[indexPath.row];
        if (model.type == AIModelTypeAll && hasNewMsg) {
            redPoint.hidden = NO;
        }else{
            redPoint.hidden = YES;
        }
        
        if (cellSelectedIndexPath.row == indexPath.row) {
            cell.isSelected = YES;
        }else{
            cell.isSelected = NO;
        }
        
        if (model.type == AIModelTypeAll) {
            
            cell.headImageView.canShowMenuView = NO;
            cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_ALL"];
            if (cell.isSelected) {
                cell.headImageView.image = [UIImage imageNamed:@"news_icon_all_selected"];
            }else{
                cell.headImageView.image = [UIImage imageNamed:@"news_icon_all_normal"];
            }
            
        }else if (model.type == AIModelTypeUnknow){
            
            cell.headImageView.canShowMenuView = NO;
            cell.headImageView.image = [UIImage imageNamed:@"news_icon_stranger"];
            cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_STRANGER"];
            
        }else if (model.type == AIModelTypeAddFace){
            
            cell.headImageView.canShowMenuView = NO;
            cell.headImageView.image = [UIImage imageNamed:@"icon_register_face"];
            cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_REGISTER_FACE"];
            
        }else if (model.type == AIModelTypeUnRegister || model.type == AIModelTypeRegister){
            
            cell.nameLabel.text = [JfgTimeFormat transToAITime:(int)model.last_time];
            NSString *imageUrl = model.faceImageUrl;
            [cell.headImageView jfg_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"news_head128"]];
            
            if (self.isFamilyshow) {
                cell.headImageView.canShowMenuView = YES;
                cell.headImageView.menuItems = @[[NSNumber numberWithInt:MenuItemTypeDel],[NSNumber numberWithInt:MenuItemTypeLook]];
            }else{
                cell.headImageView.canShowMenuView = NO;
                cell.headImageView.menuItems = @[[NSNumber numberWithInt:MenuItemTypeRecognition]];
            }
        }else{
            
            /*
             "AI_CAT" = "猫";
             "AI_DOG" = "狗";
             "AI_VEHICLE" = "车辆";
             */
            
//            cell.headImageView.menuItem2Type = MenuItemTypeNone;
//            cell.headImageView.canShowMenuView = NO;
//            if (model.type == AIModelTypeCar) {
//
//                cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"AI_VEHICLE"];
//                cell.headImageView.image = [UIImage imageNamed:@"news_icon_car_normal"];
//                if (cell.isSelected) {
//                    cell.headImageView.image = [UIImage imageNamed:@"news_icon_car_selected"];
//                }
//
//            }else if (model.type == AIModelTypeDog){
//                cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"AI_DOG"];
//                cell.headImageView.image = [UIImage imageNamed:@"news_icon_dog_normal"];
//                if (cell.isSelected) {
//                    cell.headImageView.image = [UIImage imageNamed:@"news_icon_dog_selected"];
//                }
//            }else if (model.type == AIModelTypeCat){
//
//                cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"AI_CAT"];
//                cell.headImageView.image = [UIImage imageNamed:@"news_icon_cat_normal"];
//                if (cell.isSelected) {
//                    cell.headImageView.image = [UIImage imageNamed:@"news_icon_cat_selected"];
//                }
//
//            }
        }
        
        //此行代码是为了尝试修复，全部，增加头像等三个cell有时候显示图片错误问题
        if (self.isFamilyshow) {
            if (indexPath.row == 0) {
                cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_ALL"];
                if (cell.isSelected) {
                    cell.headImageView.image = [UIImage imageNamed:@"news_icon_all_selected"];
                }else{
                    cell.headImageView.image = [UIImage imageNamed:@"news_icon_all_normal"];
                }
            }else if (indexPath.row == 1){
                cell.headImageView.canShowMenuView = NO;
                cell.headImageView.image = [UIImage imageNamed:@"news_icon_stranger"];
                cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_STRANGER"];
            }else if (indexPath.row == 2){
                cell.headImageView.canShowMenuView = NO;
                cell.headImageView.image = [UIImage imageNamed:@"icon_register_face"];
                cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_REGISTER_FACE"];
            }
            
        }
        
        cell.strangerIcon.hidden = YES;
    }
   
    return cell;
}


- (NSString *)imageUrlWithPerson_id:(NSString *)person_id
{
    //@"/long/vid/account/AI/cid/face_id.jpg";
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    JFGSDKAcount *acm = [[LoginManager sharedManager] accountCache];
    if (acm) {
        account = acm.account;
    }
    NSString *fileName = [NSString stringWithFormat:@"/long/%@/%@/AI/%@/%@.jpg",[OemManager getOemVid],account,self.cid,person_id];
    
    BOOL isExist = [SDWebImageCacheHelper diskImageExistsForFileName:fileName];
    if (isExist) {
        return [SDWebImageCacheHelper sdwebCacheForTempPathForFileName:fileName];
    }else{
        return [JFGSDK getCloudUrlWithFlag:[JFGSDK getRegionType] fileName:fileName];
    }
}

-(NSString *)imageUrlWithFace_id:(NSString *)face_id
{
    ///7day/
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    JFGSDKAcount *acm = [[LoginManager sharedManager] accountCache];
    if (acm) {
        account = acm.account;
    }
    NSString *fileName = [NSString stringWithFormat:@"/7day/%@/%@/AI/%@/%@.jpg",[OemManager getOemVid],account,self.cid,face_id];
    BOOL isExist = [SDWebImageCacheHelper diskImageExistsForFileName:fileName];
    if (isExist) {
        return [SDWebImageCacheHelper sdwebCacheForTempPathForFileName:fileName];
    }else{
        return [JFGSDK getCloudUrlWithFlag:[JFGSDK getRegionType] fileName:fileName];
    }
}

#pragma mark- 菜单选项回调
-(void)collectionViewCell:(UICollectionViewCell *)cell menuItemType:(MenuItemType)itemType indexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%d",itemType);
    if (itemType == MenuItemTypeLook) {
        MsgAIheaderModel *model = [self.dataArray objectAtIndex:indexPath.row];
        FaceMsgViewController *faceVC = [FaceMsgViewController new];
        faceVC.cid = self.cid;
        faceVC.person_id = model.person_id;
        faceVC.person_name = model.name;
        faceVC.faceList = model.faceIDList;
        faceVC.headImageUrl = model.faceImageUrl;
        faceVC.msgModel = model;
        UIViewController *supVC = [CommonMethod viewControllerForView:self];
        if (supVC) {
            [supVC.navigationController pushViewController:faceVC animated:YES];
        }
    }else if (itemType == MenuItemTypeRecognition){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"MESSAGES_IDENTIFY_POP"] delegate:self cancelButtonTitle:nil otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"MESSAGES_IDENTIFY_CREATE_BTN"],[JfgLanguage getLanTextStrByKey:@"MESSAGES_IDENTIFY_ADD_BTN"],[JfgLanguage getLanTextStrByKey:@"CANCEL"], nil];
        
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            MsgAIheaderModel *model = [self.dataArray objectAtIndex:indexPath.row];
            if (buttonIndex == 0) {
                FaceCreateViewController *faceCreate = [FaceCreateViewController new];
                faceCreate.cid = self.cid;
                faceCreate.delegate = self;
                faceCreate.selectedIndexPath = indexPath;
                faceCreate.headImageUrl = model.faceImageUrl;
                if (model.faceIDList.count) {
                    faceCreate.access_id = model.faceIDList[0];
                }
                UIViewController *vc = [CommonMethod viewControllerForView:self];
                if (vc) {
                    [vc presentViewController:faceCreate animated:YES completion:nil];
                }
            }else if (buttonIndex == 1){
                MsgAIheaderModel *model = [self.dataArray objectAtIndex:indexPath.row];
                FaceAddressBookVC *abVC = [FaceAddressBookVC new];
                abVC.cid = self.cid;
                abVC.face_id = model.faceIDList[0];
                abVC.selectedIndexPath = indexPath;
                abVC.delegate = self;
                abVC.imageUrl = model.originImageUrl;
                abVC.vcType = FaceAddressBookVCTypeRecognition;
                abVC.flag = model.flag;
                UIViewController *vc = [CommonMethod viewControllerForView:self];
                
                if (vc) {
                    [vc presentViewController:abVC animated:YES completion:nil];
                }
                
            }
            
        } otherDelegate:nil];
        
        
        
    }else if (itemType == MenuItemTypeDel){
        
        __weak typeof(self) weakSelf = self;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"MESSAGES_DELETE_POP"] delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"CANCEL"], nil];
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            
            if (buttonIndex == 0) {
                //删除头像
                [ProgressHUD showProgress:nil];
                MsgAIheaderModel *model = [weakSelf.dataArray objectAtIndex:indexPath.row];
                if (cellSelectedIndexPath.row == indexPath.row) {
                    cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                }
                //删除头像
                if (weakSelf.isFamilyshow) {
                    
                    
                    [self.msgRequest reqMsgDelAccess:model.person_id isFamiliar:YES delMsgAndHeader:YES cid:self.cid];
                    
                    LoginManager *loginManag = [LoginManager sharedManager];
                    NSMutableDictionary *patameters = [NSMutableDictionary new];
                    [patameters setObject:@"DeletePerson" forKey:@"action"];
                    [patameters setObject:loginManag.aiReqAuthToken forKey:@"auth_token"];
                    int64_t time = [[NSDate date] timeIntervalSince1970];
                    [patameters setObject:@(time) forKey:@"time"];
                    [patameters setObject:model.person_id forKey:@"person_id"];
                    //__weak typeof(self) weakSelf = self;
                    [AIRobotRequest afNetWorkingForAIRobotWithUrl:[AIRobotRequest aiServiceReqUrl] patameters:patameters sucess:^(id responseObject) {
                        
                        NSLog(@"%@",responseObject);
                        if ([responseObject isKindOfClass:[NSDictionary class]]) {
                            
                            NSDictionary *dict = responseObject;
                            int ret = [dict[@"code"] intValue];
                            if (ret == 200) {
                                //发送通知，刷新数据
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"AIFaceRegisterSuccess" object:nil];
                                //[weakSelf reqData];
                            }
                            
                        }
                       [ProgressHUD dismiss];
                        
                        
                    } failure:^(NSError *error) {
                        
                        NSLog(@"%@",error);
                        //[ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_CREATE_FAIL_TIPS"]];
                        [ProgressHUD dismiss];
                    }];
            
                }else{
                    
//                    [AIRobotRequest robotDelFaceIDList:@[model.faceIDList[0]] person_id:nil cid:self.cid sucess:^(id responseObject) {
//                        NSLog(@"%@",responseObject);
//                        [weakSelf reqData];
//                        [ProgressHUD dismiss];
//                    } failure:^(NSError *error) {
//                        [ProgressHUD dismiss];
//                    }];
            
                }

                
            }
            
        } otherDelegate:nil];
        
    }
}

-(void)delPersonForPerson_id:(NSString *)personId
{
    
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MsgAIheaderModel *model = [self.dataArray objectAtIndex:indexPath.row];
   if(model.type == AIModelTypeAddFace){
        AddFaceViewController *addFace = [AddFaceViewController new];
        addFace.cid = self.cid;
        BaseNavgationViewController *nav = [[BaseNavgationViewController alloc]initWithRootViewController:addFace];
        nav.navigationBarHidden = YES;
        UIViewController *supVC = [CommonMethod viewControllerForView:self];
        if (supVC) {
            [supVC presentViewController:nav animated:YES completion:nil];
        }
        
        return;
    }
    
    NSString *imageUrl = model.faceImageUrl;
    FLLog(@"%@",imageUrl);
    
    if (self.isFamilyshow && indexPath.row == 1) {
        
        cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.dataArray = self.unKnowArray;
        self.isFamilyshow = NO;
        [self updataLayout];
        [self resetPageCount];
        [self.headCollectionView reloadData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidUnkonwItemHasData:)]) {
            [self.delegate msgAIHeadPortraitViewDidUnkonwItemHasData:self.dataArray.count>0];
        }
        
    }else{
        
        MsgAIHeaderCollectionViewCell *currentCell = (MsgAIHeaderCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        MsgAIHeaderCollectionViewCell *oldCell = (MsgAIHeaderCollectionViewCell *)[collectionView cellForItemAtIndexPath:cellSelectedIndexPath];
        if (indexPath.row != cellSelectedIndexPath.row) {
            
            [self especialCellForSelectedIndexPath:indexPath];
            cellSelectedIndexPath = indexPath;
            currentCell.isSelected = YES;
            if (oldCell) {
                oldCell.isSelected = NO;
            }
            [self.headCollectionView reloadData];
        }
        
    }
    self.visitCountLabel.hidden = NO;
    
    if (self.isFamilyshow) {
        //选中某个cell，下方来访人数显示处理
        if (indexPath.row == 0) {
            [self.msgRequest reqAccessCountForType:5 accessID:@"all" cid:self.cid];
            //self.pageLabel.left = 15;
            //self.pageLabel.x = self.width*0.5;
            //self.pageLabel.textAlignment = NSTextAlignmentLeft;
            
            
        }else{
            
//            self.pageLabel.left = 15;
//            self.pageLabel.textAlignment = NSTextAlignmentLeft;
            
            
        }
        
    }else{
//        self.pageLabel.left = 15;
//        self.pageLabel.textAlignment = NSTextAlignmentLeft;
    }

    if (self.dataArray.count>cellSelectedIndexPath.row) {
        MsgAIheaderModel *model = [self.dataArray objectAtIndex:cellSelectedIndexPath.row];
        if (model.type != AIModelTypeAll && model.type != AIModelTypeUnknow) {
            
            if (model.visitCount>=0) {
                [self setVisitCountText:model.visitCount isAllType:NO];
            }else{
                
                [self setVisitCountText:0 isAllType:NO];
                if (self.isFamilyshow) {
                    [self.msgRequest reqAccessCountForType:2 accessID:model.person_id cid:self.cid];
                }else{
                    if (model.faceIDList.count) {
                        [self.msgRequest reqAccessCountForType:1 accessID:model.faceIDList[0] cid:self.cid];
                    }
                }
            }
            
        }else{
            if (model.type == AIModelTypeAll){
                
                //self.visitCountLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_SUM"],[NSString stringWithFormat:@"%d",allVisitCount]];
                
                [self setVisitCountText:allVisitCount isAllType:YES];
                
            }
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidSelectedCellForModel:)]) {
            [self.delegate msgAIHeadPortraitViewDidSelectedCellForModel:model];
        }
    }
    if (self.arrowButton.selected) {
        [self arrowAction:self.arrowButton];
    }
}



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    //YES表示支持多个手势同时触发，否则不允许多个手势同时触发
    if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
        return YES;
    }
    return NO;
}


-(void)setVisitCountText:(int)count isAllType:(BOOL)isAll
{
    NSString *dyy = @"";
    NSRange rang1 = NSMakeRange(0, 0);
    if (isAll) {
        dyy = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_SUM"],[NSString stringWithFormat:@"_%d",count]];
    }else{
        dyy = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_TIMES"],[NSString stringWithFormat:@"_%d",count==30?15:count]];
        rang1 = [dyy rangeOfString:@"30"];
        
        if (count == 30) {
            dyy = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_TIMES"],[NSString stringWithFormat:@"_%d",count]];
        }
        
    }
    NSRange rang = [dyy rangeOfString:[NSString stringWithFormat:@"_%d",count]];
    dyy = [dyy stringByReplacingOccurrencesOfString:@"_" withString:@""];

    NSMutableAttributedString *strArr = [[NSMutableAttributedString alloc]initWithString:dyy];
    [strArr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:12] range:NSMakeRange(rang.location>0?rang.location-1:0, rang.length)];
    [strArr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4B9FD5"] range:rang];
    
    if (!isAll) {
        if (rang1.location != NSNotFound && rang1.length < strArr.length) {
            [strArr addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"#4B9FD5"] range:rang1];
        }
    }
   
    
    self.visitCountLabel.attributedText = strArr;
    [self.visitCountLabel sizeToFit];

    if (isAll) {
        
        self.visitDetailBtn.hidden = NO;
        //防止可能被其他视图覆盖
        [self bringSubviewToFront:self.visitDetailBtn];
        
    }else{
        self.visitDetailBtn.hidden = YES;
    }
}

//全部，猫，狗等特殊筛选项图标变更处理
-(void)especialCellForSelectedIndexPath:(NSIndexPath *)indexPath
{
    MsgAIHeaderCollectionViewCell *currentCell = (MsgAIHeaderCollectionViewCell *)[self.headCollectionView cellForItemAtIndexPath:indexPath];
    MsgAIHeaderCollectionViewCell *allCell = (MsgAIHeaderCollectionViewCell *)[self.headCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (self.isFamilyshow) {
        if (allCell) {
            allCell.headImageView.image = [UIImage imageNamed:@"news_icon_all_normal"];
        }
        
        if (indexPath.row == 0) {
            currentCell.headImageView.image = [UIImage imageNamed:@"news_icon_all_selected"];
        }
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000+10) {
        
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    NSInteger page = scrollView.contentOffset.x/self.headCollectionView.width;
//    if (page*self.headCollectionView.width < scrollView.contentOffset.x) {
//        page = page+1;
//    }
//    NSInteger allPage = 0;
//    if (self.dataArray.count%6 == 0) {
//        allPage = self.dataArray.count/6;
//    }else{
//        allPage = self.dataArray.count/6+1;
//    }
//
//    if (page+1>allPage) {
//        page = page-1;
//    }
    
    //self.pageLabel.text = [NSString stringWithFormat:@"%d/%d",(int)page+1,(int)allPage];
}

-(UICollectionView *)headCollectionView
{
    if (!_headCollectionView) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 0;//左右距离
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.itemSize = CGSizeMake(self.width/3, collectionViewCellHeight);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        //flowLayout.itemCountPerRow = 3;
        //flowLayout.rowCount = 2;
        _headCollectionView = [[GestureCollection alloc]initWithFrame:CGRectMake(0, 20, self.width, collectionViewHeight) collectionViewLayout:flowLayout];
        _headCollectionView.pagingEnabled = NO;
        [_headCollectionView registerNib:[UINib nibWithNibName:@"MsgAIHeaderCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MsgAIHeaderCell"];
        _headCollectionView.delegate = self;
        _headCollectionView.dataSource = self;
        _headCollectionView.backgroundColor = [UIColor whiteColor];
        _headCollectionView.showsHorizontalScrollIndicator = NO;
        _headCollectionView.pagingEnabled = YES;
        
    }
    return _headCollectionView;
}

-(void)stepRefresh
{
    //self.headCollectionView.estimatedRowHeight = 0;
    self.headCollectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRefreshAction)];
    
    JFGRefreshLoadingHeader *header = [JFGRefreshLoadingHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRefreshAcion)];
    self.headCollectionView.mj_header = header;
    
    MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.headCollectionView.mj_footer;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    footer.stateLabel.textColor = [UIColor colorWithHexString:@"#888888"];
    self.headCollectionView.mj_header.hidden = YES;
    self.headCollectionView.mj_footer.hidden = YES;
}


#pragma mark- 刷新事件
-(void)footerRefreshAction
{
    isRefresh = NO;
    MsgAIheaderModel *model = [self.dataArray lastObject];
    int timestamp = (int)model.last_time;
    if (timestamp == 0) {
        [self.headCollectionView.mj_footer endRefreshing];
        return;
    }
    if (self.isFamilyshow) {
        [self.msgRequest reqFamiliarPersonsForCid:self.cid timestamp:(int)model.last_time ];
    }else{
        [self.msgRequest reqStrangerListForCid:self.cid timestamp:(int)model.last_time];
    }
    [self performSelector:@selector(reqMsgTimeout) withObject:nil afterDelay:10];
}

-(void)headerRefreshAcion
{
    isRefresh = YES;
    if (self.isFamilyshow) {
        [self.msgRequest reqFamiliarPersonsForCid:self.cid timestamp:0];
    }else{
        [self.msgRequest reqStrangerListForCid:self.cid timestamp:0];
    }
    [self.headCollectionView.mj_footer resetNoMoreData];
    [self performSelector:@selector(reqMsgTimeout) withObject:nil afterDelay:10];
   
}

-(void)reqMsgTimeout
{
    [self.headCollectionView.mj_header endRefreshing];
    [self.headCollectionView.mj_footer endRefreshing];
}

-(UILabel *)pageLabel
{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.headCollectionView.bottom+16, self.width, 17)];
        _pageLabel.font = [UIFont systemFontOfSize:12];
        _pageLabel.left = 15;
        _pageLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        _pageLabel.textAlignment = NSTextAlignmentLeft;
        NSInteger allPage = 0;
        if (self.dataArray.count%6 == 0) {
            allPage = self.dataArray.count/6;
        }else{
            allPage = self.dataArray.count/6+1;
        }
        _pageLabel.text = [NSString stringWithFormat:@"1/%ld",(long)allPage];
    }
    return _pageLabel;
}

-(UILabel *)visitCountLabel
{
    if (!_visitCountLabel) {
        _visitCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.headCollectionView.bottom+16, self.width*0.5-15, 17)];
        _visitCountLabel.bottom = self.height-12;
        _visitCountLabel.font = [UIFont systemFontOfSize:12];
        _visitCountLabel.left = 15;
        _visitCountLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        _visitCountLabel.userInteractionEnabled = YES;
        _visitCountLabel.textAlignment = NSTextAlignmentLeft;
        _visitCountLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_TIMES"],@"0"];
        [_visitCountLabel sizeToFit];
        _visitCountLabel.hidden = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(visitCountTap)];
        [_visitCountLabel addGestureRecognizer:tap];
    }
    return _visitCountLabel;
}

-(NSMutableArray *)familyArray
{
    if (!_familyArray) {
        _familyArray = [NSMutableArray new];
        MsgAIheaderModel *allModel = [MsgAIheaderModel new];
        allModel.type = AIModelTypeAll;
        MsgAIheaderModel *msrModel = [MsgAIheaderModel new];
        msrModel.type = AIModelTypeUnknow;
        [_familyArray addObject:allModel];
        [_familyArray addObject:msrModel];
    }
    return _familyArray;
}

-(NSMutableArray *)dataArray
{
    if(!_dataArray){
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

-(NSMutableArray *)unKnowArray
{
    if (!_unKnowArray) {
        _unKnowArray = [NSMutableArray new];
    }
    return _unKnowArray;
}

-(MsgForAIRequest *)msgRequest
{
    if (!_msgRequest) {
        _msgRequest = [MsgForAIRequest new];
        _msgRequest.delegate = self;
        [_msgRequest addJfgDelegate];
    }
    return _msgRequest;
}

-(UIButton *)arrowButton
{
    if (!_arrowButton) {
        
        _arrowButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _arrowButton = [[CommentFrameButton alloc]initWithFrame:CGRectMake(self.width-15-85, 10, 85, 20) titleFrame:CGRectMake(0, 0, 69, 20) imageRect:CGRectMake(71, 6, 14, 8)];
//        _arrowButton.right = self.width-15;
        _arrowButton.y = self.visitCountLabel.y;
        _arrowButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_arrowButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Menu_More"] forState:UIControlStateNormal];
        [_arrowButton setTitle:[JfgLanguage getLanTextStrByKey:@"FACE_COLLAPSE"] forState:UIControlStateSelected];
        [_arrowButton setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
        _arrowButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_arrowButton setImage:[UIImage imageNamed:@"icon_expand"] forState:UIControlStateNormal];
        [_arrowButton setImage:[UIImage imageNamed:@"icon_putaway"] forState:UIControlStateSelected];
        [_arrowButton addTarget:self action:@selector(arrowAction:) forControlEvents:UIControlEventTouchUpInside];

    }
    return _arrowButton;
}

-(UIButton *)visitDetailBtn
{
    if (!_visitDetailBtn) {
        _visitDetailBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _visitDetailBtn.frame = CGRectMake(self.visitCountLabel.right+6, self.visitCountLabel.top, 22, 22);
        _visitDetailBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_visitDetailBtn setImage:[UIImage imageNamed:@"icon_small_arrow"] forState:UIControlStateNormal];
        [_visitDetailBtn addTarget:self action:@selector(visitDetailAction) forControlEvents:UIControlEventTouchUpInside];
        //_visitDetailBtn.backgroundColor = [UIColor orangeColor];
    }
    return _visitDetailBtn;
}


//获取某一天的零点时间戳
-(NSTimeInterval)timestampForYear:(int)year month:(int)month day:(int)day
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.day = day;
    components.month = month;
    components.year = year;
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    components.nanosecond = 0;
    NSDate *newDate = [calendar dateFromComponents:components];
    NSTimeInterval timestamp = [newDate timeIntervalSince1970];
    return timestamp;
   
}


-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.msgRequest removeJfgDelegate];
}

@end

