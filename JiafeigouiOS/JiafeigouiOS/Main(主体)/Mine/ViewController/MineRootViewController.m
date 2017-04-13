//
//  MineRootViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/5/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "MineRootViewController.h"
#import "LoginManager.h"
#import "DateTools.h"
#import "TimeChangeMonitor.h"
#import "FLGlobal.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import <MXParallaxHeader/MXScrollView.h>
#import "BadgeLabel.h"
#import "ShareRootViewController.h"
#import "FriendsMainVC.h"
#import "AboutUsViewController.h"
#import "DeviceSettingVC.h"
#import "HelpViewController.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKDataPoint.h>
#import "SDImageCache.h"
#import "SDWebImageManager.h"
#import "PersonMsgViewController.h"
#import "TimeDelayVideoPlayer.h"
#import "DeviceSettingVC.h"
#import "LSAlertView.h"
#import "JfgConfig.h"
#import "SysMsgViewController.h"
#import "JFGHelpViewController.h"
#import "JfgLanguage.h"
#import "LoginRegisterViewController.h"
#import "UIImageView+WebCache.h"
#import "CommonMethod.h"
#import "UIButton+WebCache.h"
#import "SetDeviceNameVC.h"
#import "UIImageView+JFGImageView.h"
#import "UIImage+ImageEffects.h"
#import "ChangePhoneViewController.h"
#import "UIAlertView+FLExtension.h"
#import <Accelerate/Accelerate.h>
#import <KVOController/KVOController.h>

#define HeadImageHeight 75
#define HeadAndName 103


@interface MineRootViewController ()<LoginManagerDelegate,TimeChangeMonitorDelegate,UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate>
{
    UIImage *_headImage;
    NSString *account_name;
    NSInteger unreadCount;
    BOOL hasBindPhone;
    BOOL hasBindEmail;
    BOOL isLoadedNetImage;
    NSInteger headImageVersion;
    JFGSDKAcount *currentAccount;
    
    NSInteger headGetCount;
}
@property(nonatomic, strong)UIImageView * topBgImageView;

@property(nonatomic, strong)UIImageView * headPhotoImageView;
@property(nonatomic, strong)UIButton * nameButton;
@property(nonatomic, strong)UIButton * nameButton_top;
@property(nonatomic, strong)UITableView * myTableView;
@property(nonatomic, strong)UIButton * myMessageButton;
@property(nonatomic, strong)BadgeLabel * badgeLabel;
@property(nonatomic, strong)UIView * barView;
@property(nonatomic, strong)UIView * coverView;
@property(nonatomic, strong)CAGradientLayer * dayGradient;
@property(nonatomic, strong)CAGradientLayer * nightGradient;
@property(nonatomic, strong)NSArray * imageArray;
@property(nonatomic, strong)NSArray * titleArray;

@end

@implementation MineRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.imageArray = @[@"image_myFriends",@"image_shareDevice",@"image_help&feedback",@"image_setting"];
    self.titleArray = @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends"],[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice"],[JfgLanguage getLanTextStrByKey:@"Tap3_Feedback"],[JfgLanguage getLanTextStrByKey:@"SETTINGS"]];
    headImageVersion = 0;
    isLoadedNetImage = NO;
    headGetCount = 0;
    _headImage = [UIImage imageNamed:@"image_defaultHead"];
    topBgViewHeight = (int)kheight*0.37;
    nameButtonY = topBgViewHeight-(topBgViewHeight-HeadAndName)/2.0-HeadImageHeight-12+34;
    [[LoginManager sharedManager] addDelegate:self];
    [JFGSDK addDelegate:self];
    //头像改变通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setheadImageView) name:account_headImage_changed object:nil];
    [self.view addSubview:self.myTableView];
    [self initHeaderView];
    //self.edgesForExtendedLayout = UIRectEdgeNone;
    
    //scroll莫名其妙偏移
    if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
    {
        self.edgesForExtendedLayout = UIRectEdgeBottom;
    }
    
    [self intiData];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self unreadCountForBindMsg];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
