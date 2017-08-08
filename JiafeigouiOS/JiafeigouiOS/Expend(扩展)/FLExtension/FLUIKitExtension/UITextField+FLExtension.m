//
//  UITextField+FLExtension.m
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "UITextField+FLExtension.h"
#import <objc/runtime.h>

static const void *MaxLength = &MaxLength;

@implementation UITextField (FLExtension)
@dynamic maxLength;

+ (UITextField *)initWithFrame:(CGRect)frame placeholder:(NSString *)placeholder color:(UIColor *)color font:(FontName)fontName size:(float)size returnType:(UIReturnKeyType)returnType keyboardType:(UIKeyboardType)keyboardType secure:(BOOL)secure borderStyle:(UITextBorderStyle)borderStyle autoCapitalization:(UITextAutocapitalizationType)capitalization keyboardAppearance:(UIKeyboardAppearance)keyboardAppearence enablesReturnKeyAutomatically:(BOOL)enablesReturnKeyAutomatically clearButtonMode:(UITextFieldViewMode)clearButtonMode autoCorrectionType:(UITextAutocorrectionType)autoCorrectionType delegate:(id<UITextFieldDelegate>)delegate
{
    UITextField *textField = [[UITextField alloc] initWithFrame:frame];
    [textField setBorderStyle:borderStyle];
    [textField setAutocorrectionType:autoCorrectionType];
    [textField setClearButtonMode:clearButtonMode];
    [textField setKeyboardType:keyboardType];
    [textField setAutocapitalizationType:capitalization];
    [textField setPlaceholder:placeholder];
    [textField setTextColor:color];
    [textField setReturnKeyType:returnType];
    [textField setEnablesReturnKeyAutomatically:enablesReturnKeyAutomatically];
    [textField setSecureTextEntry:secure];
    [textField setKeyboardAppearance:keyboardAppearence];
    [textField setFont:[UIFont fontForFontName:fontName size:size]];
    [textField setDelegate:delegate];
    
    return textField;
}

- (NSInteger)maxLength {
    return [objc_getAssociatedObject(self, MaxLength) integerValue];
}

- (void)setMaxLength:(NSInteger)maxLength {
    NSNumber *number = [[NSNumber alloc]initWithInteger:maxLength];
    objc_setAssociatedObject(self, MaxLength, number, OBJC_ASSOCIATION_COPY);
    
    [self addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)textFieldDidChange:(UITextField *)sender {
    bool isChinese;//判断当前输入法是否是中文
    
    if([[self.textInputMode primaryLanguage] isEqualToString: @"en-US"]) {
        isChinese = false;
    }
    else {
        isChinese = true;
    }
    
    if(sender == self) {
        NSString *str = [[self text] stringByReplacingOccurrencesOfString:@"?" withString:@""];
        if(isChinese) {
            //中文输入法下
            UITextRange *selectedRange = [self markedTextRange];
            //获取高亮部分
            UITextPosition *position = [self positionFromPosition:selectedRange.start offset:0];
            //没有高亮选择的字，则对已输入的文字进行字数统计和限制
            if(!position) {
                if( str.length>= [self maxLength] + 1) {
                    NSString *strNew = [NSString stringWithString:str];
                    [self setText:[strNew substringToIndex:[self maxLength]]];
                }
            }
        }
        else {
            if([str length]>=[self maxLength] + 1) {
                NSString *strNew = [NSString stringWithString:str];
                [self setText:[strNew substringToIndex:[self maxLength]]];
            }
        }
    }
}


@end
