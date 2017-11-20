//
//  ShareContentVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/23.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "ShareContentVC.h"
#import "UIColor+HexColor.h"
#import "FLGlobal.h"
#import "UIView+FLExtensionForFrame.h"
#import "ShareDeviceCell.h"
#import "JfgLanguage.h"
#import <Masonry.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import "ExploreModel.h"
#import "JfgTimeFormat.h"
#import <MJRefresh.h>
#import "OemManager.h"
#import <JFGSDK/JFGSDK.h>
#import "LoginManager.h"
#import "UIImageView+WebCache.h"
#import "CommonMethod.h"
#import "UIAlertView+FLExtension.h"
#import "ShareWebViewController.h"
#import "LSAlertView.h"


@interface ShareContentVC ()<UITableViewDelegate,UITableViewDataSource,ShareWebVCDelegate>

@property (nonatomic, strong)UITableView * devicesTableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,strong)NSMutableArray *selectedArray;
@property (nonatomic,strong)UIView *bottomBgView;
@property (nonatomic,strong)UIButton *selectAllBtn;
@property (nonatomic,strong)UIButton *delBtn;
@property (nonatomic,strong)UIView *noDataView;

@end

@implementation ShareContentVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SharedContents"];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.devicesTableView];
    [self.topBarBgView addSubview:self.rightBtn];
    [self.view addSubview:self.bottomBgView];
    [self initRefresh];
    //[self.devicesTableView.mj_header beginRefreshing];
    [self getDataForServerWithTimestamp:0];
    
}



-(void)initRefresh
{
    __weak typeof(self) weakSelf = self;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
    
        ExploreModel * model = [weakSelf.dataArray lastObject];
        [weakSelf getDataForServerWithTimestamp:[model.version longLongValue]];
        
    }];
    footer.automaticallyHidden = YES;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    self.devicesTableView.mj_footer = footer;
    self.devicesTableView.estimatedRowHeight = 0;
    
//    self.devicesTableView.mj_header = [MJRefreshStateHeader headerWithRefreshingBlock:^{
//    
//        [weakSelf.devicesTableView.mj_footer resetNoMoreData];
//        [weakSelf getDataForServerWithTimestamp:0];
//    
//    }];
    
}


#pragma mark- 编辑按钮事件
-(void)editAction:(UIButton *)sender
{
    if (sender.selected) {
        //取消编辑
        [self.devicesTableView setEditing:NO animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomBgView.top = self.view.height;
            self.devicesTableView.height = self.view.height-64;
        }];
        self.devicesTableView.mj_footer.hidden = NO;
        
        if (self.selectAllBtn.selected) {
            [self selectAllAction];
        }
        
    }else{
        [self.devicesTableView setEditing:YES animated:YES];
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomBgView.bottom = self.view.height;
            self.devicesTableView.height = self.view.height-64-self.bottomBgView.height;
        }];
        self.devicesTableView.mj_footer.hidden = YES;
    }
    self.delBtn.enabled = NO;
    
    NSArray *arr = [self.devicesTableView visibleCells];
    for (ShareDeviceCell *cell in arr) {
        if (sender.selected) {
            cell.shareButton.hidden = NO;
        }else{
            cell.shareButton.hidden = YES;
        }
    }
    [self.selectedArray removeAllObjects];
    sender.selected = !sender.selected;
}

