//
//  ConnDeviceViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JfgTypeDefine.h"

@interface ConnDeviceViewController : UIViewController
{
    BOOL isConnectAp; //是否 连接ap，测试使用
}

@property (nonatomic, assign) productType pType;

@property (nonatomic, copy) NSString *cidStr;

@property (nonatomic, assign) configWifiType configType;

@end
