//
//  LoginManager.m
//  
//
//  Created by 杨利 on 16/5/26.
//  Copyright © 2016年 . All rights reserved.

#import "LoginManager.h"
#import "UserAccountMsg.h"
#import "CommonMethod.h"
#import "ApnsManger.h"
#import "JfgUserDefaultKey.h"
#import "JfgConfig.h"
#import "NetworkMonitor.h"
#import "FLShareSDKHelper.h"
#import <Bugly/Bugly.h>
#import "JfgConfig.h"
#import "SDWebImageManager.h"
#import "ProgressHUD.h"
#import "JfgLanguage.h"
#import "JfgCacheManager.h"
#import "LoginLoadingViewController.h"
#import "CheckVersionHelper.h"
#import "UIAlertView+FLExtension.h"
#import "LoginRegisterViewController.h"

static NSString * const JFGLoginStatuRecodeKey = @"JFGLOGINMARKFORUSERDEFAULT";
static NSString * const JFGLoginSessionKey = @"JFGLoginSessionKey";
static NSString * const JFGOpenLoginAccessToken = @"JFGOpenLoginAccessToken";
static NSString * const JFGOpenAccessTokenKey = @"JFGOpenAccessTokenKey";
static NSString * const JFGOpenexpiredDateKey = @"JFGOpenexpiredDateKey";

@interface LoginManager()<JFGSDKCallbackDelegate>
{
    NSHashTable *_hashTable;
    NSString *currentAccount;
    BOOL currentLoginStatu;
    BOOL isLoginOuttime;
    BOOL isAutoLogin;
    NSString *thirdNickName;
    NSString *thirdIcon;
    JFGSDKAcount *cacheAccount;
    BOOL isLoadingUserheadImageing;
}
@end

@implementation LoginManager

+(instancetype)sharedManager
{
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

-(id)init
{
    self = [super init];
    [JFGSDK addDelegate:self];
    _hashTable = [[NSHashTable alloc]initWithOptions:NSPointerFunctionsWeakMemory capacity:50];
    //NSInteger loginStatu = [[[NSUserDefaults standardUserDefaults] objectForKey:JFGAccountLoginStatueSaveKey] intValue];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground) name:UIApplicationWillTerminateNotification object:nil];
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:JFGCurrentLoginedAccountKey] && ![self isExited]) {
        self.loginStatus = JFGSDKCurrentLoginStatusLoginFailed;
    }else{
        self.loginStatus = JFGSDKCurrentLoginStatusLoginOut;
    }
    
    
    return self;
}

-(void)loginWithAccount:(NSString *)account password:(NSString *)password
{
    if (!account || !password) {
        [self loginFailRespone:JFGErrorTypeLoginInvalidPass];
        return;
    }
    self.loginType = JFGSDKLoginTypeAccountLogin;
    isAutoLogin = NO;
    JFGErrorType error = [JFGSDK userLogin:account keyword:password cerType:[ApnsManger certType]];
    NSLog(@"LoginReqResult:%lu",(unsigned long)error);
    [UserAccountMsg saveAccount:account withPw:password];
    currentAccount = account;
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:JFGCurrentLoginedAccountKey];
    [[NSUserDefaults standardUserDefaults] setObject:account forKey:JFGCurrentLoginedAccountKey];
    //self.loginStatus = JFGSDKCurrentLoginStatusLogining;
    
}

-(void)openLoginByQQ
{
    //self.loginStatus = JFGSDKCurrentLoginStatusLogining;
    isAutoLogin = NO;
    [FLShareSDKHelper qqForThirdPartyLoginWithlogintResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        
        //4815BAEA80A3698078597D124E1F1C56
        [self openLoginResultWithType:JFGSDKLoginTypeOpenLoginForQQ rspState:state baseUser:user error:error];
       
        
    }];
}

-(void)openLoginByweibo
{
    //self.loginStatus = JFGSDKCurrentLoginStatusLogining;
    isAutoLogin = NO;
    [FLShareSDKHelper sinaWebForThirdPartyLoginWithlogintResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        
        [self openLoginResultWithType:JFGSDKLoginTypeOpenLoginForSinaWeibo rspState:state baseUser:user error:error];
        
    }];
}

