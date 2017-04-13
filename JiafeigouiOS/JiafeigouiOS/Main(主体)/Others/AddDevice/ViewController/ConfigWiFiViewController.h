//
//  ConfigWiFiViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JfgTypeDefine.h"

@interface ConfigWiFiViewController : UIViewController

@property (nonatomic,assign)BOOL isCamare;

@property (nonatomic, copy) NSString *cid;

@property (nonatomic, assign) productType pType;

@property (nonatomic, assign) configWifiType configType;

@end
