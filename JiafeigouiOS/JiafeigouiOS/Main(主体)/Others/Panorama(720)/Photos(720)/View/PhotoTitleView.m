//
//  PhotoTitleView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "PhotoTitleView.h"
#import "JfgGlobal.h"

#define textFont 17.0  // textLabel 高 和 字体
#define spaceX 3.0 // imgView 和 textLabel  间距

@implementation PhotoTitleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.width = frame.size.width;
        self.height = frame.size.height;
    }
    
    return self;
}

- (void)didMoveToSuperview
{
    [self addSubview:self.titleLbel];
//    [self addSubview:self.arrowImgView];
}

- (void)updateLayout
{
    CGSize textSize = CGSizeOfString(self.titleLbel.text, CGSizeMake(Kwidth, textFont), [UIFont systemFontOfSize:textFont]);
    self.titleLbel.frame = CGRectMake((self.width - textSize.width)*0.5, self.titleLbel.top, textSize.width, textFont);
//    self.arrowImgView.frame = CGRectMake(self.titleLbel.right + spaceX, self.arrowImgView.top, self.arrowImgView.width, self.arrowImgView.height);
    
}

- (void)rotateAnimation:(BOOL)isShowMenu
{
    [UIView animateWithDuration:0.3 animations:^{
//        self.arrowImgView.transform = CGAffineTransformRotate(self.arrowImgView.transform, M_PI);
    }];
}

#pragma mark
- (UILabel *)titleLbel
{
    if (_titleLbel == nil)
    {
        _titleLbel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, Kwidth, textFont)];
        _titleLbel.font = [UIFont systemFontOfSize:textFont];
        _titleLbel.textColor = [UIColor colorWithHexString:@"#ffffff"];
    }
    
    return _titleLbel;
}

//- (UIImageView *)arrowImgView
//{
//    if (_arrowImgView == nil)
//    {
//        _arrowImgView = [[UIImageView alloc] initWithFrame:CGRectMake(self.titleLbel.right+spaceX, 43, 11, 7)];
//        _arrowImgView.image = [UIImage imageNamed:@"top_btn_arrow_up"];
//        _arrowImgView.transform = CGAffineTransformRotate(_arrowImgView.transform, M_PI);
//    }
//    return _arrowImgView;
//}

@end
