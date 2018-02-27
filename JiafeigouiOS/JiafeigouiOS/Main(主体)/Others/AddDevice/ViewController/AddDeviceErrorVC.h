//
//  AddDeviceErrorVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"

typedef NS_ENUM(NSInteger, BindResultType)
{
    BindResultType_Success, // 另外一个类里
    BindResultType_CidNotExist = 200,
    BindResultType_AlwaysBinded = 204,//已经被绑定
    BindResultType_Timeout = 400,
    BindResultType_720SetWifiFailed = 600,//720设备设置wifi错误
   
};

@interface AddDeviceErrorVC : BaseViewController

@property (nonatomic, assign) int errorType;
@property (nonatomic,copy)NSString *errorMsg;

@end
