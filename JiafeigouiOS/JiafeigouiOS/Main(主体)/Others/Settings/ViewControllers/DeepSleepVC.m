//
//  DeepSleepVC.m
//  JiafeigouiOS
//
//  Created by yangli on 2017/8/23.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "DeepSleepVC.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "JfgLanguage.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "DeviceSettingCell.h"
#import "LSAlertView.h"
#import <JFGSDK/JFGSDK.h>
#import "DeepSleepHelpVC.h"

#define DOORBELLDEEPSLEEPSHOWNOTEKEY @"DOORBELLDEEPSLEEPSHOWNOTEKEY"

@interface DeepSleepVC ()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate>
{
    BOOL isOnline;//设备是否在线
}
@property (nonatomic,strong)UITableView *dTableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,assign)BOOL isOpen;
@property (nonatomic,assign)int64_t beginTime;
@property (nonatomic,assign)int64_t endTime;
@property (nonatomic,assign)int selectedRow;
@property (nonatomic,assign)int originSelectedRow;
@property (nonatomic,assign)CGFloat footerHeight;
@property (nonatomic,strong)UIView *footerView;
@property (nonatomic,strong)UIButton *rightBtn;
@property (nonatomic,assign)BOOL isShowNote;

@end

@implementation DeepSleepVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self getData];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_MODE"];
    [self.view addSubview:self.dTableView];
    [self.topBarBgView addSubview:self.rightBtn];
    [JFGSDK addDelegate:self];
    // Do any additional setup after loading the view.
}

-(void)jfgRobotSyncDataForPeer:(NSString *)peer fromDev:(BOOL)isDev msgList:(NSArray<DataPointSeg *> *)msgList
{
    
    if ([peer isEqualToString:self.cid]) {
        
        for (DataPointSeg *seg in msgList) {
            if (seg.msgId == 201) {
                
                id obj = [MPMessagePackReader readData:seg.value error:nil];
                if ([obj isKindOfClass:[NSArray class]]) {
                    int net = [obj[0] intValue];
                    if (net == 0 || net == -1) {
                        isOnline = NO;
                    }else{
                        isOnline = YES;
                        self.isShowNote = NO;
                        [self.dTableView reloadData];
                    }
                }
            }
        }
        
    }
}

-(void)getData
{
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@404,@201] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            for (DataPointSeg *seg in subArr) {
                
                id obj = [MPMessagePackReader readData:seg.value error:nil];
                if (seg.msgId == 201) {
                    
                    if ([obj isKindOfClass:[NSArray class]]) {
                        int net = [obj[0] intValue];
                        if (net == 0 || net == -1) {
                            isOnline = NO;
                        }else{
                            isOnline = YES;
                        }
                        if (self.isShowNote && isOnline) {
                            self.isShowNote = NO;
                        }
                        [weakSelf.dTableView reloadData];
                    }
                    
                }else if(seg.msgId == 404){
                    if ([obj isKindOfClass:[NSArray class]]) {
                        
                        /**
                         enbale bool 是否开启
                         beginTime int64 开始时间，单位秒
                         endTime int64 结束时间，单位秒
                         */
                        NSArray *sourceArr = obj;
                        if (sourceArr.count > 2) {
                            
                            self.isOpen = [sourceArr[0] boolValue];
                            self.beginTime = [sourceArr[1] longLongValue];
                            self.endTime = [sourceArr[2] longLongValue];
                            
                            if (self.isOpen) {
                                if (self.beginTime/60/60 >= 22 && self.endTime/60/60 <= 8) {
                                    self.selectedRow = 1;
                                }else{
                                    self.selectedRow = 0;
                                }
                            }else{
                                self.selectedRow = 2;
                            }
                            self.originSelectedRow = self.selectedRow;
                            [weakSelf.dTableView reloadData];
                            
                            
                        }
                        
                    }

                }
                
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}

-(void)setData
{
    if (self.originSelectedRow != self.selectedRow) {
        if (self.selectedRow == 0) {
            self.isOpen = YES;
            self.beginTime = 0;
            self.endTime = 86400;
        }else if(self.selectedRow == 1){
            self.isOpen = YES;
            self.beginTime = 22*60*60;
            self.endTime = 8*60*60;
        }else if (self.selectedRow == 2){
            self.isOpen = NO;
            self.beginTime = 0;
            self.endTime = 0;
        }
        DataPointSeg *seg = [[DataPointSeg alloc]init];
        seg.msgId = 404;
        seg.value = [MPMessagePackWriter writeObject:@[@(self.isOpen),@(self.beginTime),@(self.endTime)] error:nil];
        
        [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.cid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
            
        } failure:^(RobotDataRequestErrorType type) {
            
        }];
    }
}

-(void)rightAction
{
    DeepSleepHelpVC *helpVC = [DeepSleepHelpVC new];
    [self.navigationController pushViewController:helpVC animated:YES];
}

