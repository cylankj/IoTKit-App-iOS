    //
//  Pano720PhotoVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/15.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "Pano720PhotoVC.h"
#import "BaseTableView.h"
#import "JfgGlobal.h"
#import "HeaderViewFor720.h"
#import "Pano720TableViewCell.h"
#import "YBPopupMenu.h"
#import "PhotoTitleView.h"
#import "Watch720PhotoVC.h"
#import <JFGSDK/JFGSDK.h>
#import "JfgGlobal.h"
#import "Pano720Socket.h"
#import "Pano720PhotoViewModel.h"
#import <MJRefresh/MJRefresh.h>
#import "JFGRefreshLoadingHeader.h"
#import "NetworkMonitor.h"
#import "Pano720PhotoModel.h"
#import "JFGLanguage.h"
#import "CommonMethod.h"
#import "JfgConstKey.h"
#import "LSAlertView.h"
#import "ProgressHUD.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/MPMessagePackReader.h>
#import "PanoPhotoView.h"
#import "FLProressHUD.h"
#import "CommonMethod.h"
#import "PopAnimation.h"
#import "LoginManager.h"
#import "JfgHttp.h"

#define headerViewHeight 46

#define timeoutDur  10

typedef NS_ENUM(NSInteger, controlTag) {
    alertViewTag = 1001,
};

@interface Pano720PhotoVC ()<UITableViewDelegate, UITableViewDataSource, YBPopupMenuDelegate, JFGSDKCallbackDelegate, watchPhotoDelegate>
{
    NSTimer *fpingTimer;
}

@property (nonatomic, assign) BOOL isConnectted;

@property (nonatomic, strong) BaseTableView *panoTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) PhotoTitleView *titltView;
@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UIImageView *noDataImgView;
@property (nonatomic, strong) UILabel *noDataLabel;
@property (nonatomic, strong) PanoPhotoView *bottomBiew;

@property (nonatomic, strong) Pano720PhotoViewModel *pano720VM;
@property (nonatomic, assign) DeleteModel delModel;   // delte Type

@property (nonatomic, strong) NSMutableArray *downloadArr; // need download models
@property (nonatomic, strong) NSMutableArray *videoDownloadArr; // video download models
@property (nonatomic, strong) NSMutableArray *thumbNailArr;

@property (nonatomic, assign) BOOL isFirstPing;

@end

@implementation Pano720PhotoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigation];
    
    [self initData];
    
    self.isFirstPing = YES;
    self.isConnectted = NO; // default NO
    [self jfgFpingRequest];
    [self startFping];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopFping];
    fpingTimer = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    JFGLog(@"Pano720PhotoVC dealloc");
}

#pragma mark- fping
-(void)startFping
{
    /*
    if (fpingTimer == nil) {
        fpingTimer = [NSTimer scheduledTimerWithTimeInterval:timeoutDur+1 target:self selector:@selector(fpingAction) userInfo:nil repeats:YES];
    }
     */
}

- (void)jfgFpingRequest
{
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
    [JFGSDK appendStringToLogFile:@"__f_ping request "];
    [self performSelector:@selector(changeConnectState) withObject:nil afterDelay:timeoutDur];
}

-(void)fpingAction
{
    [self jfgFpingRequest];
    self.isFirstPing = NO;
}

-(void)stopFping
{
    if (fpingTimer && [fpingTimer isValid])
    {
        [fpingTimer invalidate];
    }
    fpingTimer = nil;
}

#pragma mark 
#pragma mark  view

- (void)initView
{
    JFG_WS(weakSelf)
    
    [self.view addSubview:self.panoTableView];
    [self.panoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view).with.offset(64.0f);
        make.left.equalTo(weakSelf.view).with.offset(0);
        make.right.equalTo(weakSelf.view).with.offset(0);
        make.bottom.equalTo(weakSelf.view).with.offset(0);
    }];
    
    [self.view addSubview:self.titltView];
    [self.view addSubview:self.bottomBiew];
    
    [self.view addSubview:self.noDataView];
    [self.noDataView addSubview:self.noDataImgView];
    [self.noDataImgView addSubview:self.noDataLabel];
    
    [self initRefreshView];
    [self.titltView updateLayout];

}

