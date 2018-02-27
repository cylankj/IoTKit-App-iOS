//
//  AddFaceVSuccessVC.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2018/1/26.
//  Copyright © 2018年 lirenguang. All rights reserved.
//

#import "JFGBaseViewController.h"

@protocol AddFaceVSuccessVCDelegate <NSObject>

-(void)addFaceSucessNextAction;

@end

@interface AddFaceVSuccessVC : JFGBaseViewController

@property (nonatomic,copy)NSString *titleText;
@property (nonatomic,copy)NSString *actionText;
@property (nonatomic,weak)id <AddFaceVSuccessVCDelegate> delegate;

@end
