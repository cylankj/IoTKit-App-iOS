//
//  FriendsHeadView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/28.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FriendsHeadView.h"
#import "JfgGlobal.h"

@implementation FriendsHeadView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self addSubview:self.headLabel];
}


- (UILabel *)headLabel
{
    if (_headLabel == nil)
    {
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = 13.0f;
        CGFloat widgetX = 15.0f;
        CGFloat widgetY = 42.0 - widgetHeight - 10.0f;
        
        _headLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _headLabel.font = [UIFont systemFontOfSize:widgetHeight];
        _headLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    }
    return _headLabel;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