-(void)selectAllAction
{
    [self.selectedArray removeAllObjects];
    if (self.selectAllBtn.selected) {
        for (int i = 0; i < self.dataArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.devicesTableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        self.delBtn.enabled = NO;
    }else{
        for (int i = 0; i < self.dataArray.count; i ++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
            [self.devicesTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
        [self.selectedArray addObjectsFromArray:self.dataArray];
        self.delBtn.enabled = YES;
    }
    self.selectAllBtn.selected = !self.selectAllBtn.selected;
}
    


-(void)delAction
{
    NSMutableArray *segArr = [NSMutableArray new];
    for (ExploreModel *m in self.selectedArray) {
        
        DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
        seg.msgId = 606;
        seg.version = (int64_t)[m.version longLongValue];
        [segArr addObject:seg];
        [self.dataArray removeObject:m];
    }
    [self editAction:self.rightBtn];
    [self.devicesTableView reloadData];
    
    [[JFGSDKDataPoint sharedClient]robotDelDataWithPeer:@"" queryDps:segArr success:^(NSString *identity, int ret) {
        if (ret == 0) {
            NSLog(@"delete success");
            
        }
    } failure:^(RobotDataRequestErrorType type) {
        NSLog(@"delete fail:%ld",(long)type);
    }];
 
}


-(void)cancelShare:(UIButton *)sender
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        return ;
    }
    __weak typeof(self) weakSelf = self;
    [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_UnshareTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
        
    } OKBlock:^{
        
        exploreBtn *btn = (exploreBtn *)sender;
        ExploreModel *m = btn.model;
        DataPointIDVerSeg * seg = [[DataPointIDVerSeg alloc]init];
        seg.msgId = 606;
        seg.version = (int64_t)[m.version longLongValue];
        
        [weakSelf.dataArray removeObject:m];
        [weakSelf.devicesTableView reloadData];
        
        [[JFGSDKDataPoint sharedClient]robotDelDataWithPeer:@"" queryDps:@[seg] success:^(NSString *identity, int ret) {
            if (ret == 0) {
                NSLog(@"delete success");
                
            }
        } failure:^(RobotDataRequestErrorType type) {
            NSLog(@"delete fail:%ld",(long)type);
        }];
        
    }];
    
}


//下个页面删除数据回调
-(void)didDelShareContentForVersion:(uint64_t)version
{
    for (ExploreModel *m in [self.dataArray copy]) {
        if ([m.version longLongValue] == version) {
            [self.dataArray removeObject:m];
            [self.devicesTableView reloadData];
            break;
        }
    }
}

#pragma mark - UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count) {
        self.rightBtn.enabled = YES;
    }else{
        self.rightBtn.enabled = NO;
    }
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *IDCell = @"shareCell";
    ShareDeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (!cell) {
        cell = [[ShareDeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDCell];
    }
    [cell.shareButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(70, 28));
    }];
    [cell.iconImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(40, 40));
    }];
    cell.iconImageView.layer.masksToBounds = YES;
    cell.iconImageView.layer.cornerRadius = 20;
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor clearColor];
    UIView *topLineView = [cell.contentView viewWithTag:1023];
    if (topLineView) {
        if (indexPath.row == 0) {
            topLineView.hidden = NO;
        }else{
            topLineView.hidden = YES;
        }
    }else{
        if (indexPath.row == 0) {
            topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
            topLineView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
            topLineView.tag = 1023;
            [cell.contentView addSubview:topLineView];
        }
    }
    
    UIView *bottomLineView = [cell.contentView viewWithTag:1025];
    if (bottomLineView) {
        if (indexPath.row == self.dataArray.count-1) {
            bottomLineView.hidden = NO;
        }else{
            bottomLineView.hidden = YES;
        }
    }else{
        if (indexPath.row == self.dataArray.count-1) {
            bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 69.5, self.view.bounds.size.width, 0.5)];
            bottomLineView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
            bottomLineView.tag = 1025;
            [cell.contentView addSubview:bottomLineView];
        }
    }

    [cell.shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Delete"] forState:UIControlStateNormal];
    cell.shareButton.layer.borderColor = [UIColor colorWithHexString:@"#4b9fd5"].CGColor;
    [cell.shareButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"]forState:UIControlStateNormal];
    cell.shareButton.enabled = YES;
    if (self.dataArray.count > indexPath.row) {
        ExploreModel *m = [self.dataArray objectAtIndex:indexPath.row];
        cell.deviceNumLabel.text = m.time;
        cell.deviceNameLabel.text = m.alias;
        NSString *fileName = [m.url stringByDeletingPathExtension];
        fileName = [fileName stringByAppendingPathExtension:@"jpg"];
        JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
        NSString *wonderFilePath = [NSString stringWithFormat:@"/long/%@/%@/wonder/%@/%@",[OemManager getOemVid],account.account,m.cid,fileName];
        NSString *_url = [JFGSDK getCloudUrlWithFlag:m.regionType fileName:wonderFilePath];
        cell.shareButton.model = m;
        UIImage *defaultImage;
        if (m.isPic) {
            defaultImage = [UIImage imageNamed:@"bg_default_photo"];
        }else{
            defaultImage = [UIImage imageNamed:@"bg_default_video"];
        }
        
        [cell.iconImageView sd_setImageWithURL:[NSURL URLWithString:_url] placeholderImage:defaultImage];
    }
    
    
    
   
    [cell.shareButton removeTarget:self action:@selector(cancelShare:) forControlEvents:UIControlEventTouchUpInside];
    [cell.shareButton addTarget:self action:@selector(cancelShare:) forControlEvents:UIControlEventTouchUpInside];
    
    if (tableView.editing) {
        cell.shareButton.hidden = YES;
    }else{
        cell.shareButton.hidden = NO;
    }
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExploreModel *m = [self.dataArray objectAtIndex:indexPath.row];
    if (tableView.editing) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        if (![self.selectedArray containsObject:m]) {
             [self.selectedArray addObject:m];
        }
        if (self.selectedArray.count) {
            self.delBtn.enabled = YES;
        }else{
            self.delBtn.enabled = NO;
        }
    }else{
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        ShareWebViewController *share = [ShareWebViewController new];
        share.version = [m.version longLongValue];
        share.h5Url = m.shareVideoUrl;
        ShareDeviceCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        share.thumdImage = cell.iconImageView.image;
        share.delegate = self;
        share.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:share animated:YES];
    }
}


