//
//  JFGBigImageView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JFGBigImageView : UIView

+(instancetype)initWithImage:(UIImage *)image;
+(instancetype)initWithImage:(UIImage *)image showLongPress:(BOOL)show;
-(void)show;

@end
