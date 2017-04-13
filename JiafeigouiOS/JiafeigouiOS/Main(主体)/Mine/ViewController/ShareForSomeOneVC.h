//
//  ShareForSomeOneVC.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import <JFGSDK/JFGSDK.h>

@interface ShareForSomeOneVC : BaseViewController

@property (nonatomic, copy)NSString *remarkName;
@property (nonatomic, copy)NSString * account;

@end


//分享设备模型
@interface UserShareDeviceModel : NSObject

@property (nonatomic,copy)NSString *uuid;
@property (nonatomic,copy)NSString *alias;
@property (nonatomic,assign)NSInteger shareCount;
@property (nonatomic,assign)NSInteger tempShareCount;
@property (nonatomic,assign)JFGDeviceType deviceType;
@property (nonatomic,assign)BOOL _selected;

@end
