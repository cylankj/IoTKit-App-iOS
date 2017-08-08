//
//  FriendsInfoVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FriendsInfoVC.h"
#import "FriendsInfoCell.h"
#import "JfgTableViewCellKey.h"
#import "JfgGlobal.h"
#import "SetDeviceNameVC.h"
#import <JFGSDK/JFGSDK.h>
#import "LSAlertView.h"
#import "ProgressHUD.h"
#import "ShareForSomeOneVC.h"
#import "JfgLanguage.h"
#import <SDImageCache.h>
#import "UIImageView+WebCache.h"
#import "CommonMethod.h"
#import "LoginManager.h"
#import "JFGBoundDevicesMsg.h"
#import "JFGBigImageView.h"
#import "JFGAlbumManager.h"
#import "UIAlertView+FLExtension.h"

@interface FriendsInfoVC ()<UITableViewDelegate, UITableViewDataSource,JFGSDKCallbackDelegate>
{
    NSArray * friendMenuTitles;
}
/**
 *  列表视图
 */
@property (nonatomic, strong) UITableView *listTableView;

/**
 *  操作按钮
 */
@property (nonatomic, strong) UIButton *nextButton;

@end

@implementation FriendsInfoVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    friendMenuTitles = @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_UserInfo_Name"],[JfgLanguage getLanTextStrByKey:@"Tap3_DeleteFriends"]];

    [self initView];
    [self initNavigationView];
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
    if (self.friendsInfoType == FriendsInfoIsFriens) {
        [JFGSDK getFriendInfoByAccount:self.account];
    }
}
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [JFGSDK removeDelegate:self];
    [ProgressHUD dismiss];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    [self.view addSubview:self.headImageView];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.nickNameLabel];
    
    if (self.friendsInfoType == FriendsInfoUnFiens && self.isVerifyFriends) {
        [self initReqMsgView];
    }else{
        [self.view addSubview:self.listTableView];
    }
    
    [self.view addSubview:self.nextButton];
    
    NSString *fileName = [NSString stringWithFormat:@"/image/%@.jpg",self.account];
    NSString *h = [JFGSDK getCloudUrlWithFlag:1 fileName:fileName];
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:h] placeholderImage:[UIImage imageNamed:@"bg_head_160"]];

}

- (void)initNavigationView
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_Friends_Details"];
}


-(void)jfgGetFriendInfo:(JFGSDKFriendInfo *)info error:(JFGErrorType)errorType {
    if (errorType == 0) {
        if (self.friendsInfoType == FriendsInfoIsFriens) {
            self.nameLabel.text = info.remarkName;
            self.nickNameLabel.text = info.alias;
        }
    } else {
        
    }
    
}
#pragma mark action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

- (void)nextButtonAction:(UIButton *)sender {
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        return;
        
    }
    
    if (self.friendsInfoType == FriendsInfoIsFriens) {
        //分享设备
        
        NSMutableArray *list = [[JFGBoundDevicesMsg sharedDeciceMsg] getDevicesList];
        
        BOOL isNot = YES;
        for (JiafeigouDevStatuModel *model in list) {
            
            if (model.shareState != DevShareStatuOther) {
                isNot = NO;
                break;
            }
            
        }
        
        if (list.count && !isNot) {
            ShareForSomeOneVC * shareVC = [ShareForSomeOneVC new];
            if (![self.nameLabel.text isEqualToString:@""]) {
                shareVC.remarkName = self.nameLabel.text;
            }else if(![self.nickNameLabel.text isEqualToString:@""]){
                shareVC.remarkName = self.nickNameLabel.text;
            }
            shareVC.account = self.account;
            [self.navigationController pushViewController:shareVC animated:YES];
        }else{
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap1_Index_NoDevice"]];
        }
        
        
    }else{
        
        if (self.isVerifyFriends) {
            
            [JFGSDK agreeRequestForAddFriendByAccount:self.account];
            //[JFGSDK addFriendByAccount:self.account additionTags:@"Hello"];
            [ProgressHUD showProgress:nil];
            
            
        }else{
            SetDeviceNameVC *setWifiPass = [[SetDeviceNameVC alloc] init];
            setWifiPass.deviceNameVCType = DeviceNameVCTypeSetHelloWorld;
            
            JFGSDKAcount *account = [LoginManager sharedManager].accountCache;
            setWifiPass.cid = self.account;
            
            if (account.alias && ![account.alias isEqualToString:@""]) {
                setWifiPass.deviceName = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_StuffContents"],account.alias];
            }else{
                setWifiPass.deviceName = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_StuffContents"],account.account];
            }
            
           
            [self.navigationController pushViewController:setWifiPass animated:YES];
        }
        
    }
}



