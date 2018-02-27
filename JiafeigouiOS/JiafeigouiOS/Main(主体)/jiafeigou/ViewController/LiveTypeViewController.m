//
//  LiveTypeViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/29.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "LiveTypeViewController.h"
#import "CommentFrameButton.h"
#import "ProgressHUD.h"
#import "FLTextView.h"
#import "YoutubeLiveStreamsModel.h"
#import "JfgCacheManager.h"
#import "YoutubeLiveAPIHelper.h"
#import "YoutubeCreatChannelVC.h"
#import "BaseNavgationViewController.h"
#import "YoutubeChannelDetailVC.h"
#import "LSAlertView.h"
#import "ShareView.h"
#import "FLShareSDKHelper.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDK/ShareSDK+Base.h>
#import "LoginManager.h"
#import "WeiboLiveAPIHelper.h"
#import "FacebookLiveAPIHelper.h"
#import "FBPravicyChooseVC.h"

#define LivePlatformImageWidth 72
#define LivePlatformButtonTag 10000
#define YoutubeControlTagStart 20000
#define FacebookControlTagStart 30000
#define WeiboControlTagStart 40000
#define RtmpControlTagStart 5000

NSString *const rtmpUrlKey = @"rtmpUrlKey";
NSString *const rtmpMiYaoKey = @"rtmpMiYaoKey";

@interface LiveTypeViewController ()<UITextViewDelegate,UITextFieldDelegate,YoutubeLiveAPIHelperDelegate,FBPravicyChooseDelegate>

@property (nonatomic,strong)UIView *lineView;
@property (nonatomic,strong)UIView *allBgView;
@property (nonatomic,strong)CommentFrameButton *facebookBtn;
@property (nonatomic,strong)CommentFrameButton *youtubeBtn;
@property (nonatomic,strong)CommentFrameButton *weiboBtn;
@property (nonatomic,strong)CommentFrameButton *rtmpBtn;

@property (nonatomic,strong)UILabel *rtmpAlertLabel;
@property (nonatomic,strong)FLTextView *rtmpTextView;
@property (nonatomic,strong)UITextField *miyaoTextField;
@property (nonatomic,strong)UIButton *miyaoLockBtn;

@property (nonatomic,strong)UITableView *editTableView;

@property (nonatomic,strong)UIView *facebookEditBgView;
@property (nonatomic,strong)UIView *ytbeEditBgView;
@property (nonatomic,strong)UIView *weiboEditBgView;
@property (nonatomic,strong)UIView *rtmpEditBgView;

@property (nonatomic,strong)YoutubeLiveAPIHelper *youtubeAPIHelper;
@property (nonatomic,strong)YoutubeLiveStreamsModel *youtubeModel;

@property (nonatomic,strong)UIView *currentTextFieldView;
@property (nonatomic,strong)FacebookLiveAPIHelper *facebookHelper;

@end

@implementation LiveTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#F0F0F0"];
    [self initNavagation];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self addNoticeForKeyboard];//添加键盘出现，消失通知
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.view endEditing:YES];
    [self removeKeyBoradNotifacation];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}


-(void)initNavagation
{
    self.backBtn.hidden = YES;
    UIButton *leftBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    leftBtn.frame = CGRectMake(0, 0, 50, 20);
    leftBtn.left = 10;
    leftBtn.top = 32;
    leftBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    leftBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [leftBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
    [leftBtn addTarget:self action:@selector(leftAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarBgView addSubview:leftBtn];
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_SELECT_PLATFORM"];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 50, 20);
    rightBtn.right = self.view.width - 10;
    rightBtn.top = 32;
    rightBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    rightBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rightBtn setTitle:[JfgLanguage getLanTextStrByKey:@"OK"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightAction) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarBgView addSubview:rightBtn];
    
}

-(void)initView
{
    [self.view addSubview:self.allBgView];
    [self.view bringSubviewToFront:self.topBarBgView];
    
    UIView *btnBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 92)];
    btnBgView.backgroundColor = [UIColor whiteColor];
    [self.allBgView addSubview:btnBgView];
    
    NSArray *imgArr = @[@"choose_icon_facebook",@"choose_icon_youtube",@"choose_icon_weibo",@"choose_icon_rtmp"];
    NSArray *titleArr = @[@"Facebook",@"YouTube",[JfgLanguage getLanTextStrByKey:@"Weibo"],@"RTMP"];
    
    CGFloat space = (self.view.width - LivePlatformImageWidth*4)/7;
    CGFloat selectedCenter = 0;
    
    
    //创建顶部四个平台选择按钮
    for (int i=0; i<4; i++) {
        
        NSString *imageName = imgArr[i];
        NSString *title = titleArr[i];
        CGFloat left = 2*space+(LivePlatformImageWidth+space)*i;
        
        CommentFrameButton *btn = [[CommentFrameButton alloc]initWithFrame:CGRectMake(left, 0, LivePlatformImageWidth, 92) titleFrame:CGRectMake(0, 60, LivePlatformImageWidth, 14) imageRect:CGRectMake(21, 20, 30, 30)];
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
        [btn setTitle:title forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitleColor:[UIColor colorWithHexString:@"#666666"] forState:UIControlStateNormal];
        btn.tag = LivePlatformButtonTag+i;
        [btn addTarget:self action:@selector(livePlatformAction:) forControlEvents:UIControlEventTouchUpInside];
        [btnBgView addSubview:btn];
        
        if (i == 0) {
            self.facebookBtn = btn;
        }else if (i==1){
            self.youtubeBtn = btn;
        }else if (i==2){
            self.weiboBtn = btn;
        }else if (i==3){
            self.rtmpBtn = btn;
        }
        if (self.platformType == i) {
            
            selectedCenter = btn.x;
        }
    }
    [self.view endEditing:YES];
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 86, 50, 3)];
    self.lineView.backgroundColor = [UIColor colorWithHexString:@"#36BDFF"];
    self.lineView.x = selectedCenter;
    [btnBgView addSubview:self.lineView];
    
    //根据默认平台判断如何显示界面
    [self showEditViewForPlatformType:self.platformType];
    
}



