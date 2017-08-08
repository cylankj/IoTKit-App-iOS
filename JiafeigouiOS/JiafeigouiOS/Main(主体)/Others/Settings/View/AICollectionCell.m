//
//  AICollectionCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AICollectionCell.h"
#import "JfgGlobal.h"

@implementation AICollectionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        [self initView];
    }
    return self;
}

- (void)initView
{
    [self.contentView addSubview:self.aiImageButton];
    [self.contentView addSubview:self.aiLabel];
}


- (UIButton *)aiImageButton
{
    if (_aiImageButton == nil)
    {
        _aiImageButton = [[UIButton alloc] init];
        _aiImageButton.userInteractionEnabled = NO;
        _aiImageButton.frame = CGRectMake((self.contentView.width - 60)*0.5, 2, 60, 60);
    }
    return _aiImageButton;
}

- (UILabel *)aiLabel
{
    if (_aiLabel == nil)
    {
        _aiLabel = [[UILabel alloc] init];
        _aiLabel.frame = CGRectMake(0, 71, self.contentView.frame.size.width, 16.0f);
        _aiLabel.textAlignment = NSTextAlignmentCenter;
        _aiLabel.font = [UIFont systemFontOfSize:16.0f];
        _aiLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        _aiLabel.text = @"";
    }
    
    return _aiLabel;
}

@end
