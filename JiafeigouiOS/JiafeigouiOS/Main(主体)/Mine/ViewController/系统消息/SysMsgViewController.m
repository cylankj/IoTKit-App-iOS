//
//  SysMsgViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/9/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SysMsgViewController.h"
#import "SysMsgTableViewCell.h"
#import "UIColor+FLExtension.h"
#import "JfgLanguage.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import <MJExtension/MJExtension.h>
#import <MJRefresh/MJRefresh.h>
#import <JFGSDK/JFGSDK.h>
#import "LoginManager.h"
#import "NSString+FLExtension.h"

#define OFFLINEDELALL @"offlineDelAllDataKey"

@interface SysMsgViewController ()<UITableViewDelegate,UITableViewDataSource,UIWebViewDelegate>
{
    NSMutableArray *_selectArray; //选中的数组
    UIButton *_editBtn; //编辑按钮
    BOOL isEditing;
    UIButton *selectedAllBtn;
    UIButton *deleteBtn;
    UIView *bottomBarView;
    BOOL isSelectedAll;
    NSMutableDictionary *cellHeightDict;
}
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;


@end

@implementation SysMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.view.bounds.size.width) forKey:SysViewWidth];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_TitleName_Notice"];
    self.dataArray = [[NSMutableArray alloc]init];
    cellHeightDict = [NSMutableDictionary new];
    //[self simulantData];
    
    [self.view addSubview:self.tableView];
    [self initView];
    [self addFooter];
    [self getCacheData];
    
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        //清空绑定消息未读数
        [[JFGSDKDataPoint sharedClient] robotCountDataClear:@"" dpIDs:@[@(601),@(701)] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {} failure:^(RobotDataRequestErrorType type) {}];
        [self getDataByTime:0];
    }
    // Do any additional setup after loading the view.
}

-(void)getCacheData
{
    NSArray *arr = [self cacheForIsDel:NO];
    self.dataArray = [[NSMutableArray alloc]initWithArray:[self dealForServerData:arr]];
    [self.tableView reloadData];
}

-(void)getDataByTime:(uint64_t)timestamp
{
    
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotGetDataEx:@"" version:timestamp dpids:@[@601,@701] asc:NO success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        @try {
            NSMutableArray *bindList = [NSMutableArray new];
            
            for (NSArray *subArr in idDataList) {

                for (DataPointSeg *_seg in subArr) {

                    if (_seg.msgId == 601) {

                        id obj = [MPMessagePackReader readData:_seg.value error:nil];
                        if ([obj isKindOfClass:[NSArray class]]) {

                            NSArray *arr = obj;
                            if (arr.count >2) {

                                SysMsgModel *model = [[SysMsgModel alloc]init];
                                model.msgType = SysMsgTypeBind;
                                model.timestamp = _seg.version/1000;
                                model.cid = arr[0];
                                model.bindAccount = arr[2];
                                model.cellHeight = 0;
                                
                                if (arr.count > 4) {
                                    model.pid = [arr[4] intValue];
                                }
                                
                                
                                if ([arr[1] intValue] == 1) {

                                    model.isBinded = YES;

                                    if ([model.bindAccount isEqualToString:@""]) {
                                        model.msg = [JfgLanguage getLanTextStrByKey:@"DEVICE_EXISTED"];
                                    }else{

                                        if (model.bindAccount.length >= 7) {
                                            model.bindAccount = [self bindAccountDealForAccount:model.bindAccount];   
                                        }

                                        model.msg = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MSG_REBIND"],model.bindAccount];
                                    }


                                }else{

                                    model.isBinded = NO;
                                    model.msg = [JfgLanguage getLanTextStrByKey:@"MSG_UNBIND"];

                                }

                                [bindList addObject:model];
                                
                            }
                            
                        }
                        
                    }else if (_seg.msgId == 701){
                        
                        id obj = [MPMessagePackReader readData:_seg.value error:nil];
                        //NSLog(@"msg:%@",[obj description]);
                        if ([obj isKindOfClass:[NSArray class]]) {
                            
                            NSArray *dataArr = obj;
                            SysMsgModel *model = [[SysMsgModel alloc]init];
                            model.msgType = SysMsgTypeServer;
                            model.timestamp = _seg.version/1000;
                            model.cellHeight = 0;
                            if (dataArr.count>=2) {
                                model.msg = dataArr[1];
                            }
                            [bindList addObject:model];
                        }
                        
                    }
                    
                }
                
            }
            
            if (weakSelf.dataArray == nil) {
                weakSelf.dataArray = [NSMutableArray new];
            }
            //过滤本地已删除缓存
            if (timestamp == 0) {
                weakSelf.dataArray = [[NSMutableArray alloc]initWithArray:[self dealForServerData:bindList]];
            }else{
                [weakSelf.dataArray addObjectsFromArray:[self dealForServerData:bindList]];
                [weakSelf.tableView.mj_footer endRefreshing];
                if (bindList.count == 0) {
                    [weakSelf.tableView.mj_footer endRefreshingWithNoMoreData];
                }
            }
        

            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.tableView reloadData];
            });
            
        } @catch (NSException *exception) {
            [JFGSDK appendStringToLogFile:@"我的消息页面处理消息崩溃"];
        } @finally {
            
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
    
    
}


