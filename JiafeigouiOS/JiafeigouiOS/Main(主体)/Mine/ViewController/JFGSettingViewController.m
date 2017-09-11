//
//  JFGSettingViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/6/22.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "JFGSettingViewController.h"
#import "DeviceSettingCell.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "LoginManager.h"
#import <JFGSDK/JFGSDK.h>
#import "OemManager.h"
#import <SDImageCache.h>
#import "JfgConfig.h"
#import "LSAlertView.h"
#import "ChangePhoneViewController.h"
#import "SetDeviceNameVC.h"
#import "WebChatBindViewController.h"
#import "JFGEquipmentAuthority.h"
#import "AboutUsViewController.h"
#import "FLProressHUD.h"
#import "ProgressHUD.h"
#import "PhotoSelectionAlertView.h"
#import "LoginLoadingViewController.h"
#import "BaseNavgationViewController.h"
#import "JFGBoundDevicesMsg.h"

@interface JFGSettingViewController ()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate,PhotoSelectionAlertViewDelegate>
{
    JFGSDKAcount *currentAccount;
    NSString *fileSize;
}
@property (nonatomic,strong)UITableView *settingTableView;
@property (nonatomic,strong)NSMutableArray *dataArry;

@end

@implementation JFGSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.settingTableView];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SETTINGS"];
    JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
    currentAccount = account;
    [self refreshData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [JFGSDK addDelegate:self];
    [JFGSDK getAccount];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGIsAlwaysShowWebchatRedPointKey];
}

-(void)refreshData
{
    [self.dataArry removeAllObjects];

    //app接受消息通知
    JFGSettingModel *model1 = [JFGSettingModel new];
    model1.text = [JfgLanguage getLanTextStrByKey:@"PUSH_MSG"];
    model1.detailText = @"";
    model1.isShowSwitch = YES;
    model1.contentID = 0;
    BOOL isOpen = [[NSUserDefaults standardUserDefaults] boolForKey:@"JFGAccountIsOpnePush"];
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone == setting.types) {
        isOpen = NO;
    }
    model1.switchValue = isOpen;
    [self.dataArry addObject:@[model1]];
    
    
    //微信通知开关
    if ([OemManager oemType] == oemTypeCylan && [JfgLanguage languageType] == LANGUAGE_TYPE_CHINESE) {
        
        JFGSettingModel *model2 = [JFGSettingModel new];
        model2.text = [JfgLanguage getLanTextStrByKey:@"Alarm_WeChat"];
        model2.detailText = @"";
        model2.isShowSwitch = YES;
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"wx_push:%d",currentAccount.wx_push]];
        BOOL isOpen = YES;
        if (currentAccount.wxopenid && ![currentAccount.wxopenid isEqualToString:@""] && currentAccount.wx_push == 1) {
            isOpen = YES;
        }else{
            isOpen = NO;
        }
        model2.switchValue = isOpen;
        model2.contentID = 1;
        BOOL isWebChatRedPoint = [[NSUserDefaults standardUserDefaults] boolForKey:JFGIsAlwaysShowWebchatRedPointKey];
        model2.isShowRedPoint = !isWebChatRedPoint;
        
        
        if (isOpen) {
            JFGSettingModel *model3 = [JFGSettingModel new];
            model3.text = [JfgLanguage getLanTextStrByKey:@"Change_ID"];
            model3.detailText = @"";
            model3.isShowSwitch = NO;
            model3.contentID = 2;
            [self.dataArry addObject:@[model2,model3]];
        }else{
            [self.dataArry addObject:@[model2]];
        }
        
    }
    
    //清空消息缓存
    JFGSettingModel *model4 = [JFGSettingModel new];
    model4.text = [JfgLanguage getLanTextStrByKey:@"CLEAR_DATA"];
    model4.detailText = fileSize;
    model4.isShowSwitch = NO;
    model4.contentID = 3;
    [self.dataArry addObject:@[model4]];
    
    
    //关于
    BOOL showAbout = [[[OemManager getOemConfig:oemAboutKey] objectForKey:oemShowAboutKey] boolValue];
    if (showAbout)
    {
        JFGSettingModel *model5 = [JFGSettingModel new];
        model5.text = [JfgLanguage getLanTextStrByKey:@"ABOUT"];
        model5.detailText = fileSize;
        model5.isShowSwitch = NO;
        model5.contentID = 4;
        [self.dataArry addObject:@[model5]];
    }
    
    JFGSettingModel *model6 = [JFGSettingModel new];
    model6.text = @"";
    model6.detailText = @"";
    model6.isShowSwitch = NO;
    model6.contentID = 5;
    [self.dataArry addObject:@[model6]];
    
    [self updateCacheSize];
    [self.settingTableView reloadData];
}

