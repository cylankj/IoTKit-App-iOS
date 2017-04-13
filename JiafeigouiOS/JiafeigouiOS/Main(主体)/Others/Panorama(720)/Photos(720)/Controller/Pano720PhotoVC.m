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
#import "Pano720PhotoModel.h"
#import "LoginManager.h"

#define headerViewHeight 46


@interface Pano720PhotoVC ()<UITableViewDelegate, UITableViewDataSource, YBPopupMenuDelegate, Pano720PhotoDelegate>

@property (nonatomic, strong) BaseTableView *panoTableView;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) PhotoTitleView *titltView;
@property (nonatomic, strong) NSArray *titles;

@property (nonatomic, strong) UIView *noDataView;
@property (nonatomic, strong) UIImageView *noDataImgView;
@property (nonatomic, strong) UILabel *noDataLabel;

@property (nonatomic, strong) Pano720PhotoViewModel *pano720VM;

@property (nonatomic, assign) int fileOffset;
@property (nonatomic, assign) int fileBegin;

@end

@implementation Pano720PhotoVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigation];
    
    [self.pano720VM getPhotoListBeginTime:1489507200 endTime:(int)[[NSDate date] timeIntervalSince1970] count:10];
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
    [self.titltView updateLayout];
    
    [self.view addSubview:self.noDataView];
    [self.noDataView addSubview:self.noDataImgView];
    [self.noDataImgView addSubview:self.noDataLabel];
    
    [self initRefreshView];
}

- (void)initNavigation
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.rightButton.hidden = NO;
    [self.rightButton setImage:[UIImage imageNamed:@"album_icon_delete"] forState:UIControlStateNormal];
    [self.rightButton setImage:[UIImage imageNamed:@"album_icon_delete_disabled"] forState:UIControlStateDisabled];
    [self.rightButton addTarget:self action:@selector(deletePicAction:) forControlEvents:UIControlEventTouchUpInside];
    
}


-(void)initRefreshView
{
    self.panoTableView.mj_header = [JFGRefreshLoadingHeader headerWithRefreshingBlock:^{
        
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            [self.panoTableView.mj_footer resetNoMoreData];
        }else{
            [self.panoTableView.mj_header endRefreshing];
        }
        
        
    }];
    
    
    self.panoTableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
            
            [self.panoTableView.mj_footer endRefreshing];
            return ;
        }
        
        if (self.panoTableView.mj_footer.state != MJRefreshStateRefreshing) {
            {
                [self.panoTableView.mj_footer endRefreshing];
                return;
            }
        }
        
        __weak typeof(self)weakSelf = self;
    }];
    
    MJRefreshAutoNormalFooter *footer = (MJRefreshAutoNormalFooter *)self.panoTableView.mj_footer;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    footer.automaticallyHidden = NO;
}

#pragma mark
#pragma mark action
- (void)deletePicAction:(id)sender
{
    UIButton *senderBtn = (UIButton *)sender;
    senderBtn.selected = !senderBtn.selected;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:isEditingNotification object:@(senderBtn.selected)];
    [self.panoTableView setEditing:senderBtn.selected];
}

- (void)showMenu:(UITapGestureRecognizer *)gueseture
{
    YBPopupMenu *popupMenu = [YBPopupMenu showAtPoint:CGPointMake(Kwidth*0.5, 64.0) titles:self.titles icons:@[@"album_icon_album_gray",@"album_icon_720camera_gray",@"album_icon_iphone_gray"] menuWidth:200 delegate:nil];
    popupMenu.dismissOnSelected = YES;
    popupMenu.textColor = [UIColor colorWithHexString:@"#4b9fd5"];
    popupMenu.isShowShadow = YES;
    popupMenu.delegate = self;
    popupMenu.offset = 2;
    popupMenu.type = YBPopupMenuTypeDefault;
    
    [self.titltView rotateAnimation:YES];
}

- (void)setTitleLabelText:(NSString *)text
{
    self.titltView.titleLbel.text = text;
    [self.titltView updateLayout];
}

