//
//  ShareWithFriendsVC.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareWithFriendsVC.h"
#import "JfgGlobal.h"
#import "FriendsCell.h"
#import "FriendsModel.h"
#import "ProgressHUD.h"
#import "UIImageView+WebCache.h"
#import "LSAlertView.h"
#import "CommonMethod.h"

@interface ShareWithFriendsVC ()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate>
{
    NSInteger alwarysNum;
    NSInteger selectedResult;
    NSInteger selectedCount;
}
@property (nonatomic, strong) UITableView * friendsTableView;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong) NSMutableArray *selectedArray;
@property (nonatomic, strong) UIView *noDataView;

@end

@implementation ShareWithFriendsVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.modelArray = [NSMutableArray array];

//    self.selectNum = 0;
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Friends"];
    self.modelArray = [NSMutableArray new];
    self.selectedArray = [NSMutableArray new];
    self.titleLabel.text = @"分享给亲友";
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.rightButton.hidden = NO;

    [self setLeftButtonImage:nil title:[JfgLanguage getLanTextStrByKey:@"CANCEL"] font:[UIFont systemFontOfSize:15]];
    [self setRightButtonTitle];
    
    [self.view addSubview:self.friendsTableView];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
    [JFGSDK getUnShareListByCid:self.cid];
    [JFGSDK getDeviceSharedListForCids:@[self.cid]];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    [ProgressHUD dismiss];
}
#pragma mark - JFGDelegate
-(void)jfgUnshareFriendListByCidResult:(JFGErrorType)errorType list:(NSArray <JFGSDKFriendInfo *>*)list
{
    if (list != nil) {
        
        self.modelArray = [NSMutableArray new];
        NSMutableArray *tempArr = [NSMutableArray new];
        for (JFGSDKFriendInfo *inf in list) {
            
            friendInfo *info = [[friendInfo alloc]init];
            info.info = inf;
            info.isSelected = NO;
            [self.modelArray addObject:info];
            
            if (self.selectedArray.count) {
                for (friendInfo *sinfo in self.selectedArray) {
                    if ([sinfo.info.account isEqualToString:inf.account]) {
                        info.isSelected = YES;
                        [tempArr addObject:info];
                        break;
                    }
                }
            }
        }
        self.selectedArray = [[NSMutableArray alloc]initWithArray:tempArr];
        [self.friendsTableView reloadData];
    }
}

-(void)jfgDeviceShareList:(NSDictionary<NSString *,NSArray<JFGSDKFriendInfo *> *> *)friendList
{
    for (NSString *cidKey in friendList) {
        
        if ([cidKey isEqualToString:self.cid]) {
            
            NSArray *friends = friendList[cidKey];
            alwarysNum = friends.count;
            [self setRightButtonTitle];
        }
        
    }
}

-(void)jfgMultiShareDeviceResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account
{
     [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shareRequestTimeout) object:nil];
    if (ret == 0) {
        [self.selectedArray removeAllObjects];
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
        [self leftButtonAction:nil];
        
    }else{
        
        [ProgressHUD showText:[CommonMethod languageKeyForShareDeviceErrorType:ret]];
        [JFGSDK getUnShareListByCid:self.cid];
        self.rightButton.enabled = YES;
        
    }
    [self setRightButtonTitle];
    [self.friendsTableView reloadData];
}

