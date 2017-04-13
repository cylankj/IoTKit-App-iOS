//
//  AsseetsCollectionViewCell.m
//  PhotoPickerDemo
//
//  Created by 杨利 on 16/7/30.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "AsseetsCollectionViewCell.h"

@implementation AsseetsCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubView];
    }
    return self;
}

-(void)initSubView
{
    _imageView = [[UIImageView alloc]init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    _imageView.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    [self addSubview:_imageView];
}

-(void)layoutSubviews
{
    _imageView.frame = self.bounds;
}


@end
