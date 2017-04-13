//
//  ChangePwdViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import <JFGSDK/JFGSDKAcount.h>
@interface ChangePwdViewController : BaseViewController

@property (nonatomic,assign)BOOL isSettingPW;//是否是第三方登录设置密码
@property (nonatomic,copy)NSString *smsToken;
@property (strong, nonatomic)JFGSDKAcount * jfgAccount;

@end
