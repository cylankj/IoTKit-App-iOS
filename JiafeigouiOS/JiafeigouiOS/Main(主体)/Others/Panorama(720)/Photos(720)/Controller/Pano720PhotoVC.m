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
#import "LSAlertView.h"
#import "ProgressHUD.h"
#import <JFGSDK/JFGSDK.h>
#import "PanoPhotoView.h"
#import "CommonMethod.h"
#import "LoginManager.h"

#define headerViewHeight 46

typedef NS_ENUM(NSInteger, controlTag) {
    alertViewTag = 1001,
};

@interface Pano720PhotoVC ()<UITableViewDelegate, UITableViewDataSource, YBPopupMenuDelegate, JFGSDKCallbackDelegate>

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
@property (nonatomic, assign) DeleteModel delModel;
@end

@implementation Pano720PhotoVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigation];
    
    [self initData];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initView
{
    [self.view addSubview:self.panoTableView];
    [self.panoTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
    }];
    
    [self.view addSubview:self.titltView];
    [self.view addSubview:self.bottomBiew];
    
    [self.view addSubview:self.noDataView];
    [self.noDataView addSubview:self.noDataImgView];
    [self.noDataImgView addSubview:self.noDataLabel];
    
    [self initRefreshView];
    [self.titltView updateLayout];
    
    // foot head refresh
    MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.panoTableView.mj_footer;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    footer.automaticallyHidden = NO;
}

- (void)initNavigation
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton.hidden = NO;
    [self.rightButton setImage:[UIImage imageNamed:@"album_icon_delete"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"album_icon_delete_disabled"] forState:UIControlStateDisabled];
    [self.rightButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
    [self.rightButton addTarget:self action:@selector(deletePicAction:) forControlEvents:UIControlEventTouchUpInside];
    
}

-(void)initRefreshView
{
    __weak typeof(self)weakSelf = self;
    
    // header refresh block
    self.panoTableView.mj_header = [JFGRefreshLoadingHeader headerWithRefreshingBlock:^{
        
        if (self.isConnectted)
        {
            [weakSelf.panoTableView.mj_footer resetNoMoreData];
            
            [weakSelf.pano720VM requestURL:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getFileList&begintime=0&endtime=%lld&count=20",self.pano720VM.ipAddress,(long long)[[NSDate date]timeIntervalSince1970]] parameters:nil progress:nil downloadSuccess:^(Pano720PhotoModel *dlModel, int result) {
                [weakSelf.panoTableView reloadData];
            } success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                [weakSelf updateTableView:models];
                [weakSelf.panoTableView.mj_header endRefreshing];
            } failure:^(NSURLSessionDataTask *task, NSError *error) {
                [weakSelf.panoTableView.mj_header endRefreshing];
            }];
            
        }else{
            [self.panoTableView.mj_header endRefreshing];
        }
    }];
    
    // footer refresh block
    
    self.panoTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        NSLog(@"update more");
        
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
                
                Pano720PhotoModel *model = [[self.dataArray lastObject] lastObject];
                
                [weakSelf.pano720VM requestURL:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getFileList&begintime=0&endtime=%lld&count=20",self.pano720VM.ipAddress,model.fileTime] parameters:nil progress:nil downloadSuccess:^(Pano720PhotoModel *dlModel, int result) {
                    [weakSelf.panoTableView reloadData];
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
                Pano720PhotoModel *model = [[self.dataArray lastObject] lastObject];
                [self.pano720VM getMoreLocalDataWithBeginTime:model.fileTime count:20 success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
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
    
    
}

- (void)updateTableView:(NSArray *)data
{
    self.panoTableView.hidden = !(data.count>0);
    self.noDataView.hidden = !self.panoTableView.hidden;
    self.rightButton.hidden = self.panoTableView.hidden;
    
    if (data.count > 0)
    {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:data];
        [self.panoTableView reloadData];
        
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

#pragma mark
#pragma mark data
- (void)initData
{
    [self setDefaultFileExistType];
    [JFGSDK addDelegate:self];
    [self jfgFpingRequest];
    self.delModel = DeleteModel_Delete;
}
- (void)jfgFpingRequest
{
    [JFGSDK fping:@"255.255.255.255"];
    [JFGSDK fping:@"192.168.10.255"];
}

- (void)jfgFpingRespose:(JFGSDKUDPResposeFping *)ask
{
    if ([ask.cid isEqualToString:self.cid])
    {
        [self setIsConnectted:YES];
        [self setDefaultFileExistType];
        self.pano720VM.ipAddress = ask.address;
        [self.pano720VM requestURL:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getFileList&begintime=0&endtime=%lld&count=20",ask.address,(long long)[[NSDate date] timeIntervalSince1970]] parameters:nil  progress:nil downloadSuccess:^(Pano720PhotoModel *dlModel, int result) {
            NSLog(@"download success");
            [self.panoTableView reloadData];
        }  success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
            [self updateTableView:models];
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
        }];
        
    }
}

