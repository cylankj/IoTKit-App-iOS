//
//  ExploreRootViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ExploreRootViewController.h"
#import "UIView+FLExtensionForFrame.h"
#import "TimeChangeMonitor.h"
#import "LoginManager.h"
#import "TimeLineView.h"
#import "DateRulerView.h"
#import "ExploreTableViewCell.h"
#import <MXParallaxHeader/MXScrollView.h>
#import "FLGlobal.h"
#import <Masonry.h>
#import "ExploreTableView.h"
#import "FLRefreshHeader.h"
#import "DateTools.h"
#import "DJActionSheet.h"
#import "DJActionRuler.h"
#import "dataPointMsg.h"
#import "JfgMsgDefine.h"
#import "dataPointMsg.h"
#import <JFGSDK/JFGSDKDataPointModel.h>
#import <JFGSDK/JFGSDK.h>
#import "JfgTimeFormat.h"
#import "ExploreModel.h"
#import "UIButton+Click.h"
#import <SDWebImage/SDWebImageCompat.h>
#import "UIImageView+WebCache.h"
#import "JfgLanguage.h"
#import "JfgConfig.h"
#import "OemManager.h"
#import "CommonMethod.h"
#import "ShareView.h"
//sharesdk
#import "ShareClassView.h"
#import "JfgCacheManager.h"
#import "LoginManager.h"
#import "UIImageView+JFGImageView.h"
#import <MJRefresh/MJRefresh.h>
#import "JFGRefreshLoadingHeader.h"
#import <MediaPlayer/MediaPlayer.h>
#import "KRVideoPlayerController.h"
#import "ExploreVideoPlayViewController.h"
#import "JFGDatePickers.h"
#import "Watch720PhotoVC.h"
#import "ProgressHUD.h"
#import "LSAlertView.h"
#import "FLShareSDKHelper.h"
#import "FLLog.h"

#define COVERVIEWTAG 1001
#define TIMEBUTTONTAG 2555
#define TIMEBUTTON1TAG 2556

@interface ExploreRootViewController ()<TimeChangeMonitorDelegate,LoginManagerDelegate,JFGSDKCallbackDelegate,DJActionRulerDelegate,UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate,JFGDatePickerDelegate>
{
    BOOL isRefreshing;
}
@property (nonatomic, strong) KRVideoPlayerController *videoController;

@property (strong, nonatomic) UIView * noDataView;
//顶部主题背景图片
@property (nonatomic, strong)UIImageView *topicImageView;

//大标题
@property (nonatomic, strong)UILabel * topicTitleLabel;

@property (nonatomic,strong)UILabel *topTitleLabel;

//描述语
@property (nonatomic, strong)UILabel * greetLabel;

//日期选择按钮
@property (nonatomic, strong)UIButton * dateChooseButton;

//展示表格
@property (nonatomic, strong)UITableView * contentTableView;

//时间选择按钮
@property (nonatomic, strong)UIButton * timeSelectButton;

//选择按钮(title上)
@property (nonatomic ,strong)UIButton * timeSelectButton1;



//数组
@property (nonatomic,strong) NSMutableArray * modelArray;
//时间数组
@property (nonatomic, strong)NSMutableArray * timeArray;

//顶部透明的View,放标题按钮的
@property (nonatomic,strong)UIView * topTransparentView;


@property (nonatomic,strong)UIView *barView;

@property (nonatomic,strong)FLRefreshHeader *refreshView;

@property (nonatomic,strong)CAGradientLayer *dayGradient;

@property (nonatomic,strong)CAGradientLayer *nightGradient;

@property (nonatomic,strong)NSDateFormatter *YMDformatter;
@property (nonatomic,strong)NSDateFormatter *dateFormatter;
@property (nonatomic,strong)NSArray * dateArr;
@property (nonatomic,strong)DJActionRuler * ruler;
@property (nonatomic,strong)JFGDatePickers *dateRuler;

@end

@implementation ExploreRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapReceived:)];
    [tapGestureRecognizer setDelegate:self];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.modelArray = [NSMutableArray array];
    self.timeArray = [NSMutableArray array];
    topBgViewHeight =  170;
    [self.view addSubview:self.contentTableView];
    //[self.contentTableView addSubview:self.noDataView];
    [self createHeaderView];


    [[TimeChangeMonitor sharedManager] addDelegate:self];
    [[TimeChangeMonitor sharedManager] timerAction];
    [[TimeChangeMonitor sharedManager] starTimer];
    [[LoginManager sharedManager] addDelegate:self];
    
//    NSString *dayString =[self.YMDformatter stringFromDate:[NSDate date]];
//    [self.timeSelectButton1 setTitle:dayString forState:UIControlStateNormal];
//    [self.timeSelectButton setTitle:dayString forState:UIControlStateNormal];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(createData) name:@"JFGCollectDayHighlight" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delBigPic:) name:JFGDelExporePicKey object:nil];

    [JFGSDK addDelegate:self];
    [[LoginManager sharedManager] addDelegate:self];
    [self getExploreData];
    //[self.tipLabel setText:[self.tip_formatter stringFromDate:[self.ymd_formatter dateFromString:dateString]]];
}

-(void)getExploreData
{
    //    NSString *str =  [NSString stringWithFormat:@"JFGIsShowDemoFor%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:JFGShowDemoForExploreKey];
    //客户端第一次启动，显示延时摄影演示视频
    //    if (![[NSUserDefaults standardUserDefaults] boolForKey:str]) {
    //        [self createDemoData];
    //    }else{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        [self loadCacheData];
        [self createData];
        self.refreshView.hidden = NO;
        self.contentTableView.mj_footer.hidden = NO;
    }else if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut){
        self.refreshView.hidden = YES;
        self.contentTableView.mj_footer.hidden = YES;
    }else{
        self.refreshView.hidden = YES;
        self.contentTableView.mj_footer.hidden = YES;
        [self loadCacheData];
    }
    //  }
}

-(void)createDemoData
{
    ExploreModel * m = [[ExploreModel alloc]init];
    NSString *dateStr = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
    m.version = dateStr;
    m.msgTime = dateStr;
    long long timestamp = [m.version longLongValue]/1000;
    m.time = [JfgTimeFormat transToHHmm:[NSString stringWithFormat:@"%lld",timestamp]];
    m.isPic = NO;
    m.regionType = 1;
    m.alias = [JfgLanguage getLanTextStrByKey:@"Tap2_Index_DemoVideo"];
    m.url = @"";
    m.videoUrl = @"";
    m.cid = @"";
    
    [self.modelArray addObject:m];
    [self.timeArray addObject:[JfgTimeFormat transToyyyyMMddhhmmss:m.msgTime]];
    [self judgeHaveData];
    [self.refreshView endRefresh];
    [self.contentTableView reloadData];
    //初始化时间选择器
//    if (!self.ruler.superview) {
//        [[UIApplication sharedApplication].delegate.window addSubview: self.ruler];
//    }
//
//    [_ruler loadDateStringArray:self.timeArray markedDateString:[self.timeArray firstObject]];
    
    self.refreshView.hidden = YES;
    self.contentTableView.mj_footer.hidden = YES;
    self.contentTableView.tableFooterView = [self demoFooterView];
    
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGShowDemoForExploreKey];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self judgeHaveData];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}



