           //
//  PersonMsgViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/7/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "PersonMsgViewController.h"
#import "UIColor+HexColor.h"
#import "PhotoSelectionAlertView.h"
#import "PickerEditImageViewController.h"
#import "PickerGroupViewController.h"
#import "PersonQRCodeView.h"
#import "LoginManager.h"
#import "BaseNavgationViewController.h"
#import "OemManager.h"
#import <JFGSDK/JFGSDKCallbackDelegate.h>
#import "ChangePwdViewController.h"
#import "SetDeviceNameVC.h"
#import <JFGSDK/JFGSDKAcount.h>
#import "JfgLanguage.h"
#import "ChangePhoneViewController.h"
#import "JFGHelpViewController.h"
#import "JfgConfig.h"
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "FLProressHUD.h"
#import "CommonMethod.h"
#import "JFGBigImageView.h"
#import "UIImageView+JFGImageView.h"
#import "LoginLoadingViewController.h"
#import "JFGEquipmentAuthority.h"
#import "UIImage+ImageEffects.h"
#import "OemManager.h"


@interface PersonMsgViewController ()<UITableViewDelegate,UITableViewDataSource,PhotoSelectionAlertViewDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate,JFGSDKCallbackDelegate>
{
    NSString *accountN;
    NSString *headUrl;
    NSString *nickName;
    NSString *email;
    NSString *phone;
    UIImage *headImage;
    NSString *codeContent;
    NSInteger uploadImageRequestID;
    UIImageView *accountImageView;
    BOOL headImageUseCache;
    int64_t uploadMark;
}
@property (nonatomic,strong)NSArray *dataArray;
@property (nonatomic,strong)UITableView *tableView;


@end

@implementation PersonMsgViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text =[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_UserInfo"];
    headImageUseCache = YES;
    [self.view addSubview:self.tableView];
    [JFGSDK addDelegate:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(editFinishedImage:) name:@"PickerEditFinisehImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshAccount) name:JFGAccountMsgChangedKey object:nil];
    if (!self.jfgAccount) {
        JFGSDKAcount *acc = [[LoginManager sharedManager] accountCache];
        self.jfgAccount = acc;
    }
    [self jfgUpdateAccount:self.jfgAccount];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    //NSLog(@"%lu",self.navigationController.viewControllers.count);
    if (self.navigationController.viewControllers.count<3) {
        
        [JFGSDK getAccount];
        
    }
}

-(void)refreshAccount
{
    [JFGSDK getAccount];
}

-(void)editFinishedImage:(NSNotification *)notification
{
    UIImage *image = notification.object;
    headImage = image;
    JFGSDKAcount *acc =[[LoginManager sharedManager] accountCache];
    NSString *account = acc.account;
    
    //上传图像
    uploadMark = [JFGSDK uploadFile:[self saveImage:image] toCloudFolderPath:[NSString stringWithFormat:@"/image/%@.jpg",account]];
    //通知服务器修改了头像
    [JFGSDK resetAccountPhoto];
    
    [FLProressHUD showIndicatorViewFLHUDForStyleDarkWithView:self.view text:[JfgLanguage getLanTextStrByKey:@"Tap3_Uploading"] position:FLProgressHUDPositionCenter];
    [self performSelector:@selector(uploadImageTimeout) withObject:nil afterDelay:30];
    
}

-(void)uploadImageTimeout
{
    [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:@"上传超时" position:FLProgressHUDPositionCenter];
    [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1];
}

-(void)jfgHttpResposeRet:(int)ret requestID:(int)requestID result:(NSString *)result
{
    if (requestID == uploadMark) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(uploadImageTimeout) object:nil];
        
        NSString *aleartStr ;
        if (ret == 200) {
            
            if (headImage) {
                accountImageView.image = headImage;
            }else{
                headImageUseCache = NO;
                [self.tableView reloadData];
            }
            
            [[NSNotificationCenter defaultCenter] postNotificationName:account_headImage_changed object:nil];
            aleartStr = [JfgLanguage getLanTextStrByKey:@"Tap3_UploadingComplete"];
            
        }else{
            aleartStr = [JfgLanguage getLanTextStrByKey:@"Tap3_UploadingFailed"];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [FLProressHUD showTextFLHUDForStyleDarkWithView:self.view text:aleartStr position:FLProgressHUDPositionCenter];
            [FLProressHUD hideAllHUDForView:self.view animation:YES delay:1];
        });
    }
    
}

