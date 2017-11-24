//
//  RegionalizationViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/11/20.
//  Copyright © 2017年 lirenguang. All rights reserved.
//  区域划分

#import "BaseNavgationViewController.h"

@protocol RegionalizationVCDelegate <NSObject>

-(void)updateAreaDetection;

@end

@interface RegionalizationViewController : UIViewController

@property (nonatomic,copy)NSString *cid;
@property (nonatomic,assign)BOOL isOpenAreaDetection;//是否打开区域侦测
@property (nonatomic,weak)id <RegionalizationVCDelegate> delegate;

@end
