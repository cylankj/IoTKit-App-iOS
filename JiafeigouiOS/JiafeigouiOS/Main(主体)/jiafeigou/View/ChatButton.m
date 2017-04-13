//
//  ChatButton.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ChatButton.h"
#import "JfgGlobal.h"

@implementation ChatButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    [self setTitleColor:[UIColor colorWithHexString:@"#5a6d7d"] forState:UIControlStateNormal];
    
    self.titleLabel.font = [UIFont systemFontOfSize:14.0f];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}


//设置button上titleLabel的frame、
-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat top = 63;
    CGSize titleSize = CGSizeMake(contentRect.size.width, 30);
    CGFloat left = 0;
    return CGRectMake(left, top, titleSize.width, titleSize.height);
}

@end