- (void)setDefaultFileExistType
{
    // when wifi or ap connect, show phone_photo and photo else show  phonephoto
    if ([[NetworkMonitor sharedManager] currentNetworkStatu] == ReachableViaWiFi || [CommonMethod isConnectedAPWithPid:self.pType Cid:self.cid])
    {
        [self setTitleLabelText:[JfgLanguage getLanTextStrByKey:@"Tap1_File_CameraNPhone"]];
        self.pano720VM.fileExistType = FileExistTypeBoth;
    }
    else
    {
        [self setTitleLabelText:[JfgLanguage getLanTextStrByKey:@"Tap1_File_Phone"]];
        self.pano720VM.fileExistType = FileExistTypeLocal;
    }
}

- (void)fileExistTypeChanged:(FileExistType)changedValue
{
    self.pano720VM.fileExistType = changedValue;
    
    switch (self.pano720VM.fileExistType)
    {
        case FileExistTypeRemote:
        case FileExistTypeBoth:
        {
            if (self.pano720VM.ipAddress != nil)
            {
                
                [self.pano720VM requestURL:[NSString stringWithFormat:@"http://%@/cgi/ctrl.cgi?Msg=getFileList&begintime=0&endtime=%lld&count=20",self.pano720VM.ipAddress,(long long)[[NSDate date]timeIntervalSince1970]] parameters:nil  progress:nil downloadSuccess:^(Pano720PhotoModel *dlModel, int result) {
                    
                } success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                    [self updateTableView:models];
                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                    
                }];
            }
            
        }
            break;
        case FileExistTypeLocal:
        {
            
            [self.pano720VM requestURL:nil parameters:nil progress:nil downloadSuccess:nil success:^(NSURLSessionDataTask *task, NSMutableArray<Pano720PhotoModel *> *models) {
                [self updateTableView:models];
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

#pragma mark
#pragma mark action
- (void)deletePicAction:(id)sender
{
    UIButton *senderBtn = (UIButton *)sender;
    senderBtn.selected = !senderBtn.selected;
    self.bottomBiew.deleteButton.enabled = NO;

    [senderBtn setImage:senderBtn.selected?nil:[UIImage imageNamed:@"album_icon_delete"] forState:UIControlStateNormal];
    [self.panoTableView setAllowsMultipleSelectionDuringEditing:senderBtn.selected];
    [[NSNotificationCenter defaultCenter] postNotificationName:isEditingNotification object:@(senderBtn.selected)];
    [self.panoTableView setEditing:senderBtn.selected];
    
    [UIView animateWithDuration:0.2 animations:^{
        if (senderBtn.selected)
        {
            self.bottomBiew.frame = CGRectMake(0, kheight- 44, Kwidth, 44);
        }
        else
        {
            self.bottomBiew.frame = CGRectMake(0, kheight, Kwidth, 44);
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
    
    [self.pano720VM deleteFileWithModels:selectedModels deleteModel:self.delModel success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // delete already exist model
        [self deleteAlreadyDeletedModels:selectedModels];
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tips_DeleteFail"]];
    }];
    
    [self deletePicAction:self.rightButton];
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
    
    
    [self.panoTableView reloadData];
}

- (void)selectAllBtnAction:(UIButton *)sender
{
    self.delModel = DeleteModel_DeleteAll;
    self.bottomBiew.deleteButton.enabled = YES;
    
    for (NSInteger i = 0; i < self.dataArray.count; i ++)
    {
        NSArray *rows = [self.dataArray objectAtIndex:i];
        
        for (NSInteger j = 0; j < rows.count; j ++)
        {
            [self.panoTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i] animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    }
    
}

- (void)showMenu:(UITapGestureRecognizer *)gueseture
{
    YBPopupMenu *popupMenu =  [YBPopupMenu showAtPoint:CGPointMake(Kwidth*0.5, 64.0) titles:self.titles icons:@[@"album_icon_album_gray",@"album_icon_720camera_gray",@"album_icon_iphone_gray"] menuWidth:200 delegate:nil];
    popupMenu.tag = alertViewTag;
    popupMenu.dismissOnSelected = YES;
    popupMenu.textColor = [UIColor colorWithHexString:@"#4b9fd5"];
    popupMenu.isShowShadow = YES;
    popupMenu.delegate = self;
    popupMenu.offset = 2;
    popupMenu.isDisconnectted = !self.isConnectted;
    popupMenu.type = YBPopupMenuTypeDefault;
    
    [self.titltView rotateAnimation:YES];
}

- (void)setTitleLabelText:(NSString *)text
{
    self.titltView.titleLbel.text = text;
    [self.titltView updateLayout];
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
    
    [self.panoTableView reloadData];
}


- (void)ybPopupMenuBeganDismiss
{
    
}
- (void)ybPopupMenuDidDismiss
{
    [self.titltView rotateAnimation:NO];
}

#pragma mark
#pragma mark JFGSDK delegate
- (void)jfgNetworkChanged:(JFGNetType)netType
{
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"network changed %ld",netType]];
    [self setIsConnectted:NO];
    [self jfgFpingRequest];
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
    }
    UIImage *picImage = [UIImage imageWithContentsOfFile:dataModel.imageShowedPath];
    picImage = (picImage == nil)?[UIImage imageNamed:@"album_pic_broken"]:picImage;
    cell.picImageView.image = picImage;
    cell.progressLabel.hidden = (picImage != nil);
    BOOL isPic = (dataModel.panoFileType == FileTypePhoto);
    cell.durationLabel.hidden = isPic;
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
        }
            break;
        case FileExistTypeBoth:
        {
            cell.phoneIconImgeView.hidden = NO;
            cell.deviceIconImgeView.hidden = NO;
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
    
    [self.pano720VM deleteFileWithModels:@[panoModel] deleteModel:DeleteModel_Delete success:^(NSURLSessionDataTask *task, id responseObject) {
        [self deleteAlreadyDeletedModels:@[panoModel]];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
    
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
    watchVC.panoMediaType = (panoModel.panoFileType == FileTypePhoto)?mediaTypePhoto:mediaTypeVideo;
    watchVC.panoMediaPath = panoModel.filePath;
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
        popupMenu.isDisconnectted = !self.isConnectted;
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
        _panoTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
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
        _titles = [[NSArray alloc] initWithObjects:[JfgLanguage getLanTextStrByKey:@"Tap1_File_CameraNPhone"],[JfgLanguage getLanTextStrByKey:@"Tap1_File_Camera"],[JfgLanguage getLanTextStrByKey:@"Tap1_File_Phone"], nil];
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
        _titltView.titleLbel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_File_CameraNPhone"];
        UITapGestureRecognizer *tapGuesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMenu:)];
        [_titltView addGestureRecognizer:tapGuesture];
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
        CGFloat y = 172.0f;
        
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

@end
