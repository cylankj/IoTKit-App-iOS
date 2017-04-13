//
//  InsetsTextField.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "InsetsTextField.h"

@implementation InsetsTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
//控制 placeHolder 的位置，左右缩 20
-(CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 0 );
}

// 控制文本的位置，左右缩 20
- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 0 );
}
@end
