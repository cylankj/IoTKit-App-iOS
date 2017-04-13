//
//  AddFriendsVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AddFriendsVC.h"
#import "JfgGlobal.h"
#import "JfgTableViewCellKey.h"
#import "TextFieldView.h"
#import "SearchFriendsView.h"
#import "AddFriendsInContactVC.h"
#import "AddFriendsByScan.h"
#import <JFGSDK/JFGSDK.h>
#import "FriendsInfoVC.h"
#import "FLProressHUD.h"
#import "ProgressHUD.h"
#import "ShareWithAddrBookVC.h"

@interface AddFriendsVC ()<JFGSDKCallbackDelegate>
/**
 *  搜索框
 */
@property (nonatomic, strong) TextFieldView *fieldView;
/**
 *  列表
 */
@property (nonatomic, strong) UITableView *addFriendsTableView;
/**
 *  tableView数据源
 */
@property (nonatomic, strong) NSMutableArray *dataArray;
/**
 *  搜索View
 */
@property (nonatomic, strong) SearchFriendsView *searchView;

@end

@implementation AddFriendsVC


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initNavigationView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.searchView animationToBottom];
    [JFGSDK removeDelegate:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
}

- (void)initView
{
    [self.view addSubview:self.fieldView];
    [self.view addSubview:self.addFriendsTableView];
    [self.view addSubview:self.searchView];
    
}

- (void)initNavigationView
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd"];
    [self setRightButtonImage:nil title:[JfgLanguage getLanTextStrByKey:@"OK"] font:[UIFont systemFontOfSize:15]];
     self.rightButton.hidden = YES;
    [self.rightButton addTarget:self action:@selector(rightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - JFGSDKCallBack
-(void)jfgCheckAccount:(NSString *)account alias:(NSString *)alias isExist:(BOOL)isExist errorType:(JFGErrorType)errorType
{
    if (isExist) {
        //是好友
        [ProgressHUD dismiss];
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
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_NoContent"]];
        }else{
            //已注册
            [ProgressHUD dismiss];
            FriendsInfoVC * infoVC = [FriendsInfoVC new];
            infoVC.nickNameLabel.text = account;
            infoVC.nameLabel.text = alias;
            infoVC.friendsInfoType = FriendsInfoUnFiens;
            infoVC.isVerifyFriends = NO;
            infoVC.account = account;
            infoVC.nickNameString = alias;
            [self.navigationController pushViewController:infoVC animated:YES];
            
            
        }
        
    }
    
}
#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}
- (void)rightButtonAction:(UIButton *)sender{
//    if (self.fieldView.textField.text.length > 0) {
//        [JFGSDK addFriendByAccount:@"1586711571@qq.com" additionTags:@"加我呀"];
//    }

}
#pragma mark tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *addFriendsIdentifier = @"addFrineds";
    UITableViewCell *friendsCell = [tableView dequeueReusableCellWithIdentifier:addFriendsIdentifier];
    NSDictionary *dataDict = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    if (!friendsCell)
    {
        friendsCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:addFriendsIdentifier];
        friendsCell.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        friendsCell.textLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    
    friendsCell.textLabel.text = [dataDict objectForKey:cellTextKey];
    friendsCell.imageView.image = [UIImage imageNamed:[dataDict objectForKey:cellIconImageKey]];
    
    return friendsCell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *subArr = [self.dataArray objectAtIndex:section];
    return subArr.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    switch (indexPath.section)
    {
        case 0:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    AddFriendsByScan *addFriends = [AddFriendsByScan new];
                    [self.navigationController pushViewController:addFriends animated:YES];
                }
                    break;
                case 1:
                {
                    ShareWithAddrBookVC * addrBook = [ShareWithAddrBookVC new];
                    addrBook.cid = @"";
                    addrBook.vcType = VCTypeAddFriendFromAddrBook;
                    [self.navigationController pushViewController:addrBook animated:YES];
                }
                    break;
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark tableView delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.fieldView.textField resignFirstResponder];
    [self.searchView animationToTop];
}

#pragma mark property
- (TextFieldView *)fieldView
{
    if (_fieldView == nil)
    {
        CGFloat widgetX = -1;
        CGFloat widgetY = 20.0f + self.navigationView.height;
        CGFloat widgetWidth = Kwidth + 2;
        CGFloat widgetHeight = 44.0f;
        
        _fieldView = [[TextFieldView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _fieldView.textField.placeholder = [JfgLanguage getLanTextStrByKey:@"SHARE_ACCOUNT"];
        _fieldView.textField.delegate = self;
    }
    return _fieldView;
}

- (UITableView *)addFriendsTableView
{
    if (_addFriendsTableView == nil)
    {
        CGFloat widgetX = 0;
        CGFloat widgetY = self.fieldView.bottom + 20.0;
        CGFloat widgetWidth = Kwidth + 2;
        CGFloat widgetHeight = kheight - widgetY;
        
        _addFriendsTableView = [[UITableView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight) style:UITableViewStyleGrouped];
        _addFriendsTableView.delegate = self;
        _addFriendsTableView.dataSource = self;
        _addFriendsTableView.scrollEnabled = NO;
        _addFriendsTableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _addFriendsTableView.separatorInset = UIEdgeInsetsMake(0, -50, 0, 0);
    }
    return _addFriendsTableView;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:2];
        
        [_dataArray addObject:[NSArray arrayWithObjects:
                                   [NSDictionary dictionaryWithObjectsAndKeys:@"friends_scan", cellIconImageKey,[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_QR"],cellTextKey, nil],
                               [NSDictionary dictionaryWithObjectsAndKeys:@"friends_contacts", cellIconImageKey,[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Contacts"],cellTextKey, nil],nil]];
    }
    return _dataArray;
}

- (SearchFriendsView *)searchView
{
    if (_searchView == nil)
    {
        _searchView = [[SearchFriendsView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _searchView.hidden = YES;
    }
    return _searchView;
}

@end
