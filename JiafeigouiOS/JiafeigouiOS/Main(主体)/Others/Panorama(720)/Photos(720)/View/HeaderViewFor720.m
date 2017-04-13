//
//  HeaderViewFor720.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/3/16.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "HeaderViewFor720.h"
#import "JfgGlobal.h"
#import "TimeLineView.h"
#import "JfgTimeFormat.h"

@interface HeaderViewFor720()

@property (nonatomic, strong) TimeLineView *lineView;

@end

@implementation HeaderViewFor720

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self)
    {
        self.backgroundColor = [UIColor whiteColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInterface:) name:isEditingNotification object:nil];
    }
    
    return self;
}


- (void)didMoveToSuperview
{
    [self addSubview:self.timeLabel];
    [self addSubview:self.lineView];
    [self addSubview:self.dotImageView];
}

- (void)removeFromSuperview
{
    [super removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setEditing:(BOOL)isEditing
{
    self.lineView.hidden = self.dotImageView.hidden = isEditing;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.timeLabel.frame = CGRectMake(isEditing?39.0+15.0:39.0, self.timeLabel.top, self.timeLabel.width, self.timeLabel.height);
    }];
}

- (void)updateInterface:(NSNotification *)notifi
{
    BOOL isEditing = [notifi.object boolValue];
    [self setEditing:isEditing];
}

#pragma mark 
#pragma mark  getter

- (UILabel *)timeLabel
{
        if (_timeLabel == nil)
        {
            CGFloat width = Kwidth;
            CGFloat height = 14; //
            CGFloat x = 39.0;
            CGFloat y = (self.height - height)*0.5;
    
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
            _timeLabel.textColor = [UIColor colorWithHexString:@"#666666"];
            _timeLabel.font = [UIFont systemFontOfSize:height];
            _timeLabel.textAlignment = NSTextAlignmentLeft;
            _timeLabel.text = [JfgTimeFormat transToyyyyMMddhhmmssWithTime:[[NSDate date] timeIntervalSince1970]];
        }
        return _timeLabel;
}


- (UIImageView *)dotImageView
{
        if (_dotImageView == nil)
        {
            CGFloat width = 15;
            CGFloat height = width; //
            CGFloat x = 13.0;
            CGFloat y = (self.height - height)*0.5;
            _dotImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
            _dotImageView.image = [UIImage imageNamed:@"image_timeLine_circle"];
            _dotImageView.center = self.lineView.center;
        }
        
        return _dotImageView;
}

- (TimeLineView *)lineView
{
    if (_lineView == nil)
    {
        CGFloat x = 22;
        CGFloat y = 0;
        CGFloat width = 1;
        CGFloat height = self.height;
        
        _lineView = [[TimeLineView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#f6f6f6"];
        
    }
    
    return _lineView;
}

@end
