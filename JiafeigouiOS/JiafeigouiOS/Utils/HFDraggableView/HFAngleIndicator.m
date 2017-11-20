//
//  HFAngleIndicator.m
//  HFDraggableView
//
//  Created by Henry on 08/11/2017.
//  Copyright © 2017 Henry. All rights reserved.
//

#import "HFAngleIndicator.h"
#define kSize CGSizeMake(40, 30)

@implementation HFAngleIndicator {
    UILabel *_numberLabel;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (frame.size.width == 0 && frame.size.height == 0) {
        frame.size = kSize;
    }
    
    self = [super initWithFrame:frame];
    if (!self) {
        return nil;
    }
    
    self.backgroundColor = [UIColor blackColor];
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.textAlignment = NSTextAlignmentCenter;
    _numberLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:_numberLabel];
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return kSize;
}

- (void)setAngle:(CGFloat)angle {
    _angle = angle;
    
    _numberLabel.text = [NSString stringWithFormat:@"%d°", (int)(angle/M_PI * 180) % 360];
}

@end