//获取缓存图片大小
-(void)updateCacheSize
{
    __weak typeof(self) weakSelf = self;
    [[SDImageCache sharedImageCache] calculateSizeWithCompletionBlock:^(NSUInteger fileCount, NSUInteger  totalSize) {
        NSInteger diskSize = totalSize;
        NSString *cacheStr = [NSString stringWithFormat:@"%.1fM",diskSize/1024.0/1024.0];
        fileSize = cacheStr;
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.settingTableView reloadData];
        });
    }];
}

#pragma mark- jfgsdkDelegate
-(void)jfgUpdateAccount:(JFGSDKAcount *)account
{
    currentAccount = account;
    [self refreshData];
}

-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeUpdataAccount) {
        [JFGSDK getAccount];
    }
}

#pragma mark- actionSheetDelegate

-(void)actionSheet:(PhotoSelectionAlertView *)actionSheet mark:(NSString *)mark clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([mark isEqualToString:@"loginout"]) {
        
        if (buttonIndex == 0) {
            
            [[LoginManager sharedManager] loginOut];
            [[JFGBoundDevicesMsg sharedDeciceMsg] clearDeviceList];
            LoginLoadingViewController *lo = [LoginLoadingViewController new];
            BaseNavgationViewController * nav = [[BaseNavgationViewController alloc]initWithRootViewController:lo];
            UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
            keyWindows.rootViewController = nav;
            
        }
        
        return;
    }
}


#pragma mark- tableViewDelegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArry.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subArr = self.dataArry[section];
    return subArr.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierStr = @"settingCell";
    
    DeviceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    
    if (!cell)
    {
        cell = [[DeviceSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierStr];
        cell.detailTextLabel.text = nil;
        cell.canClickCell = YES;
        cell.cusDetailLabel.textColor =  [UIColor colorWithHexString:@"#888888"];
        [cell.settingSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    

    NSArray *subArr = self.dataArry[indexPath.section];
    JFGSettingModel *dataModel = subArr[indexPath.row];
    
    //文字显示
    cell.cusLabel.text = dataModel.text;
    cell.cusDetailLabel.text = @"";
    if (dataModel.contentID == 3) {
        cell.cusDetailLabel.text = fileSize;
    }
    
    //左侧图标
    cell.cusImageVIew.image = nil;
    
    //是否显示switch按钮
    if (dataModel.isShowSwitch) {
        cell.settingSwitch.hidden = NO;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.settingSwitch.on = dataModel.switchValue;
    }else{
        cell.settingSwitch.hidden = YES;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    cell.settingSwitch.indexPath = indexPath;
    
    //小红点
    cell.redDot.hidden = !dataModel.isShowRedPoint;
    
    //退出登录按钮
    UILabel *lb = [cell.contentView viewWithTag:12053];
    if (dataModel.contentID == 5) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        if (!lb) {
            UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = [JfgLanguage getLanTextStrByKey:@"LOGOUT"];
            titleLabel.font = [UIFont systemFontOfSize:16];
            titleLabel.textColor = [UIColor colorWithHexString:@"#ff3b30"];
            titleLabel.tag = 12053;
            [cell.contentView addSubview:titleLabel];
            lb = titleLabel;
        }
    }else{
        if (lb) {
            [lb removeFromSuperview];
        }
    }

    
    
    [cell layoutAgain];//这里调用用来掉整下cell的布局,因为有些是没有图片的
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSArray *subArr = self.dataArry[indexPath.section];
    JFGSettingModel *dataModel = subArr[indexPath.row];
    
    if (dataModel.contentID == 2) {
        
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"SETTINGS_Wechat_Switch_Open"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"SURE"] OtherButtonTitle:nil CancelBlock:^{
            
        } OKBlock:^{
            
        }];
        
    }else if (dataModel.contentID == 3){
        
        __weak typeof(self) weakSelf = self;
        [FLProressHUD showIndicatorViewFLHUDForStyleDarkWithView:self.view text:@"" position:FLProgressHUDPositionCenter];
        
        [[SDImageCache sharedImageCache] clearDiskOnCompletion:^{
            
            [FLProressHUD hideAllHUDForView:weakSelf.view animation:NO delay:0];
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Clear_Sdcard_tips3"]];
            [weakSelf performSelector:@selector(hideProgressHUD) withObject:nil afterDelay:1];
            [weakSelf refreshData];
            
        }];
        
    }else if (dataModel.contentID == 4){
        
        AboutUsViewController * aboutUs = [AboutUsViewController new];
        [self.navigationController pushViewController:aboutUs animated:YES];

    }else if (dataModel.contentID == 5){
        
        PhotoSelectionAlertView *actionSheet = [[PhotoSelectionAlertView alloc]initWithMark:@"loginout" delegate:self otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"LOGOUT"],[JfgLanguage getLanTextStrByKey:@"CANCEL"],nil];
        [actionSheet show];
        
    }
    
}

