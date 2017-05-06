//
//  MagViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/5.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "MagViewController.h"
#import "DelButton.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "UILabel+FLExtension.h"
#import "UIButton+FLExtentsion.h"
#import "FLGlobal.h"
#import "FLRefreshHeader.h"
#import "JfgLanguage.h"
#import "MCTableViewCell.h"
#import "DeviceSettingVC.h"
#import <MJRefresh.h>
#import <JFGSDK/JFGSDK.h>
#import "DateTools.h"

NSString *const magStateDateKey = @"_magDateKey";
////门磁列表
//class MsgClientMagListReq : public MsgHeader{
//public:
//    MSGPACK_DEFINE(mId, mCaller, mCallee,mSeq,timeBegin, timeEnd);
//    MsgClientMagListReq() : MsgHeader(16912){init();}
//        void init()
//    {
//        timeBegin = 0;
//        timeEnd = 0;
//    }
//    int64_t timeBegin;
//    int64_t timeEnd;
//};
////门磁主动推送状态
//class MsgClientPush: public MsgHeader{
//public:
//    MSGPACK_DEFINE(mId, mCaller, mCallee,mSeq);
//    
//    MsgClientPush() : MsgHeader(15004) {}
//    
//};
//
////获取门磁推送开关状态
//class MsgClientGetMagWarnReq:public MsgHeader{
//public:
//    MSGPACK_DEFINE(mId, mCaller, mCallee,mSeq);
//    MsgClientGetMagWarnReq() : MsgHeader(16922) {}
//};


                   
@interface MagViewController ()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate>{
    CGFloat defaultViewHeight;
}
@property(strong, nonatomic)UILabel * titleLabel;
@property(strong, nonatomic)DelButton * exitBtn;
@property(strong, nonatomic)UIButton * settingBtn;
@property(strong, nonatomic)UIImageView * doorImageView;
@property(strong, nonatomic)UIView * topHeaderView;
@property(strong, nonatomic)UITableView * stateTableView;
@property(strong, nonatomic)FLRefreshHeader * refreshView;
@property(strong, nonatomic)NSMutableArray * dateArray;
@property(strong, nonatomic)NSMutableArray *totalDateArray;
@property(strong, nonatomic)NSMutableArray *magArr;
@property(strong, nonatomic)UIView * noDataView;
@property(strong, nonatomic)NSDateFormatter * dateFormatter;
@property(strong, nonatomic)NSDateFormatter * timeFormatter;
@property(strong, nonatomic)CAGradientLayer *caLayer;
@end

@implementation MagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    defaultViewHeight = 214*designHscale;
    self.view.backgroundColor = [UIColor whiteColor];
    self.totalDateArray = [NSMutableArray array];
    self.dateArray = [NSMutableArray array];
    self.magArr = [NSMutableArray array];
    //scrollview向下偏移了一部分
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    
    [JFGSDK addDelegate:self];
    //清空门铃记录设置页返回通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createData) name:@"JFGClearMagMsgSuccess" object:nil];
    [self initView];
    [self createData];
    [self getMagWarnStatu];
}

-(void)getMagWarnStatu
{
//    MsgClientGetMagWarnReq req;
//    req.mId = 16922;
//    req.mCallee = [self.cid UTF8String];
//    req.mCaller = "";
//    std::string reqData1 = getBuff(req);
//    NSData *data1 = [NSData dataWithBytes:reqData1.c_str() length:reqData1.length()];
//    [JFGSDK sendEfamilyMsgData:data1];
}

- (void)createData
{
//    //门磁列表
//    MsgClientMagListReq req;
//    req.mId = 16912;
//    req.mCallee = [self.cid UTF8String];
//    req.mCaller = "";
//    req.timeBegin = 0;
//    req.timeEnd = [[NSDate date] timeIntervalSince1970];
//    std::string reqData = getBuff(req);
//    NSData *data = [NSData dataWithBytes:reqData.c_str() length:reqData.length()];
//   [JFGSDK sendEfamilyMsgData:data];
//    //服务器主动推送的
//    MsgClientMagListReq req1;
//    req1.mId = 15004;
//    req1.mCallee = [self.cid UTF8String];
//    req1.mCaller = "";
//    std::string reqData1 = getBuff(req1);
//    NSData *data1 = [NSData dataWithBytes:reqData1.c_str() length:reqData1.length()];
//    [JFGSDK sendEfamilyMsgData:data1];
    
}