- (void)jfgShareResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account {
    
//    selectedResult ++;
//    if (ret != 0) {
//
//        
////        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
////        } OKBlock:^{
////            
////        }];
//        
//        
//    }else {
//
//        
//        for (friendInfo *info in [self.selectedArray copy]) {
//            
//            if ([account isEqualToString:info.info.account]) {
//                [self.selectedArray removeObject:info];
//                break;
//            }
//            
//        }
//        
//    }
//    
//    if (selectedResult == selectedCount) {
//        
//        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(shareRequestTimeout) object:nil];
//        if (self.selectedArray.count == 0) {
//
//            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
//            [self leftButtonAction:nil];
//            
//        }else{
//            
//            [JFGSDK getUnShareListByCid:self.cid];
//            NSString *note =[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Friends_FailTips"],self.selectedArray.count];
//            [ProgressHUD showText:note];
//            [self setRightButtonTitle];
//            self.rightButton.enabled = YES;
//        }
//        
//        
//    }
    
}
#pragma mark - UITableView
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.modelArray.count > 0) {
        self.noDataView.hidden = YES;
        [self.noDataView removeFromSuperview];
    }else{
        [self.view addSubview:self.noDataView];
        self.noDataView.hidden = NO;
    }
    return self.modelArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FriendsCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fCell" forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = CellSelectedColor;
    friendInfo * reqInfo = [self.modelArray objectAtIndex:indexPath.row];
    
    if (reqInfo.info.remarkName && ![reqInfo.info.remarkName isEqualToString:@""]) {
        cell.nameLabel.text = reqInfo.info.remarkName;
    }else{
        cell.nameLabel.text = reqInfo.info.alias;
    }
    
    cell.phoneNumLabel.text = reqInfo.info.account;
    
    if (reqInfo.isSelected) {
        cell.selectButton.image = [UIImage imageNamed:@"camera_icon_Selected"];
    }else{
        cell.selectButton.image = [UIImage imageNamed:@"camera_icon_Select"];
    }
    
    [CommonMethod setHeadImageForImageView:cell.headerImageView account:reqInfo.info.account];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    FriendsCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    friendInfo *info = [self.modelArray objectAtIndex:indexPath.row];
    if (self.selectedArray && self.selectedArray.count+alwarysNum >=5 && !info.isSelected) {
        [ProgressHUD showWarning:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Tips"]];
        return;
    }

    //将按钮标记选中是否状态
    info.isSelected = !info.isSelected;
    if (info.isSelected) {
        cell.selectButton.image = [UIImage imageNamed:@"camera_icon_Selected"];
    }else{
        cell.selectButton.image = [UIImage imageNamed:@"camera_icon_Select"];
    }
    
    if (info.isSelected) {
        if (![self.selectedArray containsObject:info]) {
            [self.selectedArray addObject:info];
        }
    }else{
        [self.selectedArray removeObject:info];
    }
    

    //更新右上角的按钮
    [self setRightButtonTitle];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.f;
}
-(void)setRightButtonTitle{
    if (self.selectedArray.count == 0) {
        self.rightButton.enabled = NO;
        [self.rightButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    }else{
        self.rightButton.enabled = YES;
        [self.rightButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

    [self setRightButtonImage:nil title:[NSString stringWithFormat:@"%@(%ld/5)",[JfgLanguage getLanTextStrByKey:@"FINISHED"],(long)(self.selectedArray.count+alwarysNum)] font:[UIFont systemFontOfSize:15]];

}
-(UITableView *)friendsTableView{
    if (!_friendsTableView) {
        _friendsTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _friendsTableView.delegate = self;
        _friendsTableView.dataSource = self;
        _friendsTableView.showsVerticalScrollIndicator = NO;
        _friendsTableView.showsHorizontalScrollIndicator = NO;
        [_friendsTableView setTableFooterView:[UIView new]];
        _friendsTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        _friendsTableView.separatorColor = TableSeparatorColor;
        _friendsTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        [_friendsTableView setSeparatorInset:UIEdgeInsetsMake(0, 53, 0, 0)];
        [_friendsTableView registerClass:[FriendsCell class] forCellReuseIdentifier:@"fCell"];
    }
    return _friendsTableView;
}

-(UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-157)/2.0, 0.20*kheight, 140.0, 140.0)];
        iconImageView.image = [UIImage imageNamed:@"png—unmanned"];
        iconImageView.x = self.view.width*0.5;
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

-(void)leftButtonAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)rightButtonAction:(UIButton *)btn
{
    NSMutableArray *accList = [NSMutableArray new];
    
    for (int i=0; i<self.selectedArray.count; i++) {
        friendInfo * reqInfo = [self.selectedArray objectAtIndex:i];
        if (reqInfo.isSelected) {
            [accList addObject:reqInfo.info.account];
        }
    }
    
    [JFGSDK shareDevices:accList toFriends:@[self.cid]];
    [ProgressHUD showProgress:nil];
    btn.enabled = NO;
    [self performSelector:@selector(shareRequestTimeout) withObject:nil afterDelay:35];
}

-(void)shareRequestTimeout
{
    [JFGSDK getUnShareListByCid:self.cid];
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"]];
    [self setRightButtonTitle];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end


@implementation friendInfo

@end
