//
//  ShareManagerVC.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareManagerVC.h"
#import "FriendsModel.h"
#import "JfgGlobal.h"
#import "ShareManagerCell.h"
#import "DJActionSheet.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKAcount.h>
#import "UIButton+Click.h"
#import "ProgressHUD.h"
#import "JfgLanguage.h"
#import "UIImageView+WebCache.h"
#import "CommonMethod.h"
#import "LoginManager.h"

@interface ShareManagerVC ()<UITableViewDelegate,UITableViewDataSource, JFGSDKCallbackDelegate>
@property (nonatomic, strong) UITableView * friendsTableView;
@property (nonatomic, strong) NSMutableArray *modelArray;
@property (nonatomic, strong)UIView * noDataView;
@end

@implementation ShareManagerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"EQUIPMENT_NAME"];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.modelArray = [NSMutableArray array];
    [self initView];
    self.titleLabel.text = self.devAlias;

}
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
    [JFGSDK getDeviceSharedListForCids:@[self.cid]];
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
}
-(void)initView{
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.friendsTableView];
    [self showViewRuler];
}
- (void)showViewRuler {
    if (self.modelArray.count == 0) {
        self.noDataView.hidden = NO;
        self.friendsTableView.hidden = YES;
    }else{
        self.noDataView.hidden = YES;
        self.friendsTableView.hidden = NO;
    }
}
#pragma mark - JFGSDKCallback
-(void)jfgDeviceShareList:(NSDictionary <NSString *,NSArray <JFGSDKFriendInfo *>*> *)friendList {
    //本vc只请求了一个cid
    if (friendList != nil) {
        if(self.modelArray.count > 0) {
            [self.modelArray removeAllObjects];
        }
        if (friendList.allKeys.count &&  [friendList.allKeys[0] isEqualToString:self.cid]) {

            [self.modelArray addObjectsFromArray:friendList.allValues[0]];
            [self showViewRuler];
            [self.friendsTableView reloadData];
        }

    }
}
-(void)jfgUnshareResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account {
    if (ret == 0) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"DELETED_SUC"]];
        [JFGSDK getDeviceSharedListForCids:@[self.cid]];
    } else {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tips_DeleteFail"]];
    }
}
#pragma mark - UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.modelArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    ShareManagerCell * cell = [tableView dequeueReusableCellWithIdentifier:@"sCell" forIndexPath:indexPath];
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = CellSelectedColor;
    
    if (self.modelArray.count>indexPath.row) {
        JFGSDKFriendInfo * fInfo = [self.modelArray objectAtIndex:indexPath.row];
        
        [CommonMethod setHeadImageForImageView:cell.headerImageView account:fInfo.account];
        
        if (fInfo.remarkName && ![fInfo.remarkName isEqualToString:@""]) {
            cell.nameLabel.text = fInfo.remarkName;
        }else{
            cell.nameLabel.text = fInfo.alias;
        }
        
        cell.phoneNumLabel.text = fInfo.account;
        [cell.cancelShareBtn addTarget:self action:@selector(buttonBackGroundHighlighted:) forControlEvents:UIControlEventTouchDown];
        [UIButton button:cell.cancelShareBtn touchUpInSideHander:^(UIButton *button) {
            
            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
                
                [CommonMethod showNetDisconnectAlert];
                return ;
            }
            
            [cell.cancelShareBtn setBackgroundColor:[UIColor clearColor]];
            
            [DJActionSheet showDJActionSheetWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_CancleShare"] buttonTitleArray:@[[JfgLanguage getLanTextStrByKey:@"DELETE"],[JfgLanguage getLanTextStrByKey:@"CANCEL"]] actionType:actionTypeDelete defaultIndex:0 didSelectedBlock:^(NSInteger index) {
                
                if (index == 0) {
                    [JFGSDK unShareDevice:self.cid forFriend:fInfo.account];
                }
                
                
            } didDismissBlock:^{
                
            }];
        }];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView * vi = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 42)];
    vi.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    UILabel * tip = [[UILabel alloc]initWithFrame:CGRectMake(15, vi.bottom-10-13, 200, 13)];
    tip.text = [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Shared"];
    tip.font = [UIFont systemFontOfSize:13];
    tip.textColor = [UIColor colorWithHexString:@"#666666"];
    [vi addSubview:tip];
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 41.5, self.view.width, 0.5)];
    line.backgroundColor = TableSeparatorColor;
    [vi addSubview:line];
    return vi;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42;
}
#pragma mark - buttonAction
-(void)leftButtonAction:(UIButton *)btn{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)buttonBackGroundHighlighted:(UIButton *)btn{
    [btn setBackgroundColor:[UIColor colorWithHexString:@"#e5f0f8"]];
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
-(UITableView *)friendsTableView{
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
        [_friendsTableView registerClass:[ShareManagerCell class] forCellReuseIdentifier:@"sCell"];
    }
    return _friendsTableView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