-(NSString *)bindAccountDealForAccount:(NSString *)account
{
    if ([account isEmail]) {
        NSRange range = [account rangeOfString:@"@"];
        if (range.location == 1) {
            return account;
        }else if (range.location == 2){
            return [account stringByReplacingCharactersInRange:NSMakeRange(1, 1) withString:@"*"];
        }else if (range.location == 3 || range.location == 4){
            return [account stringByReplacingCharactersInRange:NSMakeRange(1, 2) withString:@"**"];
        }else if (range.location > 4 && range.location <= 8){
            return [account stringByReplacingCharactersInRange:NSMakeRange(2, range.location-3) withString:@"***"];
        }else if (range.location > 8 && range.location <= 16){
            return [account stringByReplacingCharactersInRange:NSMakeRange(3, range.location-4) withString:@"****"];
        }else{
            return [account stringByReplacingCharactersInRange:NSMakeRange(4, range.location-8) withString:@"********"];
        }
    }else if ([account isMobileNumber]){
       // 185****6063
       return [account stringByReplacingCharactersInRange:NSMakeRange(3, 4) withString:@"****"];
    }else{
        if (account.length>8) {
            return [account stringByReplacingCharactersInRange:NSMakeRange(3, account.length-7) withString:@"****"];
        }else{
            return account;
        }
    }
    return account;
}


-(void)initView
{
    //添加编辑按钮
    _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _editBtn.frame = CGRectMake(self.topBarBgView.frame.size.width-65, 5+20, 50, 34);
    _editBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [_editBtn setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
    [_editBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
    _editBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.topBarBgView addSubview:_editBtn];
    [_editBtn addTarget:self action:@selector(clickEditBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    //底部编辑栏
    bottomBarView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 50)];
    bottomBarView.backgroundColor = [UIColor orangeColor];
    bottomBarView.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
    [self.view addSubview:bottomBarView];
    
    UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
    lineView.backgroundColor =[UIColor colorWithHexString:@"#dde0e5"];
    [bottomBarView addSubview:lineView];
    
    selectedAllBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    selectedAllBtn.frame = CGRectMake(30, 10, 50, 30);
    selectedAllBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [selectedAllBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
    selectedAllBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [selectedAllBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SELECT_ALL"] forState:UIControlStateNormal];
    [selectedAllBtn addTarget:self action:@selector(selectedAllAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:selectedAllBtn];
    
    
    deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    deleteBtn.frame = CGRectMake(self.view.bounds.size.width-80, 10, 50, 30);
    deleteBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [deleteBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
    deleteBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [deleteBtn setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(delAction) forControlEvents:UIControlEventTouchUpInside];
    [bottomBarView addSubview:deleteBtn];
    
}

-(void)addFooter
{
    self.tableView.estimatedRowHeight = 0;
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        
        if (self.dataArray.count && [LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            SysMsgModel *model = [self.dataArray lastObject];
            [self getDataByTime:model.timestamp*1000];
        }else{
            [self.tableView.mj_footer endRefreshing];
        }
    
    }];
    footer.automaticallyHidden = YES;
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"RELEASE_TO_LOAD"] forState:MJRefreshStatePulling];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"PULL_TO_LOAD"] forState:MJRefreshStateIdle];
    [footer setTitle:[JfgLanguage getLanTextStrByKey:@"LOADING"] forState:MJRefreshStateRefreshing];
    footer.automaticallyHidden = YES;
    self.tableView.mj_footer = footer;
}

