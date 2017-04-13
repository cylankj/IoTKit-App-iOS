//
//  BaseTableViewCell.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseTableViewCell.h"
#import "JfgGlobal.h"

@implementation BaseTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
        self.selectedBackgroundView = selectedView;
        
        switch (style)
        {
            case UITableViewCellStyleValue1:
            {
                self.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
                self.textLabel.font = [UIFont systemFontOfSize:16.0f];
                
                self.detailTextLabel.textColor = [UIColor colorWithHexString:@"#888888"];
                self.detailTextLabel.font = [UIFont systemFontOfSize:14.0f];
            }
                break;
            
            default:
                break;
        }
        
        [self addSubview:self.redDot];
        [self initAutoLayout];
        
    }
    
    return self;
}

- (void)initAutoLayout
{
    [self.redDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self.mas_right).with.offset(-18.0f);
    }];
}

- (UIImageView *)redDot
{
    if (_redDot == nil)
    {
        _redDot = [[UIImageView alloc] init];
        _redDot.image = [UIImage imageNamed:@"bell_red_dot"];
        _redDot.hidden = YES;
    }

    return _redDot;
}

@end