-(NSString *)saveImage:(UIImage *)currentImage
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"account_pic.png"];
    NSData *imageData = UIImageJPEGRepresentation([self fixOrientation:currentImage], 0.1);//UIImagePNGRepresentation(currentImage);
    [imageData writeToFile:path atomically:YES];// 将图片写入文件
    return path;
}

-(void)tapHeadImageView
{
    if (accountImageView.image) {
        
        JFGBigImageView *bgImage = [JFGBigImageView initWithImage:accountImageView.image];
        [bgImage show];
        
    }
}

-(void)jfgUpdateAccount:(JFGSDKAcount *)account
{
    NSLog(@"acoount=%@",account.alias);
    
    if (account) {
        self.jfgAccount = account;//为什么要保存一下，因为下一个页面要用，按照接口的写法，只能传一个model
        
        
        if (account.phone && ![account.phone isEqualToString:@""]) {
            accountN = account.phone;
        }else{
            if (account.email &&![account.email isEqualToString:@""]) {
                accountN = account.email;
            }else{
                
                if ([[LoginManager sharedManager] loginType] == JFGSDKLoginTypeOpenLoginForQQ) {
                    accountN = [JfgLanguage getLanTextStrByKey:@"ACCOUNT_QQ"];
                }
                
                if ([[LoginManager sharedManager] loginType] == JFGSDKLoginTypeOpenLoginForSinaWeibo) {
                    accountN = [JfgLanguage getLanTextStrByKey:@"LOGIN_WEIBO"];
                }
                
                if ([[LoginManager sharedManager] loginType] == JFGSDKLoginTypeOpenLoginForTwitter) {
                    accountN = @"Twitter";
                }
                
                if ([[LoginManager sharedManager] loginType] == JFGSDKLoginTypeOpenLoginForFacebook) {
                    accountN = @"Facebook";
                }
                
                
                
            }
        }
        
        if (account.alias) {
            nickName = account.alias;
        }
        email = account.email;
        
        if ([email isEqualToString:@""]) {
            email = [JfgLanguage getLanTextStrByKey:@"NO_SET"];
        }
        
        phone = account.phone;
        if ([phone isEqualToString:@""]) {
            phone = [JfgLanguage getLanTextStrByKey:@"NO_SET"];
        }
        [self.tableView reloadData];
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *a = self.dataArray[section];
    return a.count;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1 && indexPath.row == 0) {
        return 75;
    }
    return 44;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"didididid";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:idCell];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        cell.clipsToBounds = YES;
        
        UIView *selectedBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
        selectedBackView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
        cell.selectedBackgroundView = selectedBackView;
        
        
        UILabel *lineView2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 43.5, self.view.bounds.size.width, 1)];
        lineView2.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
        lineView2.tag = 1203;
        lineView2.hidden = YES;
        [cell.contentView addSubview:lineView2];
        
        
        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(self.view.bounds.size.width-37-44, 10+5.5, 44, 44)];
        headImageView.layer.masksToBounds = YES;
        headImageView.tag = 1124;
        headImageView.hidden = YES;
        headImageView.userInteractionEnabled = YES;
        headImageView.layer.cornerRadius = 44*0.5;
        [cell.contentView addSubview:headImageView];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapHeadImageView)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [headImageView addGestureRecognizer:tap];
    }
    
    NSArray *subArr = self.dataArray[indexPath.section];

    if (indexPath.section ==0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = subArr[indexPath.row];
    
    
#pragma mark- detailTextLabel赋值
    switch (indexPath.section) {
        case 0:
            cell.detailTextLabel.text = accountN;
            break;
        case 1:{
            if (indexPath.row == 1) cell.detailTextLabel.text = @"";
            if (indexPath.row == 2) cell.detailTextLabel.text = nickName;
            if (indexPath.row == 3) cell.detailTextLabel.text = email;
            if (indexPath.row == 4) cell.detailTextLabel.text = phone;
        }
            
            break;
        case 2:
            cell.detailTextLabel.text = @"";
            break;
        default:
            break;
    }
        
#pragma mark- 退出登录按钮UI处理
    UILabel *bottomLine = (UILabel *)[cell.contentView viewWithTag:1203];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSArray *a = self.dataArray[indexPath.section];
    if (indexPath.row == a.count-1) {
        bottomLine.hidden = NO;
    }else{
        bottomLine.hidden = YES;
    }
    
    
#pragma mark- 头像栏UI处理
    UIImageView *headImageView = [cell.contentView viewWithTag:1124];
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        
        cell.detailTextLabel.text = @"";
        headImageView.hidden = NO;
        
        if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
            [headImageView jfg_setImageWithAccount:nil placeholderImage:nil refreshCached:!headImageUseCache completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                
                if (image == nil) {
                    headImageView.image = [UIImage imageNamed:@"image_defaultHead"];
                }
                
                NSLog(@"imageFrom:%ld",(long)cacheType);
            }];
            
        }else{
            NSInteger oldVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:JFGAccountHeadImageVersion] integerValue];
            [headImageView jfg_setImageWithAccount:nil photoVersion:oldVersion completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                NSLog(@"imageFrom:%ld",(long)cacheType);
                if (image == nil) {
                    headImageView.image = [UIImage imageNamed:@"image_defaultHead"];
                }else{
                    headImage = image;
                }

            }];
        }
        accountImageView = headImageView;
  
    }else{
        headImageView.hidden = YES;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UIView *headView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 20)];
    headView.clipsToBounds = YES;
    headView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    
    if (section != 0) {
//        UILabel *lineView = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 1)];
//        lineView.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
        //[headView addSubview:lineView];
    }
    
    
    UILabel *lineView2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 19.5, self.view.bounds.size.width, 1)];
    lineView2.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
    
    [headView addSubview:lineView2];
    
    return headView;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        if (indexPath.section == 1 ) {
            if (indexPath.row == 0 || indexPath.row == 2 || indexPath.row == 3 || indexPath.row == 4 || indexPath.row == 5) {
                
                [CommonMethod showNetDisconnectAlert];
                return;
                
            }
        }else if(indexPath.section == 2){
            
            if ([LoginManager sharedManager].loginType == JFGSDKLoginTypeAccountLogin) {
                 [CommonMethod showNetDisconnectAlert];
            }else{
                PhotoSelectionAlertView *actionSheet = [[PhotoSelectionAlertView alloc]initWithMark:@"loginout" delegate:self otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"LOGOUT"],[JfgLanguage getLanTextStrByKey:@"CANCEL"],nil];
                [actionSheet show];
            }
            return;
        }
        
       
    }
    
    switch (indexPath.section) {
        case 0:{
            
        }
            
            break;
        case 1:{
            if (indexPath.row == 0) {
                
                
                PhotoSelectionAlertView *actionSheet = [[PhotoSelectionAlertView alloc]initWithMark:@"photo" delegate:self otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"DOOR_CAMERA"],[JfgLanguage getLanTextStrByKey:@"CHOOSE_PHOTOS"],[JfgLanguage getLanTextStrByKey:@"CANCEL"],nil];
                [actionSheet show];
                
            }else if (indexPath.row == 1){
                
                NSString *content = [NSString stringWithFormat:@"http://www.jfgou.com/app/download.html?id=%@",self.jfgAccount.account];
                if ([OemManager oemType] == oemTypeDoby || [OemManager oemType] == oemTypeCell_C) {
                    content = [NSString stringWithFormat:@"id=%@",self.jfgAccount.account];
                }

                UIImage *defaultImage = [UIImage imageNamed:@"image_defaultHead"];
                if (headImage) {
                    defaultImage = headImage;
                }
                
                PersonQRCodeView *qr = [[PersonQRCodeView alloc]initWithHeadImage:defaultImage name:nickName qrImage:[self qrCodeByAccount:content]];
                [qr show];
                
            }else if (indexPath.row == 2){
                
                SetDeviceNameVC * nickNameVC = [SetDeviceNameVC new];
                nickNameVC.jfgAccount = self.jfgAccount;
                nickNameVC.deviceNameVCType = DeviceNameVCTypeNickName;
                [self.navigationController pushViewController:nickNameVC animated:YES];
                
            }else if (indexPath.row == 3){
                
                SetDeviceNameVC * emailVC = [SetDeviceNameVC new];
                emailVC.jfgAccount = self.jfgAccount;
                if (self.jfgAccount.email.length == 0) {
                    emailVC.deviceNameVCType = DeviceNameVCTypeBindEmail;
                }else{
                    emailVC.deviceNameVCType = DeviceNameVCTypeChangeEmail;
                }
                [self.navigationController pushViewController:emailVC animated:YES];
                
            }else if (indexPath.row == 4){
                ChangePhoneViewController * phoneVC = [ChangePhoneViewController new];
                phoneVC.jfgAccount = self.jfgAccount;
                JFGSDKAcount *acc = [[LoginManager sharedManager] accountCache];
                if (([acc.phone isEqualToString:@""] || acc.phone == nil) && ([acc.email isEqualToString:@""] || acc.email == nil)) {
                    phoneVC.actionType = actionTypeBingPhone;
                }else{
                    phoneVC.actionType = actionTypeChangePhone;
                }
                [self.navigationController pushViewController:phoneVC animated:YES];
                
            }
        }
            
            break;
        case 2:{
            
            ChangePwdViewController * changePwd = [ChangePwdViewController new];
            changePwd.jfgAccount = self.jfgAccount;
            [self.navigationController pushViewController:changePwd animated:YES];
            
        }
            
            break;
        case 3:{
//            PhotoSelectionAlertView *actionSheet = [[PhotoSelectionAlertView alloc]initWithMark:@"loginout" delegate:self otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"LOGOUT"],[JfgLanguage getLanTextStrByKey:@"CANCEL"],nil];
//            [actionSheet show];
            
//            JFGHelpViewController *helpView = [[JFGHelpViewController alloc]init];
//            [self.navigationController pushViewController:helpView animated:YES];
        }
            
            break;
            
        default:
            break;
    }
}


