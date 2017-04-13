//
//  NewPasswordViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,SetPasswordType){
    
    SetPasswordTypeInitializePassword,//初始化密码
    SetPasswordTypeResetPassword,//重置密码
    
};

@interface NewPasswordViewController : UIViewController

@property (nonatomic,assign)SetPasswordType type;
@property (nonatomic, assign) NSInteger registerType;

@property (nonatomic, copy) NSString *accountStr;
@property (nonatomic, copy) NSString *registerToken;

@end