-(void)showEditViewForPlatformType:(LivePlatformType)platformType
{
    self.facebookEditBgView.hidden = YES;
    self.ytbeEditBgView.hidden = YES;
    self.weiboEditBgView.hidden = YES;
    self.rtmpEditBgView.hidden = YES;
    if (platformType == LivePlatformTypeFacebook) {
        [self showFacebookEdit];
    }else if (platformType == LivePlatformTypeRTMP){
        [self showRtmpEditView];
    }else if (platformType == LivePlatformTypeWeibo){
        [self showWeiboEditView];
    }else if (platformType == LivePlatformTypeYoutube){
        [self showYoutubeEditView];
    }
}



-(void)livePlatformAction:(UIButton *)sender
{
    [self.view endEditing:YES];
    if (sender.tag == LivePlatformButtonTag) {
        self.platformType = LivePlatformTypeFacebook;
    }else if(sender.tag == LivePlatformButtonTag+1){
        //youtube
        self.platformType = LivePlatformTypeYoutube;
    }else if(sender.tag == LivePlatformButtonTag+2){
        //weibo
        self.platformType = LivePlatformTypeWeibo;
    }else if(sender.tag == LivePlatformButtonTag+3){
        //rtmp
        self.platformType = LivePlatformTypeRTMP;
    }
    [self showEditViewForPlatformType:self.platformType];
    [UIView animateWithDuration:0.3 animations:^{
        self.lineView.x = sender.x;
    }];
}

-(void)rightAction
{
    if (self.platformType == LivePlatformTypeRTMP) {
        
        if ([self.rtmpTextView.text isEqualToString:@""] ) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RTMP_EMPTY_TIPS"]];
        }else if (![self.rtmpTextView.text hasPrefix:@"rtmp://"]){
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"RTMP_ERROR_TIPS"]];
        }else{
            
            NSString *url = @"";
            if (![self.miyaoTextField.text isEqualToString:@""]) {
                url = [NSString stringWithFormat:@"%@/%@",self.rtmpTextView.text,self.miyaoTextField.text];
            }else{
                url = self.rtmpTextView.text;
            }
            
            [[NSUserDefaults standardUserDefaults] setObject:self.rtmpTextView.text forKey:rtmpUrlKey];
            [[NSUserDefaults standardUserDefaults] setObject:self.miyaoTextField.text forKey:rtmpMiYaoKey];
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(liveType:parameter:)]) {
                [self.delegate liveType:self.platformType parameter:@{@"url":url}];
            }
            [self leftAction];
            
        }
    }else if (self.platformType == LivePlatformTypeYoutube){
        
        if ([GIDSignIn sharedInstance].currentUser) {
            if (!self.youtubeModel.isValid) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_CREATE_TIPS"]];
            }else{
                if (self.delegate && [self.delegate respondsToSelector:@selector(liveType:parameter:)]) {
                    [self.delegate liveType:self.platformType parameter:@{@"model":self.youtubeModel}];
                }
                [self leftAction];
            }
        }else{
            
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT_BIND_TIPS"]];
        }
        
        
    }else if (self.platformType == LivePlatformTypeWeibo){
        
        if ([ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo]) {
            
            FLTextView *detailTextView = [self.weiboEditBgView viewWithTag:WeiboControlTagStart+1];
            [[NSUserDefaults standardUserDefaults] setObject:detailTextView.text forKey:WEIBOLIVETITLEKEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            if (self.delegate && [self.delegate respondsToSelector:@selector(liveType:parameter:)]) {
                [self.delegate liveType:self.platformType parameter:nil];
            }
            [self leftAction];
            
        }else{
            
           [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT_BIND_TIPS"]];
        }
        
    }else if (self.platformType == LivePlatformTypeFacebook){
        
        if (![FBSDKAccessToken currentAccessToken]) {
            
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT_BIND_TIPS"]];
            
        }else{
            NSString *authorityType = @"";
            TimeCell *authorityView = [self.facebookEditBgView viewWithTag:FacebookControlTagStart+2];
            if (authorityView) {
                authorityType = authorityView.detailLabel.text;
            }
            FLTextView *detailTextView = [self.facebookEditBgView viewWithTag:FacebookControlTagStart];
            if (detailTextView && ![detailTextView.text isEqualToString:@""]) {
                [[NSUserDefaults standardUserDefaults] setObject:detailTextView.text forKey:FBLiveVideoTitleKey];
            }
           
            if (self.delegate && [self.delegate respondsToSelector:@selector(liveType:parameter:)]) {
                [self.delegate liveType:self.platformType parameter:@{@"authorityType":authorityType}];
            }
            
            [self leftAction];
        }
        
    }else {
        [self leftAction];
    }
}

-(void)leftAction
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)weiboAuthorization
{
    if ([ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo]) {
        
        if ([LoginManager sharedManager].loginType == JFGSDKLoginTypeOpenLoginForSinaWeibo) {
            
            [LSAlertView showAlertWithTitle:@"当前加菲狗/doby使用新浪微博登录，暂不能解绑该账号" Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
        
            } OKBlock:^{
                
            }];
            
        }else{
            
            __weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"LIVE_UNBIND_ACCOUNT"],@"Youtube"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
                
                
            } OKBlock:^{
                
                [ShareSDK cancelAuthorize:SSDKPlatformTypeSinaWeibo];
                [weakSelf showWeiboEditView];
                
            }];
            
        }
        
    }else{
        
        [ShareSDK authorize:SSDKPlatformTypeSinaWeibo settings:@{SSDKAuthSettingKeyScopes : @[@"all"],@"SSO_From":@"LiveTypeViewController"} onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
            
            NSLog(@"%lu %@ %@",(unsigned long)state,user,error);
            if (state == SSDKResponseStateSuccess) {
                
                [self showWeiboEditView];
                
            }
            
        }];
        
    }
}

