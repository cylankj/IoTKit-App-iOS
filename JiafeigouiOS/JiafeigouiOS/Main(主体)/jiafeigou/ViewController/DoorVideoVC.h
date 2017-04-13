//
//  DoorVideoVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef NS_ENUM(NSInteger, doorActionType)
{
    doorActionTypeActive, // 主动
    doorActionTypeUnActive, // 被动
};


@interface DoorVideoVC : BaseViewController

@property (nonatomic, assign) doorActionType actionType;

@property (nonatomic,copy)NSString *imageUrl;

@property (nonatomic,copy)NSString *nickName;

@property (nonatomic, assign) BOOL isOnline;

@end