- (void)initNavigation
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton.enabled = NO;
    self.rightButton.hidden = NO;
    [self.rightButton setImage:[UIImage imageNamed:@"album_icon_delete"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"album_icon_delete_disabled"] forState:UIControlStateDisabled];
    [self.rightButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
    [self.rightButton addTarget:self action:@selector(deletePicAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)initRefreshView
{
    JFG_WS(weakSelf);
    
    // header refresh block
#pragma mark head
    //MJRefreshStateHeader
    self.panoTableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        if (weakSelf.isConnectted)
        {
            [weakSelf.panoTableView.mj_footer resetNoMoreData];
            
            [weakSelf.pano720VM requestURL:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getFileList&begintime=0&endtime=%lld&count=20",weakSelf.pano720VM.ipAddress,(long long)[[NSDate date]timeIntervalSince1970]] parameters:nil progress:nil downloadSuccess:nil success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                [weakSelf updateTableView:models];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [weakSelf.panoTableView.mj_header endRefreshing];
            }];
            
        }else{
            [weakSelf.panoTableView.mj_header endRefreshing];
        }
    
    }];
    
    MJRefreshNormalHeader *header = (MJRefreshNormalHeader *) self.panoTableView.mj_header;
    [header setTitle:[JfgLanguage getLanTextStrByKey:@"REFRESHING"] forState:MJRefreshStateRefreshing];
    [header setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_REFRESH"] forState:MJRefreshStatePulling];
    [header setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_REFRESH"] forState:MJRefreshStateIdle];
    
    header.lastUpdatedTimeLabel.hidden = YES;
    
    if ([CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
    {
        [self.panoTableView.mj_header beginRefreshing];
    }
    
#pragma mark foot
    // footer refresh block
    self.panoTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        switch (weakSelf.pano720VM.fileExistType)
        {
            case FileExistTypeRemote:
            case FileExistTypeBoth:
            {
                if (!weakSelf.isConnectted)
                {
                    [weakSelf.panoTableView.mj_footer endRefreshing];
                    return ;
                }
                
                Pano720PhotoModel *model = [[weakSelf.dataArray lastObject] lastObject];
                
                [weakSelf.pano720VM requestMoreURL:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getFileList&begintime=0&endtime=%lld&count=20",weakSelf.pano720VM.ipAddress,model.fileTime] parameters:nil progress:nil downloadSuccess:^(Pano720PhotoModel *dlModel, int result) {
                    [weakSelf reloadTableView];
                } success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                    if (models.count>0)
                    {
                        [weakSelf addDataWithArray:models];
                        [weakSelf.panoTableView.mj_footer endRefreshing];
                    }
                    else
                    {
                        [weakSelf.panoTableView.mj_footer endRefreshingWithNoMoreData];
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];
            }
                break;
            case FileExistTypeLocal:
            {
                Pano720PhotoModel *model = [[weakSelf.dataArray lastObject] lastObject];
                [weakSelf.pano720VM getMoreLocalDataWithBeginTime:model.fileTime count:20 success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                    if (models.count>0)
                    {
                        [weakSelf addDataWithArray:models];
                        [weakSelf.panoTableView.mj_footer endRefreshing];
                    }
                    else
                    {
                        [weakSelf.panoTableView.mj_footer endRefreshingWithNoMoreData];
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];
            }
                break;
            default:
                break;
        }
    }];
    
    MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)weakSelf.panoTableView.mj_footer;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
}

- (void)updateTableView:(NSArray *)data
{
    self.panoTableView.hidden = !(data.count>0);
    self.noDataView.hidden = !self.panoTableView.hidden;
    self.rightButton.enabled = !self.panoTableView.hidden;
    
    if (data.count > 0)
    {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:data];
        
        [self handleDataArray:self.dataArray];
        
        [self reloadTableView];
        
        if (self.delModel == DeleteModel_DeleteAll)
        {
            for (NSInteger i = 0; i < self.dataArray.count; i ++)
            {
                NSArray *rows = [self.dataArray objectAtIndex:i];
                
                for (NSInteger j = 0; j < rows.count; j ++)
                {
                    [self.panoTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
            }
        }
    }
}

- (void)reloadTableView
{
    if (self.rightButton.selected == YES)
    {
        return;
    }
    
    JFG_WS(weakSelf);
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.panoTableView reloadData];
    });
}

- (void)showLocalData
{
    [self setTitleLabelText:[JfgLanguage getLanTextStrByKey:@"Tap1_File_Phone"]];
    self.pano720VM.fileExistType = FileExistTypeLocal;
    
    JFG_WS(weakSelf);
    [self.pano720VM requestURL:nil parameters:nil progress:nil downloadSuccess:nil success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
        [weakSelf updateTableView:models];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

- (void)showSDcardPulloutAlert
{
    if (self.navigationController.visibleViewController == self)
    {
        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"] CancelButtonTitle:nil OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Sure"] CancelBlock:^{
            
        } OKBlock:^{
        }];
        
        [self showLocalData];
    }
}

- (void)leftButtonAction:(UIButton *)sender
{
    [self.navigationController.view.layer addAnimation:[PopAnimation moveBottomAnimation] forKey:nil];
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark
#pragma mark data
- (void)initData
{
    [self setDefaultFileExistType];
    [JFGSDK addDelegate:self];
    self.delModel = DeleteModel_Delete;
}

- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([ask.cid isEqualToString:self.cid])
    {
        [JFGSDK appendStringToLogFile:@"__f_ping response "];
        
        JFG_WS(weakSelf);
//        if (self.isFirstPing)
        {
            self.isConnectted = YES;
            [self setIsConnectted:YES];
            [self setDefaultFileExistType];
            self.pano720VM.ipAddress = ask.address;
            [self cancelChangeConnectState];
            
            [self.pano720VM requestURL:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getFileList&begintime=0&endtime=%lld&count=20",ask.address,(long long)[[NSDate date] timeIntervalSince1970]] parameters:nil  progress:nil downloadSuccess:nil success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                [weakSelf updateTableView:models];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
            }];
            
            [[JfgHttp sharedHttp] get:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getSdInfo", ask.address] parameters:nil progress:nil success:^(NSURLSessionDataTask *task, id responseObject) {
                
                BOOL isExistSDCard = [[responseObject objectForKey:panoSdCardExistKey] boolValue];
                [weakSelf setIsConnectted:isExistSDCard];
                
                if (isExistSDCard == NO)
                {
                    [weakSelf showLocalData];
                }
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
            }];
        }
    }
}