//youtube绑定账号
-(void)ytbAccountAction
{
    if ([GIDSignIn sharedInstance].currentUser) {
        //已经绑定
        
        __weak typeof(self) weakSelf = self;
        [LSAlertView showAlertWithTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"LIVE_UNBIND_ACCOUNT"],@"Youtube"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            
            [weakSelf.youtubeAPIHelper signOut];
            [weakSelf showYoutubeEditView];
            weakSelf.youtubeModel.isValid = NO;
            LiveTypeModel *md = [JfgCacheManager liveModelForCid:self.cid];
            if(md && md.liveType == LivePlatformTypeYoutube){
                md.isValid = NO;
                md.parameterDict = nil;
                md.watchUrl = nil;
                md.liveStreamingUrl = nil;
                [JfgCacheManager updateLiveModel:md];
                [[NSNotificationCenter defaultCenter] postNotificationName:LiveTypeModelRefreshNotification object:md];
            }
            
        }];
        
    }else{
        //未绑定
        [self.youtubeAPIHelper signInWithPresentVC:self];
    }
}


//直播详情
-(void)liveChannelDetailAction
{
    YoutubeChannelDetailVC *detailVC = [[YoutubeChannelDetailVC alloc]init];
    detailVC.dataModel = self.youtubeModel;
    [self.navigationController pushViewController:detailVC animated:YES];
}

//youtube分享
-(void)youtubeShareAction
{
    ShareView *sv = [[ShareView alloc]initWithLandScape:NO];
    [sv showShareView:^(SSDKPlatformType platformType) {
        
        NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
        NSString *icon = [[infoPlist valueForKeyPath:@"CFBundleIcons.CFBundlePrimaryIcon.CFBundleIconFiles"] lastObject];
        UIImage *image = [UIImage imageNamed:icon];
        
        [FLShareSDKHelper shareToThirdpartyPlatform:platformType url:self.youtubeModel.watchUrl image:image title:self.youtubeModel.title contentType:SSDKContentTypeWebPage];
        
    } cancel:^{
        
    }];
}

//youtube创建直播
-(void)createYoutubeLive
{
    if (self.youtubeModel.isValid) {
        
        __weak typeof(self) weakSelf = self;
        [LSAlertView showAlertWithTitle:@"创建新直播,当前直播地址会失效,是否创建?" Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
        } OKBlock:^{
            YoutubeCreatChannelVC *liveVC = [YoutubeCreatChannelVC new];
            liveVC.youtubeHelper = weakSelf.youtubeAPIHelper;
            liveVC.cid = self.cid;
            [weakSelf.navigationController pushViewController:liveVC animated:YES];
        }];
        
    }else{
        YoutubeCreatChannelVC *liveVC = [YoutubeCreatChannelVC new];
        liveVC.youtubeHelper = self.youtubeAPIHelper;
        liveVC.cid = self.cid;
        [self.navigationController pushViewController:liveVC animated:YES];
    }
    
}

#pragma mark- youtube 代理
-(void)signInResultForError:(NSError *)error
{
    if (!error) {
        //授权登录成功
        [self showYoutubeEditView];
    }else{
        //授权登录失败
        [ProgressHUD showText:@"Tap0_Authorizationfailed"];
    }
}