#pragma mark tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"cellIdentifier";
    FriendsInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[FriendsInfoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if (self.friendsInfoType == FriendsInfoUnFiens) {
        if (self.isVerifyFriends) {
            cell.cusTextLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Content"];
            cell.cusDetailLabel.text = self.reqMsg;
        }

    }else{
        [cell.cusDetailLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(cell).with.offset(-30.0f);
        }];
        cell.cusTextLabel.text = [friendMenuTitles objectAtIndex:indexPath.row];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.friendsInfoType == FriendsInfoUnFiens) {
        if (self.isVerifyFriends) {
            return 1;
        }
        return 0;
    }
    return 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.friendsInfoType == FriendsInfoUnFiens) {
        if (self.isVerifyFriends) {
            
//            CGSize stringSize = CGSizeOfString(self.reqMsg, CGSizeMake(Kwidth, 300), [UIFont systemFontOfSize:16.0f]);
//            make.width.equalTo(@(stringSize.width));
//            make.height.equalTo(@(stringSize.height));
            
            return 0;
        }
        return 0;
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.friendsInfoType == FriendsInfoIsFriens) {
        if (indexPath.row == 0) {
            SetDeviceNameVC * setNameVC = [SetDeviceNameVC new];
            setNameVC.deviceNameVCType = DeviceNameVCTypeFriendsRemarkName;
            setNameVC.account = self.account;
            
            /**
             self.nameLabel.text = info.remarkName;
             self.nickNameLabel.text = info.alias;
             
             */
            if (![self.nameLabel.text isEqualToString:@""]) {
                setNameVC.deviceName = self.nameLabel.text;
            }else if (![self.nickNameLabel.text isEqualToString:@""]){
                setNameVC.deviceName = [NSString stringWithFormat:@"%@ ",self.nickNameLabel.text];
            }
                
            
            [self.navigationController pushViewController:setNameVC animated:YES];
        }else {
            
            if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
                
                [CommonMethod showNetDisconnectAlert];
                return;
                
            }
            
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_DeleteFriends"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] CancelBlock:^{
                
            } OKBlock:^{
                
                [JFGSDK delFriendByAccount:self.account];
            }];
        }
    }else{
        
    }
}
-(void)jfgResultIsRelatedToFriendWithType:(JFGFriendResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGFriendResultTypeDelFriend) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"DELETED_SUC"]];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"delFriendNotification" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }else if (type == JFGFriendResultTypeAgreeAddFriend){
        //Tap3_Added
        
        if (errorType == JFGErrorTypeNone) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Success"]];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"delFriendNotification" object:nil];
            
        }else if(errorType == JFGErrorTypeFriendAlready){
            
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Success"]];
            [self.navigationController popViewControllerAnimated:YES];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"delFriendNotification" object:nil];
        }else if(errorType == JFGErrorTypeFriendInvalidRequest){
            //Tap3_FriendsAdd_ExpiredTips

            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:nil Message:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_ExpiredTips"] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"SEND"] CancelBlock:^{
                
            } OKBlock:^{
                
                FriendsInfoVC * infoVC = [FriendsInfoVC new];
                infoVC.nickNameLabel.text = weakSelf.account;
                infoVC.nameLabel.text = weakSelf.nickNameString;
                infoVC.friendsInfoType = FriendsInfoUnFiens;
                infoVC.isVerifyFriends = NO;
                infoVC.account = weakSelf.account;
                infoVC.nickNameString = weakSelf.nickNameString;
                [weakSelf.navigationController pushViewController:infoVC animated:YES];
                
            }];
            
        }else{
            
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RET_MSG_EUNKNOWN"]];
            
        }
       
    }else{
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Contacts_InvitedTips"]];
        [self.navigationController performSelector:@selector(popViewControllerAnimated:) withObject:@"YES" afterDelay:1.0];
    }
    
    int64_t delayInSeconds = 1.50;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        
        [ProgressHUD dismiss];
        
    });
}
#pragma mark property
- (UIImageView *)headImageView
{
    if (_headImageView == nil)
    {
        CGFloat widgetWidth = 80;
        CGFloat widgetHeight = widgetWidth;
        CGFloat widgetX = (Kwidth - widgetWidth)*0.5;
        CGFloat widgetY = 64 + 48;
        
        _headImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];   
        _headImageView.layer.cornerRadius = widgetWidth*0.5;
        _headImageView.layer.masksToBounds = YES;
        _headImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *_tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showBigSnapView:)];
        _tap.numberOfTouchesRequired = 1;
        _tap.numberOfTapsRequired = 1;
        [_headImageView addGestureRecognizer:_tap];
        
    }
    return _headImageView;
}