- (void)setDefaultFileExistType
{
    // when wifi or ap connect, show phone_photo and photo else show  phonephoto
    if ([CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid] || self.isConnectted)
    {
        [self setTitleLabelText:[JfgLanguage getLanTextStrByKey:@"photo"]];
        self.pano720VM.fileExistType = FileExistTypeBoth;
    }
    else
    {
        [self setTitleLabelText:[JfgLanguage getLanTextStrByKey:@"Tap1_File_Phone"]];
        self.pano720VM.fileExistType = FileExistTypeLocal;
        
        JFG_WS(weakSelf);
        [self.pano720VM requestURL:nil parameters:nil progress:nil downloadSuccess:nil success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
            [weakSelf updateTableView:models];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
    }
}

- (void)fileExistTypeChanged:(FileExistType)changedValue
{
    [self.panoTableView.mj_header endRefreshing];
    
    self.pano720VM.fileExistType = changedValue;
    JFG_WS(weakSelf);
    
    switch (self.pano720VM.fileExistType)
    {
        case FileExistTypeRemote:
        case FileExistTypeBoth:
        {
            if (self.pano720VM.ipAddress != nil)
            {
                [self.pano720VM requestURL:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getFileList&begintime=0&endtime=%lld&count=20",self.pano720VM.ipAddress,(long long)[[NSDate date]timeIntervalSince1970]] parameters:nil  progress:nil downloadSuccess:nil success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                    if (weakSelf.pano720VM.fileExistType == FileExistTypeBoth)
                    {
                        [weakSelf updateTableView:models];
                    }
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];
            }
            
        }
            break;
        case FileExistTypeLocal:
        {
            [self setTitleLabelText:[JfgLanguage getLanTextStrByKey:@"Tap1_File_Phone"]];
            [self.pano720VM requestURL:nil parameters:nil progress:nil downloadSuccess:nil success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                if (weakSelf.pano720VM.fileExistType == FileExistTypeLocal)
                {
                    [weakSelf updateTableView:models];
                }
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
            }];
        }
            break;
        default:
            break;
    }
}

- (void)addDataWithArray:(NSMutableArray *)addedData
{
    NSMutableArray *allDataArray = [NSMutableArray arrayWithArray:self.dataArray];
    [allDataArray addObjectsFromArray:addedData];
    
    [self updateTableView:[self hanldeMixedData:addedData]];
}

- (NSMutableArray *)hanldeMixedData:(NSMutableArray *)newDataArr
{
    if (newDataArr.count > 0)
    {
        NSMutableArray *resultArr = [NSMutableArray arrayWithCapacity:20];
        // origin data last time
        Pano720PhotoModel *originModel = [[self.dataArray lastObject] firstObject];
        Pano720PhotoModel *newModel = [[newDataArr firstObject] firstObject];
        
        if ([originModel.headerString isEqualToString:newModel.headerString]) // same
        {
            NSMutableArray *mixedArr = [NSMutableArray arrayWithCapacity:5];
            NSArray *originRows = [self.dataArray lastObject];
            NSArray *newRows = [newDataArr firstObject];
            
            [mixedArr addObjectsFromArray:originRows];
            [mixedArr addObjectsFromArray:newRows];
            [self.dataArray removeLastObject];
            [newDataArr removeObjectAtIndex:0];
            
            [resultArr addObjectsFromArray:self.dataArray];
            [resultArr addObject:mixedArr];
            [resultArr addObjectsFromArray:newDataArr];
        }
        else
        {
            [resultArr addObjectsFromArray:self.dataArray];
            [resultArr addObjectsFromArray:newDataArr];
        }
        
        return resultArr;
    }
    
    
    return nil;
    
}

- (NSMutableArray *)handleDataArray:(NSMutableArray *)originArr
{
    [self.downloadArr removeAllObjects];
    [self.thumbNailArr removeAllObjects];
    
    for (NSInteger i = 0; i < originArr.count; i ++)
    {
        id element = [originArr objectAtIndex:i];
        
        if ([element isKindOfClass:[NSArray class]])
        {
            NSArray *elementArr = (NSArray *)element;
            for (NSInteger j = 0; j < elementArr.count; j ++)
            {
                Pano720PhotoModel *model = [elementArr objectAtIndex:j];
                if ([model.fileName hasSuffix:@".jpg"])
                {
                    [self.downloadArr addObject:[elementArr objectAtIndex:j]];
                }
            
                [self.thumbNailArr addObject:[elementArr objectAtIndex:j]];
            }
        }
    }
    
    [self downloadThumbNailWithModel:[self.thumbNailArr firstObject]];
    [self downloadImageWithModel:[self.downloadArr firstObject]];
    
    return self.downloadArr;
}

- (void)changeConnectState
{
    self.isConnectted = NO;
    [self stopFping];
    [self setIsConnectted:NO];
    
    [self fileExistTypeChanged:FileExistTypeLocal];
}

- (void)cancelChangeConnectState
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(changeConnectState) object:nil];
}

- (BOOL)isDownloading:(NSArray <Pano720PhotoModel *> *)models
{
    if (self.videoDownloadArr.count > 0)
    {
        for (NSInteger i = 0; i < self.videoDownloadArr.count; i ++)
        {
            Pano720PhotoModel *downloadModel = [self.videoDownloadArr objectAtIndex:i];
            
            for (NSInteger j = 0; j < models.count; j ++)
            {
                Pano720PhotoModel *deleteModel = [models objectAtIndex:j];
                
                if ([downloadModel.fileName isEqualToString:deleteModel.fileName])
                {
                    return YES;
                }
            }
        }
    }
    
    return NO;
}