-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ExploreModel *m = [self.dataArray objectAtIndex:indexPath.row];
    if (tableView.editing) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        if ([self.selectedArray containsObject:m]) {
            [self.selectedArray removeObject:m];
        }
        if (self.selectedArray.count) {
            self.delBtn.enabled = YES;
        }else{
            self.delBtn.enabled = NO;
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}


-(void)getDataForServerWithTimestamp:(uint64_t)timestamp
{
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotGetDataEx:@"" version:timestamp dpids:@[@606] asc:NO success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        NSMutableArray *arr = [NSMutableArray array];
        
        for (NSArray * subArr in idDataList)
        {
            for (DataPointSeg *seg in subArr)
            {
                id obj = [MPMessagePackReader readData:seg.value error:nil];
                if ([obj isKindOfClass:[NSArray class]] && [(NSArray *)obj count]>6) {
                    
                    NSArray *vauleArr = obj;
                    ExploreModel * m = [[ExploreModel alloc]init];
                    m.version = [NSString stringWithFormat:@"%lld",seg.version];
                    m.msgID = (int)seg.msgId;
                    m.cid = [vauleArr objectAtIndex:0];
                    m.msgTime = [[vauleArr objectAtIndex:1] stringValue];
                    long long timestamp = [m.version longLongValue]/1000;
                    
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
                    NSDate *dat = [NSDate dateWithTimeIntervalSince1970:timestamp];
                    m.time = [dateFormatter stringFromDate:dat];
                    m.isPic = ![[vauleArr objectAtIndex:2] boolValue];
                    m.regionType = [[vauleArr objectAtIndex:3] intValue];
                    m.url = [vauleArr objectAtIndex:4];
                    id _obj = vauleArr[6];
                    if ([_obj isKindOfClass:[NSNumber class]]) {
                        m.collectedTimestamp = [vauleArr[6] longLongValue];
                    }else if([_obj isKindOfClass:[NSString class]]){
                        m.shareVideoUrl = vauleArr[6];
                    }
                    m.alias = [vauleArr objectAtIndex:5];
                    [arr addObject:m];
                }
            }
        }
        if (timestamp == 0) {
            [weakSelf.dataArray removeAllObjects];
            [weakSelf.devicesTableView.mj_header endRefreshing];
            [weakSelf.dataArray addObjectsFromArray:arr];
            
            if (arr.count == 0) {
                self.devicesTableView.hidden = YES;
                if (self.noDataView.superview == nil) {
                    [self.view addSubview:self.noDataView];
                }
            }else{
                self.devicesTableView.hidden = NO;
                [self.noDataView removeFromSuperview];
            }
            
        }else{
            [weakSelf.devicesTableView.mj_footer endRefreshing];
            if (!arr.count) {
                [weakSelf.devicesTableView.mj_footer endRefreshingWithNoMoreData];
            }else{
                [weakSelf.dataArray addObjectsFromArray:arr];
            }
        }
        [weakSelf.devicesTableView reloadData];
      
        
    } failure:^(RobotDataRequestErrorType type) {
        
        NSLog(@"每日精彩获取失败：%ld",(long)type);
//        [self.refreshView endRefresh];
//        self.topicTitleLabel.alpha = 1;
//        self.greetLabel.alpha = 1;
//        [self judgeHaveData];
        
    }];
    
}

