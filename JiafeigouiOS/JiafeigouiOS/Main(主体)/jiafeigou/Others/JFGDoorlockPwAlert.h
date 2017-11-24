//
//  JFGDoorlockPwAlert.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/11/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol JFGDoorlockPwAlertDelegate <NSObject>

-(void)jfgDoorlockPwAlertDone:(NSString *)pw;

@end

@interface JFGDoorlockPwAlert : NSObject

@property (nonatomic,weak)id <JFGDoorlockPwAlertDelegate> delegate;

-(void)showAlertWithVC:(UIViewController *)presenVC;

@end
