//
//  FriendsInfoVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

/**
 *  已添加 好友信息 
 *  不是好友 信息  
 *  页面 共用
 */

#import "BaseFriendsVC.h"
typedef NS_ENUM(NSInteger, FriendsInfoType)
{
    FriendsInfoIsFriens, //是 好友
    FriendsInfoUnFiens  //不是 好友
};


@interface FriendsInfoVC : BaseFriendsVC

@property (nonatomic, assign) FriendsInfoType friendsInfoType;

/**
 *  头像
 */
@property (nonatomic, strong) UIImageView *headImageView;
/**
 *  名字
 */
@property (nonatomic, strong) UILabel *nameLabel;
/**
 *  昵称
 */
@property (nonatomic, strong) UILabel *nickNameLabel;
/**
 *  数据源
 */
@property (nonatomic, copy) NSString * reqMsg;
/**
 *  账号
 */
@property (nonatomic, copy) NSString * account;

@property (nonatomic,copy)NSString *nickNameString;

/**
 是否是验证好友信息
 */
@property (nonatomic, assign)BOOL isVerifyFriends;
@end