-(NSArray *)dataArray
{
    if (!_dataArray) {
        
        if ([LoginManager sharedManager].loginType == JFGSDKLoginTypeAccountLogin) {
            
            _dataArray = @[
                           @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_Myaccount"]],
                           @[[JfgLanguage getLanTextStrByKey:@"PROFILE_PHOTO"],
                             [JfgLanguage getLanTextStrByKey:@"Tap3_MyQRCode"],
                             [JfgLanguage getLanTextStrByKey:@"ALIAS"],
                             [JfgLanguage getLanTextStrByKey:@"EMAIL"],
                             [JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER"]],
                           @[[JfgLanguage getLanTextStrByKey:@"CHANGE_PWD"]]
                           ];
            
            if ([JfgLanguage languageType] != LANGUAGE_TYPE_CHINESE) {
                _dataArray = @[
                               @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_Myaccount"]],
                               @[[JfgLanguage getLanTextStrByKey:@"PROFILE_PHOTO"],
                                 [JfgLanguage getLanTextStrByKey:@"Tap3_MyQRCode"],
                                 [JfgLanguage getLanTextStrByKey:@"ALIAS"],
                                 [JfgLanguage getLanTextStrByKey:@"EMAIL"],
                                ],
                               @[[JfgLanguage getLanTextStrByKey:@"CHANGE_PWD"]]
                               ];
            }
            
        }else{
            
            BOOL isShowPw = NO;
            if (self.jfgAccount.email && ![self.jfgAccount.email isEqualToString:@""]) {
                isShowPw = YES;
            }
            
            if (self.jfgAccount.phone && ![self.jfgAccount.phone isEqualToString:@""]) {
                isShowPw = YES;
            }
            
            _dataArray = @[
                           @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_Myaccount"]],
                           @[[JfgLanguage getLanTextStrByKey:@"PROFILE_PHOTO"],
                             [JfgLanguage getLanTextStrByKey:@"Tap3_MyQRCode"],
                             [JfgLanguage getLanTextStrByKey:@"ALIAS"],
                             [JfgLanguage getLanTextStrByKey:@"EMAIL"],
                             [JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER"]]];
            
            if (isShowPw) {
                _dataArray = @[
                               @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_Myaccount"]],
                               @[[JfgLanguage getLanTextStrByKey:@"PROFILE_PHOTO"],
                                 [JfgLanguage getLanTextStrByKey:@"Tap3_MyQRCode"],
                                 [JfgLanguage getLanTextStrByKey:@"ALIAS"],
                                 [JfgLanguage getLanTextStrByKey:@"EMAIL"],
                                 [JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER"]],
                               @[[JfgLanguage getLanTextStrByKey:@"CHANGE_PWD"]]];
            }
            
            if ([JfgLanguage languageType] != LANGUAGE_TYPE_CHINESE) {
                
                _dataArray = @[
                               @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_Myaccount"]],
                               @[[JfgLanguage getLanTextStrByKey:@"PROFILE_PHOTO"],
                                 [JfgLanguage getLanTextStrByKey:@"Tap3_MyQRCode"],
                                 [JfgLanguage getLanTextStrByKey:@"ALIAS"],
                                 [JfgLanguage getLanTextStrByKey:@"EMAIL"],
                                ]];
            }
            
            if (isShowPw) {
                _dataArray = @[
                               @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_Myaccount"]],
                               @[[JfgLanguage getLanTextStrByKey:@"PROFILE_PHOTO"],
                                 [JfgLanguage getLanTextStrByKey:@"Tap3_MyQRCode"],
                                 [JfgLanguage getLanTextStrByKey:@"ALIAS"],
                                 [JfgLanguage getLanTextStrByKey:@"EMAIL"],
                                 [JfgLanguage getLanTextStrByKey:@"PHONE_NUMBER"],
                                 ],
                               @[[JfgLanguage getLanTextStrByKey:@"CHANGE_PWD"]]];
            }
            
        }
        
    }
    return _dataArray;
}

-(UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        _tableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        
    }
    return _tableView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat sectionHeaderHeight = 20;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}

-(void)actionSheet:(PhotoSelectionAlertView *)actionSheet mark:(NSString *)mark clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if ([mark isEqualToString:@"loginout"]) {
        
        if (buttonIndex == 0) {
            
            [[LoginManager sharedManager] loginOut];
            LoginLoadingViewController *lo = [LoginLoadingViewController new];
            BaseNavgationViewController * nav = [[BaseNavgationViewController alloc]initWithRootViewController:lo];
            UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
            keyWindows.rootViewController = nav;
            
        }
        
        return;
    }
    if (buttonIndex==0) {
        
        if ([JFGEquipmentAuthority canCameraPermission]) {
            [self pickerController:UIImagePickerControllerSourceTypeCamera];
        }
        
        
    }else if (buttonIndex == 1){
        
        PickerGroupViewController *group = [[PickerGroupViewController alloc]init];
        UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:group];
        [self presentViewController:nav animated:YES completion:nil];
        
    }
    
}

-(void)pickerController:(UIImagePickerControllerSourceType)sourceType
{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    imagePickerController.sourceType = sourceType;
    [self presentViewController:imagePickerController animated:YES completion:^{}];
}


#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    image = [image normalizedImage];
    PickerEditImageViewController *edit = [[PickerEditImageViewController alloc ]init];
    edit.image = image;
    edit.sourceType = PickerEditImageSourceTypeCamera;
    [picker pushViewController:edit animated:YES];

    
}


- (UIImage *)fixOrientation:(UIImage *)originImage
{
    // No-op if the orientation is already correct
    if (originImage.imageOrientation == UIImageOrientationUp)
        return originImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch ((NSInteger)originImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, originImage.size.width, originImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, originImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, originImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
    }
    
    switch ((NSInteger)originImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, originImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, originImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, originImage.size.width, originImage.size.height,
                                             CGImageGetBitsPerComponent(originImage.CGImage), 0,
                                             CGImageGetColorSpace(originImage.CGImage),
                                             CGImageGetBitmapInfo(originImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (originImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,originImage.size.height,originImage.size.width), originImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,originImage.size.width,originImage.size.height), originImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//生成有关账号信息的二维码
-(UIImage *)qrCodeByAccount:(NSString *)account
{
    // 1.创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2.恢复默认
    [filter setDefaults];
    // 3.给过滤器添加数据
    NSString *dataString = account;
    NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
    // 4.通过KVO设置滤镜inputMessage数据
    [filter setValue:data forKeyPath:@"inputMessage"];
    // 4.获取输出的二维码
    CIImage *outputImage = [filter outputImage];
    // 5.将CIImage转换成UIImage，并放大显示
    UIImage *image = [self createNonInterpolatedUIImageFormCIImage:outputImage withSize:143];
//    UIImage *image = [UIImage imageWithCIImage:outputImage scale:1.0 orientation:UIImageOrientationUp];
    return  image;
}


- (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat) size {
    
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
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
