//
//  HFDragHandle.h
//  HFFoundation
//
//  Created by Henry on 08/11/2017.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HFDragHandleShape) {
    HFDragHandleShapeCircle,
    HFDragHandleShapeRect
};

@interface HFDragHandle : UIView
@property (nonatomic, assign) HFDragHandleShape shape; ///< 形状类型
@property (nonatomic, strong) UIColor *color; ///< 背景颜色
@property (nonatomic, assign) CGFloat scale; ///< 形状与 frame 比例
@property (nonatomic, strong) UIColor *borderColor; ///< 边框颜色
@property (nonatomic, assign) CGFloat borderWidth; ///< 边框宽度
@end