// 从数据源中 寻找正在下载的model 并返回
- (Pano720PhotoModel *)currentDownloadVideoModel:(Pano720PhotoModel *)model
{
    for (NSInteger i = 0; i < self.dataArray.count; i ++)
    {
        NSArray *rows = [self.dataArray objectAtIndex:i];
        
        for (NSInteger j = 0; j < rows.count; j ++)
        {
            Pano720PhotoModel *dataModel = [[self.dataArray objectAtIndex:i] objectAtIndex:j];
            
            if ([dataModel.fileName isEqualToString:model.fileName])
            {
                return dataModel;
            }
        }
    }
    
    return nil;
}


#pragma mark
#pragma mark download
// download image
- (void)downloadImageWithModel:(Pano720PhotoModel *)model
{
    JFG_WS(weakSelf);
    model.downloadProgressStr = @"0%";
    [self.pano720VM downloadImageWithModel:model state:^(SRDownloadState state) {
        switch (state)
        {
            case SRDownloadStateFailed:
            {
                // 放后面，继续其他的下载
                [weakSelf.downloadArr removeObject:model];
                
                for (NSInteger i = 0; i < weakSelf.dataArray.count; i ++)
                {
                    NSArray *rows = [weakSelf.dataArray objectAtIndex:i];
                    
                    for (NSInteger j = 0; j < rows.count; j ++)
                    {
                        Pano720PhotoModel *curModel = [rows objectAtIndex:j];
                        
                        if ([curModel.fileName isEqualToString:model.fileName])
                        {
                            curModel.location = fileInBoth;
                            curModel.downLoadState = DownLoadStateFinished;
                            
                            [weakSelf reloadTableView];
                        }
                    }
                }
                
                if (weakSelf.downloadArr.count > 0)
                {
                    [weakSelf downloadImageWithModel:[weakSelf.downloadArr firstObject]];
                }
            }
                break;
            case SRDownloadStateCompleted:
            {
                [weakSelf.downloadArr removeObject:model];
                
                for (NSInteger i = 0; i < weakSelf.dataArray.count; i ++)
                {
                    NSArray *rows = [weakSelf.dataArray objectAtIndex:i];
                    
                    for (NSInteger j = 0; j < rows.count; j ++)
                    {
                        Pano720PhotoModel *curModel = [rows objectAtIndex:j];
                        
                        if ([curModel.fileName isEqualToString:model.fileName])
                        {
                            curModel.location = fileInBoth;
                            curModel.downLoadState = DownLoadStateFinished;
                            
                            [weakSelf reloadTableView];
                        }
                    }
                }
                
                
                if (weakSelf.downloadArr.count > 0)
                {
                    [weakSelf downloadImageWithModel:[weakSelf.downloadArr firstObject]];
                }

                if (weakSelf.downloadArr.count == 0) // 同步完成
                {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.panoTableView.mj_header endRefreshing];
                    });
                }
                
            }
            default:
                break;
        }
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        int progressShow = progress*100;
        model.downloadProgressStr = [NSString stringWithFormat:@"%02d%%",progressShow];
        [weakSelf reloadTableView];
    } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
        
    }];
}

// download video
- (void)downloadVideoWithModel:(Pano720PhotoModel *)model
{
    JFG_WS(weakSelf);
    
    __block Pano720PhotoModel *panoModel = nil;
    
    if (![self.videoDownloadArr containsObject:model])
    {
        [self.videoDownloadArr addObject:model];
    }
    
    [self.pano720VM downloadVideoWithModel:model state:^(SRDownloadState state) {
        switch (state)
        {
            case SRDownloadStateCompleted:
            {
                model.downloadProgressStr = @"";
                model.location = fileInBoth;
                model.downLoadState = DownLoadStateFinished;
                [weakSelf reloadTableView];
                [weakSelf.videoDownloadArr removeObject:model];
            }
                break;
            case SRDownloadStateFailed:
            {
                
            }
            default:
                break;
        }
    } progress:^(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress) {
        int progressShow = progress*100;
        panoModel = [weakSelf currentDownloadVideoModel:model];
        
        panoModel.downloadProgressStr = [NSString stringWithFormat:@"%02d%%",progressShow];
        [weakSelf reloadTableView];
    } completion:^(BOOL isSuccess, NSString *filePath, NSError *error) {
        
    }];
}

//  download thumbNail
- (void)downloadThumbNailWithModel:(Pano720PhotoModel *)model
{
    JFG_WS(weakSelf);
    
    [self.pano720VM downloadThumbNailWhithModel:model state:^(SRDownloadState state) {
        switch (state)
        {
            case SRDownloadStateFailed:
            {
                [weakSelf.thumbNailArr removeObject:model];
                [weakSelf.thumbNailArr addObject:model];
                
                if (weakSelf.thumbNailArr.count > 0)
                {
                    [weakSelf downloadThumbNailWithModel:[weakSelf.thumbNailArr firstObject]];
                }
                
            }
                break;
            case SRDownloadStateCompleted:
            {
                [weakSelf.thumbNailArr removeObject:model];
                if (weakSelf.thumbNailArr.count > 0)
                {
                    [weakSelf downloadThumbNailWithModel:[weakSelf.thumbNailArr firstObject]];
                }
                
                [weakSelf reloadTableView];
            }
            default:
                break;
        }
    } progress:nil completion:nil];
}