//    if (headGetCount < 3 ) {
//        if (headGetCount != 0) {
//            [self intiData];
//        }
//        headGetCount ++;
//    }
}



-(void)intiData
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        JFGSDKAcount *acc = [LoginManager sharedManager].accountCache;
        if (acc) {
            [self jfgUpdateAccount:acc];
        }else{
            [self.nameButton setTitle:@"" forState:UIControlStateNormal];
            [self.nameButton_top setTitle:@"" forState:UIControlStateNormal];
        }
        [JFGSDK getAccount];
    }else if([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut){
        [self loginOut];
    }else{
        JFGSDKAcount *acc = [LoginManager sharedManager].accountCache;
        [self jfgUpdateAccount:acc];
    }
}


-(void)unreadCountForBindMsg
{
    [[JFGSDKDataPoint sharedClient] robotCountDataWithPeer:@"" dpIDs:@[@(601),@(701)] success:^(NSString *identity, NSArray<DataPointCountSeg *> *dataList) {
        
        NSInteger count = 0;
        
        for (DataPointCountSeg *seg in dataList) {

            if (seg.msgId == 601) {
                count = seg.count + count;
            }else if(seg.msgId == 701){
                count = seg.count + count;
            }

        }
        if (count == 0) {
            self.badgeLabel.hidden = YES;
        }else{
            self.badgeLabel.hidden = NO;
            self.badgeLabel.newMessageCount = count;
            
        }
    } failure:^(RobotDataRequestErrorType type) {
        
    }];
}


//获取用户头像
-(void)setheadImageView
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut) {
        
        _headImage = [UIImage imageNamed:@"image_defaultHead"];
        _headPhotoImageView.image = [UIImage imageNamed:@"image_defaultHead"];
        [self createBlurBackgroundImage:nil ImageView:self.topBgImageView blurRadius:40];
        
    }else if([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess){
        
        [self.headPhotoImageView jfg_setImageWithAccount:nil placeholderImage:_headImage refreshCached:YES completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                NSLog(@"imageFrom:%ld",(long)cacheType);
                _headImage = image;
                [self createBlurBackgroundImage:_headImage ImageView:self.topBgImageView blurRadius:40];
            }
        }];
        
    }else{
        
        NSInteger oldVersion = [[[NSUserDefaults standardUserDefaults] objectForKey:JFGAccountHeadImageVersion] integerValue];
        [self.headPhotoImageView jfg_setImageWithAccount:nil photoVersion:oldVersion completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            if (image) {
                _headImage = image;
                [self createBlurBackgroundImage:_headImage ImageView:self.topBgImageView blurRadius:40];
            }else{
                _headImage = [UIImage imageNamed:@"image_defaultHead"];
                _headPhotoImageView.image = [UIImage imageNamed:@"image_defaultHead"];
                [self createBlurBackgroundImage:nil ImageView:self.topBgImageView blurRadius:40];
            }
        }];
        
    }
    
}


-(void)jfgAccountOnline:(BOOL)online
{
    if (online) {
        [JFGSDK getAccount];
    }
}

