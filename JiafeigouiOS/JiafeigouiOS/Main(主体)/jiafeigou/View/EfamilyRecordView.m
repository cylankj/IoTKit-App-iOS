//
//  EfamilyRecordView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/7/6.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "EfamilyRecordView.h"
#import "JfgGlobal.h"

typedef NS_ENUM(NSUInteger, recordButtonState)
{
    recordButtonState_down,
    recordButtonState_UpInside,
    recordButtonState_UpOutside,
    recordButtonState_DtragInside,
    recordButtonState_DtragOutside,
};

@interface EfamilyRecordView()
{
    CGFloat _selfHeight;
}

/**
 *  顶部 view
 */
@property (nonatomic, strong) UIView *topView;
/**
 *  提示 Label
 */
@property (nonatomic, strong) UILabel *topLabel;
@end

@implementation EfamilyRecordView

- (instancetype)initWithFrame:(CGRect)frame
{
    
    _selfHeight = 214.0;
    
    self = [super initWithFrame:CGRectMake(-1, kheight, Kwidth + 2, _selfHeight)];
    
    if (self)
    {
        [self initView];
    }
    
    return self;
}

- (void)initView
{
    self.backgroundColor = [UIColor colorWithHexString:@"#f9fbfd"];
    self.layer.borderWidth = 0.5f;
    self.layer.borderColor = [UIColor colorWithHexString:@"#e1e1e1"].CGColor;
    
    [self addSubview:self.topView];
    [self.topView addSubview:self.topLabel];
    [self.topView addSubview:self.exitButton];
    [self addSubview:self.recordButton];
    [self addSubview:self.leftImageView];
    [self addSubview:self.rightImageView];
    [self addSubview:self.animatinLine];
}

- (void)showAnimationWithDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.frame = CGRectMake(-1, kheight - _selfHeight, Kwidth + 2, _selfHeight);
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)hideAnimationWithDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.frame = CGRectMake(-1, kheight, Kwidth + 2, _selfHeight);
    } completion:^(BOOL finished) {
    }];
}

#pragma mark action
- (void)exitButtonAction:(UIButton *)sender
{
    [self hideAnimationWithDuration:0.2f];
}

- (void)recordButtonDown:(UIButton *)sender
{
    [self updateRecordView:recordButtonState_down];
}

- (void)recordButtonUp:(UIButton *)sender
{
    [self updateRecordView:recordButtonState_UpInside];
}

- (void)recordButtonOutsideUp:(UIButton *)sender
{
    [self updateRecordView:recordButtonState_UpOutside];
}

- (void)recordButtonDragOutside:(UIButton *)sender
{
    [self updateRecordView:recordButtonState_DtragOutside];
}

- (void)recordButtonDragInside:(UIButton *)sender
{
    [self updateRecordView:recordButtonState_DtragInside];
}

- (void)updateRecordView:(recordButtonState)state
{
    switch (state)
    {
        case recordButtonState_down:
        {
            self.animatinLine.hidden = NO;
            self.leftImageView.hidden = NO;
            self.rightImageView.hidden = NO;
            
            self.animatinLine.backgroundColor = [UIColor colorWithHexString:@"#36bdff"];
            self.topLabel.textColor = RGBACOLOR(136, 136, 136, 1);
            self.topLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_CANCEL_RECORD"];
        }
            break;
        case recordButtonState_UpInside:
        case recordButtonState_UpOutside:
        {
            self.animatinLine.hidden = YES;
            self.leftImageView.hidden = YES;
            self.rightImageView.hidden = YES;
            
            [self.recordButton setImage:[UIImage imageNamed:@"efam_talk_normal"] forState:UIControlStateNormal];
            self.topLabel.textColor = RGBACOLOR(136, 136, 136, 1);
            self.animatinLine.backgroundColor = [UIColor colorWithHexString:@"#36bdff"];
            self.topLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_PUSH_TO_LEAVE_MSG"];
        }
            break;
        case recordButtonState_DtragInside:
        {
            self.topLabel.textColor = RGBACOLOR(136, 136, 136, 1);
            self.topLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_CANCEL_RECORD"];
            self.animatinLine.backgroundColor = [UIColor colorWithHexString:@"#36bdff"];
        }
            break;
        case recordButtonState_DtragOutside:
        {
            if (self.recordButton.isToUp)
            {
                [self.recordButton setImage:[UIImage imageNamed:@"efam_talk_back"] forState:UIControlStateNormal];
                self.topLabel.textColor = [UIColor colorWithHexString:@"#f26b6b"];
                self.topLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_CANCEL_SEND"];
                self.animatinLine.backgroundColor = [UIColor colorWithHexString:@"#f26b6b"];
            }
            else
            {
                [self.recordButton setImage:[UIImage imageNamed:@"efam_talk_pressed"] forState:UIControlStateNormal];
                self.animatinLine.backgroundColor = [UIColor colorWithHexString:@"#36bdff"];
            }
        }
            break;
        default:
            break;
    }
}