-(void)openLoginByType:(JFGSDKLoginType)type
{
    isAutoLogin = NO;
    SSDKPlatformType platformType = SSDKPlatformTypeUnknown;
    
    if (type == JFGSDKLoginTypeOpenLoginForQQ) {
        platformType = SSDKPlatformTypeQQ;
    }else if (type == JFGSDKLoginTypeOpenLoginForSinaWeibo){
        platformType = SSDKPlatformTypeSinaWeibo;
    }else if (type == JFGSDKLoginTypeOpenLoginForTwitter){
        platformType = SSDKPlatformTypeTwitter;
    }else if (type == JFGSDKLoginTypeOpenLoginForFacebook){
        platformType = SSDKPlatformTypeFacebook;
    }
    
    [FLShareSDKHelper thirdPartyLoginForSSDKPlatformType:platformType logintResult:^(SSDKResponseState state, SSEBaseUser *user, NSError *error) {
        
        [self openLoginResultWithType:type rspState:state baseUser:user error:error];
        
    }];
}

-(void)openLoginResultWithType:(JFGSDKLoginType)loginType
                      rspState:(SSDKResponseState)state
                      baseUser:(SSEBaseUser *)user
                         error:(NSError *)error
{
    if (state==SSDKResponseStateSuccess)
    {
        
        self.loginType = loginType;
        
        NSString *accessToken = @"";
        for (NSString *key in user.socialUsers.allKeys) {
            
            
            id obj = [user.socialUsers objectForKey:key];
            if ([obj isKindOfClass:[SSDKUser class]]) {
                
                SSDKUser *user = obj;
                thirdNickName = user.nickname;
                thirdIcon = user.icon;
                SSDKCredential *credential = user.credential;
                NSString *_accessToken = credential.token;
                accessToken = _accessToken;
                NSDate *expiredDate = credential.expired;
                
                NSMutableDictionary *parame = [[NSMutableDictionary alloc]init];
                [parame setObject:_accessToken forKey:JFGOpenAccessTokenKey];
                if (expiredDate == nil) {
                    expiredDate = [NSDate distantFuture];
                }
                [parame setObject:expiredDate forKey:JFGOpenexpiredDateKey];
                [[NSUserDefaults standardUserDefaults] setObject:parame forKey:JFGOpenLoginAccessToken];
                
            }
            
        }
        
        currentAccount = user.linkId;
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JFGCurrentLoginedAccountKey];
        [[NSUserDefaults standardUserDefaults] setObject:currentAccount forKey:JFGCurrentLoginedAccountKey];
        
        int tp = 0;
       
        switch (loginType) {
            case 1://qq
                tp = 3;
                break;
            case 2://sinaweibo
                tp = 4;
                break;
            case 3:
                tp=6;//
                break;
            case 4:
                tp=7;//facebook
                break;
            default:
                break;
        }
        [JFGSDK openLoginWithOpenId:user.linkId accessToken:accessToken cerType:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"certType"] loginType:tp];
        [Bugly setUserValue:user.linkId forKey:@"account"];
        self.loginStatus = JFGSDKCurrentLoginStatusSuccess;
        
        
    }else if (state==SSDKResponseStateCancel){
        //取消
        //[ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap0_Authorizationfailed"]];
        [self authorizationfailedAlert];
        self.loginStatus = JFGSDKCurrentLoginStatusLoginOut;
        isAutoLogin = NO;
    }else{
        //失败
        //[ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap0_Authorizationfailed"]];
        [self authorizationfailedAlert];
        self.loginStatus = JFGSDKCurrentLoginStatusLoginOut;
        isAutoLogin = NO;
    }
}



-(BOOL)loginOut
{
    BOOL isSuccess = [JFGSDK logout];
    self.loginStatus = JFGSDKCurrentLoginStatusLoginOut;
    [self setLoginStatu:NO];
    currentLoginStatu = NO;
    cacheAccount = nil;
    [self loginOutRespone];
    [[NSNotificationCenter defaultCenter] postNotificationName:JFGAccountLoginOutKey object:nil];
    
    if (self.loginType == JFGSDKLoginTypeAccountLogin) {
        [UserAccountMsg deleteWithAccount:currentAccount];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JFGOpenLoginAccessToken];
    }
    [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"AppLoginOut:%@",currentAccount]];
    
    return isSuccess;
}


-(BOOL)isExited
{
    if (self.loginType == JFGSDKLoginTypeAccountLogin) {
        NSString *lastAccount = [[NSUserDefaults standardUserDefaults] objectForKey:JFGCurrentLoginedAccountKey];
        if (lastAccount) {
            
            NSString *key = [UserAccountMsg pwWithAccount:lastAccount];
            if (key && ![key isEqualToString:@""]) {
                return NO;
            }
        }
    }else{
        
        NSString *linkID = [[NSUserDefaults standardUserDefaults] objectForKey:JFGCurrentLoginedAccountKey];
        
        if (linkID) {
            
            NSDictionary *parame = [[NSUserDefaults standardUserDefaults] objectForKey:JFGOpenLoginAccessToken];
            if (parame) {
                return NO;
            }
            
        }
        
    }
    return YES;
}