-(void)loginOut
{
    [self setheadImageView];
    //退出登录
    self.badgeLabel.hidden = YES;
    [self.nameButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_LogIn"] forState:UIControlStateNormal];
    [self.nameButton_top setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_LogIn"] forState:UIControlStateNormal];
    CGSize size = CGSizeOfString(self.nameButton.titleLabel.text, CGSizeMake(self.view.bounds.size.width, self.nameButton.height), self.nameButton.titleLabel.font);
    self.nameButton.width = size.width;
    self.nameButton.x = self.view.x;
}



-(void)jfgUpdateAccount:(JFGSDKAcount *)account
{
    NSLog(@"alias=%@",account.alias);
    NSLog(@"account=%@",account.account);
    NSLog(@"email=%@",account.email);
    currentAccount = account;
    [self resetViewMsg];
}

-(void)resetViewMsg
{
    if (currentAccount) {
        
        if (currentAccount.alias && ![currentAccount.alias isEqualToString:@""]) {
            account_name = currentAccount.alias;
        }else{
            if (currentAccount.account && ![currentAccount.account isEqualToString:@""]) {
                account_name = currentAccount.account;
                
                if ([account_name isEqualToString:currentAccount.email]) {
                    
                    NSRange range = [currentAccount.email rangeOfString:@"@"];
                    if (range.location != NSNotFound) {
                        account_name = [currentAccount.email substringToIndex:range.location];
                    }else{
                        account_name = currentAccount.email;
                    }
                    
                }
                
                
            }else if(currentAccount.phone && ![currentAccount.phone isEqualToString:@""]){
                account_name = currentAccount.phone;
            }else{
                NSRange range = [currentAccount.email rangeOfString:@"@"];
                if (range.location != NSNotFound) {
                    account_name = [currentAccount.email substringToIndex:range.location];
                }else{
                    account_name = currentAccount.email;
                }
                
            }
        }
        
        if (account_name.length > 12) {
            account_name = [account_name substringToIndex:12];
        }
        
        if (account_name && ![account_name isEqualToString:@""]) {
            [self.nameButton setTitle:account_name forState:UIControlStateNormal];
            [_nameButton_top setTitle:account_name forState:UIControlStateNormal];
            CGSize size = CGSizeOfString(self.nameButton.titleLabel.text, CGSizeMake(self.view.bounds.size.width, self.nameButton.height), self.nameButton.titleLabel.font);
            self.nameButton.width = size.width;
            self.nameButton.x = self.view.x;
        }
        
        //判断是否绑定了手机号
        if (currentAccount.phone && ![currentAccount.phone isEqualToString:@""]) {
            hasBindPhone = YES;
        } else {
            hasBindPhone = NO;
        }
        
        if (!currentAccount.email || [currentAccount.email isEqualToString:@""]) {
            hasBindEmail = NO;
        }else{
            hasBindEmail = YES;
        }
    }
    [self setheadImageView];
    headImageVersion = currentAccount.photoVersion;
}

-(void)jfgResultIsRelatedToAccountWithType:(JFGAccountResultType)type error:(JFGErrorType)errorType
{
    if (type == JFGAccountResultTypeUpdataAccount) {
        [JFGSDK getAccount];
    }
}

-(void)intoPersonMsgView
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut) {
        
        [self gotoLoginVC];
       
    }else{
        PersonMsgViewController *per = [PersonMsgViewController new];
        per.jfgAccount = currentAccount;
        per.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:per animated:YES];
    }
}


-(void)gotoLoginVC
{
    LoginRegisterViewController *loginRegister = [LoginRegisterViewController new];
    loginRegister.viewType = FristIntoViewTypeLogin;
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:loginRegister];
    nav.navigationBarHidden = YES;
    [self presentViewController:nav animated:YES completion:^{
        
    }];
}

-(void)initHeaderView
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, -topBgViewHeight, self.view.width, topBgViewHeight)];
    [headerView addSubview:self.headPhotoImageView];
    [headerView addSubview:self.nameButton];
    [self stretchHeaderView:self.topBgImageView subViews:headerView];
}

#pragma mark - 表格相关
#pragma mark -UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.imageArray.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * cellID = @"cell0";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
        cell.selectedBackgroundView.backgroundColor = CellSelectedColor;
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.imageView.image = [UIImage imageNamed:self.imageArray[indexPath.row]];
    cell.textLabel.text = self.titleArray[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-medium" size:16];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.textColor = [UIColor colorWithHexString:@"#383838"];

    return cell;
}