-(void)createLiveChannelResultForError:(NSError *)error liveModel:(YoutubeLiveStreamsModel *)liveModel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"createChannelResult" object:error];
    if (!error) {
        self.youtubeModel.watchUrl = liveModel.watchUrl;
        self.youtubeModel.streamsUrl = liveModel.streamsUrl;
        self.youtubeModel.liveStreamsID = liveModel.liveStreamsID;
        self.youtubeModel.liveBroadcastID = liveModel.liveBroadcastID;
        self.youtubeModel.isValid = YES;
        self.youtubeModel.title = liveModel.title;
        self.youtubeModel.descrips = liveModel.descrips;
        self.youtubeModel.cid = self.cid;
        self.youtubeModel.scheduledStartTime = liveModel.scheduledStartTime;
        self.youtubeModel.scheduledEndTime = liveModel.scheduledEndTime;
        [self showYoutubeEditView];
        [JfgCacheManager updateYoutubeModel:self.youtubeModel];
    }
}


#pragma mark- textViewDelegate
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.currentTextFieldView = textView;
    return YES;
}

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    self.currentTextFieldView = textField;
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.miyaoTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.tag == WeiboControlTagStart+1) {
        
        UILabel *countLabel = [self.weiboEditBgView viewWithTag:WeiboControlTagStart+2];
        if (countLabel) {
            
            if (textView.text.length > 110) {
                textView.text = [textView.text substringToIndex:109];
                countLabel.text = @"0";
            }else{
                countLabel.text = [NSString stringWithFormat:@"%d",110-(int)textView.text.length];
            }
        }
    }
}

#pragma mark- pravicyDelegate
-(void)didChooseForType:(NSString *)type
{
    TimeCell *authorityView = [self.facebookEditBgView viewWithTag:FacebookControlTagStart+2];
    if (authorityView) {
        authorityView.detailLabel.text = type;
    }
}

-(UILabel *)rtmpAlertLabel
{
    if (!_rtmpAlertLabel) {
        _rtmpAlertLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 30, 280, 14)];
        _rtmpAlertLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        _rtmpAlertLabel.font = [UIFont systemFontOfSize:13];
        _rtmpAlertLabel.text = [JfgLanguage getLanTextStrByKey:@"RTMP_SERVER_URL"];
    }
    return _rtmpAlertLabel;
}

-(UITextView *)rtmpTextView
{
    if (!_rtmpTextView) {
        _rtmpTextView = [self factoryTextViewForFrame:CGRectMake(0, 53, self.view.width, 121) placeholder:@"rtmp://"];
        NSString *my = [[NSUserDefaults standardUserDefaults] objectForKey:rtmpUrlKey];
        if (my) {
            _rtmpTextView.text = my;
        }
    }
    return _rtmpTextView;
}


//显示rtmp编辑视图
-(void)showRtmpEditView
{
    if (self.rtmpAlertLabel.superview == nil) {
        [self.rtmpEditBgView addSubview:self.rtmpAlertLabel];
    }
    if (self.rtmpTextView.superview == nil) {
        [self.rtmpEditBgView addSubview:self.rtmpTextView];
    }
    
    UILabel *miyaoLabel = [self.rtmpEditBgView viewWithTag:RtmpControlTagStart];
    if (!miyaoLabel) {
        miyaoLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 194, 100, 14)];
        miyaoLabel.textColor = [UIColor colorWithHexString:@"#888888"];
        miyaoLabel.font = [UIFont systemFontOfSize:13];
        miyaoLabel.text = [JfgLanguage getLanTextStrByKey:@"RTMP_STREAM_KEY"];
        miyaoLabel.tag = RtmpControlTagStart;
        
        [self.rtmpEditBgView addSubview:miyaoLabel];
    }
    
    
    UIView *miyaoBgView = [self.rtmpEditBgView viewWithTag:RtmpControlTagStart+1];
    if (!miyaoBgView) {
        miyaoBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 217, self.view.width, 44)];
        miyaoBgView.backgroundColor = [UIColor whiteColor];
        miyaoBgView.tag = RtmpControlTagStart+1;
        [self.rtmpEditBgView addSubview:miyaoBgView];
    }
    
    if (self.miyaoTextField.superview == nil) {
        [self.rtmpEditBgView addSubview:self.miyaoTextField];
    }
    
    if (self.miyaoLockBtn.superview == nil) {
        [miyaoBgView addSubview:self.miyaoLockBtn];
    }
    if (self.rtmpEditBgView.superview == nil) {
        [self.allBgView addSubview:self.rtmpEditBgView];
    }
    self.rtmpEditBgView.hidden = NO;
}