- (void)updateTableView:(NSArray *)data
{
    self.panoTableView.hidden = !(data.count>0);
    self.noDataView.hidden = !self.panoTableView.hidden;
    
    if (data.count > 0)
    {
        [self.dataArray removeAllObjects];
        [self.dataArray addObjectsFromArray:data];
        [self.panoTableView reloadData];
    }
}

#pragma mark
#pragma mark  panoViewModel Delegate
- (void)unHandledPhotoList:(NSArray *)photoList
{
    [self updateTableView:photoList];
}

- (void)updateDownloadedList:(NSArray <Pano720PhotoModel*>*)downloadedModel
{
    [self updateTableView:downloadedModel];
}

#pragma mark
#pragma mark  Menu delegate
- (void)ybPopupMenuDidSelectedAtIndex:(NSInteger)index ybPopupMenu:(YBPopupMenu *)ybPopupMenu
{
    [self setTitleLabelText:[self.titles objectAtIndex:index]];
}
- (void)ybPopupMenuBeganDismiss
{
    
}
- (void)ybPopupMenuDidDismiss
{
    [self.titltView rotateAnimation:NO];
}

#pragma mark
#pragma mark  tabliew delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *panoIdentifier = @"pano_cell";
    Pano720TableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:panoIdentifier];
    Pano720PhotoModel *dataModel = [self.dataArray objectAtIndex:indexPath.row];
    
    if (!cell)
    {
        cell = [[Pano720TableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:panoIdentifier];
    }
//    [cell bindModel:dataModel];
    
    UIImage *picImage = [UIImage imageWithContentsOfFile:dataModel.filePath];
    
    JFGLog(@"__picImage %@ ____ %@", picImage, dataModel.filePath);
    picImage = (picImage == nil)?[UIImage imageNamed:@"album_pic_broken"]:picImage;
    cell.picImageView.image = picImage;

    cell.progressLabel.hidden = (picImage != nil);


    BOOL isPic = (dataModel.fileType == FileTypePhoto);
    cell.durationLabel.hidden = isPic;
    
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    HeaderViewFor720 *headerView = [[HeaderViewFor720 alloc] initWithFrame:CGRectMake(0, 0, Kwidth, headerViewHeight)];
    [headerView setEditing:self.panoTableView.isEditing];
    return headerView;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Pano720PhotoModel *model = [self.dataArray objectAtIndex:indexPath.row];
    
    Watch720PhotoVC *watchVC = [[Watch720PhotoVC alloc] init];
    watchVC.mediaType = mediaTypePhoto;
    watchVC.panoMediaPath = model.filePath;
    [self.navigationController pushViewController:watchVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}


#pragma mark
#pragma mark  getter
- (Pano720PhotoViewModel *)pano720VM
{
    if (_pano720VM == nil)
    {
        _pano720VM = [[Pano720PhotoViewModel alloc] init];
        _pano720VM.delegate = self;
        _pano720VM.cid = self.cid;
        _pano720VM.pType = self.pType;
        _pano720VM.fileExistType = FileExistTypeBoth;
    }
    return _pano720VM;
}

- (UITableView *)panoTableView
{
    if (_panoTableView == nil)
    {
        _panoTableView = [[BaseTableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _panoTableView.hidden = YES;
        _panoTableView.editing = NO;
        _panoTableView.showsVerticalScrollIndicator = NO;
        _panoTableView.showsHorizontalScrollIndicator = NO;
        _panoTableView.backgroundColor = [UIColor whiteColor];
        _panoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_panoTableView setAllowsMultipleSelectionDuringEditing:YES];
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
        _titles = [[NSArray alloc] initWithObjects:@"相册+手机相册",@"全景相机",@"手机相册", nil];
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
        _titltView.titleLbel.text = [JfgLanguage getLanTextStrByKey:@"相册+手机相册"];
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
        _noDataLabel.text = [JfgLanguage getLanTextStrByKey:@"相册那么大，你还未拍摄"];
        _noDataLabel.font = [UIFont systemFontOfSize:height];
        _noDataLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        
    }
    return _noDataLabel;
}

@end
