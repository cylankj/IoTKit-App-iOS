//
//  ShareClassView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareClassView.h"
#import "JfgGlobal.h"
#import <ShareSDK/ShareSDK.h>
#import "ShareWithFriendsVC.h"
#import "ShareWithAddrBookVC.h"
#import "LSAlertView.h"
#import "FLShareSDKHelper.h"
#import "NSDictionary+FLExtension.h"
#import "CommonMethod.h"
#import "ProgressHUD.h"
#import <ShareSDKUI/ShareSDKUI.h>
#import <ShareSDKUI/SSUIEditorViewStyle.h>

#define CoverViewTag 2202
#define ShareViewTag 2221
#define CancelButtonTag 2222
//屏幕宽度相对iPhone6屏幕宽度的比例
#define KWidth_Scale    [UIScreen mainScreen].bounds.size.width/375.0f
@interface ShareClassView()
@end
@implementation ShareClassView

static NSMutableDictionary * _Content;
static shareType _type;
static UINavigationController * _nav;
static NSString * _cid;
-(instancetype)initWithFrame:(CGRect)frame shareWithContent:(NSMutableDictionary *)content withType:(shareType)type navigationController:(UINavigationController *)nav Cid:(NSString *)cid{
    if (self =[super initWithFrame:frame]) {
        _Content = content;
        _type = type;
        _nav = nav;
        _cid = cid;
        self.backgroundColor = [UIColor colorWithHexString:@"f0f0f0"];
        //目前只有2个,以后多了这里再重新布局吧
        NSArray * btnImages = [self createImages];
        NSArray * btnTitles = [self createTitles];
        
        int k = 0;
        if (_type == shareTypeDevice) {
            k=2;
        }else{
            k=4;
        }
        CGFloat top = 30;
        //CGFloat left = (Kwidth-72-2*55)/2.0;
        CGFloat sizeW = 55;
        CGFloat sizeH = 79;
        CGFloat space = (Kwidth - (sizeW*k))/(k+1);
        
        //以后多了再排
        for (int i = 0; i<k; i++) {
            UIButton * button = [[UIButton alloc]initWithFrame:CGRectMake(space+(sizeW+space)*i, top, sizeW, sizeH)];
            [button setImage:[UIImage imageNamed:btnImages[i]] forState:UIControlStateNormal];
            [button setTitle:btnTitles[i] forState:UIControlStateNormal];
            button.adjustsImageWhenHighlighted = NO;
            //button.titleLabel.font = [UIFont fontWithName:@"PingFangSC-medium" size:13];
            button.titleLabel.font = [UIFont systemFontOfSize:13];
            button.titleLabel.adjustsFontSizeToFitWidth = YES;
            button.titleLabel.textAlignment = NSTextAlignmentCenter;
            [button setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
            [button setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
            [button setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
            if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
                [button setTitleEdgeInsets:UIEdgeInsetsMake(66, -sizeW, 0, 0)];
            }else{
                [button setTitleEdgeInsets:UIEdgeInsetsMake(66, -sizeW, 0, 0)];
            }
            [button setImageEdgeInsets:UIEdgeInsetsMake(-22, 0, 0, 0)];
            button.tag = 444+i;
            [button addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:button];
        }
        UIView *line =[UIView new];
        [line setFrame:CGRectMake(0, 150*KWidth_Scale, KWidth_Scale, 0.5)];
        [line setBackgroundColor:TableSeparatorColor];
        [self addSubview:line];
        
        UIButton *cancleButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 150*KWidth_Scale+0.5, Kwidth, 50*KWidth_Scale-0.5)];
        [cancleButton setBackgroundColor:[UIColor colorWithHexString:@"#fafafa"]];
        [cancleButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        cancleButton.titleLabel.font = [UIFont fontWithName:@"PingFangSC-medium" size:16*KWidth_Scale];
        cancleButton.titleLabel.font = [UIFont systemFontOfSize:16*KWidth_Scale];
        cancleButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [cancleButton setTitleColor:[UIColor colorWithHexString:@"#333333"] forState:UIControlStateNormal];
        
        cancleButton.tag = CancelButtonTag;
        [cancleButton addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [cancleButton addTarget:self action:@selector(shareBtnHighlight:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:cancleButton];
        
    }
    return self;
}
-(NSArray *)createImages{
    NSArray * btnImages = [NSArray array];
    switch (_type) {
        case shareTypeDevice:
            btnImages = @[@"icon_friend100.png",@"icon_contacts110.png"];
            break;
            
        default:
            btnImages = @[@"btn_share_TimeLine.png",@"btn_share_wechat.png",@"icon_twitter_1",@"icon_facebook-1"];
            break;
    }
    return btnImages;
}
-(NSArray *)createTitles{
    NSArray * btnTitles = [NSArray array];

    switch (_type) {
        case shareTypeDevice:
            btnTitles = @[[JfgLanguage getLanTextStrByKey:@"Tap3_Friends"],[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Contacts"]];
            break;
            
        default:
            btnTitles = @[[JfgLanguage getLanTextStrByKey:@"Tap2_Share_Moments"],[JfgLanguage getLanTextStrByKey:@"Tap2_Share_Wechat"],@"Twitter",@"Facebook"];
            break;
    }
    return btnTitles;
}

+(void)showShareViewWithTitle:(NSString *)title content:(NSString *)content url:(NSString *)url image:(UIImage *)image imageUrl:(NSString *)imageUrl Type:(shareType)type navigationController:(UINavigationController *)nav Cid:(NSString *)cid
{
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]init];
    [dict safeSetObject:title forKey:@"title"];
    [dict safeSetObject:content forKey:@"content"];
    [dict safeSetObject:url forKey:@"url"];
    [dict safeSetObject:image forKey:@"image"];
    [dict safeSetObject:imageUrl forKey:@"imageUrl"];
    
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    ShareClassView * share = [[ShareClassView alloc]initWithFrame:CGRectMake(0, kheight, Kwidth, kheight) shareWithContent:dict withType:type navigationController:nav Cid:cid];
    
    share.tag = ShareViewTag;
    ShareCoverView * coverView = [[ShareCoverView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
    coverView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    coverView.alpha = 0;
    coverView.tag = CoverViewTag;
    [window addSubview:coverView];
    
    [window addSubview:share];
    [UIView animateWithDuration:[CommonMethod sheetAnimationTimeIntervalForHeight:200*KWidth_Scale] animations:^{
        coverView.alpha = 0.6;
        [share setFrame:CGRectMake(0, kheight-200*KWidth_Scale, Kwidth, 200*KWidth_Scale)];
    } completion:^(BOOL finished) {
        
    }];
}

+(ShareClassView *)showShareViewWitnContent:(NSMutableDictionary *)dictionary withType:(shareType)type navigationController:(UINavigationController *)nav Cid:(NSString *)cid
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    ShareClassView * share = [[ShareClassView alloc]initWithFrame:CGRectMake(0, kheight, Kwidth, kheight) shareWithContent:dictionary withType:type navigationController:nav Cid:cid];

    share.tag = ShareViewTag;
    ShareCoverView * coverView = [[ShareCoverView alloc]initWithFrame:CGRectMake(0, 0, Kwidth, kheight)];
    coverView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    coverView.alpha = 0;
    coverView.tag = CoverViewTag;
    [window addSubview:coverView];
    
    [window addSubview:share];
    [UIView animateWithDuration:[CommonMethod sheetAnimationTimeIntervalForHeight:200*KWidth_Scale] animations:^{
        coverView.alpha = 0.6;
        [share setFrame:CGRectMake(0, kheight-200*KWidth_Scale, Kwidth, 200*KWidth_Scale)];
    } completion:^(BOOL finished) {
        
    }];
    
    return share;
}
-(void)shareBtnHighlight:(UIButton *)button
{
    [button setBackgroundColor:CellSelectedColor];
}

-(void)shareBtnClick:(UIButton *)button{
    
   // [button setBackgroundColor:[UIColor colorWithHexString:@"#fafafa"]];
    [self dismiss];
    
    if (_type == shareTypeDevice) {
        
        if (button.tag == 444) {
            ShareWithFriendsVC * friendVC = [ShareWithFriendsVC new];
            friendVC.cid = _cid;
            [_nav pushViewController:friendVC animated:YES];
        }else if (button.tag == 445){
            ShareWithAddrBookVC * addrBook = [ShareWithAddrBookVC new];
            addrBook.cid = _cid;
            addrBook.deviceShareList = self.obj;
            [_nav pushViewController:addrBook animated:YES];
        }else{
            
            return;
        }
        
    }else{
        
        NSMutableDictionary *parameters = [[NSMutableDictionary alloc]init];
        NSURL *url = nil;
        
        if ([_Content objectForKey:@"url"]) {
            url = [NSURL URLWithString:[_Content objectForKey:@"url"]];
        }
        
        SSDKPlatformType shareType;
        
        [SSUIEditorViewStyle setiPhoneNavigationBarBackgroundColor:[UIColor colorWithHexString:@"#54b2d0"]];
        [SSUIEditorViewStyle setTitleColor:[UIColor whiteColor]];
        [SSUIEditorViewStyle setCancelButtonLabelColor:[UIColor whiteColor]];
        [SSUIEditorViewStyle setShareButtonLabelColor:[UIColor whiteColor]];
        
        [SSUIEditorViewStyle setCancelButtonLabel:[JfgLanguage getLanTextStrByKey:@"CANCEL"]];
        [SSUIEditorViewStyle setShareButtonLabel:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_Button"]];
        
        if (button.tag == 444) {
            shareType = SSDKPlatformSubTypeWechatTimeline;
            
            if ([ShareSDK isClientInstalled:SSDKPlatformSubTypeWechatSession]) {
                 [parameters SSDKSetupWeChatParamsByText:[_Content objectForKey:@"content"] title:[_Content objectForKey:@"title"] url:url thumbImage:nil image:[_Content objectForKey:@"image"] musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeImage forPlatformSubType:shareType];
            }else{
                //
                 [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap2_share_unabletoshare"]];
                return;
            }
            
            
           
        }else if (button.tag == 445){
            
            if ([ShareSDK isClientInstalled:SSDKPlatformSubTypeWechatSession]) {
                shareType = SSDKPlatformSubTypeWechatSession;
                [parameters SSDKSetupWeChatParamsByText:[_Content objectForKey:@"content"] title:[_Content objectForKey:@"title"] url:url thumbImage:nil image:[_Content objectForKey:@"image"] musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeImage forPlatformSubType:shareType];
            }else{
                //
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap2_share_unabletoshare"]];
                return;
            }
            
           
        }else if (button.tag == 446){
            UIImage *im = [_Content objectForKey:@"image"];
            [self shareToTwitterWithContentText:[_Content objectForKey:@"content"] title:[_Content objectForKey:@"title"] image:im];
            return;
        }else if (button.tag == 447){
            UIImage *im = [_Content objectForKey:@"image"];
            [self shareToFacebookWithContentText:[_Content objectForKey:@"content"] title:[_Content objectForKey:@"title"] image:im];
            return;
        }else{
            return;
        }
        [ShareSDK share:shareType parameters:parameters onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error)
         {
             
             //ShareCoverView
             if (error) {
                 if (error.code == 0) {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                 }else{
                     [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                 }
             } else {
                 switch (state) {
                     case SSDKResponseStateSuccess:
                     {
                         //[LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                         
                         [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                         
                         break;
                     }
                     case SSDKResponseStateFail:
                     {
                         //                             [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                         break;
                     }
                     case SSDKResponseStateCancel:
                     {
                         //                              [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_CanceldeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                         break;
                     }
                     default:
                         break;
                 }
             }
             //
             
         }];

        
        
    }
    
    
    
}


-(void)shareToFacebookWithContentText:(NSString *)text title:(NSString *)title image:(UIImage *)image
{
    //UIImage *im = [UIImage imageNamed:@"icon_facebook"];
    //创建分享参数
    //NSArray* imageArray = @[[UIImage imageNamed:@"shareImg.png"]];
    
    if (image) {
        
        [SSUIEditorViewStyle setTitle:@"Share To Facebook"];
        
        
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:@[image]
                                            url:[NSURL URLWithString:@"http://jfgou.com"]
                                          title:title
                                           type:SSDKContentTypeImage];
        
        [ShareSDK showShareEditor:SSDKPlatformTypeFacebook
               otherPlatformTypes:nil
                      shareParams:shareParams
              onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
         {
             
             if (error) {
                 NSString * errorStr = [error.userInfo objectForKey:@"error_message"];
                 NSLog(@"faceBook分享错误：userInfo:%@",errorStr);
                 if (error.code == 0) {
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                 }else{
                     [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                 }
                 
             }
             
             switch (state) {
                     
                 case SSDKResponseStateBegin:
                 {
                     //[theController showLoadingView:YES];
                     break;
                 }
                 case SSDKResponseStateSuccess:
                 {
                      [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                      //[LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                      //[LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_CanceldeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 default:
                     break;
             }
             
             if (state != SSDKResponseStateBegin)
             {
                 
             }
         }];
    }

}

-(void)shareToTwitterWithContentText:(NSString *)text title:(NSString *)title image:(UIImage *)image
{
    //UIImage *im = [UIImage imageNamed:@"icon_facebook"];
    //创建分享参数
    //NSArray* imageArray = @[[UIImage imageNamed:@"shareImg.png"]];
    
    if (image) {
        
        [SSUIEditorViewStyle setTitle:@"Share To Twitter"];
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:text
                                         images:@[image]
                                            url:[NSURL URLWithString:@"http://jfgou.com"]
                                          title:title
                                           type:SSDKContentTypeImage];
        
        [ShareSDK showShareEditor:SSDKPlatformTypeTwitter
               otherPlatformTypes:nil
                      shareParams:shareParams
              onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end)
         {
             
             if (error) {
                 if (error.code == 0) {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                 }else{
                     [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                 }
             }
             
             switch (state) {
                     
                 case SSDKResponseStateBegin:
                 {
                     //[theController showLoadingView:YES];
                     break;
                 }
                 case SSDKResponseStateSuccess:
                 {
                     [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_SuccessTips"]];
                     break;
                 }
                 case SSDKResponseStateFail:
                 {
                    // [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_FailTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 case SSDKResponseStateCancel:
                 {
                    // [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice_CanceldeTips"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"OK"] OtherButtonTitle:nil CancelBlock:nil OKBlock:nil];
                     break;
                 }
                 default:
                     break;
             }
             
             if (state != SSDKResponseStateBegin)
             {
                 
             }
         }];
    }
    
}

-(void)dismiss
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    ShareCoverView * coverView = [window viewWithTag:CoverViewTag];
    
    [UIView animateWithDuration:[CommonMethod sheetAnimationTimeIntervalForHeight:200*KWidth_Scale] animations:^{
        coverView.alpha = 0;
        [self setFrame:CGRectMake(0, kheight, Kwidth, 200*KWidth_Scale)];
    } completion:^(BOOL finished) {
        [coverView removeFromSuperview];
        [self removeFromSuperview];
    }];
}
@end
@implementation ShareCoverView
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event
{
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    ShareClassView * share = (ShareClassView *)[window viewWithTag:ShareViewTag];
    
    if ([share isKindOfClass:[ShareClassView class]]) {
        [share dismiss];
    }
    
    
}
@end