//显示youtube编辑视图
-(void)showYoutubeEditView
{
    TimeCell *accountControl = [self.ytbeEditBgView viewWithTag:YoutubeControlTagStart];
    if (!accountControl) {
        accountControl = [[TimeCell alloc]initWithFrame:CGRectMake(0, 20, self.view.width, 44)];
        accountControl.titleLabel.width = self.view.width*0.5-15;
        accountControl.detailLabel.width = ceil(self.view.width - accountControl.titleLabel.right - 37)-10;
        accountControl.detailLabel.right = self.view.width-37;;
        accountControl.backgroundColor = [UIColor whiteColor];
        [accountControl addTarget:self action:@selector(ytbAccountAction) forControlEvents:UIControlEventTouchUpInside];
        accountControl.tag = YoutubeControlTagStart;
        accountControl.titleLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT"],@"Youtube"];
        [self.ytbeEditBgView addSubview:accountControl];
    }
    
    
    if ([GIDSignIn sharedInstance].currentUser) {
        accountControl.detailLabel.text = [self.youtubeAPIHelper signInUser].profile.name;
    }else{
        accountControl.detailLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT_UNBOUND"];
    }
    
    UIButton *createLiveControl = [self.ytbeEditBgView viewWithTag:YoutubeControlTagStart+2];
    
    if (!createLiveControl) {
        
        if ([self.youtubeAPIHelper signInUser]) {
            
            createLiveControl = [[UIButton alloc]initWithFrame:CGRectMake(0, 84, self.view.width, 44)];
            createLiveControl.backgroundColor = [UIColor whiteColor];
            [createLiveControl setTitle:[JfgLanguage getLanTextStrByKey:@"LIVE_CREATE_BUTTON"] forState:UIControlStateNormal];
            [createLiveControl setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
            createLiveControl.titleLabel.font = [UIFont systemFontOfSize:17];
            createLiveControl.showsTouchWhenHighlighted = NO;
            [createLiveControl addTarget:self action:@selector(createYoutubeLive) forControlEvents:UIControlEventTouchUpInside];
            createLiveControl.tag = YoutubeControlTagStart+2;
            [self.ytbeEditBgView addSubview:createLiveControl];
            
        }
        
    }else{
        
        if ([self.youtubeAPIHelper signInUser]) {
            createLiveControl.hidden = NO;
        }else{
            createLiveControl.hidden = YES;
        }
        
    }
    
    UILabel *subTitle = [self.ytbeEditBgView viewWithTag:YoutubeControlTagStart+3];
    UIControl *liveDetailBgView = [self.ytbeEditBgView viewWithTag:YoutubeControlTagStart+4];
    UIButton *shareBtn = [self.ytbeEditBgView viewWithTag:YoutubeControlTagStart+5];
    UILabel *liveTitleLabel = [self.ytbeEditBgView viewWithTag:YoutubeControlTagStart+6];
    
    if (self.youtubeModel.isValid && [self.youtubeAPIHelper signInUser]) {
        
        if (!subTitle) {
            subTitle = [[UILabel alloc]initWithFrame:CGRectMake(15, 148, 200, 14)];
            subTitle.textColor = [UIColor colorWithHexString:@"#888888"];
            subTitle.font = [UIFont systemFontOfSize:13];
            subTitle.text = [JfgLanguage getLanTextStrByKey:@"LIVE_CURRENT_TEXT"];
            subTitle.tag =YoutubeControlTagStart+3;
            [self.ytbeEditBgView addSubview:subTitle];
            
        }else{
            subTitle.hidden = NO;
        }
        
        if (!liveDetailBgView) {
            liveDetailBgView = [[UIControl alloc]initWithFrame:CGRectMake(0, 169, self.view.width, 44)];
            liveDetailBgView.backgroundColor = [UIColor whiteColor];
            liveDetailBgView.tag = YoutubeControlTagStart+4;
            [liveDetailBgView addTarget:self action:@selector(liveChannelDetailAction) forControlEvents:UIControlEventTouchUpInside];
            [self.ytbeEditBgView addSubview:liveDetailBgView];
        }else{
            liveDetailBgView.hidden = NO;
        }
        
        if (!shareBtn) {
            shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            shareBtn.frame = CGRectMake(0, 9, 58, 28);
            shareBtn.right = self.view.width - 15;
            shareBtn.layer.masksToBounds = YES;
            shareBtn.layer.cornerRadius = 14;
            shareBtn.layer.borderColor = [UIColor colorWithHexString:@"#4B9FD5"].CGColor;
            shareBtn.layer.borderWidth = 0.5;
            [shareBtn setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
            shareBtn.titleLabel.font = [UIFont systemFontOfSize:14];
            [shareBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Button"] forState:UIControlStateNormal];
            [shareBtn addTarget:self action:@selector(youtubeShareAction) forControlEvents:UIControlEventTouchUpInside];
            shareBtn.tag = YoutubeControlTagStart+5;
            [liveDetailBgView addSubview:shareBtn];
        }
        
        if (!liveTitleLabel) {
            liveTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(15, 11, self.view.width - 40 - 58, 22)];
            liveTitleLabel.textColor = [UIColor colorWithHexString:@"#333333"];
            liveTitleLabel.font = [UIFont systemFontOfSize:16];
            liveTitleLabel.textAlignment = NSTextAlignmentLeft;
            liveTitleLabel.tag = YoutubeControlTagStart+6;
            [liveDetailBgView addSubview:liveTitleLabel];
        }
        liveTitleLabel.text = self.youtubeModel.title;
        
    }else{
        
        if (subTitle) {
            subTitle.hidden = YES;
        }
        if (liveDetailBgView) {
            liveDetailBgView.hidden = YES;
        }
        
    }
    
    if (self.ytbeEditBgView.superview == nil) {
        [self.allBgView addSubview:self.ytbeEditBgView];
    }
    self.ytbeEditBgView.hidden = NO;
    
}

-(void)showWeiboEditView
{
    FLTextView *detailTextView = [self.weiboEditBgView viewWithTag:WeiboControlTagStart+1];
    if (!detailTextView) {
        detailTextView = [self factoryTextViewForFrame:CGRectMake(0, 20, self.view.width, 121) placeholder:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"]];
        detailTextView.tag = WeiboControlTagStart+1;
        CGFloat xMargin = 15, yMargin = 25;//左右，上下边距
        detailTextView.textContainerInset = UIEdgeInsetsMake(15, xMargin, 0, xMargin);
        detailTextView.contentInset = UIEdgeInsetsMake(0, 0, yMargin, 0);
        [self.weiboEditBgView addSubview:detailTextView];
        
        UILabel *countLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 118, 50, 14)];
        countLable.right = self.view.width - 15;
        countLable.font = [UIFont systemFontOfSize:13];
        countLable.textColor = [UIColor colorWithHexString:@"#adadad"];
        countLable.textAlignment = NSTextAlignmentRight;
        countLable.text = @"110";
        countLable.tag = WeiboControlTagStart+2;
        [self.weiboEditBgView addSubview:countLable];
        
    }
    
    
    TimeCell *accountView = [self.weiboEditBgView viewWithTag:WeiboControlTagStart];
    
    if (!accountView) {
        
        accountView = [[TimeCell alloc]initWithFrame:CGRectMake(0, 161, self.view.width, 44)];
        accountView.titleLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT"],[JfgLanguage getLanTextStrByKey:@"LIVE_PLATFORM_WEIBO"]];
        accountView.titleLabel.width = self.view.width*0.5-15;
        accountView.detailLabel.width = ceil(self.view.width - accountView.titleLabel.right - 37)-10;
        accountView.detailLabel.right = self.view.width-37;
        accountView.detailLabel.textAlignment = NSTextAlignmentRight;
        accountView.tag = WeiboControlTagStart;
        [accountView addTarget:self action:@selector(weiboAuthorization) forControlEvents:UIControlEventTouchUpInside];
        [self.weiboEditBgView addSubview:accountView];
        
    }
    if ([ShareSDK hasAuthorized:SSDKPlatformTypeSinaWeibo]) {
        SSDKUser *user = [ShareSDK currentUser:SSDKPlatformTypeSinaWeibo];
        accountView.detailLabel.text = user.nickname;
    }else{
        accountView.detailLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT_UNBOUND"];
    }
    
    if (self.weiboEditBgView.superview == nil) {
        [self.allBgView addSubview:self.weiboEditBgView];
    }
    self.weiboEditBgView.hidden = NO;
    
}


-(void)showFacebookEdit
{
    FLTextView *detailTextView = [self.facebookEditBgView viewWithTag:FacebookControlTagStart];
    if (!detailTextView) {
        detailTextView = [self factoryTextViewForFrame:CGRectMake(0, 20, self.view.width, 121) placeholder:[JfgLanguage getLanTextStrByKey:@"LIVE_DETAIL_DEFAULT_CONTENT"]];
        detailTextView.tag = FacebookControlTagStart;
        NSString *ti = [[NSUserDefaults standardUserDefaults] objectForKey:FBLiveVideoTitleKey];
        if (ti) {
            detailTextView.text = ti;
        }
        [self.facebookEditBgView addSubview:detailTextView];
    }
    
    
    
    TimeCell *accountView = [self.facebookEditBgView viewWithTag:FacebookControlTagStart+1];
    
    if (!accountView) {
        accountView = [[TimeCell alloc]initWithFrame:CGRectMake(0, 161, self.view.width, 44)];
        accountView.titleLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT"],[JfgLanguage getLanTextStrByKey:@"LIVE_PLATFORM_FACEBOOK"]];
        accountView.titleLabel.width = self.view.width*0.5-15;
        accountView.detailLabel.width = ceil(self.view.width - accountView.titleLabel.right - 37)-10;
        accountView.detailLabel.right = self.view.width-37;
        accountView.detailLabel.textAlignment = NSTextAlignmentRight;
        accountView.tag = FacebookControlTagStart+1;
        [accountView addTarget:self action:@selector(facebookAuthorization) forControlEvents:UIControlEventTouchUpInside];
        [self.facebookEditBgView addSubview:accountView];
    
    }
    
    TimeCell *authorityView = [self.facebookEditBgView viewWithTag:FacebookControlTagStart+2];
    if (!authorityView) {
        
        authorityView = [[TimeCell alloc]initWithFrame:CGRectMake(0, 205, self.view.width, 44)];
        authorityView.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_FACEBOOK_PERMISSIONS"];
        authorityView.titleLabel.width = self.view.width*0.5-15;
        authorityView.detailLabel.width = ceil(self.view.width - accountView.titleLabel.right - 37)-10;
        authorityView.detailLabel.right = self.view.width-37;
        authorityView.detailLabel.textAlignment = NSTextAlignmentRight;
        authorityView.tag = FacebookControlTagStart+2;
        [authorityView addTarget:self action:@selector(facebookAuthorityChoose) forControlEvents:UIControlEventTouchUpInside];
        [self.facebookEditBgView addSubview:authorityView];
        
        
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(15, 204.5, self.view.width-15, 0.5)];
        lineView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        [self.facebookEditBgView addSubview:lineView];
    }
    
    if ([FacebookLiveAPIHelper currentToken]) {
        
        authorityView.hidden = NO;
        if (self.facebookHelper.userName) {
            accountView.detailLabel.text = self.facebookHelper.userName;
        }else{
            accountView.detailLabel.text = [FacebookLiveAPIHelper currentToken].appID;
            [self.facebookHelper userNameWithHandler:^(NSError *error, id result) {
                if (!error) {
                    if ([result isKindOfClass:[NSDictionary class]]) {
                        NSDictionary *dict = result;
                        NSString *name = [dict objectForKey:@"name"];
                        accountView.detailLabel.text = name;
                    }
                }
            }];
        }
    
    }else{
        accountView.detailLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_ACCOUNT_UNBOUND"];
        authorityView.hidden = YES;
    }
    
    NSNumber *chooseNum = [[NSUserDefaults standardUserDefaults] objectForKey:FBLiveVideoAuthorityKey];
    if (!chooseNum) {
        chooseNum = @(0);
    }
    authorityView.detailLabel.text = [FacebookLiveAPIHelper privacyForIndex:(FBPrivacyType)[chooseNum intValue]];
    if (self.facebookEditBgView.superview == nil) {
        [self.allBgView addSubview:self.facebookEditBgView];
    }
    self.facebookEditBgView.hidden = NO;
    
}

