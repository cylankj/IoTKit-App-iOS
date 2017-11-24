//
//  ChangePwdViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import <JFGSDK/JFGSDKAcount.h>

typedef NS_ENUM(NSInteger,ChangePwdType) {
    
    ChangePwdTypeForAccount,//修改账号密码
    ChangePwdTypeForDoorlock,//修改门铃开门密码
    
};

@interface ChangePwdViewController : BaseViewController

@property (nonatomic,assign)ChangePwdType changeType;//修改密码类型
@property (nonatomic,assign)JFGSDKAcount * jfgAccount;

@end