#pragma mark -UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 62.0;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut || [LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLogining) {
        [self gotoLoginVC];
        return;
    }else{
        
        if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
            
            switch (indexPath.row) {
                case 0:
                case 1:
                case 2:
                    [CommonMethod showNetDisconnectAlert];
                    return;
                    break;
                    
                default:
                    break;
            }
            
        }
        
        
    }
    
    switch (indexPath.row)
    {
        case 0: //亲友
        {
            if (([LoginManager sharedManager].loginType != JFGSDKLoginTypeAccountLogin) && !hasBindPhone && !hasBindEmail) {
    
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Tap3_Friends_NoBindTips"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"Tap2_Index_Open_NoDeviceOption"], nil];
                [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                    
                    if (buttonIndex == 1) {
                        if ([JfgLanguage languageType] == 0) {
                            ChangePhoneViewController * setNameVC = [ChangePhoneViewController new];
                            setNameVC.actionType = actionTypeBingPhone;
                            setNameVC.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:setNameVC animated:YES];
                        }else{
                            SetDeviceNameVC * emailVC = [SetDeviceNameVC new];
                            emailVC.jfgAccount = currentAccount;
                            emailVC.deviceNameVCType = DeviceNameVCTypeBindEmail;
                            [self.navigationController pushViewController:emailVC animated:YES];
                        }
                    }
                    
                } otherDelegate:nil];
                
                
                return;
            }
            
            FriendsMainVC *friends = [FriendsMainVC new];
            friends.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:friends animated:YES];
           
        }
            break;
        case 1:
        {
            if (([LoginManager sharedManager].loginType != JFGSDKLoginTypeAccountLogin) && !hasBindPhone && !hasBindEmail) {
                
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Tap3_Share_NoBindTips"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"Tap2_Index_Open_NoDeviceOption"], nil];
                [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                    
                    if (buttonIndex == 1) {
                        if ([JfgLanguage languageType] == 0) {
                            ChangePhoneViewController * setNameVC = [ChangePhoneViewController new];
                            setNameVC.actionType = actionTypeBingPhone;
                            setNameVC.hidesBottomBarWhenPushed = YES;
                            [self.navigationController pushViewController:setNameVC animated:YES];
                        }else{
                            SetDeviceNameVC * emailVC = [SetDeviceNameVC new];
                            emailVC.jfgAccount = currentAccount;
                            emailVC.deviceNameVCType = DeviceNameVCTypeBindEmail;
                            [self.navigationController pushViewController:emailVC animated:YES];
                        }
                    }
                    
                } otherDelegate:nil];
                
                
                return;
            }
            ShareRootViewController *share = [ShareRootViewController new];
            share.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:share animated:YES];
        }
            break;
        case 2:{
            JFGHelpViewController * help = [[JFGHelpViewController alloc]init];
            help.showRightBarItem = YES;
            help.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:help animated:YES];
        }
            break;
        case 3:{
            
            DeviceSettingVC * device = [[DeviceSettingVC alloc]init];
            device.pType = productType_Mine;
            device.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:device animated:YES];

        }
            break;
        default:
            break;
    }
}

#pragma mark- 顶部视图相关
- (void)stretchHeaderView:(UIView*)view subViews:(UIView *)subview
{
    //设置顶部被拉伸的图片
    self.myTableView.parallaxHeader.view =view;
    self.myTableView.parallaxHeader.view.backgroundColor = [UIColor grayColor];
    defaultViewHeight = view.size.height;
    
    //设置顶部图片显示区域高度
    self.myTableView.parallaxHeader.height = defaultViewHeight;
    self.myTableView.parallaxHeader.mode = MXParallaxHeaderModeFill;
    
    //设置上推之后留出的最小距离
    self.myTableView.parallaxHeader.minimumHeight = 64;
    
    //头部视图上添加模拟的navigationBar,同时也是一个遮罩，随着滚动颜色渐变
    [self.myTableView.parallaxHeader.view addSubview:self.barView];
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut || [LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLogining) {
        //覆盖一层灰色蒙版
        [self.myTableView.parallaxHeader.view addSubview:self.coverView];
    }
    [self.barView addSubview:self.nameButton_top];
    [self.barView addSubview:self.myMessageButton];
    self.badgeLabel.hidden = YES;
    [self.barView addSubview:self.badgeLabel];
    [self.view insertSubview:self.nameButton_top atIndex:1];
    [self.view insertSubview:self.myMessageButton atIndex:2];
    [self.view insertSubview:self.badgeLabel aboveSubview:self.myMessageButton];

    //添加到tableview上的视图，会随着tableview的拖拉变动而变动
    //添加文字内容到tableview上（parallaxHeader的height随着滚动会发生改变，位置不可控）
    [self.myTableView addSubview:subview];

}

