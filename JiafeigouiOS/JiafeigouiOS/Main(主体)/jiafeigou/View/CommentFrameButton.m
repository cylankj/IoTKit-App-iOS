//
//  CommentFrameButton.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/6/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "CommentFrameButton.h"

@interface CommentFrameButton()

@property (nonatomic,assign)CGRect _titleRect;
@property (nonatomic,assign)CGRect _imageRect;

@end

@implementation CommentFrameButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(instancetype)initWithFrame:(CGRect)frame titleFrame:(CGRect)titleFrame imageRect:(CGRect)imageRect
{
    self = [super initWithFrame:frame];
    self._titleRect = titleFrame;
    self._imageRect = imageRect;
    return self;
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return self._titleRect;
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return self._imageRect;
}

@end