#pragma mark- 删除
-(void)delAction
{
    //删除的操作
    //得到删除的商品索引
    
    //全选删除
//    if (_selectArray.count == self.dataArray.count) {
//        
//        [self.dataArray removeObjectsInArray:_selectArray];
//        [_selectArray removeAllObjects];
//        [self clickEditBtn:nil];
//        [self saveSysMsg:self.dataArray isDel:NO];
//        
//        DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
//        seg.msgId = 601;
//        seg.version = -1;
//    
////        DataPointIDVerSeg *seg2 = [[DataPointIDVerSeg alloc]init];
////        seg2.msgId = 701;
////        seg2.version = -1;
//        //网络正常直接删除
//        if ([JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
//            
//            [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:@"" queryDps:@[seg] success:^(NSString *identity, int ret) {
//                //NSLog(@"identity:%@  ret:%d",identity,ret);
//                
//                NSFileManager *fileManager = [NSFileManager defaultManager];
//                [fileManager removeItemAtPath:[self delCachePath] error:nil];
//                
//            } failure:^(RobotDataRequestErrorType type) {
//                
//            }];
//        }
//        
//        return;
//        
//    }
    
    [self deleteBindData:_selectArray];
    
    NSMutableArray *indexArray = [NSMutableArray array];
    for (id obj in _selectArray)
    {
        NSInteger num = [self.dataArray indexOfObject:obj];
        NSIndexPath *path = [NSIndexPath indexPathForRow:num inSection:0];
        [indexArray addObject:path];
    }
    
    //修改数据模型
    [self.dataArray removeObjectsInArray:_selectArray];
    [_selectArray removeAllObjects];
    
    //刷新
    [_tableView deleteRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationLeft];
    
    //重新缓存数据到本地
    [self saveSysMsg:self.dataArray isDel:NO];
}


/**
 *  server删除数据
 */
-(void)deleteBindData:(NSArray *)deleteData
{
    NSMutableArray *bindDeleteData = [[NSMutableArray alloc]init];
    for (SysMsgModel *model in deleteData) {
        
        //因为绑定消息与服务消息是不同接口
        if (model.msgType == SysMsgTypeBind) {
            
            DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
            seg.msgId = 601;
            seg.version = model.timestamp*1000;
            [bindDeleteData addObject:seg];
            
        }else{
            
//            DataPointIDVerSeg *seg = [[DataPointIDVerSeg alloc]init];
//            seg.msgId = 701;
//            seg.version = model.timestamp*1000;
//            [bindDeleteData addObject:seg];
        }
        
    }
    if (bindDeleteData.count) {
        
        //网络正常直接删除
        if ([JFGSDK currentNetworkStatus] != JFGNetTypeOffline) {
            
            [[JFGSDKDataPoint sharedClient] robotDelDataWithPeer:@"" queryDps:bindDeleteData success:^(NSString *identity, int ret) {
                //NSLog(@"identity:%@  ret:%d",identity,ret);
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:[self delCachePath] error:nil];
                if (isSelectedAll) {
                    self.tableView.mj_footer.hidden = YES;
                    [self clickEditBtn:_editBtn];
                }
                
            } failure:^(RobotDataRequestErrorType type) {
                
            }];
 
            
        }else{
            
            //无网络缓存本地
            [self saveSysMsg:deleteData isDel:YES];
        }
        
        
    }
    
}

-(void)selectedAllAction
{
    isSelectedAll = NO;
    //判断是全选还是取消全选
    for (SysMsgModel *model in self.dataArray) {
        if (model.isDelSelected == NO) {
            isSelectedAll = YES;
            break;
        }
    }
    
    //选择数据装入数组
    if (isSelectedAll) {
        _selectArray = [[NSMutableArray alloc]initWithArray:self.dataArray];
    }else{
        [_selectArray removeAllObjects];
    }
    
    //刷新界面
    for (SysMsgModel *model in self.dataArray) {
        
        model.isDelSelected = isSelectedAll;
    }
    [self.tableView reloadData];
}