-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.modelArray.count) {
        [JfgCacheManager cacheDayJingcaiMsgList:self.modelArray];
    }
}

-(void)loadCacheData
{
    NSArray *cacheData = [JfgCacheManager getCacheForDayJingcai];
    self.modelArray = [[NSMutableArray alloc]initWithArray:cacheData];
    self.timeArray = [[NSMutableArray alloc]init];
    for (ExploreModel *m in self.modelArray) {
        [self.timeArray addObject:[JfgTimeFormat transToyyyyMMddhhmmss:m.msgTime]];
    }
    [self judgeHaveData];
    [self.refreshView endRefresh];
    [self.contentTableView reloadData];
    self.topicTitleLabel.alpha = 1;
    self.greetLabel.alpha = 1;

    if (self.modelArray.count) {
        self.contentTableView.mj_footer.hidden = NO;
    }else{
        self.contentTableView.mj_footer.hidden = YES;
    }
}

- (void)judgeHaveData{
    if (self.modelArray.count == 0) {
        self.noDataView.hidden = NO;
    }else{
        self.noDataView.hidden = YES;
    }
    if (self.modelArray.count) {
        self.contentTableView.mj_footer.hidden = NO;
    }else{
        self.contentTableView.mj_footer.hidden = YES;
    }
}
#pragma mark - create Data
- (void)createData
{
    if (self.contentTableView.mj_footer) {
        [self.contentTableView.mj_footer resetNoMoreData];
    }
    [[JFGSDKDataPoint sharedClient] robotGetDataEx:@"" version:0 dpids:@[@602] asc:NO success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        NSMutableArray *arr = [NSMutableArray array];
        
        for (NSArray * subArr in idDataList)
        {
            NSMutableArray *elementArr = [NSMutableArray array];
            for (DataPointSeg *seg in subArr)
            {
                NSError *error = nil;
                NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (!error)
                {
                    [elementDict setObject:@(seg.version) forKey:dpTimeKey];
                    [elementDict setObject:[NSNumber numberWithInt:(int)seg.msgId] forKey:@"msgID"];
                    [elementDict setValue:obj forKey:dpValueKey];
                    [elementDict setValue:@(seg.msgId) forKey:dpIdKey];
                    [elementArr addObject:elementDict]; // error 不为nil 添加数
                    
                }else{
                    
                    NSLog(@"___error %@",error);
                }
            }
            [arr addObject:elementArr];
        }

        if (arr.count > 0) {
            [self.modelArray removeAllObjects];
            [self.timeArray removeAllObjects];
            for (NSArray * msgArr in arr) {
                for (NSDictionary * dic in msgArr) {
                    NSArray * vauleArr = [dic objectForKey:@"_dpValue"];
                    ExploreModel * m = [[ExploreModel alloc]init];
                    m.version = [dic objectForKey:@"_dpTime"];
                    m.msgID = [[dic objectForKey:@"msgID"] intValue];
                    m.cid = [vauleArr objectAtIndex:0];
                    m.msgTime = [[vauleArr objectAtIndex:1] stringValue];
                    
                    long long timestamp = [m.version longLongValue]/1000;
                    m.time = [JfgTimeFormat transToHHmm:[NSString stringWithFormat:@"%lld",timestamp]];
                    m.isPic = ![[vauleArr objectAtIndex:2] boolValue];
                    m.regionType = [[vauleArr objectAtIndex:3] intValue];
                    m.url = [vauleArr objectAtIndex:4];
                    
                    if (vauleArr.count>6) {
                        id _obj = vauleArr[6];
                        if ([_obj isKindOfClass:[NSNumber class]]) {
                           m.collectedTimestamp = [vauleArr[6] longLongValue];
                        }else if([_obj isKindOfClass:[NSString class]]){
                           m.shareVideoUrl = vauleArr[6];
                        }
                    }else{
                        m.collectedTimestamp = 0;
                    }
                    
                    if (vauleArr.count>5) {
                        m.alias = [vauleArr objectAtIndex:5];
                    }else{
                        m.alias = m.cid;
                    }
                    
                    [self.modelArray addObject:m];
                    [self.timeArray addObject:[JfgTimeFormat transToyyyyMMddhhmmss:m.msgTime]];
                }
            }
            [self judgeHaveData];
            [self.refreshView endRefresh];
            [self.contentTableView reloadData];
            self.topicTitleLabel.alpha = 1;
            self.greetLabel.alpha = 1;
            
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
        NSLog(@"每日精彩获取失败：%ld",(long)type);
        [self.refreshView endRefresh];
        self.topicTitleLabel.alpha = 1;
        self.greetLabel.alpha = 1;
        [self judgeHaveData];
        
    }];
    
//    DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
//    seg.msgId = dpMsgAccount_Wonder;
//    seg.version = 0;
//    [[dataPointMsg shared]packMutableDataPointMsg:@[seg] withCid:@"" isAsc:NO countLimit:15 SuccessArrBlock:^(NSMutableArray *arr) {
//        if (arr.count > 0) {
//            [self.modelArray removeAllObjects];
//            [self.timeArray removeAllObjects];
//            for (NSArray * msgArr in arr) {
//                for (NSDictionary * dic in msgArr) {
//                    NSArray * vauleArr = [dic objectForKey:@"_dpValue"];
//                    ExploreModel * m = [[ExploreModel alloc]init];
//                    m.version = [dic objectForKey:@"_dpTime"];
//                    m.cid = [vauleArr objectAtIndex:0];
//                    m.msgTime = [[vauleArr objectAtIndex:1] stringValue];
//                    
//                    long long timestamp = [m.version longLongValue]/1000;
//                    m.time = [JfgTimeFormat transToHHmm:[NSString stringWithFormat:@"%lld",timestamp]];
//                    m.isPic = ![[vauleArr objectAtIndex:2] boolValue];
//                    m.regionType = [[vauleArr objectAtIndex:3] intValue];
//                    m.url = [vauleArr objectAtIndex:4];
//                    
//                    if (vauleArr.count>6) {
//                        m.collectedTimestamp = [vauleArr[6] longLongValue];
//                    }else{
//                        m.collectedTimestamp = 0;
//                    }
//                    
//                    if (vauleArr.count>5) {
//                        m.alias = [vauleArr objectAtIndex:5];
//                    }else{
//                        m.alias = m.cid;
//                    }
//                    
//                    [self.modelArray addObject:m];
//                    [self.timeArray addObject:[JfgTimeFormat transToyyyyMMddhhmmss:m.msgTime]];
//                }
//            }
//            [self judgeHaveData];
//            [self.refreshView endRefresh];
//            [self.contentTableView reloadData];
//            self.topicTitleLabel.alpha = 1;
//            self.greetLabel.alpha = 1;
//
//            
//            //初始化时间选择器
////            if (!self.ruler.superview) {
////                [[UIApplication sharedApplication].delegate.window addSubview: self.ruler];
////            }
////            
//////            ExploreModel * m = [self.modelArray firstObject];
////            [_ruler loadDateStringArray:self.timeArray markedDateString:[self.timeArray firstObject]];
//        }
//        
//    } FailBlock:^(RobotDataRequestErrorType error) {
//        NSLog(@"每日精彩获取失败：%ld",(long)error);
//        [self.refreshView endRefresh];
//        self.topicTitleLabel.alpha = 1;
//        self.greetLabel.alpha = 1;
//
//        [self judgeHaveData];
//    }];
    [self performSelector:@selector(headerEndRefresh) withObject:nil afterDelay:10.0];

}
#pragma mark - create view
-(void)createHeaderView
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, -topBgViewHeight, self.view.width, topBgViewHeight)];
    //[headerView addSubview:self.timeSelectButton];
    [headerView addSubview:self.topicTitleLabel];
    [headerView addSubview:self.greetLabel];
    
    [self stretchHeaderView:self.topicImageView subViews:headerView];
}


