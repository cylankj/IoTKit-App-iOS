//
//  VideoSnapImageView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "VideoSnapImageView.h"

@interface VideoSnapImageView()
@property (nonatomic,strong)UIView *shadeView;
@end


@implementation VideoSnapImageView

-(void)didMoveToSuperview
{
    [self addSubview:self.shadeView];
}

-(void)removeFromSuperview
{
    [self.shadeView removeFromSuperview];

    [super removeFromSuperview];
}

-(void)layoutSubviews
{
    self.shadeView.frame = self.bounds;
}

-(UIView *)shadeView
{
    if (!_shadeView) {
        _shadeView = [[UIView alloc]initWithFrame:self.bounds];
        _shadeView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
    }
    return _shadeView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