-(void)jfgEfamilyMsg:(id)msg
{
    //NSLog(@"门磁：%@",[msg description]);
    
    if ([msg isKindOfClass:[NSArray class]]) {
        
        NSArray *sourceArr = msg;
        if (sourceArr.count >= 7) {
            
            //(mId, mCaller, mCallee, ret, msg, curStatus,list)
            int msgid = [sourceArr[0] intValue];
            if (msgid == 16913) {
                NSString *cid = sourceArr[1];
                if (![cid isEqualToString:self.cid]) {
                    return;
                }
                //int ret = [sourceArr[3] intValue];//错误吗
                int curStatus= [sourceArr[5] intValue];//当前开关情况 0关闭 1打开
                [self setTopColor:curStatus];
                
                NSArray *msgList = sourceArr[6];
                if ([msgList isKindOfClass:[NSArray class]]) {
                    
                    for (id obj in msgList) {
                        
                        if ([obj isKindOfClass:[NSArray class]] ) {
                            
                            NSArray *msgArr = obj;
                            if (msgArr.count>=2) {
                                
                                MenciModel *model = [MenciModel new];
                                model.isOpen = [msgArr[0] intValue];
                                model.timestamp = [msgArr[1] longLongValue];
                                [self.magArr addObject:model];
                                
                            }
                            
                        }
                        
                    }
                    NSLog(@"分类前的数组：%@",_magArr);
                    self.totalDateArray = [self catalogueMag:self.magArr];
                    [self judgeHaveData];
                    [self.stateTableView reloadData];
                    
                }
            }
            if (msgid == 15004) {
                int magPushType = [sourceArr[4] intValue];
                
                if (magPushType == 19 || magPushType == 18) {
                    
                    int64_t magPushTime = [sourceArr[7] longLongValue];
                    MenciModel *model = [MenciModel new];
                    model.timestamp = magPushTime;
                    if (magPushType == 19) {
                        //关闭
                        [self setTopColor:0];
                        model.isOpen = NO;

                    }
                    if (magPushType == 18) {
                        [self setTopColor:1];
                        model.isOpen = YES;
                    }
                    [self.magArr insertObject:model atIndex:0];
                    self.totalDateArray = [self catalogueMag:self.magArr];
                    [self judgeHaveData];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.stateTableView reloadData];
                    });
                }
            }
        }else if(sourceArr.count >=6){
            
            int msgid = [sourceArr[0] intValue];
            if (msgid == 16923) {
                
                int wanrn = [sourceArr[5] intValue];
                if (wanrn == 1) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"JFGMagWarnStatue"];
                }else{
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"JFGMagWarnStatue"];
                }
                
            }
            
        }
        
    }
}
- (void)judgeHaveData {
    if (self.totalDateArray.count == 0) {
        self.noDataView.hidden = NO;
        self.stateTableView.hidden = YES;
    }else{
        self.noDataView.hidden = YES;
        self.stateTableView.hidden = NO;
    }
}
-(void)initView{
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.stateTableView];
    [self.view addSubview:self.topHeaderView];
    [self judgeHaveData];
}
- (NSMutableArray *)catalogueMag :(NSArray *)arr {
    NSMutableArray * totalArr = [NSMutableArray array];
    if (arr.count > 0) {
        //给定一个初始值用于比较第一天
        NSString * dafaultDay = @"+";
        NSMutableArray * subArr = [NSMutableArray new];
        for (int i = 0; i < arr.count; i++) {
            MenciModel * aM = [arr objectAtIndex:i];
            NSString * aDay = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:aM.timestamp]];
            if (![aDay isEqualToString:dafaultDay]) {
                if (i != 0) {
                    [totalArr addObject:subArr];
                }
                //由于初始值为特殊值，所以i=0的比较一定会走这里，创建一个新的section小数组
                subArr = [NSMutableArray new];
            }
            [subArr addObject:aM];
            dafaultDay = aDay;
        }
        // 最后一组数据，没有异同，所以不会进if (![aDay isEqualToString:dafaultDay])
        [totalArr addObject:subArr];
    }
    return totalArr;
}
-(void)updateTopImageWithState:(MagState)state{
    switch (state) {
        case magStateOpen:{
            [self.topHeaderView setBackgroundColor:[UIColor colorWithHexString:@"#f28080"]];
            [self.doorImageView setImage:[UIImage imageNamed:@"icon_open"]];
        }
            break;
        case magStateClose:{
            [self.topHeaderView setBackgroundColor:[UIColor colorWithHexString:@"#66bb6a"]];
            [self.doorImageView setImage:[UIImage imageNamed:@"icon_close"]];
        }
            break;
        case magStateOffline:{
            [self.topHeaderView setBackgroundColor:[UIColor colorWithHexString:@"#bcbcbc"]];
            [self.doorImageView setImage:[UIImage imageNamed:@"icon_close"]];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - JFGSDK
- (void)efamilyResponseWithDict:(NSDictionary *)dict {
    NSLog(@"门磁请求字典：%@",dict);
}
#pragma mark - UITabelViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.totalDateArray.count;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray * arr = [self.totalDateArray objectAtIndex:section];
    return arr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MCTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"MCell" forIndexPath:indexPath];
    NSArray * arr = [self.totalDateArray objectAtIndex:indexPath.section];
    MenciModel * m = [arr objectAtIndex:indexPath.row];
    cell.timeLabel.text = [self.timeFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.timestamp]];
    cell.stateLabel.text = m.isOpen?[JfgLanguage getLanTextStrByKey:@"MAGNETISM_ON"]:[JfgLanguage getLanTextStrByKey:@"MAGNETISM_OFF"];
    if(indexPath.row == 0){
        if([[NSDate dateWithTimeIntervalSince1970:m.timestamp] isToday])
        {
            [cell setDateLabelText:[JfgLanguage getLanTextStrByKey:@"DOOR_TODAY"]];
        } else {
            [cell setDateLabelText:[self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:m.timestamp]]];
        }
    }else{
        [cell setDateLabelText:nil];
    }
    if (indexPath.section ==0 &&indexPath.row == 0) {
        [cell.dotImageView setImage:[UIImage imageNamed:@"magnetic_new"]];
        cell.timeLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        cell.stateLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }else{
        [cell.dotImageView setImage:[UIImage imageNamed:@"magnetic_history"]];
        cell.timeLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        cell.stateLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    }

    return cell;
}
#pragma mark - UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section !=0 && indexPath.row == 0) {
        return 64;
    }
    return 40.0;
}
//-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    
//    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
//    
//    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
//        [cell setLayoutMargins:UIEdgeInsetsZero];
//    }
//}
-(void)startRefresh{
    NSLog(@"startRefresh");
}
#pragma mark - 界面
-(NSDateFormatter *)dateFormatter
{
    if (!_dateFormatter) {
        _dateFormatter =[[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"MM/dd"];
    }
    return _dateFormatter;
}
-(NSDateFormatter *)timeFormatter
{
    if (!_timeFormatter) {
        _timeFormatter =[[NSDateFormatter alloc] init];
        [_timeFormatter setDateFormat:@"HH:mm:ss"];
    }
    return _timeFormatter;
}
-(UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, defaultViewHeight, self.view.width, self.view.height-defaultViewHeight)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-140)/2.0, 0.13*kheight, 140, 140)];
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
-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [UILabel initWithFrame:CGRectMake((self.view.width-200)/2.0, 33, 200, 17) text:[JfgLanguage getLanTextStrByKey:@"DOG_MAGNETISM_NAME"] font:FontNameHelvetica size:17 color:[UIColor whiteColor] alignment:NSTextAlignmentCenter lines:1];
        [_titleLabel setFont:[UIFont systemFontOfSize:17]];
    }
    return _titleLabel;
}
-(DelButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [UIButton initWithFrame:CGRectMake(10, 27, 30, 30) image:[UIImage imageNamed:@"qr_backbutton_normal"] highlightedImage:nil cornerRadius:0 handerForTouchUpInside:^(UIButton *button) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }
    return _exitBtn;
}
-(UIButton *)settingBtn{
    if (!_settingBtn) {
        _settingBtn = [UIButton initWithFrame:CGRectMake(self.view.width-44-5, 20, 44, 44) image:[UIImage imageNamed:@"camera_ico_install"] highlightedImage:nil cornerRadius:0 handerForTouchUpInside:^(UIButton *button) {
            DeviceSettingVC * settingVC = [[DeviceSettingVC alloc]init];
            settingVC.pType = productType_Mag;
            settingVC.cid = self.cid;
            [self.navigationController pushViewController:settingVC animated:YES];
        }];
    }
    return _settingBtn;
}
-(UIImageView *)doorImageView{
    if (!_doorImageView) {
        _doorImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-100*designHscale)/2.0,81*designHscale, 100*designHscale, 115*designHscale)];
        [_doorImageView setImage:[UIImage imageNamed:@"icon_close"]];
    }
    return _doorImageView;
}
-(UITableView *)stateTableView{
    if (!_stateTableView) {
        _stateTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, defaultViewHeight, self.view.width, self.view.height-defaultViewHeight) style:UITableViewStylePlain];
        _stateTableView.dataSource = self;
        _stateTableView.delegate = self;
        _stateTableView.showsVerticalScrollIndicator = NO;
        _stateTableView.showsHorizontalScrollIndicator = NO;
        _stateTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _stateTableView.allowsSelection = NO;
        [_stateTableView registerClass:[MCTableViewCell class] forCellReuseIdentifier:@"MCell"];
        //__weak __typeof(self) weakSelf = self;