#pragma mark -UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView*)scrollView
{
    //parallaxHeader.view的高度;
    CGFloat topHeight ;
    if (scrollView.parallaxHeader.progress<0) {
        //上推
        topHeight = scrollView.parallaxHeader.height-fabs(scrollView.parallaxHeader.progress *scrollView.parallaxHeader.height);
    }else{
        //下拉
        topHeight = scrollView.parallaxHeader.height+fabs(scrollView.parallaxHeader.progress) *scrollView.parallaxHeader.height;
    }
    //往上滚动了，顶部视图高度小于原始高度
    if (topHeight < defaultViewHeight-2) {
        
        //设置遮罩的高度与顶部视图高度一致
        self.barView.height  = topHeight;

        if (fabs(scrollView.contentOffset.y)<defaultViewHeight) {
            self.barView.alpha = (defaultViewHeight-topHeight)/(defaultViewHeight-64);
            self.coverView.alpha =0.2*(1-(defaultViewHeight-topHeight)/(defaultViewHeight-64));
        }
    }else {
        
        self.barView.alpha = 0;
        self.coverView.alpha = 0.1;
        self.barView.height  = topHeight;
    }
    self.coverView.height = topHeight;

   if(scrollView.contentOffset.y>=-nameButtonY)
   {
       self.nameButton_top.alpha =1;
       self.nameButton.alpha = 0;
   }
    else
    {
        self.nameButton_top.alpha =0;
        self.nameButton.alpha = 1;
    }
}
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{

}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
   
}
#pragma mark - 模糊头像背景
-(void)createBlurBackgroundImage:(UIImage *)image ImageView:(UIImageView *)imageView blurRadius:(CGFloat)radius{
    
    if (image) {
        imageView.image = image;
    } else {
        self.topBgImageView.image = [UIImage imageNamed:@"bgimage_top_default"];
        NSLog(@"默认背景!");
    }
    
}


//- (UIImage *)accelerateBlurWithImage:(UIImage *)image
//{
//    NSInteger boxSize = (NSInteger)(10 * 5);
//    boxSize = boxSize - (boxSize % 2) + 1;
//    
//    CGImageRef img = image.CGImage;
//    
//    vImage_Buffer inBuffer, outBuffer, rgbOutBuffer;
//    vImage_Error error;
//    
//    void *pixelBuffer, *convertBuffer;
//    
//    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
//    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
//    
//    convertBuffer = malloc( CGImageGetBytesPerRow(img) * CGImageGetHeight(img) );
//    rgbOutBuffer.width = CGImageGetWidth(img);
//    rgbOutBuffer.height = CGImageGetHeight(img);
//    rgbOutBuffer.rowBytes = CGImageGetBytesPerRow(img);
//    rgbOutBuffer.data = convertBuffer;
//    
//    inBuffer.width = CGImageGetWidth(img);
//    inBuffer.height = CGImageGetHeight(img);
//    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
//    inBuffer.data = (void *)CFDataGetBytePtr(inBitmapData);
//    
//    pixelBuffer = malloc( CGImageGetBytesPerRow(img) * CGImageGetHeight(img) );
//    
//    if (pixelBuffer == NULL) {
//        NSLog(@"No pixelbuffer");
//    }
//    
//    outBuffer.data = pixelBuffer;
//    outBuffer.width = CGImageGetWidth(img);
//    outBuffer.height = CGImageGetHeight(img);
//    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
//    
//    void *rgbConvertBuffer = malloc( CGImageGetBytesPerRow(img) * CGImageGetHeight(img) );
//    vImage_Buffer outRGBBuffer;
//    outRGBBuffer.width = CGImageGetWidth(img);
//    outRGBBuffer.height = CGImageGetHeight(img);
//    outRGBBuffer.rowBytes = 5;
//    outRGBBuffer.data = rgbConvertBuffer;
//    
//    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
//    
//    if (error) {
//        NSLog(@"error from convolution %ld", error);
//    }
//    const uint8_t mask[] = {2, 1, 0, 3};
//    
//    vImagePermuteChannels_ARGB8888(&outBuffer, &rgbOutBuffer, mask, kvImageNoFlags);
//    
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
//    CGContextRef ctx = CGBitmapContextCreate(rgbOutBuffer.data,
//                                             rgbOutBuffer.width,
//                                             rgbOutBuffer.height,
//                                             8,
//                                             rgbOutBuffer.rowBytes,
//                                             colorSpace,
//                                             kCGImageAlphaNoneSkipLast);
//    CGImageRef imageRef = CGBitmapContextCreateImage(ctx);
//    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
//    
//    //clean up
//    CGContextRelease(ctx);
//    
//    free(pixelBuffer);
//    free(convertBuffer);
//    free(rgbConvertBuffer);
//    CFRelease(inBitmapData);
//    
//    CGColorSpaceRelease(colorSpace);
//    CGImageRelease(imageRef);
//    
//    return returnImage;
//}

