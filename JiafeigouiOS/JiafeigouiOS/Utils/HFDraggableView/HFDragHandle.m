//
//  HFDragHandle.m
//  HFFoundation
//
//  Created by Henry on 08/11/2017.
//

#import "HFDragHandle.h"

@implementation HFDragHandle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [UIColor clearColor];
    _shape = HFDragHandleShapeCircle;
    _color = [UIColor blackColor];
    _scale = 1;
    _borderColor = [UIColor clearColor];
    _borderWidth = 0;
    
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rct = self.bounds;
    rct.origin.x = 0.5 * (rct.size.width - self.scale * rct.size.width);
    rct.origin.y = 0.5 * (rct.size.height - self.scale * rct.size.height);
    rct.size.width = self.scale * rct.size.width;
    rct.size.height = self.scale * rct.size.height;
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    
    CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
    CGContextSetLineWidth(context, self.borderWidth);
    
    if (self.shape == HFDragHandleShapeCircle) {
        CGContextFillEllipseInRect(context, rct);
        CGContextStrokeEllipseInRect(context, rct);
    } else if (self.shape == HFDragHandleShapeRect) {
        CGContextFillRect(context, rct);
        CGContextStrokeRect(context, rct);
    }
}

#pragma mark- accessor
- (void)setColor:(UIColor *)color {
    if(color != _color){
        _color = color;
        [self setNeedsDisplay];
    }
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    if (backgroundColor != self.backgroundColor) {
        [self setNeedsDisplay];
    }
    [super setBackgroundColor:backgroundColor];
}

- (void)setBorderColor:(UIColor *)borderColor {
    if(borderColor != _borderColor){
        _borderColor = borderColor;
        [self setNeedsDisplay];
    }
}

- (void)setBorderWidth:(CGFloat)borderWidth {
    if(borderWidth != _borderWidth){
        _borderWidth = borderWidth;
        [self setNeedsDisplay];
    }
}

@end