#pragma mark- JFGSDKDelegate
-(void)jfgAccountOnline:(BOOL)online
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:JFGShowDemoForExploreKey]) {
        if (online) {
            self.refreshView.hidden = NO;
            self.contentTableView.mj_footer.hidden = NO;
            [self createData];
        }else{
            self.refreshView.hidden = YES;
            self.contentTableView.mj_footer.hidden = YES;
        }
    }else{
        self.refreshView.hidden = YES;
        self.contentTableView.mj_footer.hidden = YES;
    }
    
    
}

-(void)loginOut
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:JFGShowDemoForExploreKey]) {
        [self.modelArray removeAllObjects];
        [self judgeHaveData];
        [self.refreshView endRefresh];
        [self.contentTableView reloadData];
        self.topicTitleLabel.alpha = 1;
        self.greetLabel.alpha = 1;

    }
    self.refreshView.hidden = YES;
}

-(void)loginSuccess
{
    [self createData];
    self.refreshView.hidden = NO;
    [self.contentTableView bringSubviewToFront:self.refreshView];
}


#pragma mark - 表格相关
#pragma mark -UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellE1";
    static NSString *cellID1 = @"cellE0";
    ExploreModel *m = [self.modelArray objectAtIndex:indexPath.row];
    if(!m.isPic)//视频
    {
        ExploreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID1];
        if(!cell) {
            cell= [[NSBundle mainBundle]loadNibNamed:@"ExploreTableViewCell" owner:self options:nil][0];
            [cell.shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Button"] forState:UIControlStateNormal];
            if ([OemManager oemType] == oemTypeCell_C) {
                cell.shareButton.hidden = YES;
            }
        }
        cell.msgTime = m.msgTime;
        cell._indexPath = indexPath;
        
        JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
        
        NSString *fileName = [m.url stringByDeletingPathExtension];
        fileName = [fileName stringByAppendingPathExtension:@"jpg"];
        
        if (m.msgID == 602) {
            fileName = m.url;
        }
        if (m.ossUrl == nil) {
            NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,m.cid,fileName];
            
            NSString *_url = [JFGSDK getCloudUrlWithFlag:m.regionType fileName:wonderFilePath];
            m.ossUrl = _url;
        }
       
        
        [cell.playVideoButton removeTarget:self action:@selector(videoPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        [cell.playVideoButton addTarget:self action:@selector(videoPlayButton:) forControlEvents:UIControlEventTouchUpInside];
        cell.playVideoButton.exModel = m;
        cell.playVideoButton.supImageView = cell.videoImageView;
        
        
        [cell.videoImageView sd_setImageWithURL:[NSURL URLWithString:m.ossUrl] placeholderImage:[UIImage imageNamed:@"Wonderful_bg_image"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                cell.shareButton.shareImage = image;
            }else{
                NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,m.cid,fileName];
                NSString *_url = [JFGSDK getCloudUrlWithFlag:m.regionType fileName:wonderFilePath];
                m.ossUrl = _url;
                [cell.videoImageView sd_setImageWithURL:[NSURL URLWithString:m.ossUrl] placeholderImage:cell.videoImageView.image];
                FLLog(@"errorUrl:%@",wonderFilePath);
            }
        }];
        cell.timeLineTimeLabel.text = m.time;
        
        NSMutableString *newStr = [NSMutableString new];
        int j=0;
        for(int i =0; i < [m.alias length]; i++)
        {
            NSString *temp = [m.alias substringWithRange:NSMakeRange(i, 1)];
            if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1) {
                j = j+2;
            }else{
                j++;
            }
            if (j<=16) {
                [newStr appendString:temp];
            }else{
                [newStr appendString:@"..."];
                break;
            }
        }
        cell.fromDeviceLabel.text = newStr;
        
        //删除
        [UIButton button:cell.deleteButton touchUpInSideHander:^(UIButton *button) {
            
            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
                
                [CommonMethod showNetDisconnectAlert];
                return ;
            }
            
            [DJActionSheet showDJActionSheetWithTitle:[JfgLanguage getLanTextStrByKey:@"Tips_SureDelete"] buttonTitleArray:@[[JfgLanguage getLanTextStrByKey:@"DELETE"],[JfgLanguage getLanTextStrByKey:@"CANCEL"]] actionType:actionTypeDelete defaultIndex:0 didSelectedBlock:^(NSInteger index) {
                if(index == 0) {
                    
                    if ([[NSUserDefaults standardUserDefaults] boolForKey:JFGShowDemoForExploreKey]) {
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:JFGShowDemoForExploreKey];
                        NSString *str =  [NSString stringWithFormat:@"JFGIsShowDemoFor%@",[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]];
                        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:str];
                        
                        self.contentTableView.tableFooterView = nil;
                        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
                            [self createData];
                            self.refreshView.hidden = NO;
                            self.contentTableView.mj_footer.hidden = NO;
                        }else if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut){
                           
                            [self judgeHaveData];
                            self.refreshView.hidden = YES;
                            self.contentTableView.mj_footer.hidden = YES;
                            
                        }else{
                            self.refreshView.hidden = YES;
                            self.contentTableView.mj_footer.hidden = YES;
                            [self loadCacheData];
                        }

                    }else{
                        
                        [_modelArray removeObject:m];
                        [_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                        [_contentTableView reloadData];
                        DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
                        seg.msgId = m.msgID;
                        seg.version = (int64_t)[m.version longLongValue];
                        [[JFGSDKDataPoint sharedClient]robotDelDataWithPeer:@"" queryDps:@[seg] success:^(NSString *identity, int ret) {
                            if (ret == 0) {
                                NSLog(@"delete success");
                                 [self cancelCollectedMarkWithTimestamp:m.collectedTimestamp cid:m.cid];
                            }
                        } failure:^(RobotDataRequestErrorType type) {
                            NSLog(@"delete fail:%ld",(long)type);
                        }];
                        
                    }

                }
                
            } didDismissBlock:nil];
        }];
        cell.shareButton.exModel = m;
        [cell.shareButton removeTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //分享视频
//        [UIButton button:cell.shareButton touchUpInSideHander:^(UIButton *button) {
//            
//            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
//                
//                [CommonMethod showNetDisconnectAlert];
//                return ;
//            }
//            
//            NSMutableDictionary *shareContent = [NSMutableDictionary dictionary];
//            [shareContent SSDKEnableUseClientShare];
//            
//            NSArray* imageArray = @[[UIImage imageNamed:@"bgimage_top_day.png"]];
//            if (imageArray) {
//                [shareContent SSDKSetupShareParamsByText:[JfgLanguage getLanTextStrByKey:@"Tap2_share_sharevideo_tips"]
//                                                  images:imageArray
//                                                     url:[NSURL URLWithString:@"http://www.mob.com"]
//                                                   title:[JfgLanguage getLanTextStrByKey:@"Tap2_share_sharevideo"]
//                                                    type:SSDKContentTypeWebPage];
//                [ShareClassView showShareViewWitnContent:shareContent withType:shareTypeVendor navigationController:nil Cid:nil];
//            }
//        }];
        
//        [UIButton button:cell.playVideoButton touchUpInSideHander:^(UIButton *button) {
//            [self playButtonTapped];
//        }];

        return cell;
    }
    else {//图片
        ExploreTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (!cell) {
            cell= [[NSBundle mainBundle]loadNibNamed:@"ExploreTableViewCell" owner:self options:nil][1];
            [cell.shareButton1 setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Button"] forState:UIControlStateNormal];
            cell.shareButton1.titleLabel.adjustsFontSizeToFitWidth = YES;
            if ([OemManager oemType] == oemTypeCell_C) {
                cell.shareButton1.hidden = YES;
            }
        }
        cell.msgTime = m.msgTime;
        cell._indexPath = indexPath;
        cell.photoImageView.msgID = m.msgID;
        JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
        
       
        if (m.ossUrl == nil) {
            NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,m.cid,m.url];
            NSString *_url = [JFGSDK getCloudUrlWithFlag:m.regionType fileName:wonderFilePath];
            if (_url == nil || [_url isEqualToString:@""]) {
                NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,m.cid,m.url];
                //拼一个假的url作为key，获取缓存图片
                _url = [NSString stringWithFormat:@"https://www.jfgou.com%@",wonderFilePath];
            }
            m.ossUrl = _url;
        }
        
        
        
        cell.photoImageView.imageUrl = m.ossUrl;
        [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:m.ossUrl] placeholderImage:[UIImage imageNamed:@"picMoren"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                cell.shareButton1.shareImage = image;
            }else{
                NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,m.cid,m.url];
                NSString *_url = [JFGSDK getCloudUrlWithFlag:m.regionType fileName:wonderFilePath];
                if (_url == nil || [_url isEqualToString:@""]) {
                    NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,m.cid,m.url];
                    //拼一个假的url作为key，获取缓存图片
                    _url = [NSString stringWithFormat:@"https://www.jfgou.com%@",wonderFilePath];
                }
                m.ossUrl = _url;
                [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:m.ossUrl] placeholderImage:cell.photoImageView.image completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                    
                    if (error) {
                        //如果oss链接获取失败，重新获取
                        m.ossUrl = nil;
                        FLLog(@"errorUrl:%@",wonderFilePath);
                    }
                    
                }];
            }
            
            
        }];
        
        cell.timeLineTimeLabel1.text = m.time;
        NSMutableString *newStr = [NSMutableString new];
        int j=0;
        for(int i =0; i < [m.alias length]; i++)
        {
            NSString *temp = [m.alias substringWithRange:NSMakeRange(i, 1)];
            if ([temp lengthOfBytesUsingEncoding:NSUTF8StringEncoding]>1) {
                j = j+2;
            }else{
                j++;
            }
            if (j<=16) {
                [newStr appendString:temp];
            }else{
                [newStr appendString:@"..."];
                break;
            }
        }
        cell.fromDeviceLabel1.text = newStr;
        cell.shareButton1.exModel = m;
        __weak typeof(self) weakSelf = self;
        //删除
        [UIButton button:cell.deleteButton1 touchUpInSideHander:^(UIButton *button) {
            
            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
                
                [CommonMethod showNetDisconnectAlert];
                return ;
            }
            
            [DJActionSheet showDJActionSheetWithTitle:[JfgLanguage getLanTextStrByKey:@"Tips_SureDelete"] buttonTitleArray:@[[JfgLanguage getLanTextStrByKey:@"DELETE"],[JfgLanguage getLanTextStrByKey:@"CANCEL"]] actionType:actionTypeDelete defaultIndex:0 didSelectedBlock:^(NSInteger index) {
                if(index == 0) {
                    [weakSelf.modelArray removeObject:m];
                    //NSLog(@"每日精彩的数据:%@",self.modelArray);
                    [_contentTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationBottom];
                    [_contentTableView reloadData];
                    DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
                    seg.msgId = dpMsgAccount_Wonder;
                    if (m.msgID == 606) {
                        seg.msgId = 606;
                    }
                    seg.version = (int64_t)[m.version longLongValue];
                    [[JFGSDKDataPoint sharedClient]robotDelDataWithPeer:@"" queryDps:@[seg] success:^(NSString *identity, int ret) {
                        if (ret == 0) {
                            NSLog(@"delete success");
                            [weakSelf cancelCollectedMarkWithTimestamp:m.collectedTimestamp cid:m.cid];
                            [weakSelf judgeHaveData];
                        }
                    } failure:^(RobotDataRequestErrorType type) {
                         NSLog(@"delete fail:%ld",(long)type);
                    }];
                }
                
            } didDismissBlock:nil];

        }];

        [cell.shareButton1 removeTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        [cell.shareButton1 addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
        
        //分享图片
//        [UIButton button:cell.shareButton1 touchUpInSideHander:^(UIButton *button) {
//            UIImage *Im = cell.photoImageView.image ;
//            
//            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
//                
//                [CommonMethod showNetDisconnectAlert];
//                return ;
//            }
//            
//            [ShareClassView showShareViewWithTitle:@"" content:@"" url:@"www.jfgou.com" image:Im imageUrl:_url Type:shareTypeVendor navigationController:self.navigationController Cid:nil];
//            
//        }];

        return cell;
    }
    return nil;
}