-(void)backAction
{
    [super backAction];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 21.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row != self.selectedRow) {
        
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectedRow inSection:0]];
        if (oldCell) {
            oldCell.accessoryType = UITableViewCellAccessoryNone;
        }
        UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
        currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"HH"];
        int hour = [[dateFormatter stringFromDate:[NSDate date]] intValue];
        //NSString *alert = @"";
        BOOL isShowAlert = NO;
        if (self.selectedRow == 0){
            //全天切其他 弹窗
            isShowAlert = YES;
        }else if (self.selectedRow == 1 && (hour>=22 || hour<=8)){
            //夜晚模式切其他 弹窗
            isShowAlert = YES;
        }else if ((self.selectedRow == 0 || self.selectedRow == 1) && indexPath.row == 2 && !isOnline){
            isShowAlert = YES;
        }
        self.isShowNote = isShowAlert;
//        if (indexPath.row == 0 || indexPath.row == 1) {
//            alert = ];
//        }else if(indexPath.row == 2){
//            alert = [JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_MODE_OFF_POP"];
//        }
        
        if (isShowAlert) {
            
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_MODE_POP"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
                
            } OKBlock:^{
                
            }];
            
        }
        self.selectedRow = (int)indexPath.row;
        [self setData];
        [self.dTableView reloadData];
    }
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDCell = @"deepsleepCellID";
    DeviceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (!cell) {
        cell = [[DeviceSettingCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDCell];
        cell.canClickCell = YES;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *noteView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 44)];
        noteView.backgroundColor = [UIColor clearColor];
        noteView.tag = 158888;
        noteView.hidden = YES;
        
        UIImageView *noteIcon = [[UIImageView alloc]initWithFrame:CGRectMake(0, 14, 19, 19)];
        noteIcon.image = [UIImage imageNamed:@"icon_prompt"];
        [noteView addSubview:noteIcon];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(noteIcon.right+6, 16, 50, 19)];
        label.font = [UIFont systemFontOfSize:13];
        label.textColor = [UIColor colorWithHexString:@"#999999"];
        label.text = [JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_CALL"];
        [label sizeToFit];
        [noteView addSubview:label];
        
        [cell.contentView addSubview:noteView];
        
    }
    cell.cusLabel.text = self.dataArray[indexPath.row];
    [cell.cusLabel sizeToFit];
    
    UIView *v = [cell.contentView viewWithTag:158888];
    v.left = cell.cusLabel.right + 14;
    v.width = self.view.width - v.left - 40;
    v.hidden = YES;
    
    cell.cusDetailLabel.text = @"";
    cell.cusImageVIew.image = nil;
    cell.settingSwitch.hidden = YES;
    cell.redDot.hidden = YES;
    if (self.selectedRow == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if (self.isShowNote) {
            v.hidden = NO;
        }
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    [cell layoutAgain];
    
    return cell;
}

-(UIView *)footerView
{
    if (!_footerView) {
        _footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 50)];
        _footerView.backgroundColor = [UIColor groupTableViewBackgroundColor];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 8, self.view.width-30, 30)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"#888888"];
        label.text = [JfgLanguage getLanTextStrByKey:@"ENERGY_SAVE_MODE_Description"];
        label.numberOfLines = 0;
        [label sizeToFit];
        _footerView.height = label.height + 16;
        self.footerHeight = _footerView.height;
        [_footerView addSubview:label];
    }
    return _footerView;
}

-(UITableView *)dTableView
{
    if (!_dTableView) {
        _dTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.height-64) style:UITableViewStyleGrouped];
        _dTableView.tableFooterView = self.footerView;
        _dTableView.delegate = self;
        _dTableView.dataSource = self;
        _dTableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _dTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
        _dTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, CGFLOAT_MIN)];
    }
    return _dTableView;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [[NSMutableArray alloc]initWithArray:@[[JfgLanguage getLanTextStrByKey:@"ALLDAY_OPEN"],[JfgLanguage getLanTextStrByKey:@"open_night"],[JfgLanguage getLanTextStrByKey:@"MAGNETISM_OFF"]]];
    }
    return _dataArray;
}

-(UIButton *)rightBtn
{
    if (!_rightBtn) {
        _rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightBtn.frame = CGRectMake(0, 30, 22, 22);
        _rightBtn.right = self.view.width - 15;
        [_rightBtn setImage:[UIImage imageNamed:@"icon_explain_white"] forState:UIControlStateNormal];
        [_rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightBtn;
}

-(BOOL)isShowNote
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:[NSString stringWithFormat:@"%@_%@",DOORBELLDEEPSLEEPSHOWNOTEKEY,self.cid]];
}

-(void)setIsShowNote:(BOOL)isShowNote
{
    [[NSUserDefaults standardUserDefaults] setBool:isShowNote forKey:[NSString stringWithFormat:@"%@_%@",DOORBELLDEEPSLEEPSHOWNOTEKEY,self.cid]];
}

-(void)dealloc
{
    [JFGSDK removeDelegate:self];
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
