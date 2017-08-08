//
//  UITextField+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIFont+FLExtension.h"

@interface UITextField (FLExtension)

+ (UITextField *)initWithFrame:(CGRect)frame
                   placeholder:(NSString *)placeholder
                         color:(UIColor *)color
                          font:(FontName)fontName
                          size:(float)size
                    returnType:(UIReturnKeyType)returnType
                  keyboardType:(UIKeyboardType)keyboardType
                        secure:(BOOL)secure
                   borderStyle:(UITextBorderStyle)borderStyle
            autoCapitalization:(UITextAutocapitalizationType)capitalization
            keyboardAppearance:(UIKeyboardAppearance)keyboardAppearence
 enablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically
               clearButtonMode:(UITextFieldViewMode)clearButtonMode
            autoCorrectionType:(UITextAutocorrectionType)autoCorrectionType
                      delegate:(id<UITextFieldDelegate>)delegate;

@property (assign, nonatomic) NSInteger maxLength;

@end