#pragma mark property

- (UIView *)topView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 49.0;
    CGFloat widgetX = 0; // 设计 描边癖
    CGFloat widgetY = 0;
    
    if (_topView == nil)
    {
        _topView = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _topView.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        _topView.layer.shadowColor = [UIColor colorWithHexString:@"#f2f4f5"].CGColor;
        _topView.layer.shadowOffset = CGSizeMake(0, 4);
        _topView.layer.shadowOpacity = 0.8;
    }
    return _topView;
}

- (UILabel *)topLabel
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 30.0;
    CGFloat widgetX = 0; 
    CGFloat widgetY = (self.topView.height - widgetHeight)/2.0;
    
    if (_topLabel == nil)
    {
        _topLabel = [[UILabel alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.font = [UIFont systemFontOfSize:16.0f];
        _topLabel.textColor = [UIColor colorWithHexString:@"#888888"]; // Default
        _topLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_PUSH_TO_LEAVE_MSG"]; // Default
    }
    return _topLabel;
}
/**
 *  倒计时动画 view
 */
- (UIView *)animatinLine
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 2.0;
    CGFloat widgetX = 0; // 设计 描边癖
    CGFloat widgetY = self.topView.height;
    
    if (_animatinLine == nil)
    {
        _animatinLine = [[UIView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _animatinLine.hidden = YES; // Default YES
        _animatinLine.backgroundColor = [UIColor colorWithHexString:@"#36bdff"];
    }
    return _animatinLine;
}
/**
 *   录音 按钮
 */
- (RecordButton *)recordButton
{
    CGFloat widgetWidth = 100.0;
    CGFloat widgetHeight = 100.0;
    CGFloat widgetX = (Kwidth - widgetWidth)/2.0;
    // 加号前  间隙
    CGFloat widgetY = (_selfHeight - self.topView.height - widgetHeight)/2.0 + self.topView.height;
    
    if(_recordButton == nil)
    {
        _recordButton = [[RecordButton alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        [_recordButton setImage:[UIImage imageNamed:@"efam_talk_normal"] forState:UIControlStateNormal];
        [_recordButton setImage:[UIImage imageNamed:@"efam_talk_pressed"] forState:UIControlStateHighlighted];
        
        [_recordButton addTarget:self action:@selector(recordButtonUp:) forControlEvents:UIControlEventTouchUpInside];
        [_recordButton addTarget:self action:@selector(recordButtonDown:) forControlEvents:UIControlEventTouchDown];
        [_recordButton addTarget:self action:@selector(recordButtonOutsideUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_recordButton addTarget:self action:@selector(recordButtonDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [_recordButton addTarget:self action:@selector(recordButtonDragInside:) forControlEvents:UIControlEventTouchDragInside];
    }
    return _recordButton;
}

- (UIButton *)exitButton
{
    CGFloat widgetWidth = 16.5;
    CGFloat widgetHeight = 16.5;
    CGFloat widgetX = 15.0;
    CGFloat widgetY = (self.topView.height - widgetHeight)/2.0;
    
    if (_exitButton == nil)
    {
        _exitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitButton.frame = CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight);
        [_exitButton setImage:[UIImage imageNamed:@"login_btn_close"] forState:UIControlStateNormal];
        [_exitButton addTarget:self action:@selector(exitButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitButton;
}
/**
 *  录音 按钮  左右两边 音波图片
 */
- (UIImageView *)leftImageView
{
    UIImage *widgetImage = [UIImage imageNamed:@"efamily_voice_0"];
    CGFloat widgetSpace = 26.0; // 距离 录音按钮的 间距
    CGFloat widgetWidth = widgetImage.size.width ;
    CGFloat widgetHeight = widgetImage.size.height;
    CGFloat widgetX = self.recordButton.left - (widgetWidth + widgetSpace); 
    CGFloat widgetY = (_selfHeight - self.topView.height - widgetHeight)/2.0 + self.topView.height;
    
    if (_leftImageView == nil)
    {
        _leftImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _leftImageView.hidden = YES;  //Default YES
        _leftImageView.image = widgetImage;
    }
    return _leftImageView;
}

- (UIImageView *)rightImageView
{
    UIImage *widgetImage = [UIImage imageNamed:@"efamily_voice_0"];
    CGFloat widgetSpace = 26.0; // 距离 录音按钮的 间距
    CGFloat widgetWidth = widgetImage.size.width ;
    CGFloat widgetHeight = widgetImage.size.height;
    CGFloat widgetX = self.recordButton.right + widgetSpace; 
    CGFloat widgetY = (_selfHeight - self.topView.height - widgetHeight)/2.0 + self.topView.height;
    
    if (_rightImageView == nil)
    {
        _rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _rightImageView.hidden = YES;  //Default YES
        _rightImageView.image = widgetImage;
    }
    return _rightImageView;
}

@end