-(UITableView *)devicesTableView
{
    if (!_devicesTableView) {
        _devicesTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _devicesTableView.delegate = self;
        _devicesTableView.dataSource = self;
        _devicesTableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _devicesTableView.separatorColor = TableSeparatorColor;
        _devicesTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        [_devicesTableView setTableFooterView:[UIView new]];
        [_devicesTableView setSeparatorInset:UIEdgeInsetsMake(0, 73, 0, 0)];
        [_devicesTableView setShowsVerticalScrollIndicator:NO];
        [_devicesTableView registerClass:[ShareDeviceCell class] forCellReuseIdentifier:@"shareCell"];
        _devicesTableView.allowsMultipleSelectionDuringEditing = YES;
    }
    return _devicesTableView;
}

-(UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 0, 80, self.backBtn.height);
        _rightBtn.right = self.view.bounds.size.width - self.backBtn.left+10;
        _rightBtn.top = self.backBtn.top;
        _rightBtn.titleLabel.font = self.backBtn.titleLabel.font;
        _rightBtn.titleLabel.textColor = self.backBtn.titleLabel.textColor;
        _rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_rightBtn setTitle:[JfgLanguage getLanTextStrByKey:@"EDIT_THEME"] forState:UIControlStateNormal];
        [_rightBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
        [_rightBtn setTitleColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        [_rightBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}



-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]init];
    }
    return _dataArray;
}

-(NSMutableArray *)selectedArray
{
    if (!_selectedArray) {
        _selectedArray = [[NSMutableArray alloc]init];
    }
    return _selectedArray;
}

-(UIView *)bottomBgView
{
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.height, self.view.width, 50)];
        _bottomBgView.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
        UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _bottomBgView.width, 0.5)];
        line.backgroundColor = [UIColor colorWithHexString:@"#dde0e5"];
        [_bottomBgView addSubview:line];
        [_bottomBgView addSubview:self.selectAllBtn];
        [_bottomBgView addSubview:self.delBtn];
    }
    return _bottomBgView;
}

-(UIButton *)selectAllBtn
{
    if (_selectAllBtn == nil) {
        _selectAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectAllBtn.frame = CGRectMake(30, 17, 60, 16);
        _selectAllBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_selectAllBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SELECT_ALL"] forState:UIControlStateNormal];
        [_selectAllBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
        [_selectAllBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        _selectAllBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_selectAllBtn addTarget:self action:@selector(selectAllAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectAllBtn;
}

-(UIButton *)delBtn
{
    if (!_delBtn) {
        _delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _delBtn.frame = CGRectMake(0, self.selectAllBtn.top, self.selectAllBtn.width, self.selectAllBtn.height);
        _delBtn.right = self.view.width-self.selectAllBtn.left;
        _delBtn.titleLabel.font = self.selectAllBtn.titleLabel.font;
        [_delBtn setTitleColor:[UIColor colorWithHexString:@"#aaaaaa"] forState:UIControlStateDisabled];
         [_delBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        _delBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_delBtn setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
        [_delBtn addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _delBtn;
}

-(UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-140)/2.0, 0.25*kheight, 140, 140)];
        iconImageView.image = [UIImage imageNamed:@"png_no-share"];
        [_noDataView addSubview:iconImageView];
        UILabel * noShareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImageView.bottom+20, Kwidth, 15)];
        noShareLabel.font = [UIFont systemFontOfSize:15];
        noShareLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        noShareLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_NoShare"];
        noShareLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:noShareLabel];
    }
    return _noDataView;
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
