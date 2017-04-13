//
//  AddFriendsInContactVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AddFriendsInContactVC.h"
#import "JfgGlobal.h"
#import "ContactCell.h"
#import "CommonMethod.h"
#import "ContactModel.h"
#import <MessageUI/MessageUI.h>
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKAcount.h>
#import "LSAlertView.h"
#import <AddressBook/AddressBook.h>
#import <CoreFoundation/CFArray.h>
#import "ProgressHUD.h"
#import "SetDeviceNameVC.h"
#import "LoginManager.h"
#import "UIAlertView+FLExtension.h"
#import "OemManager.h"
#import "FriendsInfoVC.h"
#import "BMChineseSort.h"

@interface AddFriendsInContactVC ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, MFMessageComposeViewControllerDelegate,JFGSDKCallbackDelegate>
{
    NSString *currentAccount;
}
@property (nonatomic, strong) SearchView *searchView;

@property (nonatomic, strong) UITableView *concactTableView;
/**
 *  数据源 数组
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 *  搜索结果 数组
 */
@property (nonatomic, strong) NSMutableArray *searchArray;
/**
 *  通信录 数组
 */
@property (nonatomic, strong) NSMutableArray *contactArray;
/**
 *  好友数组
 */
@property (nonatomic, strong) NSMutableArray *friendsArray;

//排序后的出现过的拼音首字母数组
@property(nonatomic,strong)NSMutableArray *indexArray;
//排序好的结果数组
@property(nonatomic,strong)NSMutableArray *letterResultArr;

@end

@implementation AddFriendsInContactVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.friendsArray = [NSMutableArray array];
    [self fetchAddressBookBeforeIOS9];
    [JFGSDK addDelegate:self];
    [self initView];
    [self initNavigationView];
    [self addNotificationObserver];
    
}

- (void)fetchAddressBookBeforeIOS9{
    ABAddressBookRef addressBook = ABAddressBookCreate();
    //用户授权
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {//首次访问通讯录
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            if (!error) {
                if (granted) {//允许
                    
                    [self.contactArray addObjectsFromArray:[CommonMethod copyAddressBook]];
                    self.dataArray = [[NSMutableArray alloc]initWithArray:self.contactArray];
                    [self compareContactsIfAdded];
                    self.indexArray = [BMChineseSort IndexWithArray:self.contactArray Key:@"name"];
                    self.letterResultArr = [BMChineseSort sortObjectArray:self.contactArray Key:@"name"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        [self.concactTableView reloadData];
                    });
                }else{//拒绝
                    
                    NSLog(@"拒绝!");
                }
            }else{
                NSLog(@"错误!");
            }
        });
    }else{//非首次访问通讯录
//        NSArray *contacts = [self fetchContactWithAddressBook:addressBook];
//        dispatch_async(dispatch_get_main_queue(), ^{
//            NSLog(@"contacts:%@", contacts);
//        });
        
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
          
            if (error == nil) {
                if (granted) {
                    [self.contactArray addObjectsFromArray:[CommonMethod copyAddressBook]];
                    self.dataArray = [[NSMutableArray alloc]initWithArray:self.contactArray];
                    [self compareContactsIfAdded];
                    self.indexArray = [BMChineseSort IndexWithArray:self.contactArray Key:@"name"];
                    self.letterResultArr = [BMChineseSort sortObjectArray:self.contactArray Key:@"name"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.concactTableView reloadData];
                    });
                }else{
                    NSLog(@"jujue");
                    NSString *titleName;
                    if ([JfgLanguage languageType] == 0) {
                        titleName = @"\"加菲狗\"";
                    }else{
                        titleName = @"\"Clever Dog\"";
                    }
                    NSString *str = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_CONTACTS_C"],titleName];
                    //[JfgLanguage getLanTextStrByKey:@"Tap2_Index_OpenTimelapse"]
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                       UIAlertView *aler = [[UIAlertView alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_CONTACTS"] message:str delegate:self cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"]  otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"Tap1_Tosetup"], nil];
                        [aler showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                            
                            //NSString *identifier = [[NSBundle mainBundle] bundleIdentifier];
                            //NSString *rul = [NSString stringWithFormat:@"prefs:root=%@",identifier];
                            if (buttonIndex == 1) {
                                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                //NSURL *url = [NSURL URLWithString:rul];
                                [[UIApplication sharedApplication]openURL:url];
                            }
                            
                        } otherDelegate:nil];
                    });
                    
                    

                }
            }
            
        });
        
       
    }
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK getFriendList];
}
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self removeNotificationObserver];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma  mark view
- (void)initView
{
    [self.view addSubview:self.searchView];
    [self.view addSubview:self.concactTableView];
}