#pragma mark 点击编辑按钮
- (void)clickEditBtn:(UIButton *)sender {
    
    if (isEditing) {
        
        for (SysMsgModel *model in self.dataArray) {
            model.isDelSelected = NO;
        }
        isEditing = NO;
        _editBtn.selected = NO;
        [self.tableView reloadData];
        
        CGRect _frame = self.tableView.frame;
        _frame.size.height = self.view.bounds.size.height-64;
        self.tableView.frame = _frame;
        
        CGRect frame = bottomBarView.frame;
        frame.origin.y = self.view.bounds.size.height;
        [UIView animateWithDuration:0.3 animations:^{
            
            bottomBarView.frame = frame;
            
        } completion:^(BOOL finished) {
            
            

        }];
        
       
        
        
    }else
    {
        //开始选择行
        [_selectArray removeAllObjects];
        
        isEditing = YES;
        _editBtn.selected = YES;
        [self.tableView reloadData];
        
        CGRect frame = bottomBarView.frame;
        frame.origin.y = self.view.bounds.size.height-50;
        [UIView animateWithDuration:0.3 animations:^{
            
            bottomBarView.frame = frame;
            
        } completion:^(BOOL finished) {
            
            CGRect _frame = self.tableView.frame;
            _frame.size.height = self.view.bounds.size.height-64-50;
            self.tableView.frame = _frame;
            
        }];
        
    }
    
}

#pragma mark- TableViewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.dataArray.count) {
        self.tableView.mj_footer.hidden = NO;
        return self.dataArray.count;
    }else{
        self.tableView.mj_footer.hidden = YES;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.dataArray.count > indexPath.row) {
        
        SysMsgModel *model = self.dataArray[indexPath.row];
        if (model.msgType == SysMsgTypeServer) {
            
            return model.cellHeight;
    
        }else{
            
            if (model.cellHeight <= 0) {
                CGFloat height = [SysMsgTableViewCell heightForRowWithString:model.msg].height;
                model.cellHeight = height;
            }
            if (model.cellHeight <= 0) {
                model.cellHeight = 0;
            }
            return model.cellHeight;
        }
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idForCell = @"sysMsgCellID";
    SysMsgTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idForCell];
    if (!cell) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"SysMsgTableViewCell" owner:self options:nil]lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        cell.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        cell.msgWebView.delegate = self;
    }
    SysMsgModel *model = self.dataArray[indexPath.row];
    cell.isEditing = isEditing;
    cell.msgWebView.indexPath = indexPath;
    if (model.msgType == SysMsgTypeServer) {
        cell.msgLabel.hidden = YES;
        cell.msgWebView.hidden = NO;
        cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_UserMessage_System"];
        [cell.msgWebView loadHTMLString:model.msg baseURL:[NSURL URLWithString:@""]];
        cell.msgBgViewRightConstraint.constant = 45;
    }else{
        cell.msgWebView.hidden = YES;
        cell.msgLabel.hidden = NO;
        cell.nameLabel.text = model.cid;
        cell.msgLabel.text = model.msg;
        CGSize msgTestSize = [SysMsgTableViewCell heightForRowWithString:model.msg];
        CGFloat right = self.view.bounds.size.width-(cell.msgLabel.frame.origin.x+msgTestSize.width);
        cell.msgBgViewRightConstraint.constant = right-15;
    }
    
    cell.timeLabel.text = [self transToHHmm:[NSString stringWithFormat:@"%lld",model.timestamp]];
    if (isEditing) {
        cell.isEditSelected = model.isDelSelected;
    }
    
    
    
    if ([model.cid isKindOfClass:[NSString class]]&& model.cid.length>4) {
        
        NSString *ps = [model.cid substringWithRange:NSMakeRange(0, 4)];
        if ([ps isEqualToString:@"5000"] || [ps isEqualToString:@"5100"] || [ps isEqualToString:@"6900"] || [ps isEqualToString:@"2101"] || [ps isEqualToString:@"2102"]) {
            //门铃
            cell.iconImageView.image = [UIImage imageNamed:@"ico_ring_disabled_sysMsg"];
            
        }else if([ps isEqualToString:@"6006"] || [ps isEqualToString:@"6007"] || [ps isEqualToString:@"6008"] ){
            //rs
            cell.iconImageView.image = [UIImage imageNamed:@"me_icon_ruishi_camera"];
        }else if([ps isEqualToString:@"2900"]){
            //720
            cell.iconImageView.image = [UIImage imageNamed:@"me_icon_720camera"];
        }else if([ps isEqualToString:@"6901"]){
            //猫眼
            cell.iconImageView.image = [UIImage imageNamed:@"me_icon_intelligent_eye"];
        }else{
            //摄像头
            cell.iconImageView.image = [UIImage imageNamed:@"image_jfg80_sysMsg"];
        }
    }else{
        
        cell.iconImageView.image = [UIImage imageNamed:@"image_jfg_ser_sysMsg"];
        
    }
    
    /*
     
     NSAttributedString * attrStr = [[NSAttributedString alloc]initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType} documentAttributes:nil error:nil];
     
     NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:10.0f]};
     CGSize size = [_xiangMuLabel.text boundingRectWithSize:CGSizeMake(_xiangMuLabel.frame.size.width, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
     
     */
    
    
    return cell;
}