-(void)jfgVideoShareUrl:(NSString *)url
{
    NSLog(@"%@",url);
}

-(void)shareAction:(ExploreShareButton *)btn
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        return ;
    }
    ExploreModel *m = btn.exModel;
    ShareView *sv = [[ShareView alloc]initWithLandScape:NO];
    [sv showShareView:^(SSDKPlatformType platformType) {
        
        NSString *title = [OemManager appName];

        if (m.isPic) {
            
            if (m.msgID == 606) {
                //全景图片  Tap1_Shared_Title
                if ([OemManager oemType] == oemTypeDoby) {
                    title = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title_zhognxing"];
                }else{
                    title = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title"];
                }
                [FLShareSDKHelper shareToThirdpartyPlatform:platformType url:m.shareVideoUrl image:btn.shareImage title:title contentType:SSDKContentTypeImage];
            }else{
                [FLShareSDKHelper shareToThirdpartyPlatform:platformType url:@"http://http://www.jfgou.com" image:btn.shareImage title:title contentType:SSDKContentTypeImage];
            }
            
        }else{
           
            if (m.msgID == 606) {
                //全景视频
                if ([OemManager oemType] == oemTypeDoby) {
                    title = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title_zhognxing"];
                }else{
                    title = [JfgLanguage getLanTextStrByKey:@"Tap1_Shared_Title"];
                }
                [FLShareSDKHelper shareToThirdpartyPlatform:platformType url:m.shareVideoUrl image:btn.shareImage title:title contentType:SSDKContentTypeImage];
            }
            
        }
        
    } cancel:^{
        
    }];
}