#pragma mark
#pragma mark action
- (void)deletePicAction:(id)sender
{
    UIButton *senderBtn = (UIButton *)sender;
    senderBtn.selected = !senderBtn.selected;
    self.bottomBiew.deleteButton.enabled = NO;
    self.bottomBiew.selectAllBtn.selected = NO;

    [senderBtn setImage:senderBtn.selected?nil:[UIImage imageNamed:@"album_icon_delete"] forState:UIControlStateNormal];
    
    [self.panoTableView setAllowsMultipleSelectionDuringEditing:senderBtn.selected];
    [[NSNotificationCenter defaultCenter] postNotificationName:isEditingNotification object:@(senderBtn.selected)];
    [self.panoTableView setEditing:senderBtn.selected];
    
    JFG_WS(weakSelf);
    
    [UIView animateWithDuration:0.2 animations:^{
        if (senderBtn.selected)
        {
            weakSelf.bottomBiew.frame = CGRectMake(0, kheight- 44, Kwidth, 44);
        }
        else
        {
            weakSelf.bottomBiew.frame = CGRectMake(0, kheight, Kwidth, 44);
        }
    }];
}

- (void)deleteButtonAction:(UIButton *)sender
{
    NSArray *allSeletedIndexPath = [self.panoTableView indexPathsForSelectedRows];
    NSMutableArray *selectedModels = [NSMutableArray arrayWithCapacity:5];
    
    for (NSInteger i = 0; i < allSeletedIndexPath.count; i ++)
    {
        NSIndexPath *indexPath = [allSeletedIndexPath objectAtIndex:i];
        Pano720PhotoModel *panoModel = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        
        [selectedModels addObject:panoModel];
    }
    
    JFG_WS(weakSelf);
    
    switch (self.pano720VM.fileExistType)
    {
        case FileExistTypeBoth:
        {
            if ([self isDownloading:selectedModels])
            {
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_DeleteDownloadingTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                    
                } OKBlock:^{
                    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_DeletedCameraNCellphoneFileTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Sure"] CancelBlock:^{
                        
                    } OKBlock:^{
                        [weakSelf.pano720VM deleteFileWithModels:selectedModels deleteModel:weakSelf.delModel success:^(NSURLSessionDataTask *task, id responseObject) {
                            
                            // delete already exist model
                            [weakSelf deleteAlreadyDeletedModels:selectedModels];
                            
                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tips_DeleteFail"]];
                        }];
                        [weakSelf deletePicAction:weakSelf.rightButton];
                    }];
                }];
            }
            else // 直接删除
            {
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_DeletedCameraNCellphoneFileTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Sure"] CancelBlock:^{
                    
                } OKBlock:^{
                    [weakSelf.pano720VM deleteFileWithModels:selectedModels deleteModel:weakSelf.delModel success:^(NSURLSessionDataTask *task, id responseObject) {
                        
                        // delete already exist model
                        [weakSelf deleteAlreadyDeletedModels:selectedModels];
                        
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tips_DeleteFail"]];
                    }];
                    [weakSelf deletePicAction:weakSelf.rightButton];
                }];
            }
        }
            break;
            
        default:
        {
            [weakSelf.pano720VM deleteFileWithModels:selectedModels deleteModel:self.delModel success:^(NSURLSessionDataTask *task, id responseObject) {
                
                // delete already exist model
                [weakSelf deleteAlreadyDeletedModels:selectedModels];
                
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tips_DeleteFail"]];
            }];
            [weakSelf deletePicAction:weakSelf.rightButton];
        }
            break;
    }
    
    
    
    
}

- (void)deleteAlreadyDeletedModels:(NSArray *)selectedModels
{
    switch (self.delModel)
    {
        case DeleteModel_Delete:
        {
            for (NSInteger i = 0; i <self.dataArray.count; i ++)
            {
                NSMutableArray *rows = [NSMutableArray arrayWithArray:[self.dataArray objectAtIndex:i]];
                
                for (NSInteger j = 0; j < rows.count; j ++)
                {
                    
                    Pano720PhotoModel *model = [[self.dataArray objectAtIndex:i] objectAtIndex:j];
                    for (NSInteger h = 0; h < selectedModels.count; h ++)
                    {
                        Pano720PhotoModel *selectedModel = [selectedModels objectAtIndex:h];
                        
                        if ([model.fileName isEqualToString:selectedModel.fileName])
                        {
                            [rows removeObject:model];
                        }
                    }
                }
                
                [self.dataArray replaceObjectAtIndex:i withObject:rows];
            }
        }
            break;
        case DeleteModel_DeleteAll:
        {
            [self.dataArray removeAllObjects];
            [self updateTableView:nil];
            
            return;
        }
            break;
        case DeleteModel_Keep:
        {
            
        }
            break;
        default:
            break;
    }
    
    
    [self reloadTableView];
}


