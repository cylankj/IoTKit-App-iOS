//
//  JFGEquipmentAuthority.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2016/12/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGEquipmentAuthority.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "JfgLanguage.h"
#import "UIAlertView+FLExtension.h"
#import "OemManager.h"
#import "LSAlertView.h"

@implementation JFGEquipmentAuthority

//是否有麦克风权限
+(BOOL)canRecordPermission
{
    __block BOOL bCanRecord = YES;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 7.0)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                }
                else {
                    bCanRecord = NO;//
                    NSString *titleName = [OemManager appName];
                    NSString *str = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_MICROPHONE_C"],titleName];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        //__weak typeof(self) weakSelf = self;
                        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_MICROPHONE"] Message:str CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tosetup"] CancelBlock:^{
                            
                        } OKBlock:^{
                            
                            NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                            [[UIApplication sharedApplication]openURL:url];
                        }];

                    });

                }
            }];
        }
    }
    
    return bCanRecord;
}

+(BOOL)canCameraPermission
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
            NSString *titleName = [OemManager appName];
            NSString *str = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_CAMERA_C"],titleName];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //__weak typeof(self) weakSelf = self;
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_CAMERA"] Message:str CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tosetup"] CancelBlock:^{
                    
                } OKBlock:^{
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication]openURL:url];
                }];
                
                
            });
            return NO;
        }
        return YES;
    }
    return NO;
}

+(BOOL)canPhotoPermission
{
    //判断是否已授权
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
        if (authStatus == ALAuthorizationStatusDenied || authStatus ==  ALAuthorizationStatusRestricted) {
            NSString *titleName = [OemManager appName];
            NSString *str = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_PHOTOS_C"],titleName];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //__weak typeof(self) weakSelf = self;
                [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_PHOTOS"] Message:str CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tosetup"] CancelBlock:^{
                    
                } OKBlock:^{
                    
                    NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication]openURL:url];
                }];
                
            });
            return NO;
        }
        return YES;
    }
    return NO;
}

+ (BOOL)canNotificationPermission {
       //iOS8 check if user allow notification
    UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (UIUserNotificationTypeNone != setting.types) {
        return YES;
    }else{
        NSString *titleName = [OemManager appName];
        NSString *str = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"LOCAL_NOTIFICATION_MSG"],titleName];
        dispatch_async(dispatch_get_main_queue(), ^{
            
            //__weak typeof(self) weakSelf = self;
            [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"UNABLE_TO_NOTIFICATIONS"] Message:str CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Tosetup"] CancelBlock:^{
                
            } OKBlock:^{
                
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication]openURL:url];
            }];
            
        });
    }
    return NO;
}

@end
