//
//  PersonQRCodeView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 16/8/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PersonQRCodeView : UIView

-(instancetype)initWithHeadImage:(UIImage *)headImage name:(NSString *)name qrImage:(UIImage *)qrImage;

-(void)show;

@end
