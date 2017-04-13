//
//  SetAngleVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/2/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import "JfgTypeDefine.h"

@protocol setAngleDelegate <NSObject>

- (void)angleChanged:(int)angleType;

@end

@interface SetAngleVC : BaseViewController

@property (nonatomic, assign) int oldAngleType;

@property (nonatomic, assign) id<setAngleDelegate> angleDelegate;

@end
