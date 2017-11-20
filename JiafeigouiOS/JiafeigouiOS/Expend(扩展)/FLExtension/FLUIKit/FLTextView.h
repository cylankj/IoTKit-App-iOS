//
//  FLTextView.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/8/31.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTextView : UITextView

@property (nonatomic, strong)NSString *placeholder;
@property (nonatomic, strong)UIFont *placeholderFont;
@property (nonatomic, strong)UIColor *placeholderColor;

//placeholder视图位置（默认（4,7））
@property (nonatomic, strong)NSValue *placeholderPoint;

@end
