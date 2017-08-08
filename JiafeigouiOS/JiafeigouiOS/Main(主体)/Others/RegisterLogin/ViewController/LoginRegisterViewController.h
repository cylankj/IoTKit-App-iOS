//
//  LoginRegisterViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

NSString * const LoginSuccessNotification = @"LOGINSUCCESSNOTIFICATION";

//进入后首先呈现是登陆还是注册页面
typedef NS_ENUM(NSInteger,FristIntoViewType){
    
    FristIntoViewTypeLogin,
    FristIntoViewTypeRegister,
    
};


//登陆状态
typedef NS_ENUM(NSInteger,LoginState){
    
    LoginStateNot,
    LoginStateLogining,
    LoginStateLoginFinished,
    
};

@interface LoginRegisterViewController : UIViewController

@property (nonatomic,assign)FristIntoViewType viewType;


@end
