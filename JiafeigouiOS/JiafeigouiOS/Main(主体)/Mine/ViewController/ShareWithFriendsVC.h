//
//  ShareWithFriendsVC.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import <JFGSDK/JFGSDK.h>
#import <JFGSDK/JFGSDKAcount.h>

@interface ShareWithFriendsVC :BaseViewController



@end


@interface friendInfo : NSObject

@property (nonatomic,strong)JFGSDKFriendInfo *info;
@property (nonatomic,assign)NSIndexPath *indexPath;
@property (nonatomic,assign)BOOL isSelected;

@end