- (void)initNavigationView
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Contacts"];
}
#pragma mark - JFGSDKCallBack
- (void)jfgFriendList:(NSArray *)list error:(JFGErrorType)errorType{
    if (list != nil) {
        if (self.friendsArray.count > 0) {
            [self.friendsArray removeAllObjects];
        }
        for (JFGSDKFriendInfo * fInfo in list) {
            ContactModel * cModel = [[ContactModel alloc]init];
            cModel.phoneNum = fInfo.account;
            cModel.name = fInfo.alias;
            [self.friendsArray addObject:cModel];
        }
        [self compareContactsIfAdded];
        [self.concactTableView reloadData];
    }
}
#pragma mark data
- (void)updateDataWithArray:(NSMutableArray *)tempArray
{
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:tempArray];
    [self.concactTableView reloadData];
}
//标记通讯录的号码是否添加过
-(void)compareContactsIfAdded{
    for (int i = 0; i<self.friendsArray.count; i++) {
        ContactModel * model1 = [self.friendsArray objectAtIndex:i];
        for (int j = 0; j<self.contactArray.count; j++) {
            ContactModel * model2 = [self.contactArray objectAtIndex:j];
            if ([model1.phoneNum isEqualToString:model2.phoneNum]) {
                model2.isAdded = YES;
            }
        }
    }
}
#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)searchArrayWithStr:(NSString *)searchStr
{
    NSUInteger searchOptions = NSCaseInsensitiveSearch | NSDiacriticInsensitiveSearch;
    
    if([searchStr isEqualToString:@""] || searchStr == nil)
    {
        [self updateDataWithArray:self.contactArray];
        return;
    }
    [self.searchArray removeAllObjects];
    // 遍历所有数据 匹配 搜索字符串
    for (int i = 0; i < self.contactArray.count; i++)
    {
        ContactModel * m = [self.contactArray objectAtIndex:i];
        NSString *storeString = m.name;
        NSRange storeRange = NSMakeRange(0, storeString.length);
        NSRange foundRange = [storeString rangeOfString:searchStr options:searchOptions range:storeRange];
        if (foundRange.length)
        {
            [self.searchArray addObject:m];
        }
        else
        {
            NSString *storeString1 = m.phoneNum;
            NSRange storeRange1 = NSMakeRange(0, storeString1.length);
            NSRange foundRange1 = [storeString1 rangeOfString:searchStr options:searchOptions range:storeRange1];
            
            if (foundRange1.length)
            {
                [self.searchArray addObject:m];
            }
        }
    }
    [self updateDataWithArray:self.searchArray];
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldsChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)shareButtonAction:(ContactBtn *)sender
{
    currentAccount = [CommonMethod formatPhoneNum:sender.phoneNumber];
    currentAccount = [currentAccount stringByReplacingOccurrencesOfString:@"-" withString:@""];
    [JFGSDK checkFriendIsExistWithAccount:currentAccount];
    [ProgressHUD showProgress:nil];
}

-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeIsRegistered) {
        if (errorType == 0) {
            //账号已经注册
            [ProgressHUD showText:[CommonMethod languageKeyForLoginErrorType:JFGErrorTypeAccountAlreadyExist]];
        }else{
           
        }
    }
}



-(void)jfgCheckAccount:(NSString *)account alias:(NSString *)alias isExist:(BOOL)isExist errorType:(JFGErrorType)errorType
{
    
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
            
            NSDictionary *dict = [OemManager getOemConfig:oemRecommendKey];
            BOOL showReccommend = [[dict objectForKey:oemShowRecommendKey] boolValue];
            if (showReccommend)
            {
                //首先判断当前设备是否可以发送短信
                if([MFMessageComposeViewController canSendText])
                {
                    MFMessageComposeViewController *mc=[[MFMessageComposeViewController alloc] init];
                    
                    //设置委托
                    mc.messageComposeDelegate=self;
                    
                    NSString *appName = @"";
                    //
                    if ([JfgLanguage languageType] == 0) {
                        appName = @"加菲狗";
                    }else{
                        appName = @"Clever Dog";
                    }
                    //短信内容
                    NSString *body = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap1_share_tips"],[dict objectForKey:oemRecommendUrl],appName];
                    mc.body=body;
                    
                    //设置短信收件方
                    mc.recipients=@[currentAccount];
                    
                    [self presentViewController:mc animated:YES completion:nil];
                }
                else
                {
                    [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"RET_ESEND_SMS"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil
                                            OKBlock:nil];
                }
            }
            
            
            
        }else{
            
            //已注册
            SetDeviceNameVC *setWifiPass = [[SetDeviceNameVC alloc] init];
            setWifiPass.deviceNameVCType = DeviceNameVCTypeSetHelloWorld;
            
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            setWifiPass.cid = currentAccount;
            setWifiPass.deviceName = [NSString stringWithFormat:@"I am %@",account.alias];
            [self.navigationController pushViewController:setWifiPass animated:YES];
            
        }
        
    }
        
        
    


}