-(void)facebookAuthorityChoose
{
    FBPravicyChooseVC *vc = [[FBPravicyChooseVC alloc]init];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)facebookAuthorization
{
    if ([FacebookLiveAPIHelper currentToken]) {
        
        __weak typeof(self) weakSelf = self;
        [LSAlertView showAlertWithTitle:[NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"LIVE_UNBIND_ACCOUNT"],@"Facebook"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] CancelBlock:^{
            
            
        } OKBlock:^{
            
            //[ShareSDK cancelAuthorize:SSDKPlatformTypeFacebook];
            [self.facebookHelper loginOut];
            [weakSelf showFacebookEdit];
            
        }];
        
//        if ([LoginManager sharedManager].loginType == JFGSDKLoginTypeOpenLoginForFacebook) {
//            
//            [LSAlertView showAlertWithTitle:@"当前加菲狗/doby使用Facebook登录，暂不能解绑该账号" Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:^{
//                
//            } OKBlock:^{
//                
//            }];
//            
//        }else{
//            
//            
//            
//        }
        
    }else{
        /*
         
         用户：publish_actions
         主页：manage_pages、publish_pages
         小组：publish_actions、user_managed_groups
         事件：publish_actions、user_events
         
         */
        [self.facebookHelper loginFromViewController:self handler:^(NSError *error) {
            if (error == nil) {
                [self showFacebookEdit];
            }
        }];
        
//        [ShareSDK authorize:SSDKPlatformTypeFacebook settings:@{SSDKAuthSettingKeyScopes : @[@"publish_actions",@"manage_pages",@"publish_pages",@"user_managed_groups",@"user_events"]} onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
//            
//            NSLog(@"%lu %@ %@",(unsigned long)state,user,error);
//            if (state == SSDKResponseStateSuccess) {
//                NSLog(@"%@\n%@",user.credential.token,user.credential.secret);
//                
//                [self showFacebookEdit];
//                
//            }
//            
//            
//            /*
//            
//             https://developers.facebook.com/apps/1698182270477391/settings/
//             */
//            
//        }];
        
    }

}