-(void)switchAction:(JFGSettingSwitch *)sender
{
    BOOL setPush = sender.on;
    
    NSArray *subArr = self.dataArry[sender.indexPath.section];
    JFGSettingModel *dataModel = subArr[sender.indexPath.row];
    
    if (dataModel.contentID == 0) {
        //开启app推送
        if (setPush) {
            
            if ([JFGEquipmentAuthority canNotificationPermission]) {
                //_switch.on = YES;
                [JFGSDK isOpenPush:YES];
                [[NSUserDefaults standardUserDefaults] setBool:setPush forKey:@"JFGAccountIsOpnePush"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
        }else{
            
            [JFGSDK isOpenPush:NO];
            [[NSUserDefaults standardUserDefaults] setBool:setPush forKey:@"JFGAccountIsOpnePush"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        }
    }else if (dataModel.contentID == 1){
        //开启微信推送
        JFGSDKAcount *account = currentAccount;
        if (setPush) {
            
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
                [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Alarm_WeChat_NoBindTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap2_Index_Open_NoDeviceOption"] CancelBlock:^{
                    
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
                
                if (account.wxopenid && ![account.wxopenid isEqualToString:@""]) {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:JFGIsAlwaysShowWebchatRedPointKey];
                    [JFGSDK resetAccountForWxpush:1];
                    account.wx_push = 1;
                    
                }else{
                    //未绑定微信号
                    WebChatBindViewController *webCat = [WebChatBindViewController new];
                    [self.navigationController pushViewController:webCat animated:YES];
                }
                
            }
            
        }else{
            
            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"SETTINGS_Wechat_Switch_Cancel"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"MAGNETISM_OFF"] CancelBlock:^{
                
            } OKBlock:^{
                [JFGSDK resetAccountForWxpush:0];
                account.wx_push = 0;
                [weakSelf refreshData];
            }];
            
        }
    }
    [self refreshData];
}


-(void)hideProgressHUD
{
    [ProgressHUD dismiss];
}

-(NSMutableArray *)dataArry
{
    if (!_dataArry) {
        _dataArry = [NSMutableArray new];
    }
    return _dataArry;
}

-(UITableView *)settingTableView
{
    if (!_settingTableView) {
        _settingTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStyleGrouped];
        _settingTableView.tableFooterView = [UIView new];
        _settingTableView.delegate = self;
        _settingTableView.dataSource = self;
        _settingTableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, CGFLOAT_MIN)];
        _settingTableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _settingTableView.separatorInset = UIEdgeInsetsMake(0, 15, 0, 0);
    }
    return _settingTableView;
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

@implementation JFGSettingModel

@end