-(NSString *)stringForTimeFromTimestamp:(int64_t)timestamp
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timestamp];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MM-dd HH:mm"];
    NSString *str = [dateFormatter stringFromDate:date];
    return str;
}

-(void)webViewDidFinishLoad:(UIWebView *)webView
{
    if ([webView isKindOfClass:[SysWebView class]]) {
        
        SysWebView *sysView = (SysWebView *)webView;
        NSIndexPath *indexPath = sysView.indexPath;
        if (self.dataArray.count > indexPath.row) {
            
            SysMsgModel *model = self.dataArray[indexPath.row];
            if (model.cellHeight <= 0) {
                //document.body.scrollHeight
                model.cellHeight = [[webView stringByEvaluatingJavaScriptFromString: @"document.body.scrollHeight"] floatValue] + 90;
                NSLog(@"time:%@ cellHeight:%f contentSize:%f",[self transToHHmm:[NSString stringWithFormat:@"%lld",model.timestamp]],model.cellHeight,webView.scrollView.contentSize.height);
                
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
            }
        }
        
    }
}

#pragma mark 选中行
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isEditing)
        return;
    
    SysMsgTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    SysMsgModel *model = [self.dataArray objectAtIndex:indexPath.row];
    model.isDelSelected = !model.isDelSelected;
    cell.isEditSelected = model.isDelSelected;
    
    if (_selectArray == nil) {
        _selectArray = [[NSMutableArray alloc]init];
    }
    
    if (model.isDelSelected) {
        if (![_selectArray containsObject:model]) {
            [_selectArray addObject:model];
        }
    }else{
        if ([_selectArray containsObject:model]) {
            [_selectArray removeObject:model];
            if (isSelectedAll) {
                isSelectedAll = NO;
            }
        }
    }
    
    
}

#pragma mark 返回编辑模式，默认为删除模式
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}



-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        
    }
    return _tableView;
}


-(NSArray *)dealForServerData:(NSArray *)sourceList
{
    NSMutableArray *resultArr = [NSMutableArray new];
    //获取本地无网络情况下已删除数据
    NSArray *delArr = [self cacheForIsDel:YES];
    if (delArr.count) {
        
        for (SysMsgModel *_model in sourceList)
        {
            BOOL isDel = NO;
            for (SysMsgModel *model in delArr)
            {
                if ([_model.cid isEqualToString:model.cid] && _model.timestamp == model.timestamp) {
                    isDel = YES;
                    break;
                }
            }
            if (isDel == NO) {
                [resultArr addObject:_model];
            }
        }
        
        //网络正常删除本地的缓存数据
        if ([JFGSDK currentNetworkStatus]!=JFGNetTypeOffline ) {
            [self deleteBindData:delArr];
        }
        
        
        
    }else{
        
        resultArr = [[NSMutableArray alloc]initWithArray:sourceList];
    }
    return resultArr;
}