- (void)selectAllBtnAction:(UIButton *)sender
{
    self.delModel = DeleteModel_DeleteAll;
    self.bottomBiew.deleteButton.enabled = YES;
    sender.selected = !sender.selected;

    for (NSInteger i = 0; i < self.dataArray.count; i ++)
    {
        NSArray *rows = [self.dataArray objectAtIndex:i];
        
        for (NSInteger j = 0; j < rows.count; j ++)
        {
            if (sender.selected)
            {
                [self.panoTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES scrollPosition:UITableViewScrollPositionNone];
            }
            else
            {
                [self.panoTableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES];
            }
        }
    }
    self.bottomBiew.deleteButton.enabled = [self.panoTableView indexPathsForSelectedRows]>0;
}

//- (void)showMenu:(UITapGestureRecognizer *)gueseture
//{
//    YBPopupMenu *popupMenu =  [YBPopupMenu showAtPoint:CGPointMake(Kwidth*0.5, 64.0) titles:self.titles icons:@[@"album_icon_album_gray",@"album_icon_720camera_gray",@"album_icon_iphone_gray"] menuWidth:200 delegate:nil];
//    popupMenu.tag = alertViewTag;
//    popupMenu.dismissOnSelected = YES;
//    popupMenu.textColor = [UIColor colorWithHexString:@"#4b9fd5"];
//    popupMenu.isShowShadow = YES;
//    popupMenu.delegate = self;
//    popupMenu.offset = 2;
//    popupMenu.firstCellCanClicked = self.isConnectted;
//    popupMenu.secondCellCanClicked = self.isConnectted;
//    popupMenu.type = YBPopupMenuTypeDefault;
//    
//    JFGLog(@"____self.isConnect  [%d]", self.isConnectted);
//    
//    [self.titltView rotateAnimation:YES];
//}

- (void)setTitleLabelText:(NSString *)text
{
//    self.titltView.titleLbel.text = text;
//    [self.titltView updateLayout];
}


// using WWAN network to download alter
- (void)showWWANNetWorkAlter:(NSString *)alertTitle
{
    if (![CommonMethod isWifiConnectted] && [[NetworkMonitor sharedManager] currentNetworkStatu] == ReachableViaWWAN)
    {
        [LSAlertView showAlertWithTitle:nil Message:alertTitle CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] CancelBlock:^{
            
        } OKBlock:^{
            
        }];
    }
}

#pragma mark
#pragma mark  Menu delegate
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    [self setTitleLabelText:[self.titles objectAtIndex:index]];
    
    switch (index)
    {
        case 0:
        {
            [self fileExistTypeChanged:FileExistTypeBoth];
            [self showWWANNetWorkAlter:[JfgLanguage getLanTextStrByKey:@"Tap1_Firmware_DataTips"]];
        }
            break;
        case 1:
        {
            [self fileExistTypeChanged:FileExistTypeRemote];
            [self showWWANNetWorkAlter:[JfgLanguage getLanTextStrByKey:@"Tap1_Sync_NetworkChangeTips"]];
        }
            break;
        case 2:
        {
            [self fileExistTypeChanged:FileExistTypeLocal];
        }
            break;
        default:
            break;
    }
    
    [self reloadTableView];
}


- (void)ybPopupMenuBeganDismiss
{
    
}
- (void)ybPopupMenuDidDismiss
{
    [self.titltView rotateAnimation:NO];
}

#pragma mark
#pragma mark  watch Video&photo delegate
- (void)donwloadWithModel:(Pano720PhotoModel *)model
{
    [self downloadVideoWithModel:model];
}

