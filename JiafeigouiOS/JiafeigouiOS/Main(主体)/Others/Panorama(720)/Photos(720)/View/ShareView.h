//
//  ShareView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/5/6.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShareSDK/ShareSDK.h>

typedef NS_ENUM(NSInteger, shareType) {
    shareTypeWebChat = 0,       // webChat
    shareTypeInFriends,     // webFriend
    shareTypeQQ,            // QQ
    shareTypeQQZone,        // QQ zone
    shareTypeSinaWeibo,     // sina weibo
    shareTypeFaceBook,      // face book
    shareTypeTwitter        // twitter
};

@interface ShareView : UIView

@property (nonatomic, assign) BOOL isLandScape;

- (instancetype)initWithLandScape:(BOOL)isLandScape;

- (void)showShareView:(void (^)(SSDKPlatformType))clickedBlock cancel:(void (^)())cancelBlock;

- (void)dismissShareView;

@end