-(void)cancelCollectedMarkWithTimestamp:(int64_t)timestamp cid:(NSString *)cid
{
    if (timestamp > 0) {
        //取消标记
        DataPointSeg *seg2 = [[DataPointSeg alloc]init];
        seg2.msgId = 511;
        seg2.version = timestamp;
        seg2.value = [MPMessagePackWriter writeObject:[NSNumber numberWithLongLong:0] error:nil];
        
        [[JFGSDKDataPoint sharedClient] robotSetDataByTimeWithPeer:cid dsp:@[seg2] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
            for (DataPointIDVerRetSeg *seg in dataList) {
                
                if (seg.ret == 0) {
                    
                    
                    
                }
            }
            
        } failure:^(RobotDataRequestErrorType type) {
            
            
            
        }];
    }
}



#pragma mark -UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExploreModel * m = [self.modelArray objectAtIndex:indexPath.row];
    if (!m.isPic) {
        return 288.0;
    }
    return 232;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark- 播放视频
-(void)playButtonTapped
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
//        NSString *netPath = @"https://jiafeigou-yf.oss-cn-hangzhou.aliyuncs.com/long/demo.mp4";
//        NSURL *URL = [[NSURL alloc] initWithString:netPath];
//        
//        
//    
//        if (!self.videoController) {
//            CGFloat width = [UIScreen mainScreen].bounds.size.width;
//            self.videoController = [[KRVideoPlayerController alloc] initWithFrame:CGRectMake(0, 0, width, [UIScreen mainScreen].bounds.size.height)];
//            __weak typeof(self)weakSelf = self;
//            [self.videoController setDimissCompleteBlock:^{
//                weakSelf.videoController = nil;
//            }];
//            [self.videoController showInWindow];
//        }
//        self.videoController.contentURL = URL;
       
        ExploreVideoPlayViewController *videoView = [[ExploreVideoPlayViewController alloc]init];
        videoView.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:videoView animated:NO
         ];
        
    });
    
    
}


#pragma mark - TimeChange Delegate
-(void)timeChangeWithCurrentYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute{
    NSString *reminderText = [JfgLanguage getLanTextStrByKey:@"Tap2_Index_Greetings"];
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusLoginOut) {
        reminderText = [JfgLanguage getLanTextStrByKey:@"Tap2_Index_Greetings"];
    }
    if (hour>=6 && hour<18) {
        //白天
        //            reminderText = @"在这里,发现你最美的一天";
        _topicImageView.image = [UIImage imageNamed:@"bgimage_top_day"];
    }
    else{
        //晚上
        //            reminderText = @"晚安，好梦，朋友们";
        _topicImageView.image = [UIImage imageNamed:@"bgimage_top_night"];
    }
    if (![reminderText isEqualToString:self.greetLabel.text]) {
        self.greetLabel.text = reminderText;
    }
}
#pragma mark- 大图删除通知
-(void)delBigPic:(NSNotification *)notification
{
    NSIndexPath *_indexPath = notification.object;
    
    if (_indexPath && _indexPath.row < self.modelArray.count) {
        ExploreModel *m = [self.modelArray objectAtIndex:_indexPath.row];
        [self.modelArray removeObject:m];
        //NSLog(@"每日精彩的数据:%@",self.modelArray);
        [_contentTableView deleteRowsAtIndexPaths:@[_indexPath] withRowAnimation:UITableViewRowAnimationBottom];
        [_contentTableView reloadData];
        DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
        seg.msgId = dpMsgAccount_Wonder;
        seg.version = (int64_t)[m.version longLongValue];
        [[JFGSDKDataPoint sharedClient]robotDelDataWithPeer:@"" queryDps:@[seg] success:^(NSString *identity, int ret) {
            if (ret == 0) {
                NSLog(@"delete success");
                [self judgeHaveData];
            }
        } failure:^(RobotDataRequestErrorType type) {
            NSLog(@"delete fail:%ld",(long)type);
        }];
    }
    
    
}


#pragma mark - 时间选择器
-(void)showTimePicker
{
    [_ruler setFrame:CGRectMake(0, kheight-74, Kwidth, 74)];
}

-(void)hiddenTimePicker
{
    //JFGLog(@"hidden");
    [_ruler setFrame:CGRectMake(0, kheight, Kwidth, 74)];
}

#pragma mark - DJActionRuler
-(void)actionRuler:(DJActionRuler *)actionRuler willSelectedDateString:(NSString *)aDateString{
    //JFGLog(@"willSelectedDateString");
    NSDate *showDate =[self.dateFormatter dateFromString:aDateString];
    NSString *dayString =[self.YMDformatter stringFromDate:showDate];
    
    if (dayString) {
        [self.timeSelectButton1 setTitle:dayString forState:UIControlStateNormal];
        [self.timeSelectButton setTitle:dayString forState:UIControlStateNormal];
    }
    
}
-(void)actionRuler:(DJActionRuler *)actionRuler didSelectedDateString:(NSString *)aDateString{
    JFGLog(@"didSelectedDateString");
//    for (int i = 0; i < self.modelArray.count; i++) {
//        ExploreModel * m = [self.modelArray objectAtIndex:i];
//        NSString * time = [JfgTimeFormat transToyyyyMMddhhmmss:m.msgTime];
//        NSString * time = [self];
//        NSLog(@"time = %@",time);
//        if ([time isEqualToString:aDateString]) {
//            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
//            break;
//        }
//    }
    for (NSString * time in self.timeArray) {
        if ([time isEqualToString:aDateString]) {
            [self.contentTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.timeArray indexOfObject:time] inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:YES];
            break;
        }
    }

}

-(void)didSelectedRowForIndexPath:(NSIndexPath *)indexPath
{
   // DatePickerModel *dateModel = self.dateRuler.dataArray[indexPath.row];
}

#pragma mark - button方法
-(void)selectDate:(UIButton *)button{
    button.selected = !button.selected;
    
    if (button.selected == YES) {
        self.ruler.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform transform= CGAffineTransformMakeRotation(M_PI);
            _timeSelectButton.imageView.transform = transform;
            _timeSelectButton1.imageView.transform = transform;
            [self showTimePicker];
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.3 animations:^{
            CGAffineTransform transform= CGAffineTransformMakeRotation(2*M_PI);
            _timeSelectButton.imageView.transform = transform;
            _timeSelectButton1.imageView.transform = transform;
            [self hiddenTimePicker];
        } completion:^(BOOL finished) {
            self.ruler.hidden = YES;
        }];
    }
}
- (void)videoPlayButton:(id)sender
{
    ExploreVideoButton *btn = sender;
    ExploreModel *m = btn.exModel;

    JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
    NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,m.cid,m.url];
    NSString *videoUrl = [JFGSDK getCloudUrlWithFlag:m.regionType fileName:wonderFilePath];
    

    Watch720PhotoVC *vc = [Watch720PhotoVC new];
    vc.thumbNailImage = btn.supImageView.image;
    vc.titleTime = [m.msgTime longLongValue];
    vc.panoMediaType = mediaTypeVideo;
    vc.panoMediaPath = videoUrl;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void)shareButtonAction:(id)sender
{

}

