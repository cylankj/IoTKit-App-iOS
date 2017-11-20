//
//  FacebookLiveAPIHelper.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/13.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FBSDKAccessToken.h>

typedef NS_ENUM(NSInteger,FBPrivacyType){
    FBPrivacyTypePublic,
    FBPrivacyTypeFriends,
    FBPrivacyTypeSelf,
    FBPrivacyTypeFriendsOfFriends,
};

NSString *const FBLiveVideoAuthorityKey = @"FBLiveVideoAuthorityKey";
NSString *const FBLiveVideoTitleKey = @"FBLiveVideoTitleKey_";

@interface FacebookLiveAPIHelper : NSObject

@property (nonatomic,copy)NSString *userName;

//获取当前授权信息，nil则未授权需要调用一下方法授权
+(FBSDKAccessToken *)currentToken;

//登录授权
-(void)loginFromViewController:(UIViewController *)vc handler:(void (^)(NSError *error))handler;

//取消授权登陆
-(void)loginOut;

//创建直播
-(void)createLiveWithHandler:(void(^)(NSError *error,id result))handler;

//获取组
-(void)groupListWithHandler:(void(^)(NSError *error,id result))handler;

//获取用户名字
-(void)userNameWithHandler:(void(^)(NSError *error,id result))handler;

-(void)endLiveWithHandler:(void(^)(NSError *error,id result))handler;

//获取权限数组
+(NSArray *)fbPrivacy;

//根据权限获取相信显示内容
+(NSString *)privacyForIndex:(FBPrivacyType)type;

@end
