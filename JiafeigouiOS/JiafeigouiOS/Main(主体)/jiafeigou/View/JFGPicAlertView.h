//
//  JFGPicAlertView.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JFGPicAlertView : UIView

+(void)showAlertWithImage:(UIImage *)image Title:(NSString *)title Message:(NSString *)msg cofirmButtonTitle:(NSString *)btnTitle didDismissBlock:(void (^) (void))dissmissBlock;

@end