#pragma mark- 顶部视图相关
- (void)stretchHeaderView:(UIView*)view subViews:(UIView *)subview
{
    //设置顶部被拉伸的图片
    self.contentTableView.parallaxHeader.view =view;
    defaultViewHeight = view.size.height;
    
    //设置顶部图片显示区域高度
    self.contentTableView.parallaxHeader.height = defaultViewHeight;
    self.contentTableView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    
    //设置上推之后留出的最小距离
    self.contentTableView.parallaxHeader.minimumHeight = 64;
    
    //头部视图上添加模拟的navigationBar,同时也是一个遮罩，随着滚动颜色渐变
    [self.contentTableView.parallaxHeader.view addSubview:self.barView];

    [self.barView addSubview:self.topTitleLabel];
    [self.barView insertSubview:self.topTitleLabel atIndex:1];
//    [self.barView addSubview:self.timeSelectButton1];
//    [self.view insertSubview:self.timeSelectButton1 atIndex:1];
    
    //添加到tableview上的视图，会随着tableview的拖拉变动而变动
    //添加文字内容到tableview上（parallaxHeader的height随着滚动会发生改变，位置不可控）
    [self.contentTableView addSubview:subview];
    [self addRefreshController];
}

-(void)addRefreshController
{
    [self.contentTableView addSubview:self.refreshView];
    [self.refreshView setRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
    [self addFooter];
}

-(void)addFooter
{
    
    __weak typeof(self) weakSelf = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        ExploreModel * model = [weakSelf.modelArray lastObject];
        [[JFGSDKDataPoint sharedClient] robotGetDataEx:@"" version:[model.version longLongValue] dpids:@[@602] asc:NO success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
            NSMutableArray *arr = [NSMutableArray array];
            
            for (NSArray * subArr in idDataList)
            {
                NSMutableArray *elementArr = [NSMutableArray array];
                
                for (DataPointSeg *seg in subArr)
                {
                    NSError *error = nil;
                    NSMutableDictionary *elementDict = [NSMutableDictionary dictionary];
                    id obj = [MPMessagePackReader readData:seg.value error:&error];
                    
                    if (!error)
                    {
                        [elementDict setObject:@(seg.version) forKey:dpTimeKey];
                        [elementDict setValue:obj forKey:dpValueKey];
                        [elementDict setValue:@(seg.msgId) forKey:dpIdKey];
                        [elementDict setObject:[NSNumber numberWithInt:(int)seg.msgId] forKey:@"msgID"];
                        [elementArr addObject:elementDict]; // error 不为nil 添加数组
                       
                    }
                    else
                    {
                        NSLog(@"___error %@",error);
                    }
                }
                [arr addObject:elementArr];
            }
            [weakSelf.contentTableView.mj_footer endRefreshing];
            NSString *showString = nil;
            if (arr.count > 0) {
                
                for (NSArray * msgArr in arr) {
                    for (NSDictionary * dic in msgArr) {
                        NSArray * vauleArr = [dic objectForKey:@"_dpValue"];
                        NSString *msgTime = [[vauleArr objectAtIndex:1] stringValue];
                        
                        ExploreModel * m = [[ExploreModel alloc]init];
                        m.version = [dic objectForKey:@"_dpTime"];
                        m.msgID = [[dic objectForKey:@"msgID"] intValue];
                        m.cid = [vauleArr objectAtIndex:0];
                        m.msgTime = msgTime;
                        long long timestamp = [m.version longLongValue]/1000;
                        m.time = [JfgTimeFormat transToHHmm:[NSString stringWithFormat:@"%lld",timestamp]];
                        m.isPic = ![[vauleArr objectAtIndex:2] boolValue];
                        m.regionType = [[vauleArr objectAtIndex:3] intValue];
                        m.url = [vauleArr objectAtIndex:4];
                        
                        if (vauleArr.count>5) {
                            m.alias = [vauleArr objectAtIndex:5];
                        }else{
                            m.alias = m.cid;
                        }
                        
                        if (vauleArr.count>6) {
                            id _obj = vauleArr[6];
                            if ([_obj isKindOfClass:[NSNumber class]]) {
                                m.collectedTimestamp = [vauleArr[6] longLongValue];
                            }else if([_obj isKindOfClass:[NSString class]]){
                                m.shareVideoUrl = vauleArr[6];
                            }
                        }else{
                            m.collectedTimestamp = 0;
                        }
                        
                        [weakSelf.modelArray addObject:m];
                        [weakSelf.timeArray addObject:[JfgTimeFormat transToyyyyMMddhhmmss:m.msgTime]];
                        
                        if (showString == nil) {
                            showString = [JfgTimeFormat transToyyyyMMddhhmmss:m.msgTime];
                        }
                    }
                    if (msgArr.count<=0) {
                        [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
                    }
                }
                
                
                [weakSelf judgeHaveData];
                [weakSelf.contentTableView reloadData];
                
                
            }else{
                [weakSelf.contentTableView.mj_footer endRefreshingWithNoMoreData];
            }

            
        } failure:^(RobotDataRequestErrorType type) {
            NSLog(@"每日精彩获取失败：%ld",(long)type);
            [weakSelf.contentTableView.mj_footer endRefreshing];
            [weakSelf judgeHaveData];
        }];

        [weakSelf performSelector:@selector(headerEndRefresh) withObject:nil afterDelay:10.0];
        
        
    }];
    /**
     "PULL_TO_LOAD" = "下拉加载";
     "RELEASE_TO_LOAD" = "释放加载更多";
     */
    footer.automaticallyHidden = YES;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    self.contentTableView.mj_footer = footer;
    self.contentTableView.estimatedRowHeight = 0;
}

//刷新事件
-(void)headerRereshing{

    if (!isRefreshing) {
        
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            JFGLog(@"刷新");
            isRefreshing = YES;
            [self createData];
            [self performSelector:@selector(resetRefreshStates) withObject:nil afterDelay:2];
        }else{
            
            [CommonMethod showNetDisconnectAlert];
            isRefreshing = YES;
            [self performSelector:@selector(resetRefreshStates) withObject:nil afterDelay:2];
            [self.refreshView endRefresh];
            self.topicTitleLabel.alpha = 1;
            self.greetLabel.alpha = 1;

        }
    }
}

-(void)resetRefreshStates
{
    isRefreshing = NO;
}

