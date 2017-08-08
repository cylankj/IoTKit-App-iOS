//
//  FriendsMainVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FriendsMainVC.h"
#import "AddFriendsVC.h"
#import "JfgGlobal.h"
#import "SetDeviceNameVC.h"
#import "FriendsInfoVC.h"
#import "FriendsMainCell.h"
#import "JfgTableViewCellKey.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKAcount.h>
#import "UIButton+Click.h"
#import "FriendsHeadView.h"
#import "JfgLanguage.h"
#import "UIImageView+WebCache.h"
#import "CommonMethod.h"
#import "LoginManager.h"
#import "ProgressHUD.h"
#import "FriendsInfoVC.h"
#import "UIAlertView+FLExtension.h"
#import "JfgCacheManager.h"
#import "LSAlertView.h"

typedef enum {
    dataTypeOnlyReq, //只有请求列表
    dataTypeOnlyFriends,//只有朋友列表
    dataTypeBoth,//两个列表都有
    dataTypeNone //两个都没有
}dataType;
@interface FriendsMainVC ()<JFGSDKCallbackDelegate, UITableViewDelegate, UITableViewDataSource>
{
    JFGSDKFriendRequestInfo * currentReqInfo;
    JFGSDKFriendInfo * currentFInfo;
}

@property (nonatomic) UITableView *friendsTableView;
/**
 *  数据源
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
@property (nonatomic, strong) NSMutableArray *friendList;
@property (nonatomic, strong) NSMutableArray *friendReqList;
@property (nonatomic ,assign) dataType dtype;
@property (nonatomic, strong)UIView * noDataView;
@end

@implementation FriendsMainVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.friendReqList = [NSMutableArray array];
    self.friendList = [NSMutableArray array];
    [self initView];
    [self initNavigationView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(delFriendNotification:) name:@"delFriendNotification" object:nil];
    [JFGSDK getFriendRequestList];
    [JFGSDK getFriendList];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    [JfgCacheManager cacheReadAddFriendReqList:self.friendReqList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)delFriendNotification:(NSNotification *)notifica
{
    [JFGSDK getFriendRequestList];
    [JFGSDK getFriendList];
}

- (void)judgeHaveData{
    if (self.dataArray.count==0) {
        self.noDataView.hidden = NO;
        self.friendsTableView.hidden = YES;
    }else{
        self.noDataView.hidden = YES;
        self.friendsTableView.hidden = NO;
    }
    [self.friendsTableView reloadData];
}
#pragma mark view
- (void)initView
{
    [self.view addSubview:self.friendsTableView];
    [self.view addSubview:self.noDataView];
    
}

- (void)initNavigationView
{
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_Friends"];
    
    self.rightButton.hidden = NO;
    [self setRightButtonImage:nil title:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd"] font:[UIFont systemFontOfSize:15.0]];
    [self.rightButton addTarget:self action:@selector(rightButtonAcion:) forControlEvents:UIControlEventTouchUpInside];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}


#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)rightButtonAcion:(UIButton *)sender
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        return;
    }
    AddFriendsVC *addFriends = [[AddFriendsVC alloc] init];
    addFriends.frindsArr = self.friendList;
    [self.navigationController pushViewController:addFriends animated:YES];
}

#pragma mark property
-(UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-157)/2.0, 0.20*kheight, 140.0, 140.0)];
        iconImageView.image = [UIImage imageNamed:@"png—unmanned"];
        iconImageView.x = self.view.width*0.5;
        _noDataView.hidden = YES;
        [_noDataView addSubview:iconImageView];
        
        UILabel * noShareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImageView.bottom+20, Kwidth, 15)];
        noShareLabel.font = [UIFont systemFontOfSize:15];
        noShareLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        noShareLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_NoneFriends"];
        noShareLabel.textAlignment = NSTextAlignmentCenter;
        noShareLabel.x = self.view.width*0.5;
        [_noDataView addSubview:noShareLabel];
    }
    return _noDataView;
}

-(UITableView *)friendsTableView
{
    if (_friendsTableView == nil)
    {
        CGFloat widgetX = 0;
        CGFloat widgetY = 64.0f;
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = kheight - widgetY;
        
        _friendsTableView = [[UITableView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight) style:UITableViewStyleGrouped];
        _friendsTableView.delegate = self;
        _friendsTableView.dataSource = self;
        _friendsTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    }
    return _friendsTableView;
}

-(NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _dataArray;
}
#pragma mark - 表格数据处理

- (dataType)judgeDataType {
    
    BOOL isHavReqList = NO;
    BOOL isHavFriendList = NO;
    for (NSArray *subArr in self.dataArray) {
        for (id obj in subArr) {
            if ([obj isKindOfClass:[JFGSDKFriendInfo class]]) {
                isHavFriendList = YES;
                break;
            }
            if ([obj isKindOfClass:[JFGSDKFriendRequestInfo class]]) {
                isHavReqList = YES;
            }
        }
    }
    
    if (isHavFriendList && isHavReqList) {
        self.dtype = dataTypeBoth;
    }else if (isHavReqList) {
        self.dtype = dataTypeOnlyReq;
    }else if (isHavFriendList) {
        self.dtype = dataTypeOnlyFriends;
    }else{
        self.dtype = dataTypeNone;
    }
    return self.dtype;
}


-(void)jfgFriendRequestList:(NSArray *)list error:(JFGErrorType)errorType
{
    self.friendReqList = [[NSMutableArray alloc]initWithArray:list];
    if (self.friendReqList.count) {
        if (self.dataArray.count>=2) {
            [self.dataArray replaceObjectAtIndex:0 withObject:self.friendReqList];
        }else{
            
            if (self.friendList.count) {
                [self.dataArray insertObject:self.friendReqList atIndex:0];
            }else{
                [self.dataArray removeAllObjects];
                [self.dataArray addObject:self.friendReqList];
            }
            
        }
    }else{
        for (NSArray *subArr in [self.dataArray copy]) {
            for (id obj in subArr) {
                if ([obj isKindOfClass:[JFGSDKFriendRequestInfo class]]) {
                    [self.dataArray removeObject:subArr];
                    break;
                }
            }
        }
    }
    
    //
    //[self judgeHaveData];
    //NSLog(@"好友请求列表：%@",list);
}

-(void)jfgFriendList:(NSArray *)list error:(JFGErrorType)errorType
{
    self.friendList = [[NSMutableArray alloc]initWithArray:list];
    if (self.friendList.count) {
        if (self.dataArray.count>=2) {
            [self.dataArray replaceObjectAtIndex:1 withObject:self.friendList];
        }else{
            if (self.friendReqList.count) {
                [self.dataArray addObject:self.friendList];
            }else{
                [self.dataArray removeAllObjects];
                [self.dataArray addObject:self.friendList];
            }
            
        }
    }else{
        for (NSArray *subArr in [self.dataArray copy]) {
            for (id obj in subArr) {
                if ([obj isKindOfClass:[JFGSDKFriendInfo class]]) {
                    [self.dataArray removeObject:subArr];
                    break;
                }
            }
        }
    }
    
    [self judgeHaveData];
    //NSLog(@"好友列表：%@",list);
}

-(void)jfgResultIsRelatedToFriendWithType:(JFGFriendResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGFriendResultTypeAgreeAddFriend){
        if (errorType == JFGErrorTypeNone) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Success"]];
            
            //[self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@"YES" afterDelay:1.0];
        }else if(errorType == JFGErrorTypeFriendAlready){
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Success"]];
            
            //[self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@"YES" afterDelay:1.0];
        }else if(errorType == JFGErrorTypeFriendInvalidRequest){
            
            [JFGSDK getFriendRequestList];
            [JFGSDK getFriendList];
            
            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_ExpiredTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"SEND"] CancelBlock:^{
                
            } OKBlock:^{
                
                FriendsInfoVC * infoVC = [FriendsInfoVC new];
                infoVC.nickNameLabel.text = currentReqInfo.account;
                infoVC.nameLabel.text = currentReqInfo.account;
                infoVC.friendsInfoType = FriendsInfoUnFiens;
                infoVC.isVerifyFriends = NO;
                infoVC.account = currentReqInfo.account;
                infoVC.nickNameString = currentReqInfo.account;
                [weakSelf.navigationController pushViewController:infoVC animated:YES];
                
            }];
            
            
        }else{
            
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RET_MSG_EUNKNOWN"]];
            
        }
    }
    
}

#pragma mark tableView Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *friendsIdentifier = @"friendsCell";
    FriendsMainCell *cell = [tableView dequeueReusableCellWithIdentifier:friendsIdentifier];
    NSArray *readAddFriendReqList = [JfgCacheManager getCacheReadAddFriendReqAccountList];
    if (!cell)
    {
        cell = [[FriendsMainCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:friendsIdentifier];
        cell.imageView.image = nil;
        cell.textLabel.text = nil;
        cell.detailTextLabel.text = nil;
        cell.headImageView.layer.masksToBounds = YES;
        cell.headImageView.layer.cornerRadius = 45*0.5;
    }
    switch ([self judgeDataType]) {
        case dataTypeBoth:{
            if (indexPath.section ==0) {
                JFGSDKFriendRequestInfo * reqInfo = [[self.dataArray objectAtIndex:0] objectAtIndex:indexPath.row];
                currentReqInfo = reqInfo;
                cell.cusTextLabel.text = reqInfo.alias;
                if ([reqInfo.alias isEqualToString:@""]) {
                    cell.cusTextLabel.text = reqInfo.account;
                }
                BOOL isNewMsg = YES;
                if (readAddFriendReqList.count) {
                    for (NSString *acc in readAddFriendReqList) {
                        if ([acc isEqualToString:reqInfo.account]) {
                            isNewMsg = NO;
                            break;
                        }
                    }
                }
                if (isNewMsg) {
                    cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
                }else{
                    cell.contentView.backgroundColor = [UIColor whiteColor];
                }
                cell.cusDetailTextLabel.text = reqInfo.additionMsg;
                
                if ([reqInfo.additionMsg isEqualToString:@""]) {
                    cell.cusDetailTextLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_RequestContents"],cell.cusTextLabel.text];
                }
                
                [UIButton button:cell.agreeButton touchUpInSideHander:^(UIButton *button) {
                    [JFGSDK agreeRequestForAddFriendByAccount:reqInfo.account];
                    [JFGSDK getFriendRequestList];
                    [JFGSDK getFriendList];
                }];
                
                cell.agreeButton.hidden = NO;
                [CommonMethod setHeadImageForImageView:cell.headImageView account:reqInfo.account];
                
            }else{
                
                JFGSDKFriendInfo * fInfo = [[self.dataArray objectAtIndex:1] objectAtIndex:indexPath.row];
                currentFInfo = fInfo;
                if (fInfo.remarkName && ![fInfo.remarkName isEqualToString:@""]) {
                    cell.cusTextLabel.text = fInfo.remarkName;
                }else{
                    cell.cusTextLabel.text = fInfo.alias;
                }
                cell.cusDetailTextLabel.text = fInfo.account;
                cell.agreeButton.hidden = YES;
                [CommonMethod setHeadImageForImageView:cell.headImageView account:fInfo.account];
    
            }
        }
            break;
        case dataTypeOnlyReq: {
            JFGSDKFriendRequestInfo * reqInfo = [[self.dataArray objectAtIndex:0] objectAtIndex:indexPath.row];
            currentReqInfo = reqInfo;
            cell.cusTextLabel.text = reqInfo.alias;
            if ([reqInfo.alias isEqualToString:@""]) {
                cell.cusTextLabel.text = reqInfo.account;
            }
            cell.cusDetailTextLabel.text = reqInfo.additionMsg;
            if ([reqInfo.additionMsg isEqualToString:@""]) {
                cell.cusDetailTextLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_RequestContents"],cell.cusTextLabel.text];
            }
            [UIButton button:cell.agreeButton touchUpInSideHander:^(UIButton *button) {
                [JFGSDK agreeRequestForAddFriendByAccount:reqInfo.account];
                [JFGSDK getFriendRequestList];
                [JFGSDK getFriendList];
            }];
            cell.agreeButton.hidden = NO;
            BOOL isNewMsg = YES;
            if (readAddFriendReqList.count) {
                for (NSString *acc in readAddFriendReqList) {
                    if ([acc isEqualToString:reqInfo.account]) {
                        isNewMsg = NO;
                        break;
                    }
                }
            }
            if (isNewMsg) {
                cell.contentView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
            }else{
                cell.contentView.backgroundColor = [UIColor whiteColor];
            }
            [CommonMethod setHeadImageForImageView:cell.headImageView account:reqInfo.account];
            
        }
            break;
        case dataTypeOnlyFriends: {
            JFGSDKFriendInfo * fInfo = [[self.dataArray objectAtIndex:0] objectAtIndex:indexPath.row];
            currentFInfo = fInfo;
            if (fInfo.remarkName && ![fInfo.remarkName isEqualToString:@""]) {
                cell.cusTextLabel.text = fInfo.remarkName;
            }else{
                cell.cusTextLabel.text = fInfo.alias;
            }
            cell.cusDetailTextLabel.text = fInfo.account;
            cell.agreeButton.hidden = YES;
            cell.headImageView.image = [UIImage imageNamed:@"friends_head"];
            [CommonMethod setHeadImageForImageView:cell.headImageView account:fInfo.account];
            
            //cell.headImageView.image = [UIImage imageNamed:@"friends_head"];
            
        }
            break;
        case dataTypeNone: {
            
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subArr = [self.dataArray objectAtIndex:section];
    return subArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.dataArray.count > 2) {
        return 2;
    }
    return self.dataArray.count;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSArray * headers = @[[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Request"],[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsList"]];
    
    switch ([self judgeDataType]) {
        case dataTypeBoth: {
            FriendsHeadView *headView =[[FriendsHeadView alloc] init];
            headView.headLabel.text = [headers objectAtIndex:section];
            return headView;
        }
            break;
        case dataTypeOnlyReq: {
            FriendsHeadView *headView =[[FriendsHeadView alloc] init];
            headView.headLabel.text = [headers objectAtIndex:0];
            return headView;
            
        }
            break;
        case dataTypeOnlyFriends: {
            FriendsHeadView *headView =[[FriendsHeadView alloc] init];
            headView.headLabel.text = [headers objectAtIndex:1];
            return headView;
            
        }
            break;
        case dataTypeNone: {
            return nil;
        }
            
            break;
            
        default:
            break;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 42.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendsInfoVC *friendsInfo = [FriendsInfoVC new];
    FriendsMainCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if (!cell.agreeButton.hidden) {
        //非好友
        JFGSDKFriendRequestInfo * reqInfo = [[self.dataArray objectAtIndex:0] objectAtIndex:indexPath.row];
        friendsInfo.friendsInfoType = FriendsInfoUnFiens;
        friendsInfo.reqMsg = reqInfo.additionMsg;
        //friendsInfo.reqMsg = @"我是达芬奇";
        friendsInfo.nickNameLabel.text = reqInfo.account;
        friendsInfo.nameLabel.text = reqInfo.alias;
        friendsInfo.isVerifyFriends = YES;
        friendsInfo.account = reqInfo.account;
        
    }else{
        JFGSDKFriendInfo * fInfo = [[self.dataArray objectAtIndex:indexPath.section]objectAtIndex:indexPath.row];
        friendsInfo.friendsInfoType = FriendsInfoIsFriens;
        friendsInfo.account = fInfo.account;
    }
    

    [self.navigationController pushViewController:friendsInfo animated:YES];
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch ([self judgeDataType]) {
        case dataTypeBoth:{
            if (indexPath.section ==0) {
                return YES;
                
            }else{
                
                return NO;
                
            }
        }
            break;
        case dataTypeOnlyReq: {
            return YES;
            
        }
            break;
        case dataTypeOnlyFriends: {
            return NO;
            
        }
            break;
        case dataTypeNone: {
            return NO;
        }
            break;
        default:
            break;
    }

    
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
       
#pragma mark- 滑动删除接口
        if([self judgeDataType] == dataTypeBoth || [self judgeDataType] == dataTypeOnlyReq){
            NSArray *arr = [self.dataArray objectAtIndex:0];
            if (indexPath.section == 0 && arr.count > indexPath.row) {
                JFGSDKFriendRequestInfo * reqInfo = arr[indexPath.row];
                [self.friendReqList removeObject:reqInfo];
                
                if (self.friendReqList.count>0) {
                     [self.friendsTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                }else{
                    [self.dataArray removeObject:self.friendReqList];
                    [self.friendsTableView reloadData];
                }
               
                [JFGSDK delAddRequestForFriendAccount:reqInfo.account];
                
            }
        }
        
        
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}

//- (void)friendsTableViewAgreeButton:(NSDictionary *)dataInfo
//{
//    SetDeviceNameVC *setDevice = [SetDeviceNameVC new];
//    setDevice.deviceNameVCType = DeviceNameVCTypeFriendsNickName;
//    setDevice.deviceName = @"多多";
//    [self.navigationController pushViewController:setDevice animated:YES];
//}
@end