#pragma mark - Getter
-(UIImageView *)topBgImageView{
    if (!_topBgImageView) {
        _topBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, topBgViewHeight)];
        _topBgImageView.backgroundColor = [UIColor whiteColor];
        _topBgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _topBgImageView.clipsToBounds = YES;
        _topBgImageView.image = [UIImage imageNamed:@"bgimage_top_default"];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effectview = [[UIVisualEffectView alloc] initWithEffect:blur];
        effectview.frame = _topBgImageView.bounds;
        [_topBgImageView addSubview:effectview];
        

        [self.KVOController observe:self.topBgImageView keyPaths:@[@"bounds"] options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            
            effectview.frame = self.topBgImageView.bounds;
            
        }];
        
    }
    return _topBgImageView;
}
-(UIImageView *)headPhotoImageView{
    if (!_headPhotoImageView) {
        _headPhotoImageView = [UIImageView new];
        _headPhotoImageView.userInteractionEnabled = YES;

        //[_headPhotoButton setImage:[UIImage imageNamed:@"image_defaultHead"] forState:UIControlStateNormal];
        _headPhotoImageView.image = [UIImage imageNamed:@"image_defaultHead"];
        _headPhotoImageView.frame = CGRectMake((Kwidth-HeadImageHeight)/2.0, (topBgViewHeight-HeadAndName)/2.0, HeadImageHeight, HeadImageHeight);
        _headPhotoImageView.layer.cornerRadius = HeadImageHeight/2;
        _headPhotoImageView.layer.masksToBounds = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(intoPersonMsgView)];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        [_headPhotoImageView addGestureRecognizer:tap];
        //[_headPhotoImageView addTarget:self action:@selector(intoPersonMsgView) forControlEvents:UIControlEventTouchUpInside];
    }
    return _headPhotoImageView;
}
-(UIButton *)nameButton{
    if (!_nameButton) {
        _nameButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nameButton.frame =  CGRectMake((Kwidth-200)/2.0, self.headPhotoImageView.bottom+12.0, 200, 16);
        _nameButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-regular" size:16];
        [_nameButton setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_LogIn"] forState:UIControlStateNormal];
        _nameButton.titleLabel.font = [UIFont systemFontOfSize:17];
        _nameButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        _nameButton.titleLabel.textColor = [UIColor whiteColor];
        _nameButton.alpha = 1;
        [_nameButton addTarget:self action:@selector(intoPersonMsgView) forControlEvents:UIControlEventTouchUpInside];

    }
    return _nameButton;
}
-(UIButton *)nameButton_top
{
    if (!_nameButton_top) {
        _nameButton_top = [UIButton buttonWithType:UIButtonTypeCustom];
        _nameButton_top.frame = CGRectMake((Kwidth-300)/2.0, 34, 300, 16);
        _nameButton_top.titleLabel.font = [UIFont fontWithName:@"PingFangSC-regular" size:16];
        [_nameButton_top setTitle:self.nameButton.titleLabel.text forState:UIControlStateNormal];
        _nameButton_top.titleLabel.font = [UIFont systemFontOfSize:17];
        _nameButton_top.titleLabel.textAlignment = NSTextAlignmentCenter;
        _nameButton_top.titleLabel.textColor = [UIColor whiteColor];
        _nameButton_top.alpha = 0;
    }
    return _nameButton_top;
}
-(UITableView *)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight-49) style:UITableViewStylePlain];
        [_myTableView setTableFooterView:[UIView new]];
        _myTableView .dataSource = self;
        _myTableView.delegate = self;
        _myTableView.showsVerticalScrollIndicator = NO;
        _myTableView.showsHorizontalScrollIndicator = NO;
        _myTableView .backgroundColor = [UIColor whiteColor];
        [_myTableView setSeparatorColor:TableSeparatorColor];
    }
    return _myTableView;
}