-(UIView *)facebookEditBgView
{
    if (!_facebookEditBgView) {
        _facebookEditBgView = [self factoryBgView];
    }
    return _facebookEditBgView;
}

-(UIView *)ytbeEditBgView
{
    if (!_ytbeEditBgView) {
        _ytbeEditBgView = [self factoryBgView];
    }
    return _ytbeEditBgView;
}

-(UIView *)weiboEditBgView
{
    if (!_weiboEditBgView) {
        _weiboEditBgView = [self factoryBgView];
    }
    return _weiboEditBgView;
}

-(UIView *)rtmpEditBgView
{
    if (!_rtmpEditBgView) {
        _rtmpEditBgView =[self factoryBgView];
    }
    return _rtmpEditBgView;
}

-(UIView *)factoryBgView
{
    UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 92, self.view.width, self.allBgView.height-92)];
    bgView.backgroundColor = self.view.backgroundColor;
    bgView.userInteractionEnabled = YES;
    return bgView;
}

-(YoutubeLiveStreamsModel *)youtubeModel
{
    if (!_youtubeModel) {
        _youtubeModel = [JfgCacheManager youtubeModelForCid:self.cid];
        if (!_youtubeModel) {
            _youtubeModel = [[YoutubeLiveStreamsModel alloc]init];
            _youtubeModel.isValid = NO;
        }
    }
    return _youtubeModel;
}

