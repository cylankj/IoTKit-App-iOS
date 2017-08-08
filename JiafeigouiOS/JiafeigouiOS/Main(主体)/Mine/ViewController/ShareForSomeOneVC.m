//
//  ShareForSomeOneVC.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareForSomeOneVC.h"
#import "ShareForFriendsCell.h"
#import "ShareDeviceModel.h"
#import "JfgGlobal.h"
#import "ProgressHUD.h"
#import "JiafeigouDevStatuModel.h"
#import "JFGBoundDevicesMsg.h"
#import "LoginManager.h"
#import "jiafeigouTableView+Data.h"
#import "CommonMethod.h"
#import "jfgConfigManager.h"


@implementation UserShareDeviceModel

@end

@interface ShareForSomeOneVC ()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate>
{
    NSInteger selectedResult;
    NSInteger selectedCount;
}
@property (nonatomic, strong) UITableView * friendsTableView;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, assign) NSInteger selectNum;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) NSArray *devList;
@end

@implementation ShareForSomeOneVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectNum = 0;
    self.titleLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_Share"],self.remarkName?self.remarkName:self.account];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.hidden = NO;
    self.selectedArray = [[NSMutableArray alloc]init];
    [self setLeftButtonImage:nil title:[JfgLanguage getLanTextStrByKey:@"CANCEL"] font:[UIFont systemFontOfSize:15]];
    [self setRightButtonTitle];
    
    [self.view addSubview:self.friendsTableView];
    
    NSMutableArray * list = [[JFGBoundDevicesMsg sharedDeciceMsg]getDevicesList];
    self.modelArray = [NSMutableArray new];
    
    for (JiafeigouDevStatuModel * m in list) {
        
        if (m.shareState != DevShareStatuOther && m.deviceType != JFGDeviceTypeDoorSensor) {
            
            UserShareDeviceModel *model = [[UserShareDeviceModel alloc]init];
            model.uuid = m.uuid;
            model.deviceType = m.deviceType;
            model.shareCount = m.shareCount;
            model._selected = NO;
            model.alias = m.alias;
            model.pid = m.pid;
            [self.modelArray addObject:model];
        }
        
    }
    
    [self getShareData];
    
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
}

-(void)getShareData
{
    NSMutableArray * cidsArr = [NSMutableArray new];
    //查询每个设备被分享了多少次,没办法,服务器不给接口
    for (int i = 0; i<self.modelArray.count; i++) {
        UserShareDeviceModel * m = [self.modelArray objectAtIndex:i];
        [cidsArr addObject:m.uuid];
    }
    [JFGSDK getDeviceSharedListForCids:cidsArr];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
   // [JFGSDK refreshDeviceList];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    [ProgressHUD dismiss];
}



#pragma mark - UITableVIewDelegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.modelArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ShareForFriendsCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fCell" forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = CellSelectedColor;
    
    UserShareDeviceModel *m = [self.modelArray objectAtIndex:indexPath.row];
    cell.nameLabel.text = m.alias;
    if (m._selected) {
        cell.selectButton.image = [UIImage imageNamed:@"camera_icon_Selected"] ;
    }else{
        cell.selectButton.image = [UIImage imageNamed:@"camera_icon_Select"] ;
    }
    
    UIImage * image = [UIImage imageNamed:@"add_icon_camera"];
    
    BOOL isFinished = NO;
    for (NSArray *subArr in self.devList) {
        for (AddDevConfigModel *model in subArr) {
            
            for (NSNumber *os in model.osList) {
                
                if ([os integerValue] == [m.pid integerValue]) {
                    image = [UIImage imageNamed:model.iconName];
                    isFinished = YES;
                    break;
                }
                
            }
            if (isFinished) {
                break;
            }
            
        }
        if (isFinished) {
            break;
        }
    }
    
    cell.iconImageView.image = image;
    cell.shareNumLabel.text = [NSString stringWithFormat:@"%ld/5",(long)m.tempShareCount];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ShareForFriendsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UserShareDeviceModel *m = [self.modelArray objectAtIndex:indexPath.row];
    //如果超过5个再选中，则不能再更多的操作
    if (m.shareCount >=5 && m._selected == NO) {
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Tips"]];
        return;
    }
    //将按钮标记选中是否状态
    cell.selectButton.isSelected = m._selected = !m._selected;
    if (cell.selectButton.isSelected) {
        cell.selectButton.image = [UIImage imageNamed:@"camera_icon_Selected"] ;
    }else{
        cell.selectButton.image = [UIImage imageNamed:@"camera_icon_Select"] ;
    }

    //遍历所有cell上的按钮