-(void)loginForLastTimeAccount
{
    if (self.loginType == JFGSDKLoginTypeAccountLogin) {
    
        NSString *lastAccount = [[NSUserDefaults standardUserDefaults] objectForKey:JFGCurrentLoginedAccountKey];
        if (lastAccount) {
            
            NSString *key = [UserAccountMsg pwWithAccount:lastAccount];
            if (key && ![key isEqualToString:@""]) {
                currentAccount = lastAccount;
                isAutoLogin = YES;
                [JFGSDK userLogin:lastAccount keyword:key cerType:[ApnsManger certType]];
            }
            
        }
    }else{
        
        NSString *linkID = [[NSUserDefaults standardUserDefaults] objectForKey:JFGCurrentLoginedAccountKey];
        
        if (linkID) {
            
            NSDictionary *parame = [[NSUserDefaults standardUserDefaults] objectForKey:JFGOpenLoginAccessToken];
            if (parame) {
                
                NSDate *expiredDate = [parame objectForKey:JFGOpenexpiredDateKey];
                NSString *accessToken = [parame objectForKey:JFGOpenAccessTokenKey];
                
                /*
                 case 1://qq
                 tp = 3;
                 break;
                 case 2://sinaweibo
                 tp = 4;
                 break;
                 case 3:
                 tp=6;//
                 break;
                 case 4:
                 tp=7;//facebook
                 */
                
                NSTimeInterval secondsBetweenDates= [expiredDate timeIntervalSinceNow];
                if (secondsBetweenDates > 0 && accessToken) {
                    isAutoLogin = YES;
                    currentAccount = linkID;
                    if (self.loginType == JFGSDKLoginTypeOpenLoginForQQ) {
                        
                    [JFGSDK openLoginWithOpenId:linkID accessToken:accessToken cerType:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"certType"] loginType:3];
                        
                    }else if(self.loginType == JFGSDKLoginTypeOpenLoginForSinaWeibo){
                        
                         [JFGSDK openLoginWithOpenId:linkID accessToken:accessToken cerType:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"certType"] loginType:4];
                        
                    }else if (self.loginType == JFGSDKLoginTypeOpenLoginForTwitter){
                        [JFGSDK openLoginWithOpenId:linkID accessToken:accessToken cerType:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"certType"] loginType:6];
                    }else if (self.loginType == JFGSDKLoginTypeOpenLoginForFacebook){
                        [JFGSDK openLoginWithOpenId:linkID accessToken:accessToken cerType:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"certType"] loginType:7];
                    }
                    
                }else{
                    isAutoLogin = YES;
                    [self openLoginByQQ];
                }
                
            }
            //self.loginStatus = JFGSDKCurrentLoginStatusLogining;
        }
    }
    
}

-(void)addDelegate:(id<LoginManagerDelegate>)delegate
{
    [_hashTable addObject:delegate];
}

-(void)removeDelegate:(id<LoginManagerDelegate>)delegate
{
    [_hashTable removeObject:delegate];
}

#pragma mark- JFGSDKDelegate
- (void)jfgCheckClientVersionForErrorType:(JFGErrorType)errorType coerce_Upgrade:(int)coerce_Upgrade url:(NSString *)url
{
    if (errorType == JFGErrorTypeNone)
    {
        CheckVersionHelper *checkHelper = [[CheckVersionHelper alloc] init];
        checkHelper.url = url;
        checkHelper.isForeceUpgrade = coerce_Upgrade;
        [checkHelper checkVersion];
    }
}


