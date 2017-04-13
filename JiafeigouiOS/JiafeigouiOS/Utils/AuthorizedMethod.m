//
//  AuthorizedMethod.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AuthorizedMethod.h"
#import <AddressBook/AddressBook.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVFoundation/AVFoundation.h>
#import "JfgGlobal.h"

@implementation AuthorizedMethod
// 通信录 权限
+ (BOOL)isAdressBookAuthorized
{
    ABAuthorizationStatus authStatus = ABAddressBookGetAuthorizationStatus();
    if (authStatus == kABAuthorizationStatusRestricted || authStatus == kABAuthorizationStatusDenied)
    {
        return NO;
    }
    return YES;
}
// 摄像头权限
+ (BOOL)isCameraAuthorized
{
    NSString *mediaType = AVMediaTypeVideo;
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:mediaType];
    if(authStatus ==AVAuthorizationStatusAuthorized || authStatus == AVAuthorizationStatusNotDetermined)
    {
        return YES;
    }
    return NO;
}
// 麦克风 权限
+ (BOOL)isMikeAuthorized
{
    __block BOOL bCanRecord = YES;
    if ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
    {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
            [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
                if (granted) {
                    bCanRecord = YES;
                } else {
                    bCanRecord = NO;
                }
            }];
        }
    }
    
    return bCanRecord;
}
//相册权限
+ (BOOL)isPhotosAuthorized
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author ==ALAuthorizationStatusDenied)//无权限
    {
        return NO;
    }
    return YES;
}


+ (BOOL)isOpenSystemNotification
{
    if(IOS_SYSTEM_VERSION_EQUAL_OR_ABOVE(8.0))
    {
        UIUserNotificationSettings *mySet = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (mySet.types == UIUserNotificationTypeNone)
        {
            return NO;
        }
    }
    else
    {
        if ([[ UIApplication sharedApplication ] enabledRemoteNotificationTypes] == UIRemoteNotificationTypeNone)
        {
            
            return  NO;
        }
    }
    return YES;
}

@end
