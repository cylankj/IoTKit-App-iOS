//
//  ChangePhoneViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import <JFGSDK/JFGSDKAcount.h>
typedef enum {
    actionTypeBingPhone,
    actionTypeChangePhone
}actionType;
@interface ChangePhoneViewController : BaseViewController

@property (strong, nonatomic) JFGSDKAcount * jfgAccount;
@property (assign, nonatomic) actionType actionType;
@end