#pragma mark UIMessage delegate

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            JFGLog(@"Result: SMS sending canceled");
            break;
        case MessageComposeResultSent:
            JFGLog(@"Result: SMS sent");
            break;
        case MessageComposeResultFailed:
            break;
        default:
            JFGLog(@"Result: SMS not sent");
            break;
    }
    sleep(1.0);
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

#pragma mark textfieldDelegate
- (void)textFieldsChanged:(NSNotification *)notification
{
    if (self.searchView != nil)
    {
        [self searchArrayWithStr:self.searchView.searchTextField.text];
    }
}

#pragma mark tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"addFriends";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    ContactModel *model;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        model = [self.dataArray objectAtIndex:indexPath.row];
        cell.shareButton.isSearchBar = YES;
    }else{
        model =[[self.letterResultArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.shareButton.isSearchBar = NO;
    }
    
    if (!cell)
    {
        cell = [[ContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.nameLabel.text = model.name;
    cell.phoneLabel.text = model.phoneNum;
    
    if (model.isAdded == NO) {
        [cell.shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Button_Add"] forState:UIControlStateNormal];
        [cell.shareButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        cell.shareButton.layer.cornerRadius = 4;
        cell.shareButton.layer.borderWidth = 0.5;
        [cell.shareButton.layer setBorderColor:[UIColor colorWithHexString:@"#4b9fd5"].CGColor];
        [cell.shareButton addTarget:self action:@selector(shareButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        cell.shareButton.phoneNumber = model.phoneNum;
    }else{
        [cell.shareButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_Added"] forState:UIControlStateNormal];
        [cell.shareButton setTitleColor:[UIColor colorWithHexString:@"#888888"] forState:UIControlStateNormal];
        cell.shareButton.layer.borderWidth = 0;
        cell.shareButton.enabled = YES;
        cell.shareButton.enabled = NO;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.dataArray.count;
    }else{
        NSArray *arr = [self.letterResultArr objectAtIndex:section];
        return [arr count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView){
        return @"";
    }else{
        return [self.indexArray objectAtIndex:section];
    }
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }else{
        return [self.indexArray count];
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 0;
    }else{
        return 25;
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

#pragma mark scrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.searchView.searchTextField resignFirstResponder];
}

#pragma mark property
- (SearchView *)searchView
{
    CGFloat widgetX = 0;
    CGFloat widgetY = 64;
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 44;
    
    if (_searchView == nil)
    {
        _searchView = [[SearchView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _searchView.showCancelButton = NO;
    }
    return _searchView;
}

- (UITableView *)concactTableView
{
    if (_concactTableView == nil)
    {
        CGFloat widgetX = 0;
        CGFloat widgetY = self.searchView.bottom + 10;
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = kheight - widgetY;
        
        _concactTableView = [[UITableView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight) style:UITableViewStylePlain];
        _concactTableView.delegate = self;
        _concactTableView.dataSource = self;
        _concactTableView.showsVerticalScrollIndicator = NO;
        _concactTableView.showsHorizontalScrollIndicator = NO;
        [_concactTableView setTableFooterView:[UIView new]];
        _concactTableView.separatorColor = TableSeparatorColor;
        _concactTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    }
    return _concactTableView;
}


- (NSMutableArray *)searchArray
{
    if (_searchArray == nil)
    {
        _searchArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _searchArray;
}

- (NSMutableArray *)contactArray
{
    if (_contactArray == nil)
    {
        _contactArray = [[NSMutableArray alloc] initWithCapacity:5];
       
    }
    return _contactArray;
}

@end
