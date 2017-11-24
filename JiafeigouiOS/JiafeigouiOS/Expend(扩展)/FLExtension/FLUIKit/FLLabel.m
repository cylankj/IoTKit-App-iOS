//
//  FLLabel.m
//  HFDraggableView
//
//  Created by 杨利 on 2017/11/21.
//  Copyright © 2017年 Henry. All rights reserved.
//

#import "FLLabel.h"

@implementation FLLabel

- (void)setVerticalAlignment:(FLVerticalAlignment)verticalAlignment
{  
    _verticalAlignment= verticalAlignment;  
    [self setNeedsDisplay];  
}  

- (void)drawTextInRect:(CGRect)rect  
{  
    if (_verticalAlignment == FLVerticalAlignmentNone)
    {  
        [super drawTextInRect:UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets)];  
    }  
    else  
    {  
        CGRect textRect = [self textRectForBounds:UIEdgeInsetsInsetRect(rect, self.edgeInsets) limitedToNumberOfLines:self.numberOfLines];  
        [super drawTextInRect:textRect];  
    }  
}  

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines  
{  
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];  
    switch (_verticalAlignment) {  
        case FLVerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;  
            break;  
            
        case FLVerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;  
            break;  
            
        case FLVerticalAlignmentCenter:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;  
            break;  
            
        default:  
            break;  
    }  
    return textRect;  
}  

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
