//
//  JFGBaseViewController.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/7/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "JfgLanguage.h"

@interface JFGBaseViewController : UIViewController

/**
 *  navigationBar底部视图
 */
@property (nonatomic,strong)UIView *topBarBgView;
@property (nonatomic,strong)UILabel *titleLabel;
@property (nonatomic,strong)UIButton *backBtn;

-(void)backAction;

@end