-(UIButton *)myMessageButton
{
    if (!_myMessageButton) {
        _myMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _myMessageButton.frame = CGRectMake(Kwidth-15-22-10, 32-10, 22+20, 20+20);
        _myMessageButton.adjustsImageWhenHighlighted = NO;
        [_myMessageButton setImage:[UIImage imageNamed:@"image_myMessages"] forState:UIControlStateNormal];
        //[_myMessageButton setBackgroundImage:[UIImage imageNamed:@"image_myMessages"] forState:UIControlStateNormal];
        [_myMessageButton addTarget:self action:@selector(sysMsgAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _myMessageButton;
}

-(void)sysMsgAction
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLoginOut || [LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusLogining) {
       [self gotoLoginVC];
    }else{
        SysMsgViewController *sysMsg = [SysMsgViewController new];
        sysMsg.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sysMsg animated:YES];
    }
}

-(BadgeLabel *)badgeLabel
{
    if (!_badgeLabel) {
        _badgeLabel = [[BadgeLabel alloc]init];
        _badgeLabel.bounds = CGRectMake(0, 0, 26, 16);//26表示规定长度加上左右偏移长度,多1是因为裁剪的圆角有问题,看起少了2像素
        _badgeLabel.center = CGPointMake(Kwidth-15, 32);
        _badgeLabel.newMessageCount = 0;
    }
    return _badgeLabel;
}
-(UIView *)barView
{
    if (!_barView) {
        _barView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, defaultViewHeight)];
        NSDate *now = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSUInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
        if (dateComponent.hour >=6 && dateComponent.hour < 18) {
            [self setBarViewColor:YES];
        }else{
            [self setBarViewColor:NO];
        }
        _barView.alpha = 0;
        _barView.userInteractionEnabled = YES;
    }
    return _barView;
}
-(UIView *)coverView{
    if (!_coverView) {
        _coverView = [UIView new];
        [_coverView setFrame:CGRectMake(0, 0, Kwidth, defaultViewHeight)];
        [_coverView setBackgroundColor:[UIColor blackColor]];
        _coverView.alpha = 0;
    }
    return _coverView;
}
-(void)setBarViewColor:(BOOL)day
{
    if (!day) {
        
        CALayer *layer = [[self.barView.layer sublayers] objectAtIndex:0];
        if (layer == self.nightGradient) {
            return;
        }
        [self.dayGradient removeFromSuperlayer];
        [self.barView.layer insertSublayer:self.nightGradient atIndex:0];
        
    }else{
        
        CALayer *layer = [[self.barView.layer sublayers] objectAtIndex:0];
        if (layer == self.dayGradient) {
            return;
        }
        [self.nightGradient removeFromSuperlayer];
        [self.barView.layer insertSublayer:self.dayGradient atIndex:0];
    }
}

-(CAGradientLayer *)dayGradient
{
    if (!_dayGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.barView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#54b2d0"].CGColor,
                           (id)[UIColor colorWithHexString:@"#439ac4"].CGColor,
                           nil];
        
        _dayGradient = gradient;
    }
    return _dayGradient;
}

-(CAGradientLayer *)nightGradient
{
    if (!_nightGradient) {
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = self.barView.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithHexString:@"#7590ae"].CGColor,
                           (id)[UIColor colorWithHexString:@"#3a5170"].CGColor,
                           nil];
        _nightGradient = gradient;
    }
    return _nightGradient;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"MineRootViewController");
}

@end
