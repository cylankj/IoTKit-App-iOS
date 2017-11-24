//
//  JFGDraggableView.h
//  HFDraggableView
//
//  Created by 杨利 on 2017/11/21.
//  Copyright © 2017年 Henry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JFGDraggableView : UIView

//拖拽最小尺寸
@property (nonatomic,assign)CGSize minDragViewSize;

@property (nonatomic,copy)NSString *hint;

@end
