//
//  ShareManagerMainVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/5/23.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "ShareManagerMainVC.h"
#import "UIColor+HexColor.h"
#import "LoginManager.h"
#import "CommonMethod.h"
#import "ShareRootViewController.h"
#import "ShareContentVC.h"
#import "JfgLanguage.h"
#import "JFGBoundDevicesMsg.h"
#import "LSAlertView.h"
#import "ChangePhoneViewController.h"
#import "SetDeviceNameVC.h"

@interface ShareManagerMainVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)UITableView *_tableView;
@property (nonatomic,strong)NSMutableArray *dataArray;

@property (nonatomic, assign) BOOL isBind720Camera;

@end

@implementation ShareManagerMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Sharing_Management"];
    [self.view addSubview:self._tableView];
    // Do any additional setup after loading the view.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cellIDForSVC";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-medium" size:16];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#383838"];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess){
        [CommonMethod showNetDisconnectAlert];
    }else{
        if (indexPath.row == 0) {
            
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            BOOL hasBindPhone = NO;
            BOOL hasBindEmail = NO;
            if ([account.phone isKindOfClass:[NSString class]] && ![account.phone isEqualToString:@""]) {
                hasBindPhone = YES;
            }
            if ([account.email isKindOfClass:[NSString class]] && ![account.email isEqualToString:@""]) {
                hasBindEmail = YES;
            }
            
            
            if (([LoginManager sharedManager].loginType != JFGSDKLoginTypeAccountLogin) && !hasBindPhone && !hasBindEmail) {
                
                __weak typeof(self) weakSelf = self;
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap3_Share_NoBindTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap2_Index_Open_NoDeviceOption"] CancelBlock:^{
                    
                } OKBlock:^{
                    if ([JfgLanguage languageType] == 0) {
                        ChangePhoneViewController * setNameVC = [ChangePhoneViewController new];
                        setNameVC.actionType = actionTypeBingPhone;
                        setNameVC.hidesBottomBarWhenPushed = YES;
                        [weakSelf.navigationController pushViewController:setNameVC animated:YES];
                    }else{
                        SetDeviceNameVC * emailVC = [SetDeviceNameVC new];
                        emailVC.jfgAccount = account;
                        emailVC.deviceNameVCType = DeviceNameVCTypeBindEmail;
                        [weakSelf.navigationController pushViewController:emailVC animated:YES];
                    }
                }];
                
            }else{
                ShareRootViewController *share = [ShareRootViewController new];
                share.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:share animated:YES];
            }
            
            
        }else{
            ShareContentVC *share = [ShareContentVC new];
            share.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:share animated:YES];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 62;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 18;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        
        if (self.isBind720Camera)
        {
            _dataArray = [[NSMutableArray alloc]initWithObjects:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice"],[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SharedContents"], nil];
        }
        else
        {
            _dataArray = [[NSMutableArray alloc]initWithObjects:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice"], nil];
        }
    }
    return _dataArray;
}

- (BOOL)isBind720Camera
{
    NSArray *cidlist = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
    
    for (JiafeigouDevStatuModel *model in cidlist)
    {
        switch ([model.pid intValue]) {
            case productType_720:
            case productType_720p:
            {
                return YES;
            }
                break;
                
            default:
                break;
        }
    }
    
    return NO;
}
-(UITableView *)_tableView
{
    if (__tableView == nil) {
        __tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
        __tableView.delegate = self;
        __tableView.dataSource = self;
        __tableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        __tableView.scrollEnabled = NO;
        [__tableView setTableFooterView:[UIView new]];
        [__tableView setSeparatorColor:[UIColor colorWithHexString:@"#e1e1e1"]];
    }
    return __tableView;
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
