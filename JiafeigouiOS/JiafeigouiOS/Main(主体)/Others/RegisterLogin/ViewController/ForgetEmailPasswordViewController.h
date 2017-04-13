//
//  ForgetEmailPasswordViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/8.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,EmailCheckType){
    EmailCheckTypeForgetPassword,
    EmailCheckTypeCheckEmailTip,
};

@interface ForgetEmailPasswordViewController : UIViewController

@property (nonatomic,assign)EmailCheckType type;
@property (nonatomic,strong)NSString *email;

@end