-(void)headerEndRefresh {
    [self.refreshView endRefresh];
    [self.contentTableView.mj_footer endRefreshing];
    [self judgeHaveData];
    self.topicTitleLabel.alpha = 1;
    self.greetLabel.alpha = 1;
}
#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView*)scrollView{
    //parallaxHeader.view的高度;
    CGFloat topHeight ;
    if (scrollView.parallaxHeader.progress<0) {
        //上推
        topHeight = scrollView.parallaxHeader.height-fabs(scrollView.parallaxHeader.progress *scrollView.parallaxHeader.height);
    }else{
        //下拉
        topHeight = scrollView.parallaxHeader.height+fabs(scrollView.parallaxHeader.progress) *scrollView.parallaxHeader.height;
    }
    //往上滚动了，顶部视图高度小于原始高度
    if (topHeight < defaultViewHeight-2) {
        
        //设置遮罩的高度与顶部视图高度一致
        self.barView.height  = topHeight;
        
        if (fabs(scrollView.contentOffset.y)<defaultViewHeight) {
            self.barView.alpha = (defaultViewHeight-topHeight)/(defaultViewHeight-64);
        }
    }else {
        
        self.barView.alpha = 0;
        self.barView.height  = topHeight;
    }
    if (scrollView.contentOffset.y <= -76) {
        if (self.timeSelectButton.alpha==0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.timeSelectButton.alpha = 1;
                [self.timeSelectButton setSelected:self.timeSelectButton1.isSelected];
            }];
        }
        if (self.topTitleLabel.alpha==1) {
            self.topTitleLabel.alpha=0;
        }
    }else {
        if (self.timeSelectButton.alpha==1) {
            self.timeSelectButton.alpha=0;
        }
        if (self.topTitleLabel.alpha==0) {
            [UIView animateWithDuration:0.5 animations:^{
                self.topTitleLabel.alpha=1;
                //[self.timeSelectButton1 setSelected:self.timeSelectButton.isSelected];
            }];
        }
    }
    //-170起始点,先注释,不要删掉,用下面的
//    if (scrollView.contentOffset.y<= -200) {
//        [UIView animateWithDuration:0.5 animations:^{
//            self.topicTitleLabel.alpha = 0;
//            self.greetLabel.alpha = 0;
//        }];
//    }
//    else{
//        if (self.refreshView.state != FLRefreshStateRefreshing) {
//            [UIView animateWithDuration:0.3 animations:^{
//                self.topicTitleLabel.alpha = 1;
//                self.greetLabel.alpha = 1;
//            }];
//        }
//    }
    if(scrollView.contentOffset.y<=-170)
    {
        if (self.refreshView.state == FLRefreshStateRefreshing) {
            self.topicTitleLabel.alpha = 0;
            self.greetLabel.alpha = 0;
        }
        else{
            self.topicTitleLabel.alpha = (scrollView.contentOffset.y+205)/35;
            self.greetLabel.alpha = (scrollView.contentOffset.y+205)/35;
        }
    }
    else
    {
        if (self.refreshView.state != FLRefreshStateRefreshing) {
            self.topicTitleLabel.alpha = 1;
            self.greetLabel.alpha = 1;
        }
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    JFGLog(@"offset:%f",scrollView.contentOffset.y);
    if (self.refreshView.state != FLRefreshStateRefreshing) {
        [self.refreshView scrollViewDidEndDrag:scrollView];
    }
    if (!decelerate) {
        [self updateTimeSelectedText];
    }
    
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.refreshView.state != FLRefreshStateRefreshing) {
        self.topicTitleLabel.alpha = 1;
        self.greetLabel.alpha = 1;
    }
    [self updateTimeSelectedText];
}
- (void)updateTimeSelectedText {
    
    NSArray * cells =[self.contentTableView visibleCells];
    
    if (!cells.count) {
        return;
    }
    
    UITableViewCell * cell = [cells objectAtIndex:0];
    NSIndexPath * indexPath = [self.contentTableView indexPathForCell:cell];
    NSString * time = [self.timeArray objectAtIndex:indexPath.row];
    
    NSDate *showDate =[self.dateFormatter dateFromString:time];
    [self.ruler scrollToRowForDate:showDate];
    NSString *dayString =[self.YMDformatter stringFromDate:showDate];
    if (dayString) {
        [self.timeSelectButton1 setTitle:dayString forState:UIControlStateNormal];
        [self.timeSelectButton setTitle:dayString forState:UIControlStateNormal];
    }
   
}
#pragma mark - getter方法
-(UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height-topBgViewHeight)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-140)/2.0,kheight*0.1, 140, 140)];
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
-(UIImageView *)topicImageView{
    if (!_topicImageView) {
        _topicImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Kwidth,topBgViewHeight)];
        _topicImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topicImageView.clipsToBounds = YES;
        _topicImageView.image = [UIImage imageNamed:@"bgimage_top_day"];
        _topicImageView.userInteractionEnabled = YES;
    }
    return _topicImageView;
}
-(UITableView *)contentTableView{
    if (!_contentTableView) {
        _contentTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight-49) style:UITableViewStylePlain];
        _contentTableView.showsVerticalScrollIndicator = NO;
        _contentTableView.showsHorizontalScrollIndicator = NO;
        [_contentTableView setTableFooterView:[UIView new]];
        [_contentTableView setSeparatorColor:TableSeparatorColor];
        _contentTableView.backgroundColor = [UIColor whiteColor];
        [_contentTableView setSeparatorInset:UIEdgeInsetsMake(0, 37, 0, 0)];
        _contentTableView.delegate = self;
        _contentTableView.dataSource = self;
        [_contentTableView addSubview:self.noDataView];
    }
    return _contentTableView;
}
-(UILabel *)topicTitleLabel{
    if (!_topicTitleLabel) {
        _topicTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 63, Kwidth,22)];
        _topicTitleLabel.textAlignment = NSTextAlignmentCenter;
        _topicTitleLabel.textColor = [UIColor whiteColor];
        _topicTitleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap2_TitleName"];
        _topicTitleLabel.font = [UIFont fontWithName:@"PingFangSC-medium" size:22];
        _topicTitleLabel.font = [UIFont systemFontOfSize:22];
    }
    return _topicTitleLabel;
}
-(UILabel *)greetLabel{
    if (!_greetLabel) {
        _greetLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.topicTitleLabel.bottom+11, Kwidth,15)];
        _greetLabel.textAlignment = NSTextAlignmentCenter;
        _greetLabel.textColor = [UIColor whiteColor];
        _greetLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap2_Index_Greetings"];
        _greetLabel.font = [UIFont fontWithName:@"PingFangSC-regular" size:15];
        _greetLabel.font = [UIFont systemFontOfSize:15];
    }
    return _greetLabel;
}
-(UIButton *)timeSelectButton{
    if (!_timeSelectButton) {
        _timeSelectButton = [[UIButton alloc]init];
        [_timeSelectButton setBackgroundImage:[UIImage imageNamed:@"btn_image_selectTime"] forState:UIControlStateNormal];
        _timeSelectButton.frame = CGRectMake((Kwidth-126.0)/2.0, topBgViewHeight-9-47, 126, 47);
        _timeSelectButton.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        _timeSelectButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _timeSelectButton.backgroundColor = [UIColor clearColor];
        _timeSelectButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-medium" size:16];
        _timeSelectButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [_timeSelectButton setImage:[UIImage imageNamed:@"btn_selectTime_down"] forState:UIControlStateNormal];
        [_timeSelectButton setImage:[UIImage imageNamed:@"btn_arrow_disdown"] forState:UIControlStateDisabled];
        // [_timeSelectButton setImage:[UIImage imageNamed:@"btn_selectTime_up"] forState:UIControlStateSelected];
        [_timeSelectButton setTag:TIMEBUTTONTAG];
        _timeSelectButton.adjustsImageWhenHighlighted =NO;
        _timeSelectButton.adjustsImageWhenDisabled = NO;
        [_timeSelectButton setBackgroundImage:[UIImage imageNamed:@"btn_image_selectTime"] forState:UIControlStateNormal];

        [_timeSelectButton setTitleColor:[UIColor colorWithHexString:@"#888888"] forState:UIControlStateNormal];
        [_timeSelectButton setTitleColor:[UIColor colorWithHexString:@"#8888887f"] forState:UIControlStateDisabled];
        [_timeSelectButton setImageEdgeInsets:UIEdgeInsetsMake(0, 96, 0, 0)];
        [_timeSelectButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -28, 0, 0)];
        [_timeSelectButton addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
        _timeSelectButton.selected = NO;
        _timeSelectButton.alpha =1;

    }
    return _timeSelectButton;
}
-(UIButton *)timeSelectButton1{
    if (!_timeSelectButton1) {
        _timeSelectButton1 = [[UIButton alloc]init];
        _timeSelectButton1.frame = CGRectMake((Kwidth-126.0)/2.0, 34, 126, 16);
        _timeSelectButton1.contentHorizontalAlignment=UIControlContentHorizontalAlignmentCenter;
        _timeSelectButton1.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        _timeSelectButton1.backgroundColor = [UIColor clearColor];
        _timeSelectButton1.titleLabel.font = [UIFont fontWithName:@"PingFangSC-medium" size:16];
        _timeSelectButton1.titleLabel.font = [UIFont systemFontOfSize:16];
        _timeSelectButton1.adjustsImageWhenHighlighted =NO;
        _timeSelectButton1.adjustsImageWhenDisabled = NO;
        [_timeSelectButton1 setImage:[UIImage imageNamed:@"btn_selectTime_down_white"] forState:UIControlStateNormal];
        //  [_timeSelectButton1 setImage:[UIImage imageNamed:@"btn_selectTime_up_white"] forState:UIControlStateSelected];
        [_timeSelectButton1 setTag:TIMEBUTTON1TAG];
        [_timeSelectButton1 setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        //[_timeSelectButton1 setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        [_timeSelectButton1 setImageEdgeInsets:UIEdgeInsetsMake(0, 96, 0, 0)];
        [_timeSelectButton1 setTitleEdgeInsets:UIEdgeInsetsMake(0, -28, 0, 0)];
        [_timeSelectButton1 addTarget:self action:@selector(selectDate:) forControlEvents:UIControlEventTouchUpInside];
        _timeSelectButton1.selected = NO;
        _timeSelectButton1.alpha=0;;
    }
    return _timeSelectButton1;
}

-(UILabel *)topTitleLabel
{
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake((Kwidth-126.0)/2.0, 34, 126, 16)];
        _topTitleLabel.font = [UIFont systemFontOfSize:20];
        _topTitleLabel.textColor = [UIColor colorWithHexString:@"#ffffff"];
        _topTitleLabel.backgroundColor = [UIColor clearColor];
        _topTitleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap2_TitleName"];
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _topTitleLabel;
}