- (void)deleteModelInLocal:(Pano720PhotoModel *)model
{
    JFG_WS(weakSelf);
    
    [self.pano720VM deleteFileWithModels:@[model] deleteModel:DeleteModel_Delete success:^(NSURLSessionDataTask *task, id responseObject) {
        [weakSelf deleteAlreadyDeletedModels:@[model]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

#pragma mark
#pragma mark JFGSDK delegate
- (void)jfgNetworkChanged:(JFGNetType)netType
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"network changed %ld",netType]];
    
    if ([CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
    {
        return;
    }
    
    self.isConnectted = NO;
    [self setIsConnectted:NO];
    [self jfgFpingRequest];
}

-(void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray <DataPointSeg *> *)msgList
{
    JFG_WS(weakSelf);
    
    if ([peer isEqualToString:self.cid])
    {
        @try
        {
            for (DataPointSeg *seg in msgList)
            {
                NSError *error = nil;
                id obj = [MPMessagePackReader readData:seg.value error:&error];
                if (error == nil)
                {
                    switch (seg.msgId)
                    {
                        case dpMsgBase_SDCardInfoList:
                        {
                            if ([obj isKindOfClass:[NSArray class]])
                            {
                                BOOL isExistSDCard = [[obj objectAtIndex:0] boolValue];
                                if (weakSelf.isConnectted == YES)
                                {
                                    [weakSelf setIsConnectted:isExistSDCard];
                                }
                                
                                if (isExistSDCard == NO)
                                {
                                    [self showSDcardPulloutAlert];
                                }
                                
                            }
                        }
                            break;
                    }
                }
            }
        } @catch (NSException *exception) {
            [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"Pano720PhotoVC exception: %@",exception]];
        } @finally {
            
        }
    }
}

// 720 专用
-(void)jfgDPMsgRobotForwardDataV2AckForTcpWithMsgID:(NSString *)msgID
                                               mSeq:(uint64_t)mSeq
                                                cid:(NSString *)cid
                                               type:(int)type
                                       isInitiative:(BOOL)initiative
                                           dpMsgArr:(NSArray *)dpMsgArr
{
    for (DataPointSeg *seg in dpMsgArr)
    {
        NSError *error = nil;
        id obj = [MPMessagePackReader readData:seg.value error:&error];
        if (error == nil)
        {
            switch (seg.msgId)
            {
                    // SDCard 插拔
                case dpMsgBase_SDStatus:
                {
                    if ([obj isKindOfClass:[NSArray class]])
                    {
                        BOOL isExistSDCard = [[obj objectAtIndex:3] boolValue];
                        if (self.isConnectted == YES)
                        {
                            [self setIsConnectted:isExistSDCard];
                        }
                        
                        
                        if (isExistSDCard == NO)
                        {
                            // sdCard was pulled out
                            if (initiative)
                            {
                                [self showSDcardPulloutAlert];
                            }
                            
                            [self fileExistTypeChanged:FileExistTypeLocal];
                        }
                        
                    }
                }
                    break;
            }
        }
    }
}

#pragma mark
#pragma mark  tabliew delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *panoIdentifier = @"pano_cell";
    Pano720TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:panoIdentifier];
    Pano720PhotoModel *dataModel = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (!cell)
    {
        cell = [[Pano720TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:panoIdentifier];
        cell.selectedBackgroundView.backgroundColor = [UIColor whiteColor];
    }
    
    UIImage *picImage = [UIImage imageWithContentsOfFile:dataModel.thumbNailFilePath];
    picImage = (picImage == nil)?[UIImage imageNamed:@"album_pic_placeholder"]:picImage;
    cell.picImageView.image = picImage;
    BOOL isPic = (dataModel.panoFileType == FileTypePhoto);
    cell.progressLabel.hidden = (dataModel.downLoadState == DownLoadStateFinished || dataModel.downLoadState == DownLoadStateFailed);
    cell.durationLabel.hidden = isPic;
    cell.progressLabel.text = dataModel.downloadProgressStr;
    cell.durationLabel.text = dataModel.videoDurationStr;
    
    switch (self.pano720VM.fileExistType) {
        case FileExistTypeRemote:
        {
            cell.phoneIconImgeView.hidden = YES;
            cell.deviceIconImgeView.hidden = NO;
        }
            break;
        case FileExistTypeLocal:
        {
            cell.phoneIconImgeView.hidden = NO;
            cell.deviceIconImgeView.hidden = YES;
            cell.progressLabel.hidden = YES;
        }
            break;
        case FileExistTypeBoth:
        {
            switch (dataModel.location)
            {
                case fileInLocal:
                {
                    cell.phoneIconImgeView.hidden = NO;
                    cell.deviceIconImgeView.hidden = YES;
                }
                    break;
                case fileInRemote:
                {
                    cell.phoneIconImgeView.hidden = YES;
                    cell.deviceIconImgeView.hidden = YES;
                }
                    break;
                case fileInBoth:
                {
                    cell.phoneIconImgeView.hidden = NO;
                    cell.deviceIconImgeView.hidden = YES;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    [cell updateIconImageViewLayout];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = [self.dataArray objectAtIndex:section];
    return rows.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray *rows = [self.dataArray objectAtIndex:section];
    if (rows.count > 0)
    {
        Pano720PhotoModel *model = [rows firstObject];
        HeaderViewFor720 *headerView = [[HeaderViewFor720 alloc] initWithFrame:CGRectMake(0, 0, Kwidth, headerViewHeight)];
        [headerView setEditing:self.panoTableView.isEditing];
        headerView.timeLabel.text = model.headerString;

        return headerView;
    }
    
    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return cellRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return headerViewHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // deleteCode
    Pano720PhotoModel *panoModel = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    JFG_WS(weakSelf);
    
    switch (self.pano720VM.fileExistType)
    {
        case FileExistTypeBoth:
        {
            if ([self isDownloading:@[panoModel]])
            {
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_DeleteDownloadingTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                    
                } OKBlock:^{
                    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_DeletedCameraNCellphoneFileTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Sure"] CancelBlock:^{
                        
                    } OKBlock:^{
                        [weakSelf.pano720VM deleteFileWithModels:@[panoModel] deleteModel:DeleteModel_Delete success:^(NSURLSessionDataTask *task, id responseObject) {
                            [weakSelf deleteAlreadyDeletedModels:@[panoModel]];
                        } failure:^(NSURLSessionDataTask *task, NSError *error) {
                            
                        }];
                    }];
                }];
            }
            else // 直接删除
            {
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap1_DeletedCameraNCellphoneFileTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Button_Sure"] CancelBlock:^{
                    
                } OKBlock:^{
                    [weakSelf.pano720VM deleteFileWithModels:@[panoModel] deleteModel:DeleteModel_Delete success:^(NSURLSessionDataTask *task, id responseObject) {
                        [weakSelf deleteAlreadyDeletedModels:@[panoModel]];
                    } failure:^(NSURLSessionDataTask *task, NSError *error) {
                        
                    }];
                }];
            }
            
        }
            break;
            
        default:
        {
            [self.pano720VM deleteFileWithModels:@[panoModel] deleteModel:DeleteModel_Delete success:^(NSURLSessionDataTask *task, id responseObject) {
                [weakSelf deleteAlreadyDeletedModels:@[panoModel]];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                
            }];
        }
            break;
    }
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.panoTableView.editing == YES)
    {
        self.bottomBiew.deleteButton.enabled = [self.panoTableView indexPathsForSelectedRows]>0;
        return;
    }
    
    Pano720PhotoModel *panoModel = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    Watch720PhotoVC *watchVC = [[Watch720PhotoVC alloc] init];
    watchVC.cid = self.cid;
    watchVC.pType = self.pType;
    watchVC.panoModel = panoModel;
    watchVC.myDelegate = self;
    watchVC.nickName = self.nickName;
    watchVC.panoMediaType = (panoModel.panoFileType == FileTypePhoto)?mediaTypePhoto:mediaTypeVideo;
    watchVC.existType = self.pano720VM.fileExistType;
    
    watchVC.thumbNailImage = [UIImage imageWithContentsOfFile:panoModel.thumbNailFilePath];
    watchVC.panoMediaPath = panoModel.filePath;
    watchVC.urlString = panoModel.urlString;
    watchVC.titleTime = panoModel.fileTime;
    
    [self.navigationController pushViewController:watchVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.bottomBiew.deleteButton.enabled = [self.panoTableView indexPathsForSelectedRows]>0;
}

