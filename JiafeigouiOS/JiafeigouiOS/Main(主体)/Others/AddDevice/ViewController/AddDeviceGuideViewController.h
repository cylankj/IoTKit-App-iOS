//
//  AddDeviceGuideViewController.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/16.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import "JfgTypeDefine.h"
#import "jfgConfigManager.h"

@protocol AddDeviceGuideVCNextActionDelegate <NSObject>

-(void)addDeviceGuideVCNectActionForVC:(UIViewController *)vc;

@end

@interface AddDeviceGuideViewController : BaseViewController
{
    
}

@property (nonatomic, assign) configWifiType configType;
@property (nonatomic, weak) id<AddDeviceGuideVCNextActionDelegate>delegate;

@end