-(UIView *)topTransparentView{
    if (!_topTransparentView) {
        _topTransparentView = [[UIView alloc]initWithFrame:_topicImageView.frame];
        _topTransparentView.backgroundColor = [UIColor clearColor];
        topTransparentSize = _topTransparentView.size;
    }
    return _topTransparentView;
}

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

-(UIView *)barView
{
    if (!_barView) {
        _barView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, defaultViewHeight)];
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
        if (dateComponent.hour >=6 && dateComponent.hour < 18) {
            [self setBarViewColor:YES];
        }else{
            [self setBarViewColor:NO];
        }
        _barView.alpha = 0;
        _barView.userInteractionEnabled = YES;
    }
    return _barView;
}

-(void)setBarViewColor:(BOOL)day
{
    if (!day) {
        
        CALayer *layer = [[self.barView.layer sublayers] objectAtIndex:0];
        if (layer == self.nightGradient) {
            return;
        }
        [self.dayGradient removeFromSuperlayer];
        [self.barView.layer insertSublayer:self.nightGradient atIndex:0];
        
    }else{
        
        CALayer *layer = [[self.barView.layer sublayers] objectAtIndex:0];
        if (layer == self.dayGradient) {
            return;
        }
        [self.nightGradient removeFromSuperlayer];
        [self.barView.layer insertSublayer:self.dayGradient atIndex:0];
    }
}

-(FLRefreshHeader *)refreshView
{
    if (!_refreshView) {
        _refreshView = [[FLRefreshHeader alloc]initWithFrame:CGRectMake(0, -defaultViewHeight+50, Kwidth, 23)];
        _refreshView.originOffset_y = defaultViewHeight;
    }
    return _refreshView;
}

-(JFGDatePickers *)dateRuler
{
    if (!_dateRuler) {
        _dateRuler = [[JFGDatePickers alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height, self.view.bounds.size.width, 88)];
        _dateRuler.delegate = self;
    }
    return _dateRuler;
}

-(CAGradientLayer *)dayGradient
{
    if (!_dayGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.barView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#17AFD1"].CGColor,(id)[UIColor colorWithHexString:@"#17AFD1"].CGColor,
                           nil];
        
        _dayGradient = gradient;
    }
    return _dayGradient;
}

-(CAGradientLayer *)nightGradient
{
    if (!_nightGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.barView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#263954"].CGColor,(id)[UIColor colorWithHexString:@"#263954"].CGColor,
                           nil];
        _nightGradient = gradient;
    }
    return _nightGradient;
}

-(UIView *)demoFooterView
{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.height, 88)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 20, 180, 44);
    btn.x = self.view.width*0.5;
    btn.layer.masksToBounds = YES;
    btn.layer.cornerRadius = 22;
    btn.layer.borderWidth = 1;
    btn.layer.borderColor = [UIColor colorWithHexString:@"#d8d8d8"].CGColor;
    [btn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_CameraFun_Timelapse_Start"] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    [bgView addSubview:btn];
    
    
    TimeLineView *lineV = [[TimeLineView alloc]initWithFrame:CGRectMake(0, 0, 37, bgView.height)];
    lineV.backgroundColor = [UIColor whiteColor];
    [bgView addSubview:lineV];
    
    return bgView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    JFGLog(@"ExploreRootViewController");
}
#pragma mark - tapGestureRecognizer
-(void)tapReceived:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if (self.timeSelectButton.selected == YES || self.timeSelectButton1.selected == YES) {
        [UIView animateWithDuration:0.2 animations:^{
            CGAffineTransform transform= CGAffineTransformMakeRotation(2*M_PI);
            _timeSelectButton.imageView.transform = transform;
            _timeSelectButton1.imageView.transform = transform;
            [self hiddenTimePicker];
        } completion:^(BOOL finished) {
            self.ruler.hidden = YES;
        }];
        self.timeSelectButton.selected = NO;
        self.timeSelectButton1.selected = NO;
    }
}




@end