//    self.selectNum = 0;
//    for (int i=0; i<self.modelArray.count; i++) {
//        NSIndexPath * path = [NSIndexPath indexPathForRow:i inSection:0];
//        ShareForFriendsCell *cell1 = [tableView cellForRowAtIndexPath:path];
//        if (cell1.selectButton.isSelected) {
//            self.selectNum += 1;
//        }
//    }
    
    if (m._selected) {
        if (![self.selectedArray containsObject:m]) {
            [self.selectedArray addObject:m];
        }
    }else{
        [self.selectedArray removeObject:m];
    }
    
    //更新右上角的按钮
    [self setRightButtonTitle];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 42;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView * vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, 42)];
    vi.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    UILabel * label = [[UILabel alloc]initWithFrame:CGRectMake(15, 18, Kwidth-15, 13)];
    label.text = [JfgLanguage getLanTextStrByKey:@"Tap3_Friends_UserInfo_ShareDevice_Select"];
    label.font = [UIFont systemFontOfSize:13];
    label.textColor = [UIColor colorWithHexString:@"#666666"];
    [vi addSubview:label];
    return vi;
}
-(void)setRightButtonTitle{
    if (self.selectedArray.count == 0) {
        self.rightButton.enabled = NO;
        [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else{
        self.rightButton.enabled = YES;
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    [self setRightButtonImage:nil title:[JfgLanguage getLanTextStrByKey:@"OK"] font:[UIFont systemFontOfSize:15]];
}
#pragma mark - UIButtonAction
-(void)leftButtonAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightButtonAction:(UIButton *)btn
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        return;
        
    }
    NSMutableArray *cidList = [[NSMutableArray alloc]init];
    for (int i=0; i<self.selectedArray.count; i++) {
        UserShareDeviceModel * m =[self.selectedArray objectAtIndex:i];
        if (m._selected) {
            [cidList addObject:m.uuid];
        }
    }
    
    [JFGSDK shareDevices:@[self.account] toFriends:cidList];
    
    [ProgressHUD showProgress:nil];
    self.rightButton.enabled = NO;
    [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self performSelector:@selector(shareRequestTimeout) withObject:nil afterDelay:15];
}

-(void)shareRequestTimeout
{
    if (self.selectedArray.count == 0) {
        //全部成功
        //            [ProgressHUD dismiss];
        //            [JFGSDK getUnShareListByCid:self.cid];
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
        [self leftButtonAction:nil];
        //[self setRightButtonTitle];
        
    }else{
        
        [self getShareData];
        NSString *note =[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Friends_FailTips"],self.selectedArray.count];
        [ProgressHUD showText:note];
        self.rightButton.enabled = YES;
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma mark - JFGCallback
- (void)jfgShareResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account {
    //[ProgressHUD dismiss];
    
//    selectedResult ++;
//    if (ret == 0) {
//
//        for ( UserShareDeviceModel * m in [self.selectedArray copy]) {
//            
//            if ([cid isEqualToString:m.uuid]) {
//                
//                break;
//            }
//            
//        }
//    }
//    
//    if (selectedResult == selectedCount) {
//        
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shareRequestTimeout) object:nil];
//        if (self.selectedArray.count == 0) {
//            
//            
//            
//        }else{
//            
//            //[JFGSDK getUnShareListByCid:self.cid];
//            NSString *note =[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Friends_FailTips"],self.selectedArray.count];
//           
//        }
//        [self setRightButtonTitle];
//        [self.friendsTableView reloadData];
//        
//    }
    
}

-(void)jfgMultiShareDeviceResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shareRequestTimeout) object:nil];
    if (ret == 0) {
        
        for (int i=0; i<self.selectedArray.count; i++) {
            UserShareDeviceModel * m =[self.selectedArray objectAtIndex:i];
            for (UserShareDeviceModel * _m in [self.modelArray copy]){
                
                if ([_m.uuid isEqualToString:m.uuid]) {
                    [self.modelArray removeObject:_m];
                }
                
            }
        }
        [self.selectedArray removeAllObjects];
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
        //[self leftButtonAction:nil];
        //[self setRightButtonTitle];
        self.rightButton.enabled = YES;
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }else{
        [ProgressHUD showText:[CommonMethod languageKeyForShareDeviceErrorType:ret]];
        self.rightButton.enabled = YES;
    }
    [self setRightButtonTitle];
    [self.friendsTableView reloadData];
    
}

-(void)jfgDeviceShareList:(NSDictionary <NSString *,NSArray <JFGSDKFriendInfo *>*> *)friendList {
    
    for (UserShareDeviceModel * m in [self.modelArray copy]) {
        
        NSArray *shareListt = friendList[m.uuid];
        if (shareListt.count) {
            
            for (JFGSDKFriendInfo *info in shareListt) {
                
                if ([[info.account lowercaseString] isEqualToString:[self.account lowercaseString]]) {
                    [self.modelArray removeObject:m];
                    break;
                }
                
            }
            m.shareCount = shareListt.count;
            m.tempShareCount = m.shareCount;
            
        }else{
            
            m.shareCount = 0;
            m.tempShareCount = 0;
            
        }
        
    }
    [self.friendsTableView reloadData];
}


-(UITableView *)friendsTableView
{
    if (!_friendsTableView) {
        _friendsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _friendsTableView.delegate = self;
        _friendsTableView.dataSource = self;
        _friendsTableView.showsVerticalScrollIndicator = NO;
        _friendsTableView.showsHorizontalScrollIndicator = NO;
        [_friendsTableView setTableFooterView:[UIView new]];
        _friendsTableView.separatorColor = TableSeparatorColor;
        _friendsTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        [_friendsTableView setSeparatorInset:UIEdgeInsetsMake(0, 53, 0, 0)];
        [_friendsTableView registerClass:[ShareForFriendsCell class] forCellReuseIdentifier:@"fCell"];
    }
    return _friendsTableView;
}

-(NSArray *)devList
{
    if (!_devList) {
        _devList = [[NSArray alloc]initWithArray:[jfgConfigManager getAllDevModel]];
    }
    return _devList;
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
