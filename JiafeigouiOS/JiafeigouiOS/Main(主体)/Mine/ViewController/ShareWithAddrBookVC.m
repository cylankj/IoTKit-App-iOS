//
//  ShareWithAddrBookVC.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareWithAddrBookVC.h"
#import "JfgGlobal.h"
#import "ContactModel.h"
#import "ContactCell.h"
#import "NSString+Validate.h"
#import "CommonMethod.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKAcount.h>
#import "UIButton+Click.h"
#import "ProgressHUD.h"
#import <MessageUI/MessageUI.h>
#import "LSAlertView.h"
#import "UIAlertView+FLExtension.h"
#import "BMChineseSort.h"
#import "FriendsInfoVC.h"
#import "SetDeviceNameVC.h"
#import "LoginManager.h"
#import "OemManager.h"

#define APPDOWNLOADURLSTR @" http://www.jfgou.com/app/download.html "

@interface ShareWithAddrBookVC ()<UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource,UISearchDisplayDelegate,JFGSDKCallbackDelegate,MFMessageComposeViewControllerDelegate,MFMailComposeViewControllerDelegate,UIAlertViewDelegate>
{
    NSString *currentAccount;
    NSMutableArray *sectionIndexArr;
}
@property(nonatomic, strong)UISearchBar * searchBar;

@property(nonatomic, strong)UITableView * contactTableView;
//联系人，指通讯录中的
@property(nonatomic, strong)NSMutableArray * contactArray;
//朋友，指服务器下发的加菲狗好友
@property(nonatomic, strong)NSMutableArray * friendsArray;

@property (nonatomic,strong)NSMutableArray *myFriedsArr;
//搜索结果
@property(nonatomic, strong)NSMutableArray * searchArray;
//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

//ios 8.0废除的
@property(nonatomic, strong)UISearchDisplayController * searchDisplayController;

@end

@implementation ShareWithAddrBookVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    self.contactArray = [NSMutableArray array];
    [self.view addSubview:self.searchBar];
    [self.view addSubview:self.contactTableView];
    _searchDisplayController = [[UISearchDisplayController alloc]initWithSearchBar:self.searchBar contentsController:self];
    _searchDisplayController.delegate = self;
    _searchDisplayController.searchResultsDelegate = self;
    _searchDisplayController.searchResultsDataSource = self;
    [_searchDisplayController.searchResultsTableView registerClass:[ContactCell class] forCellReuseIdentifier:@"cCell"];
    [self.searchDisplayController.searchResultsTableView setTableFooterView:[UIView new]];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Contacts"];
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];

    self.friendsArray = [NSMutableArray array];
    self.contactArray = [NSMutableArray array];
    self.searchArray = [NSMutableArray array];
  
    //加载通讯录
    [self loadPerson];
    
    [self.contactTableView reloadData];
    
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [JFGSDK addDelegate:self];
    if (self.vcType == VCTypeShareDeviceFromAddrBook) {
        //获取设备已分享列表
        if (!self.deviceShareList.count) {
            [JFGSDK getDeviceSharedListForCids:@[self.cid]];
        }else{
            self.friendsArray = [[NSMutableArray alloc]initWithArray:self.deviceShareList];
        }
        
    }else{
        //获取好友列表
        [JFGSDK getFriendList];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    
}
-(void)leftButtonAction:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - JFGSDKCallBack

-(void)jfgAccountOnline:(BOOL)online
{
    if (online) {
        if (self.vcType == VCTypeShareDeviceFromAddrBook) {
            //获取设备已分享列表
            [JFGSDK getDeviceSharedListForCids:@[self.cid]];
        }else{
            //获取好友列表
            [JFGSDK getFriendList];
        }
    }
}

//设备分享列表
-(void)jfgDeviceShareList:(NSDictionary <NSString *,NSArray <JFGSDKFriendInfo *>*> *)friendList{
    if (friendList != nil) {
        
        if(self.friendsArray.count > 0) {
            [self.friendsArray removeAllObjects];
        }
 
        if (friendList.count!=0) {
            if ([friendList.allKeys[0] isEqualToString:self.cid]) {
                [self.friendsArray addObjectsFromArray:friendList.allValues[0]];
                //对比数据
                [self compareContactsIfShared];
                [self.contactTableView reloadData];
            }
        }
        
        
    }
}