#pragma mark- 缓存操作
-(void)saveSysMsg:(NSArray <SysMsgModel *> *)msgs isDel:(BOOL)del
{
    if (!msgs) {
        return;
    }
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc]initForWritingWithMutableData:data];
    [archiver encodeObject:msgs forKey:@"sysmsglist"];
    [archiver finishEncoding];
    
    if (del) {
        [data writeToFile:[self delCachePath] atomically:YES];
    }else{
        [data writeToFile:[self cachePath] atomically:YES];
    }
}

-(NSArray <SysMsgModel *>*)cacheForIsDel:(BOOL)isDel
{
    NSData *data;
    if (isDel) {
        data = [NSData dataWithContentsOfFile:[self delCachePath]];
    }else{
        data = [NSData dataWithContentsOfFile:[self cachePath]];
    }
    NSKeyedUnarchiver *unArchiver = [[NSKeyedUnarchiver alloc]initForReadingWithData:data];
    NSArray *arr = [unArchiver decodeObjectForKey:@"sysmsglist"];
    [unArchiver finishDecoding];
    return arr;
}


//系统消息本地缓存
-(NSString *)cachePath
{
    NSString *account;
    JFGSDKAcount *acc = [LoginManager sharedManager].accountCache;
    account = acc.account;
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:account];
    path = [path stringByAppendingPathComponent:@"sysMsg"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    path = [path stringByAppendingPathComponent:@"sysmessage.db"];
    return path;
}

//无网络情况下，删除的系统消息本地缓存
-(NSString *)delCachePath
{
    NSString *account ;
    JFGSDKAcount *acc = [LoginManager sharedManager].accountCache;
    account = acc.account;
    
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:account];
    path = [path stringByAppendingPathComponent:@"sysMsg"];
    path = [path stringByAppendingPathComponent:@"delsysmessage.db"];
    return path;
}

-(NSString *)transToHHmm:(NSString *)timsp{
    
    NSTimeInterval time=[timsp doubleValue];//如果不使用本地时区,因为时差问题要加8小时 == 28800 sec
    NSDate *detaildate=[NSDate dateWithTimeIntervalSince1970:time];
    
    //NSLog(@"%@",detaildate);
    
    NSCalendar * calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar]; // 指定日历的算法 NSCalendarIdentifierGregorian,NSGregorianCalendar
    // NSDateComponent 可以获得日期的详细信息，即日期的组成
    NSDateComponents *comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:[NSDate date]];
    NSInteger currentYear = comps.year;
    NSInteger currentMounth = comps.month;
    NSInteger currentday = comps.day;
    
    comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit|NSWeekCalendarUnit|NSWeekdayCalendarUnit fromDate:detaildate];
    NSInteger detailYear = comps.year;
    NSInteger detailMounth = comps.month;
    NSInteger detailDay = comps.day;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];//设置本地时区
    
    NSString *timsStr = @"";
    
    if (detailYear == currentYear &&
        detailMounth == currentMounth &&
        detailDay == currentday) {
        //同一天
        [dateFormatter setDateFormat:@"HH:mm"];
        NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
        timsStr = [NSString stringWithFormat:@"%@ %@",[JfgLanguage getLanTextStrByKey:@"DOOR_TODAY"],currentDateStr];
    }else{
        
        if (detailDay+1 == currentday) {
            //昨天
            [dateFormatter setDateFormat:@"HH:mm"];
            NSString *currentDateStr = [dateFormatter stringFromDate:detaildate];
            timsStr = [NSString stringWithFormat:@"%@ %@",[JfgLanguage getLanTextStrByKey:@"Yesterday"],currentDateStr];
            
        }else if(detailYear == currentYear){
            //今年
            [dateFormatter setDateFormat:@"MM.dd-HH:mm"];
            timsStr = [dateFormatter stringFromDate:detaildate];
            
        }else{
            [dateFormatter setDateFormat:@"yyyy.MM.dd-HH:mm"];
            timsStr = [dateFormatter stringFromDate:detaildate];
        }
        
        
    }
    
    //实例化一个NSDateFormatter对象
    
    //设定时间格式,这里可以设置成自己需要的格
    //NSString *currentDateStr = [dateFormatter stringFromDate: detaildate];
    //NSLog(@"%@",timsStr);
    return timsStr;
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


@implementation SysMsgModel

MJCodingImplementation

+ (NSArray *)mj_ignoredCodingPropertyNames
{
    return @[@"isDelSelected"];
}

@end