-(void)jfgLoginResult:(JFGErrorType)errorType
{
    if (errorType == JFGErrorTypeNone) {
        
        self.loginStatus = JFGSDKCurrentLoginStatusSuccess;
        currentLoginStatu = YES;
        [self setLoginStatu:YES];
        [self loginSuccessRespone];
        [Bugly setUserValue:currentAccount forKey:@"account"];
        [JFGSDK checkClientVersion];
    
    }else{
        
        [UserAccountMsg deleteWithAccount:currentAccount];
        [JFGSDK appendStringToLogFile:[NSString stringWithFormat:@"AppLoginOut:%@",currentAccount]];
        currentLoginStatu = NO;
        currentAccount = nil;
        self.loginStatus = JFGSDKCurrentLoginStatusLoginOut;
        [self loginFailRespone:errorType];
        [self setLoginStatu:NO];
        [self loginOutRespone];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:JFGAccountLoginOutKey object:nil];
        
    
        if (errorType == JFGErrorTypeLoginInvalidPass) {
            [JFGSDK logout];
        }
        
        
        //自动登录，并且是账号密码错误，跳转欢迎页面
        if (isAutoLogin && errorType == JFGErrorTypeLoginInvalidPass) {
            
            LoginLoadingViewController *lo = [LoginLoadingViewController new];
            UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:lo];
            UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
            keyWindows.rootViewController = nav;
            
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"PWD_CHANGED"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
            [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
                
                
                //        for (id<LoginManagerDelegate>delegate in _hashTable) {
                //
                //            if ([delegate respondsToSelector:@selector(loginOutForServer:)]) {
                //                [delegate loginOutForServer:errorType];
                //            }
                //            
                //        }
                
            } otherDelegate:nil];
            
        }
        
    }

    isAutoLogin = NO;
}

-(void)jfgAccountOnline:(BOOL)online
{
    currentLoginStatu = online;
    [self setLoginStatu:online];
    if (online == NO)
    {

        if (self.loginStatus != JFGSDKCurrentLoginStatusLoginOut) {
            self.loginStatus = JFGSDKCurrentLoginStatusLoginFailed;
        }
        
    }
    else
    {
        self.loginStatus = JFGSDKCurrentLoginStatusSuccess;
//        [self loginSuccessRespone];
        
        /**
         *  保存 当前可用wifi
         */
        NSString *availWifi = [CommonMethod currentConnecttedWifi];
        if ([availWifi hasPrefix:@"DOG"] || [availWifi hasPrefix:@"dog"]) {
            
        }else{
           [[NSUserDefaults standardUserDefaults] setValue:[CommonMethod currentConnecttedWifi] forKey:availableWIFI]; 
        }
        
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
   
}

-(void)jfgServerDisConnected
{
    currentLoginStatu = NO;
    self.loginStatus = JFGSDKCurrentLoginStatusLoginFailed;
}

-(void)jfgLoginOutByServerWithCause:(JFGErrorType)errorType
{
    [self loginOut];
//    UIWindow * window = [UIApplication sharedApplication].keyWindow;
//    UITabBarController * barCon = (UITabBarController *)window.rootViewController;
//    for (UIViewController *vc in barCon.viewControllers) {
//        
//        if ([vc isKindOfClass:[UINavigationController class]]) {
//            UINavigationController *__nav = (UINavigationController *)vc;
//            [__nav popToRootViewControllerAnimated:YES];
//        }
//        
//    }
//    barCon.selectedIndex = 0;
//    UINavigationController * nav = barCon.viewControllers[0];
//    LoginRegisterViewController *loginRegister = [LoginRegisterViewController new];
//    loginRegister.viewType = FristIntoViewTypeLogin;
//    UINavigationController *_nav = [[UINavigationController alloc]initWithRootViewController:loginRegister];
//    _nav.navigationBarHidden = YES;
//    [nav presentViewController:_nav animated:YES completion:^{
//        
//    }];
    
    LoginLoadingViewController *lo = [LoginLoadingViewController new];
    UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:lo];
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    keyWindows.rootViewController = nav;
    
   
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"PWD_CHANGED"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
    [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
        
        
//        for (id<LoginManagerDelegate>delegate in _hashTable) {
//            
//            if ([delegate respondsToSelector:@selector(loginOutForServer:)]) {
//                [delegate loginOutForServer:errorType];
//            }
//            
//        }
        
    } otherDelegate:nil];
    
    
}

-(JFGSDKAcount *)accountCache
{
    if (cacheAccount) {
        return cacheAccount;
    }
    return [JfgCacheManager getCacheForAccountWithAccountNumber:self.currentLoginedAcount];
}