-(void)showBigSnapView:(UITapGestureRecognizer *)tap
{
    UIImageView *tapView = (UIImageView *)tap.view;
    JFGBigImageView *bigimageView = [JFGBigImageView initWithImage:tapView.image showLongPress:YES];
    [bigimageView show];
}

- (UILabel *)nameLabel
{
    if (_nameLabel == nil)
    {
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = 17.0;
        CGFloat widgetX = 0;
        CGFloat widgetY = 10 + self.headImageView.bottom;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight+2)];
        _nameLabel.textAlignment = NSTextAlignmentCenter;
        _nameLabel.font = [UIFont systemFontOfSize:widgetHeight];
        _nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    }
    return _nameLabel;
}

- (UILabel *)nickNameLabel
{
    if (_nickNameLabel == nil)
    {
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = 14.0;
        CGFloat widgetX = 0;
        CGFloat widgetY = 5 + self.nameLabel.bottom;
        
        _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight+2)];
        _nickNameLabel.textAlignment = NSTextAlignmentCenter;
        _nickNameLabel.font = [UIFont systemFontOfSize:widgetHeight];
        _nickNameLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        _nickNameLabel.text = self.nickNameString;
    }
    
    return _nickNameLabel;
}

- (UITableView *)listTableView
{
    if (_listTableView == nil)
    {
        CGFloat widgetX = 0;
        CGFloat widgetY = self.nickNameLabel.bottom + 42;
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = self.nextButton.top - widgetY;
        
        _listTableView = [[UITableView alloc]initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight) style:UITableViewStylePlain];
        _listTableView.delegate = self;
        _listTableView.dataSource = self;
        _listTableView.backgroundColor = self.view.backgroundColor;
        _listTableView.scrollEnabled = NO;
        _listTableView.showsVerticalScrollIndicator = NO;
        _listTableView.showsHorizontalScrollIndicator = NO;
        [_listTableView setTableFooterView:[UIView new]];
        [_listTableView setSeparatorColor:TableSeparatorColor];
    }
    return _listTableView;
}

- (UIButton *)nextButton
{
    if (_nextButton == nil)
    {
        CGFloat widgetWidth = 280;
        CGFloat widgetHeight = 44;
        CGFloat widgetX = (Kwidth - widgetWidth)*0.5;
        CGFloat widgetY = (kheight - widgetHeight - 30.0);
        
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"friends_infobtn"] forState:UIControlStateNormal];
        [_nextButton setBackgroundImage:[UIImage imageNamed:@"friends_infobtn_press"] forState:UIControlStateHighlighted];
        [_nextButton setTitle:[JfgLanguage getLanTextStrByKey:(self.friendsInfoType == FriendsInfoIsFriens)?@"Tap3_ShareDevice":@"Tap3_Friends_UserInfo_Add"] forState:UIControlStateNormal];
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

-(void)initReqMsgView
{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, self.nickNameLabel.bottom + 42, Kwidth, 20)];
    bgView.backgroundColor = [UIColor whiteColor];
    
    UILabel *_cusTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 0, 0)];
    _cusTextLabel.textColor = [UIColor colorWithHexString:@"#333333"];
    _cusTextLabel.font = [UIFont systemFontOfSize:16.0f];
    _cusTextLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_Content"];
    [_cusTextLabel sizeToFit];
    [bgView addSubview:_cusTextLabel];
    
    UITextView *textVie =[[ UITextView alloc]initWithFrame:CGRectMake(_cusTextLabel.right+20, 10, Kwidth-_cusTextLabel.right-20-15, 20)];
    textVie.editable = NO;
    textVie.backgroundColor = [UIColor whiteColor];
    textVie.textColor = [UIColor colorWithHexString:@"#888888"];
    textVie.font = [UIFont systemFontOfSize:16.0f];
    textVie.text = self.reqMsg;
    textVie.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    [bgView addSubview:textVie];
    
    
    CGFloat maxHeight = self.nextButton.top - bgView.top - 10;
    
    CGSize size = [textVie sizeThatFits:CGSizeMake(Kwidth-_cusTextLabel.right-20-15, maxHeight)];
    
    if (size.height > maxHeight-20) {
        textVie.size = CGSizeMake(size.width, maxHeight-20);
        bgView.height = textVie.size.height + 20;
        textVie.scrollEnabled = YES;
    }else{
        textVie.scrollEnabled = NO;
        textVie.size = size;
        bgView.height = size.height+20;
    }
    
    
    [self.view addSubview:bgView];
    
    
}

@end
