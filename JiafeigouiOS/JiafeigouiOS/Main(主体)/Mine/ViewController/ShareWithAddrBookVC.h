//
//  ShareWithAddrBookVC.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
typedef NS_ENUM(NSInteger,VCType){
    VCTypeShareDeviceFromAddrBook,//分享设备
    VCTypeAddFriendFromAddrBook,//添加好友
};

@interface ShareWithAddrBookVC : BaseViewController

@property(nonatomic,assign)VCType vcType;

@property (nonatomic,strong)NSMutableArray *deviceShareList;

@end