//        _stateTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [_stateTableView.mj_header endRefreshing];
//            });
//        }];
//        [_stateTableView addSubview:self.refreshView];
//        [self.refreshView setRefreshingTarget:self refreshingAction:@selector(startRefresh)];
    }
    return _stateTableView;
}

-(UIView *)topHeaderView{
    if (!_topHeaderView) {
        _topHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, defaultViewHeight)];
        [self setTopColor:magStateOffline];
        [_topHeaderView addSubview:self.doorImageView];
        [_topHeaderView addSubview:self.exitBtn];
        [_topHeaderView addSubview:self.settingBtn];
        [_topHeaderView addSubview:self.titleLabel];
    }
    return _topHeaderView;
}
//-(FLRefreshHeader *)refreshView
//{
//    if (!_refreshView) {
//        _refreshView = [[FLRefreshHeader alloc]initWithFrame:CGRectMake(0, -50, Kwidth, 23)];
//        _refreshView.originOffset_y = defaultViewHeight;
//    }
//    return _refreshView;
//}
- (void)setTopColor:(int)state{
    if (!_caLayer) {
        _caLayer = [CAGradientLayer layer];
        _caLayer.frame = self.topHeaderView.bounds;
        [self.topHeaderView.layer addSublayer:_caLayer];
        [self.topHeaderView.layer insertSublayer:_caLayer atIndex:0];
    }

    //颜色分配:四个一组代表一种颜色(r,g,b,a)
    switch (state) {
        case magStateOpen:{
            _caLayer.colors = @[(__bridge id) [UIColor colorWithHexString:@"#e99685"].CGColor,
                             (__bridge id) [UIColor colorWithHexString:@"#fd6464"].CGColor];
            //起始点
            _caLayer.startPoint = CGPointMake(0, 1);
            //结束点
            _caLayer.endPoint = CGPointMake(1, 0);
            self.doorImageView.image = [UIImage imageNamed:@"icon_open"];
        }
            break;
        case magStateClose:{
            _caLayer.colors = @[(__bridge id) [UIColor colorWithHexString:@"#6bdbf2"].CGColor,
                             (__bridge id) [UIColor colorWithHexString:@"#64b3f4"].CGColor];
            //起始点
            _caLayer.startPoint = CGPointMake(0, 1);
            //结束点
            _caLayer.endPoint = CGPointMake(1, 0);
            self.doorImageView.image = [UIImage imageNamed:@"icon_close"];
        }
            break;
        case magStateOffline:{
            _caLayer.colors = @[(__bridge id) [UIColor colorWithHexString:@"#acb5c4"].CGColor,
                             (__bridge id) [UIColor colorWithHexString:@"#686f7f"].CGColor];
            //起始点
            _caLayer.startPoint = CGPointMake(0, 1);
            //结束点
            _caLayer.endPoint = CGPointMake(0, 0);
            self.doorImageView.image = [UIImage imageNamed:@"icon_close"];
        }
            break;
            
        default:
            break;
    }
}
#pragma mark - didReceiveMemoryWarning
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end


@implementation MenciModel

@end