//账号是否注册，是否是好友
-(void)jfgCheckAccount:(NSString *)account alias:(NSString *)alias isExist:(BOOL)isExist errorType:(JFGErrorType)errorType
{
    [ProgressHUD dismiss];
    if (self.vcType == VCTypeAddFriendFromAddrBook) {
        [ProgressHUD dismiss];
        if (isExist) {
            //是好友
            FriendsInfoVC * infoVC = [FriendsInfoVC new];
            infoVC.nickNameLabel.text = account;
            infoVC.nameLabel.text = alias;
            infoVC.friendsInfoType = FriendsInfoIsFriens;
            infoVC.isVerifyFriends = NO;
            infoVC.account = account;
            infoVC.nickNameString = alias;
            [self.navigationController pushViewController:infoVC animated:YES];
        }else{
            //非好友
            if (errorType == 240) {
                
                //未注册
                [self sendEmailOrSMS];
               
            }else{
                //已注册
                SetDeviceNameVC *setWifiPass = [[SetDeviceNameVC alloc] init];
                setWifiPass.deviceNameVCType = DeviceNameVCTypeSetHelloWorld;
                JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
                setWifiPass.cid = currentAccount;
                setWifiPass.deviceName = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_StuffContents"],account.alias];;
                [self.navigationController pushViewController:setWifiPass animated:YES];
            }
            
        }
    }else{
        
        
        if (errorType == 0) {
            
            currentAccount = account;
            
            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
            } OKBlock:^{
                
                [ProgressHUD showProgress:nil];
                [JFGSDK shareDevice:weakSelf.cid toFriend:currentAccount];
                
            }];
            
            for (ContactModel *model in self.contactArray) {
                if ([model.phoneNum isEqualToString:account] || [model.email isEqualToString:account]) {
                    model.isRegiter = YES;
                    break;
                }
            }
            
        }else{
            
            [self sendEmailOrSMS];
        }
        
    }
    
   

        
}
    
-(void)sendEmailOrSMS
{
    if ([self isPhone:currentAccount]) {
        //调用短信界面
        //首先判断当前设备是否可以发送短信
        if([MFMessageComposeViewController canSendText])
        {
            @try {
                
                MFMessageComposeViewController *mc=[[MFMessageComposeViewController alloc] init];
                
                //设置委托
                mc.messageComposeDelegate=self;
                
                NSDictionary *dict = [OemManager getOemConfig:oemRecommendKey];
                //短信内容
                NSString *downUrl = [dict objectForKey:oemRecommendUrl];
//                if ([OemManager oemType] == oemTypeDoby) {
//                    downUrl = [dict objectForKey:oemRecommendDobyUrl];
//                }
                NSString *body = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_share_tips"],downUrl,[OemManager appName]];
                //短信内容
                mc.body = body;
                //设置短信收件方
                mc.recipients=[NSArray arrayWithObject:currentAccount];
                
                [self presentViewController:mc animated:YES completion:nil];
                
            } @catch (NSException *exception) {
                
            } @finally {
                
            }
           
        }else{
            
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"RET_ESEND_SMS"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"SURE"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
            
        }
    } else {
        //调用邮箱界面
        if ([MFMailComposeViewController canSendMail]) {
            MFMailComposeViewController * mc = [[MFMailComposeViewController alloc]init];
            mc.mailComposeDelegate = self;
            //标题
            //                [mc setSubject:@"加菲狗"];
            //发送给谁
            [mc setToRecipients:@[currentAccount]];
            
            NSDictionary *dict = [OemManager getOemConfig:oemRecommendKey];
            //短信内容
            NSString *downUrl = [dict objectForKey:oemRecommendUrl];
//            if ([OemManager oemType] == oemTypeDoby) {
//                downUrl = [dict objectForKey:oemRecommendDobyUrl];
//            }
            //else if([OemManager oemType] == oemTypeCylan){
//
//            }else{
//                downUrl = [dict objectForKey:oemRecommendCellCUrl];
//            }
            NSString *body = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_share_tips"],downUrl,[OemManager appName]];
            
            [mc setMessageBody:body isHTML:NO];
            [self presentViewController:mc animated:YES completion:nil];
            
        } else {
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_Contacts_Feedback"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"SURE"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
        }
    }
}


- (void)jfgShareResult:(JFGErrorType)ret device:(NSString *)cid forAccount:(NSString *)account {
    if (ret == 0) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
        [JFGSDK getDeviceSharedListForCids:@[self.cid]];
    } else {
        [ProgressHUD showText:[CommonMethod languageKeyForShareDeviceErrorType:ret]];
    }
}