-(void)jfgUpdateAccount:(JFGSDKAcount *)account
{
    //第一次三方登录成功设置头像，昵称
    if (self.loginType != JFGSDKLoginTypeAccountLogin){
        
        if (account.photoVersion == 0) {
            
            NSLog(@"坑爹的进入了这里");
            if (isLoadingUserheadImageing) {
                return;
            }
            
            if (thirdNickName) {
                [JFGSDK resetAccountEmail:nil orAlias:thirdNickName];
            }
            
            [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:thirdIcon] options:SDWebImageCacheMemoryOnly progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                
            } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
               
                if (finished && !error) {
                    
                    [JFGSDK uploadFile:[self saveImage:image] toCloudFolderPath:[NSString stringWithFormat:@"/image/%@.jpg",account.account]];
                    //通知服务器修改了头像
                    [JFGSDK resetAccountPhoto];
                    
                }else{
                    
                    isLoadingUserheadImageing = NO;
                }
                
            }];
            
            isLoadingUserheadImageing = YES;
            
        }
        
    }
    
    [JfgCacheManager cacheAccountMsg:account];
    cacheAccount = account;
    
    if (cacheAccount == nil || [[NSUserDefaults standardUserDefaults] boolForKey:JFGAccountMsgChangedKey] || ![cacheAccount.account isEqualToString:account.account]) {
        
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:JFGAccountMsgChangedKey];
        
    }
}


-(NSString *)saveImage:(UIImage *)currentImage
{
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    path = [path stringByAppendingPathComponent:@"account_pic.png"];
    NSData *imageData = UIImageJPEGRepresentation(currentImage, 1);//UIImagePNGRepresentation(currentImage);
    [imageData writeToFile:path atomically:YES];// 将图片写入文件
    return path;
}

#pragma mark- getter and setter
//记录本次登陆操作是否成功
-(void)setLoginStatu:(BOOL)login
{
    [[NSUserDefaults standardUserDefaults] setBool:login forKey:JFGLoginStatuRecodeKey];
    [[NSUserDefaults standardUserDefaults]synchronize];
}

-(BOOL)isLogined
{
    return currentLoginStatu;
}

-(BOOL)isSuccessLogined
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:JFGLoginStatuRecodeKey];
}

-(NSString *)currentLoginedAcount
{
    if (!currentAccount) {
        currentAccount = [[NSUserDefaults standardUserDefaults]objectForKey:JFGCurrentLoginedAccountKey];
    }
    return currentAccount;
}


//-(void)setLoginStatus:(JFGSDKLoginStatus)loginStatus
//{
//    if (_loginStatus != loginStatus) {
//        _loginStatus = loginStatus;
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:JFGAccountLoginStatueSaveKey];
//        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:loginStatus] forKey:JFGAccountLoginStatueSaveKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//}


-(void)setLoginType:(JFGSDKLoginType)loginType
{
    [[NSUserDefaults standardUserDefaults] setInteger:loginType forKey:@"JFGSDKLoginType"];
}

-(JFGSDKLoginType)loginType
{
    NSInteger inter = [[NSUserDefaults standardUserDefaults] integerForKey:@"JFGSDKLoginType"];
    if (inter == 0) {
        return JFGSDKLoginTypeAccountLogin;
    }else if(inter == 1){
        return JFGSDKLoginTypeOpenLoginForQQ;
    }else if (inter == 2){
        return JFGSDKLoginTypeOpenLoginForSinaWeibo;
    }else if (inter == 3){
        return JFGSDKLoginTypeOpenLoginForTwitter;
    }else if (inter == 4){
        return JFGSDKLoginTypeOpenLoginForFacebook;
    }
    return JFGSDKLoginTypeOpenLoginForSinaWeibo;
}

#pragma mark- 登陆代理回调
-(void)loginSuccessRespone
{
    NSArray *delegateArr = _hashTable.allObjects;
    for (id<LoginManagerDelegate>delegate in delegateArr) {
        
        if (delegate && [delegate respondsToSelector:@selector(loginSuccess)])
        {
            [delegate loginSuccess];
            [ApnsManger registerRemoteNotification:YES];
        }
        
    }
}

-(void)loginOutRespone
{
    for (id<LoginManagerDelegate>delegate in _hashTable) {
        
        if ([delegate respondsToSelector:@selector(loginOut)]) {
            [delegate loginOut];
            [ApnsManger unRegisterNotification];
        }
    }
}

-(void)loginFailRespone:(JFGErrorType)error
{
    for (id<LoginManagerDelegate>delegate in _hashTable) {
        
        if ([delegate respondsToSelector:@selector(loginFail:)]) {
            [delegate loginFail:error];
        }
    }
    
}
#pragma mark- 授权登录失败提示
-(void)authorizationfailedAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"Tap0_Authorizationfailed"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] otherButtonTitles:nil, nil];
    [alert show];
    
    [self loginFailRespone:JFGErrorTypeUnknown];
}

-(void)applicationDidEnterBackground
{
    if (self.loginStatus == JFGSDKCurrentLoginStatusLogining) {
        self.loginStatus = JFGSDKCurrentLoginStatusLoginOut;
    }
}

@end
