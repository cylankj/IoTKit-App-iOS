//
//  FaceRecognitionSettingVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2018/1/26.
//  Copyright © 2018年 lirenguang. All rights reserved.
//

#import "FaceRecognitionSettingVC.h"
#import "DeviceSettingCell.h"
#import "JfgTableViewCellKey.h"
#import "JfgMsgDefine.h"
#import "DeviceInfoFootView.h"
#import "LoginManager.h"
#import "CommonMethod.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "UISwitch+Clicked.h"
#import "JFGDataPointValueAnalysis.h"
#import "JfgUserDefaultKey.h"
#import "ProgressHUD.h"

@interface FaceRecognitionSettingVC ()<UITableViewDelegate,UITableViewDataSource>
{
    BOOL isOpenUpladImage;
}
@property (strong, nonatomic) UITableView *faceSetTableView;
@property (strong, nonatomic) NSMutableArray *dataArray;

@end

@implementation FaceRecognitionSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self refreshLocalData];
    [self getUploadImageEable];
    [self initNavigation];
    [self initView];
    [self initViewLayout];
    // Do any additional setup after loading the view.
}

#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

-(void)setDataForOpen:(BOOL)isOpen
{
    DataPointSeg *seg = [DataPointSeg new];
    seg.msgId = 525;
    seg.value = [MPMessagePackWriter writeObject:@(isOpen) error:nil];
    
    [[JFGSDKDataPoint sharedClient] robotSetDataWithPeer:self.cid dps:@[seg] success:^(NSArray<DataPointIDVerRetSeg *> *dataList) {
        
        for (DataPointIDVerRetSeg *seg in dataList) {
            if (seg.ret == 0) {
                [ProgressHUD showSuccess:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
            }else{
                [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
    }];
}

-(void)refreshLocalData
{
    [self.dataArray removeAllObjects];
    //下载消息图片
    NSMutableDictionary *dict1 = [NSMutableDictionary new];
    [dict1 setObject:[JfgLanguage getLanTextStrByKey:@"DOWNLOAD_MSG_PICTURE"] forKey:cellTextKey];
    [dict1 setObject:idCellAbnormalRecord forKey:cellUniqueID];
    [dict1 setObject:@(isOpenUpladImage) forKey:isCellSwitchOn];
    [dict1 setObject:@(1) forKey:cellshowSwitchKey];
    [dict1 setObject:[JfgLanguage getLanTextStrByKey:@"DOWNLOAD_MSG_PICTURE_EXPLAIN"] forKey:cellFootViewTextKey];
    [dict1 setObject:@(UITableViewCellAccessoryNone) forKey:cellAccessoryKey];
    
    [self.dataArray addObject:@[dict1]];
}

#pragma mark tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"deviceAutoPhoto";
    
    NSDictionary *dataDict = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DeviceSettingCell *autoPhotocell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!autoPhotocell)
    {
        autoPhotocell = [[DeviceSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        autoPhotocell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    autoPhotocell.accessoryType = UITableViewCellAccessoryNone;
    autoPhotocell.cusLabel.text = [dataDict objectForKey:cellTextKey];
    autoPhotocell.cusDetailLabel.text = [dataDict objectForKey:cellDetailTextKey];
    autoPhotocell.settingSwitch.hidden = ![[dataDict objectForKey:cellshowSwitchKey] boolValue];
    autoPhotocell.redDot.hidden = ![[dataDict objectForKey:cellRedDotInRight] boolValue];
    autoPhotocell.settingSwitch.on = [[dataDict objectForKey:isCellSwitchOn] boolValue];
    
    __weak typeof(self) weakSelf = self;
    [autoPhotocell.settingSwitch addValueChangedBlockAcion:^(UISwitch *_switch) {
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess ) {
            [CommonMethod showNetDisconnectAlert];
            _switch.on = !_switch.on;
            return ;
        }else{
            
            [weakSelf setDataForOpen:_switch.on];
            isOpenUpladImage = _switch.on;
        }
    }];

    [autoPhotocell layoutAgain];
    return autoPhotocell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.dataArray objectAtIndex:section];
    return [arr count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        CGSize labelSize = CGSizeOfString([dataInfo objectForKey:cellFootViewTextKey], CGSizeMake(footLabelWidth, kheight), [UIFont systemFontOfSize:14.0f]);
        return labelSize.height + 8;
    }
    return 1.0f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        DeviceInfoFootView *footView =[[DeviceInfoFootView alloc] init];
        footView.footLabel.text = [dataInfo objectForKey:cellFootViewTextKey];
        return footView;
    }
    
    return nil;
}

- (void)initNavigation
{
    //顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"FACE_RECOGNITION"];
}

- (void)initView
{
    [self.view addSubview:self.faceSetTableView];
}

- (void)initViewLayout
{
    [self.faceSetTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).with.offset(64.0f);
        make.left.equalTo(self.view).with.offset(0);
        make.right.equalTo(self.view).with.offset(0);
        make.bottom.equalTo(self.view).with.offset(0);
    }];
}

#pragma mark data
-(void)getUploadImageEable
{
    __weak typeof(self) weakSelf = self;
    [[JFGSDKDataPoint sharedClient] robotGetSingleDataWithPeer:self.cid msgIds:@[@(525)] success:^(NSString *identity, NSArray<NSArray<DataPointSeg *> *> *idDataList) {
        
        for (NSArray *subArr in idDataList) {
            
            if (subArr.count == 0) {
                //如果数据为空，默认是打开
                isOpenUpladImage = YES;
                [weakSelf refreshLocalData];
                [weakSelf.faceSetTableView reloadData];
                
            }else{
                for (DataPointSeg *seg in subArr) {
                    
                    if (seg.msgId == 525) {
                        
                        id obj = [MPMessagePackReader readData:seg.value error:nil];
                        if ([obj isKindOfClass:[NSNumber class]]) {
                            isOpenUpladImage = [obj boolValue];
                            [weakSelf refreshLocalData];
                            [weakSelf.faceSetTableView reloadData];
                        }else if(obj == nil){
                            isOpenUpladImage = YES;
                            [weakSelf refreshLocalData];
                            [weakSelf.faceSetTableView reloadData];
                        }
                        
                    }
                }
            }
        }
        
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}


#pragma mark getter
- (UITableView *)faceSetTableView
{
    if (_faceSetTableView == nil)
    {
        _faceSetTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _faceSetTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _faceSetTableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _faceSetTableView.delegate = self;
        _faceSetTableView.dataSource = self;
    }
    
    return _faceSetTableView;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _dataArray;
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