#pragma mark
#pragma mark  getter
- (void)setIsConnectted:(BOOL)isConnectted
{
    _isConnectted = isConnectted;
    
    YBPopupMenu *popupMenu = (YBPopupMenu *)[self.view viewWithTag:alertViewTag];
    if (popupMenu != nil)
    {
        popupMenu.firstCellCanClicked = _isConnectted;
        popupMenu.secondCellCanClicked = _isConnectted;
    }
}

- (Pano720PhotoViewModel *)pano720VM
{
    if (_pano720VM == nil)
    {
        _pano720VM = [[Pano720PhotoViewModel alloc] init];
        _pano720VM.cid = self.cid;
        _pano720VM.pType = self.pType;
    }
    return _pano720VM;
}

- (UITableView *)panoTableView
{
    if (_panoTableView == nil)
    {
        _panoTableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _panoTableView.hidden = YES;
        [_panoTableView setAllowsMultipleSelectionDuringEditing:NO];
        _panoTableView.showsVerticalScrollIndicator = NO;
        _panoTableView.showsHorizontalScrollIndicator = NO;
        _panoTableView.backgroundColor = [UIColor whiteColor];
        _panoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _panoTableView.delegate = self;
        _panoTableView.dataSource = self;
        _panoTableView.mj_footer.hidden = NO;
    }
    
    return _panoTableView;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _dataArray;
}

- (NSArray *)titles
{
    if (_titles == nil)
    {
        _titles = [[NSArray alloc] initWithObjects:[JfgLanguage getLanTextStrByKey:@"photo"],[JfgLanguage getLanTextStrByKey:@"photo"],[JfgLanguage getLanTextStrByKey:@"Tap1_File_Phone"], nil];
    }
    return _titles;
}

- (PhotoTitleView *)titltView
{
    if (_titltView == nil)
    {
        CGFloat x = 50;
        CGFloat y = 0;
        CGFloat width = Kwidth - x*2.0;
        CGFloat height = 64;
        
        _titltView = [[PhotoTitleView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _titltView.titleLbel.text = [JfgLanguage getLanTextStrByKey:@"photo"];
//        UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
//        [_titltView addGestureRecognizer:tapGuesture];
    }
    return _titltView;
}

- (UIView *)noDataView
{
    if (_noDataView == nil)
    {
        CGFloat width = self.noDataImgView.width;
        CGFloat height = self.noDataImgView.height + self.noDataLabel.height + 17.0f;
        CGFloat x = (Kwidth - width)*0.5;
        CGFloat y = 172.0f + 64.0;
        
        _noDataView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _noDataView.hidden = NO;
    }
    
    return _noDataView;
}

- (UIImageView *)noDataImgView
{
    if (_noDataImgView == nil)
    {
        _noDataImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 250, 91)];
        _noDataImgView.image = [UIImage imageNamed:@"album_pic_empty_state"];
        
    }
    return _noDataImgView;
}

- (UILabel *)noDataLabel
{
    if (_noDataLabel == nil)
    {
        CGFloat x = 0;
        CGFloat y = self.noDataImgView.height + 17.0f;
        CGFloat width = self.noDataImgView.width;
        CGFloat height = 15.0f;
        
        _noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Album_Empty"];
        _noDataLabel.font = [UIFont systemFontOfSize:height];
        _noDataLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        
    }
    return _noDataLabel;
}

- (PanoPhotoView *)bottomBiew
{
    if (_bottomBiew == nil)
    {
        _bottomBiew = [[PanoPhotoView alloc] init];
        _bottomBiew.frame = CGRectMake(0, kheight, Kwidth, 50);
        
        [_bottomBiew.deleteButton addTarget:self action:@selector(deleteButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBiew.selectAllBtn addTarget:self action:@selector(selectAllBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBiew;
}

- (NSMutableArray *)downloadArr
{
    if (_downloadArr == nil)
    {
        _downloadArr = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _downloadArr;
}

- (NSMutableArray *)thumbNailArr
{
    if (_thumbNailArr == nil)
    {
        _thumbNailArr = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _thumbNailArr;
}

- (NSMutableArray *)videoDownloadArr
{
    if (_videoDownloadArr == nil)
    {
        _videoDownloadArr = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _videoDownloadArr;
}
@end
