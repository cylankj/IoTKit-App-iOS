//
//  ShareDeviceModel.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JfgTypeDefine.h"

@interface ShareDeviceModel : NSObject
@property (nonatomic, strong) UIImage * icomIage;

@property (nonatomic, assign) productType ptype;

@property (nonatomic, assign) NSInteger shareNum;

@property (nonatomic, copy)NSString * deviceName;


@end
