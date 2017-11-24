//
//  FLLabel.h
//  HFDraggableView
//
//  Created by 杨利 on 2017/11/21.
//  Copyright © 2017年 Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    FLVerticalAlignmentNone = 0,
    FLVerticalAlignmentCenter,
    FLVerticalAlignmentTop,
    FLVerticalAlignmentBottom
} FLVerticalAlignment;

@interface FLLabel : UILabel

@property (nonatomic) UIEdgeInsets edgeInsets;

/**
 *  对齐方式
 */
@property (nonatomic) FLVerticalAlignment verticalAlignment;

@end