-(void)jfgFriendList:(NSArray *)list error:(JFGErrorType)errorType
{
    self.myFriedsArr = [[NSMutableArray alloc]initWithArray:list];
    for (JFGSDKFriendInfo *info in list) {
        for (int j = 0; j<self.contactArray.count; j++) {
            ContactModel * model2 = [self.contactArray objectAtIndex:j];
            if ([info.account isEqualToString: model2.phoneNum]) {
                model2.isShared = YES;
                break;
            }
        }
    }
    [self.contactTableView reloadData];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 15263 && buttonIndex == 1) {
        [ProgressHUD showProgress:nil];
        [JFGSDK shareDevice:self.cid toFriend:currentAccount];
    }
}

#pragma mark -UITableViewDataSource
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return @"";
    }else{
        return [self.indexArray objectAtIndex:section];
    }
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }else{
        return [self.indexArray count];
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchArray.count;
    }else{
        NSArray *arr = [self.letterResultArr objectAtIndex:section];
        return [arr count];
    }
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *iDForCell = @"cCell";
    ContactCell *cell =[tableView dequeueReusableCellWithIdentifier:iDForCell];
    //dequeueReusableCellWithIdentifier
    //dequeueReusableCellWithIdentifier
    if (cell == nil) {
        cell = [[ContactCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iDForCell];
        
    }
    
    ContactModel * model;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        model = [self.searchArray objectAtIndex:indexPath.row];
        cell.shareButton.isSearchBar = YES;
    }else{
        model =[[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.shareButton.isSearchBar = NO;
    }
    cell.nameLabel.text = model.name;
    cell.phoneLabel.text = model.phoneNum;
    cell.shareButton._indexPath = indexPath;
    [cell.shareButton removeTarget:self action:@selector(shareBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    if (model.isShared == NO) {
       
        [cell.shareButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        cell.shareButton.layer.cornerRadius = 4;
        cell.shareButton.layer.borderWidth = 0.5;
        [cell.shareButton.layer setBorderColor:[UIColor colorWithHexString:@"#4b9fd5"].CGColor];
        [cell.shareButton addTarget:self action:@selector(shareBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        if (self.vcType == VCTypeShareDeviceFromAddrBook) {
             [cell.shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Button"] forState:UIControlStateNormal];
        }else{
             [cell.shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Button_Add"] forState:UIControlStateNormal];
        }
        
    }else{
        [cell.shareButton setTitleColor:[UIColor colorWithHexString:@"#888888"] forState:UIControlStateNormal];
        cell.shareButton.layer.borderWidth = 0;
        cell.shareButton.enabled = NO;
        if (self.vcType == VCTypeShareDeviceFromAddrBook) {
             [cell.shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Shared"] forState:UIControlStateNormal];
        }else{
             [cell.shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_Added"] forState:UIControlStateNormal];
        }
        
    }
    return cell;
}

-(void)shareBtnAction:(ContactBtn *)btn
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        return;
    }
    
    ContactModel * model;
    if (btn.isSearchBar) {
        model = [self.searchArray objectAtIndex:btn._indexPath.row];
    }else{
        model =[[self.letterResultArr objectAtIndex:btn._indexPath.section] objectAtIndex:btn._indexPath.row];
    }
    currentAccount = [CommonMethod formatPhoneNum:model.phoneNum];
    currentAccount = [currentAccount stringByReplacingOccurrencesOfString:@"-" withString:@""];
    JFGSDKAcount *acc = [LoginManager sharedManager].accountCache;
    if ([acc.account isEqualToString:currentAccount] || [acc.phone isEqualToString:currentAccount] || [acc.email isEqualToString:currentAccount]) {
        
        if (self.vcType == VCTypeShareDeviceFromAddrBook) {
            [ProgressHUD showText:[CommonMethod languageKeyForShareDeviceErrorType:JFGErrorTypeShareToSelf]];
        }else{
            [ProgressHUD showText:[CommonMethod languageKeyForAddFriendErrorType:JFGErrorTypeFriendToSelf]];
        }
        return;
    }
    
    if (self.vcType == VCTypeShareDeviceFromAddrBook) {
        if (model.isRegiter) {
            currentAccount = model.phoneNum;
            
            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
            } OKBlock:^{
                
                [ProgressHUD showProgress:nil];
                [JFGSDK shareDevice:weakSelf.cid toFriend:currentAccount];
                
            }];
            
        }else{
            [ProgressHUD showProgress:nil];
            [JFGSDK checkFriendIsExistWithAccount:currentAccount];
        }

    }else{
        
        [JFGSDK checkFriendIsExistWithAccount:currentAccount];
        [ProgressHUD showProgress:nil];
    }
    
}
#pragma mark -UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0;
}
-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if ([tableView respondsToSelector:@selector(setSeparatorInset:)]) {
//        [tableView setSeparatorInset:UIEdgeInsetsZero];
//    }
//    
//    if ([tableView respondsToSelector:@selector(setLayoutMargins:)]) {
//        [tableView setLayoutMargins:UIEdgeInsetsZero];
//    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark- 索引相关
//section右侧index数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    return self.indexArray;
}
//点击右侧索引表项时调用 索引与section的对应关系
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index{
    return index;
}

#pragma mark UIMessage delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_MessageCancel"]];
            JFGLog(@"Result: SMS sending canceled");
            break;
        case MessageComposeResultSent:
            [ProgressHUD showText:@"发送短信成功"];
            JFGLog(@"Result: SMS sent");
            break;
        case MessageComposeResultFailed:
            [ProgressHUD showText:@"发短信失败"];
            break;
        default:
            JFGLog(@"Result: SMS not sent");
            break;
    }
    sleep(1.0);
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark UIMail delegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(nullable NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            [ProgressHUD showText:@"发送邮件取消"];
            JFGLog(@"Result: mail sent canceled");
            break;
        case MFMailComposeResultSaved:
            [ProgressHUD showText:@"邮件已保存到草稿箱"];
            JFGLog(@"Result: mail saved");
            break;
        case MFMailComposeResultSent:
            [ProgressHUD showText:@"发送邮件成功"];
            JFGLog(@"Result: mail sent success");
            break;
        case MFMailComposeResultFailed:
            [ProgressHUD showText:@"发送邮件失败"];
            JFGLog(@"Result: mail sent failed");
            break;
            
        default:
            break;
    }
    sleep(1.0);
    [self dismissViewControllerAnimated:YES completion:nil];
}
//标记通讯录的号码是否共享过
-(void)compareContactsIfShared{
    for (int i = 0; i<self.friendsArray.count; i++) {
        JFGSDKFriendInfo * fInfo = [self.friendsArray objectAtIndex:i];
        for (int j = 0; j<self.contactArray.count; j++) {
            ContactModel * model2 = [self.contactArray objectAtIndex:j];
            
            NSString *str1 = [CommonMethod formatPhoneNum:fInfo.account];
            str1 = [str1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            NSString *str2 = [CommonMethod formatPhoneNum:model2.phoneNum];
            str2 = [str2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            if ([str2 isEqualToString:str1]) {
                model2.isShared = YES;
            }
        }
        for (int j=0; j<self.searchArray.count; j++) {
            ContactModel * model2 = [self.searchArray objectAtIndex:j];
            
            NSString *str1 = [CommonMethod formatPhoneNum:fInfo.account];
            str1 = [str1 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            NSString *str2 = [CommonMethod formatPhoneNum:model2.phoneNum];
            str2 = [str2 stringByReplacingOccurrencesOfString:@"-" withString:@""];
            
            if ([str2 isEqualToString:str1]) {
                model2.isShared = YES;
            }
        }
        
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
}
//判断当前账号是邮箱还是手机号
- (BOOL)isPhone:(NSString *)str {
    if ([str containsString:@"@"]) {
        return NO;
    }
    return YES;
}
#pragma mark - 通讯录
-(void)loadPerson{
    
    ABAddressBookRef addressBook = ABAddressBookCreate();
    //用户授权
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {//首次访问通讯录
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (!error) {
                if (granted) {//允许
                    
                    self.contactArray = [[NSMutableArray alloc]initWithArray:[CommonMethod copyAddressBook]];
                    //根据Person对象的 name 属性 按中文 对 Person数组 排序
                    self.indexArray = [BMChineseSort IndexWithArray:self.contactArray Key:@"name"];
                    self.letterResultArr = [BMChineseSort sortObjectArray:self.contactArray Key:@"name"];
                    
                    if (self.myFriedsArr.count) {
                        for (JFGSDKFriendInfo *info in self.myFriedsArr) {
                            for (int j = 0; j<self.contactArray.count; j++) {
                                ContactModel * model2 = [self.contactArray objectAtIndex:j];
                                if ([info.account isEqualToString: model2.phoneNum]) {
                                    model2.isShared = YES;
                                    break;
                                }
                            }
                        }
                    }
                    
                    //[self compareContactsIfAdded];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self compareContactsIfShared];
                        [self.contactTableView reloadData];
                    });

                }else{//拒绝
                    
                    NSLog(@"拒绝!");
                }
            }else{
                NSLog(@"错误!");
            }
        });
    }else{//非首次访问通讯录
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            
            if (error == nil) {
                if (granted) {
                    
                    self.contactArray = [[NSMutableArray alloc]initWithArray:[CommonMethod copyAddressBook]];
                    //[self compareContactsIfAdded];
                    
                    //根据Person对象的 name 属性 按中文 对 Person数组 排序
                    self.indexArray = [BMChineseSort IndexWithArray:self.contactArray Key:@"name"];
                    self.letterResultArr = [BMChineseSort sortObjectArray:self.contactArray Key:@"name"];
                    if (self.myFriedsArr.count) {
                        for (JFGSDKFriendInfo *info in self.myFriedsArr) {
                            for (int j = 0; j<self.contactArray.count; j++) {
                                ContactModel * model2 = [self.contactArray objectAtIndex:j];
                                if ([info.account isEqualToString: model2.phoneNum]) {
                                    model2.isShared = YES;
                                    break;
                                }
                            }
                        }
                    }
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self compareContactsIfShared];
                        [self.contactTableView reloadData];
                    });
                }else{
                    NSLog(@"jujue");
                    NSString *titleName= [OemManager appName];
                    NSString *str = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_CONTACTS_C"],titleName];
                    //[JfgLanguage getLanTextStrByKey:@"Tap2_Index_OpenTimelapse"]
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        
                        [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_CONTACTS"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tosetup"] CancelBlock:^{
                            
                        } OKBlock:^{
                            
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication]openURL:url];
                            
                        }];
                        
                        
                    });
                }
            }
            
        });
    }
}
#pragma mark - UISearchDisplayControllerDelegate
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString{
    [self filterContentForSearchText:searchString scope:[_searchBar scopeButtonTitles][_searchBar.selectedScopeButtonIndex]];
    return YES;
}
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:_searchBar.text scope:_searchBar.scopeButtonTitles[searchOption]];
    
    return YES;
}
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope{
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    [self.searchArray removeAllObjects];
    for (int i = 0; i < self.contactArray.count; i++) {
        ContactModel * m = [self.contactArray objectAtIndex:i];
        NSString *storeString = m.name;
        NSRange storeRange = NSMakeRange(0, storeString.length);
        NSRange foundRange = [storeString rangeOfString:searchText options:searchOptions range:storeRange];
        if (foundRange.length) {
            [self.searchArray addObject:m];
        }else{
            NSString *storeString1 = m.phoneNum;
            NSRange storeRange1 = NSMakeRange(0, storeString1.length);
            NSRange foundRange1 = [storeString1 rangeOfString:searchText options:searchOptions range:storeRange1];
            if (foundRange1.length) {
                [self.searchArray addObject:m];
            }
        }
        
    }
}
#pragma mark - UI
-(UISearchBar *)searchBar{
    if (!_searchBar) {
        _searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, self.view.width, 44)];
        _searchBar.placeholder = [JfgLanguage getLanTextStrByKey:@"Search"];
        _searchBar.tintColor = [UIColor blueColor];
        _searchBar.barTintColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _searchBar.translucent = YES;

        _searchBar.tintColor = [UIColor colorWithHexString:@"#4b9fd5"];
        _searchBar.delegate = self;
        [_searchBar setBackgroundImage:[UIImage new]];
        
        UITextField *searchField = [_searchBar valueForKey:@"searchField"];
        if (searchField) {
            [searchField setBackgroundColor:[UIColor whiteColor]];
            searchField.layer.cornerRadius = 14.0f;
            searchField.layer.masksToBounds = YES;
        }
    }
    return _searchBar;
}

-(UITableView *)contactTableView{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64+44, self.view.width, self.view.height-64-44) style:UITableViewStylePlain];
        _contactTableView.delegate = self;
        _contactTableView.dataSource = self;
        _contactTableView.showsVerticalScrollIndicator = NO;
        _contactTableView.showsHorizontalScrollIndicator = NO;
        [_contactTableView setTableFooterView:[UIView new]];
        _contactTableView .backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _contactTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        [_contactTableView setSeparatorColor:TableSeparatorColor];
        [_contactTableView registerClass:[ContactCell class] forCellReuseIdentifier:@"cCell"];
    }
    return _contactTableView;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