-(UITextField *)miyaoTextField
{
    if (!_miyaoTextField) {
        _miyaoTextField = [[UITextField alloc]initWithFrame:CGRectMake(15, 217, self.view.width-15-50, 44)];
        _miyaoTextField.textColor = [UIColor colorWithHexString:@"#666666"];
        _miyaoTextField.font = [UIFont systemFontOfSize:14];
        _miyaoTextField.borderStyle = UITextBorderStyleNone;
        _miyaoTextField.placeholder = [JfgLanguage getLanTextStrByKey:@"RTMP_STREAM_KEY"];
        _miyaoTextField.backgroundColor = [UIColor whiteColor];
        _miyaoTextField.secureTextEntry = YES;
        _miyaoTextField.returnKeyType = UIReturnKeyDone;
        _miyaoTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _miyaoTextField.delegate = self;
        NSString *my = [[NSUserDefaults standardUserDefaults] objectForKey:rtmpMiYaoKey];
        if (my) {
            _miyaoTextField.text = my;
        }
    }
    return _miyaoTextField;
}


//创建密码输入框右边控件
-(UIButton *)miyaoLockBtn
{
    if (!_miyaoLockBtn) {
        UIButton *lockBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        lockBtn.frame = CGRectMake(0, 4.5, 35, 35);
        lockBtn.right = self.view.width-15;
        [lockBtn setImage:[UIImage imageNamed:@"lock_btn_noshow password"] forState:UIControlStateNormal];
        [lockBtn setImage:[UIImage imageNamed:@"lock_btn_show password"] forState:UIControlStateSelected];
        lockBtn.adjustsImageWhenDisabled = NO;
        lockBtn.adjustsImageWhenHighlighted = NO;
        [lockBtn addTarget:self action:@selector(lockPwAction:) forControlEvents:UIControlEventTouchUpInside];
        _miyaoLockBtn = lockBtn;
    }
    return _miyaoLockBtn;
}

-(FLTextView *)factoryTextViewForFrame:(CGRect)frame placeholder:(NSString *)placeholder
{
    FLTextView *TextView = [[FLTextView alloc]initWithFrame:frame];
    CGFloat xMargin = 15, yMargin = 15;//左右，上下边距
    // 使用textContainerInset设置top、left、right
    TextView.textContainerInset = UIEdgeInsetsMake(yMargin, xMargin, 0, xMargin);
    //当光标在最后一行时，始终显示低边距，需使用contentInset设置bottom.
    TextView.contentInset = UIEdgeInsetsMake(0, 0, yMargin, 0);
    //防止在拼音打字时抖动
    TextView.layoutManager.allowsNonContiguousLayout=NO;
    TextView.font = [UIFont systemFontOfSize:14];
    TextView.placeholder = placeholder;
    TextView.placeholderFont = [UIFont systemFontOfSize:14];
    TextView.placeholderColor = [UIColor colorWithHexString:@"#CECECE"];
    TextView.placeholderPoint = [NSValue valueWithCGPoint:CGPointMake(18, 15)];
    TextView.textColor = [UIColor colorWithHexString:@"#666666"];
    TextView.delegate = self;
    return TextView;
}


//密码明文密文切换
-(void)lockPwAction:(UIButton *)sender
{
    NSString *text = self.miyaoTextField.text;
    if (sender.selected) {
        self.miyaoTextField.text = @"";
        self.miyaoTextField.secureTextEntry = YES;
        sender.selected  = NO;
    }else{
        self.miyaoTextField.text = @"";
        self.miyaoTextField.secureTextEntry = NO;
        sender.selected  = YES;
    }
    self.miyaoTextField.text = text;
}


-(UIView *)allBgView
{
    if (!_allBgView) {
        _allBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        _allBgView.backgroundColor = [UIColor colorWithHexString:@"#F0F0F0"];
    }
    return _allBgView;
}

#pragma mark - 键盘通知
- (void)addNoticeForKeyboard {
    
    //注册键盘出现的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    //注册键盘消失的通知
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

-(void)removeKeyBoradNotifacation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}


#pragma mark- 键盘监控通知
///键盘显示事件
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘高度，在不同设备上，以及中英文下是不同的
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    if (self.rtmpEditBgView.hidden == NO) {
        
        
        //获取视图相对于self.view的坐标
        CGRect rc = [self.currentTextFieldView.superview convertRect:self.currentTextFieldView.frame toView:self.view];
        
        CGFloat offset = rc.origin.y+rc.size.height+kbHeight-self.view.height;
        double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        if(offset > 0) {
            [UIView animateWithDuration:duration animations:^{
                self.allBgView.top = 64-offset;
            }];
        }else{
            [UIView animateWithDuration:duration animations:^{
                self.allBgView.top = 64;
            }];
        }
    
    }
}

///键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notify {
    // 键盘动画时间
    double duration = [[notify.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    //视图下沉恢复原状
    [UIView animateWithDuration:duration animations:^{
         self.allBgView.top = 64;
    }];
}

-(YoutubeLiveAPIHelper *)youtubeAPIHelper
{
    if (!_youtubeAPIHelper) {
        _youtubeAPIHelper = [[YoutubeLiveAPIHelper alloc]init];
        _youtubeAPIHelper.delegate = self;
    }
    return _youtubeAPIHelper;
}

-(FacebookLiveAPIHelper *)facebookHelper
{
    if (!_facebookHelper) {
        _facebookHelper = [[FacebookLiveAPIHelper alloc]init];
    }
    return _facebookHelper;
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

