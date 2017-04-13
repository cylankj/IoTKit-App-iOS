//
//  BellView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BellView.h"
#import "UIColor+HexColor.h"
#import <Masonry.h>
#import "FLGlobal.h"
#import "doorBellTableView.h"
#import "BellModel.h"
#import "JfgLanguage.h"
#import "LoginManager.h"

@interface BellView()
@property (strong, nonatomic)UIImageView * bgImageView;
@property (strong, nonatomic)UIView * Line;
@property (strong, nonatomic)UIImageView * coverImageView;

@end
@implementation BellView

-(instancetype)initWithFrame:(CGRect)frame{
    if ([super initWithFrame:frame]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self initView];
        [self initState];
        
        UILongPressGestureRecognizer * longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressAction:)];
        longPress.minimumPressDuration = 0.75f;
        [self addGestureRecognizer:longPress];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        tap.numberOfTapsRequired = 1;
        [self addGestureRecognizer:tap];
        [tap requireGestureRecognizerToFail:longPress];
    }
    return self;
}
#pragma mark - UIGestureRecognizer
-(void)longPressAction:(UILongPressGestureRecognizer *)press{
    doorBellTableView * _tableView = (doorBellTableView *)[[[[self superview]superview]superview] superview];

    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess || self.isShared) {
        return;
    }
    
    if (_tableView.isEditingView == NO) {
        if(press.state == UIGestureRecognizerStateBegan){
            CABasicAnimation * scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnimation.fromValue = @1.0;
            scaleAnimation.toValue = @1.1;
            scaleAnimation.autoreverses = YES;
            scaleAnimation.fillMode = kCAFillModeRemoved;
            scaleAnimation.removedOnCompletion = YES;
            scaleAnimation.duration = 0.2f;
            [press.view.layer addAnimation:scaleAnimation forKey:@"addAnimation"];
            
            _tableView.isEditingView = YES;
            
            self.isSelected =YES;
            
            [self setBellModelIsSelected:self.isSelected];
        }
    }else{
        //nothing changed
    }

}
-(void)tapAction:(UITapGestureRecognizer *)tap{
    doorBellTableView * _tableView = (doorBellTableView *)[[[[self superview]superview]superview] superview];
    if (_tableView.isEditingView == NO) {
        //查看门铃
    }else{
        self.isSelected =!self.isSelected;
        
        [self setBellModelIsSelected:self.isSelected];
    }
}

-(void)setBellModelIsSelected:(BOOL)sel{
    doorBellTableView *tableView =(doorBellTableView *)[[[[self superview] superview] superview] superview];
    
    UITableViewCell *cell =(UITableViewCell *)[[self superview] superview];
    
    NSIndexPath *selfPath =[tableView indexPathForCell:cell];
    
    if (tableView.tableModelArray.count > selfPath.row) {
        BellModel *aModel =[tableView.tableModelArray objectAtIndex:selfPath.row];
        
        aModel.isSelected =sel;
        
        
        //在这里遍历  model数组里面有没有被选中的  如果没有被选中的  则 退出编辑状态
        BOOL selectedIsEmpty =YES;
        for (BellModel *model in tableView.tableModelArray) {
            if (model.isSelected) {
                selectedIsEmpty =NO;
                break;
            }
        }
        
        if (selectedIsEmpty) {
            [tableView setIsEditingView:NO];
        }

    }
    
    }

- (void)setIsSelected:(BOOL)isSelected
{
    _isSelected =isSelected;
    if (_isSelected) {
        [UIView animateWithDuration:0.1 animations:^{
            [self.bgImageView setImage:[UIImage imageNamed:@"doorbell_focus"]];
            [self.selectedImage setHidden:NO];
            [self.coverImageView setHidden:NO];
        }];
    }else{
        [UIView animateWithDuration:0.1 animations:^{
            [self.bgImageView setImage:[UIImage imageNamed:@"doorbell_normal"]];
            [self.selectedImage setHidden:YES];
            [self.coverImageView setHidden:YES];
        }];
    }
}
- (void)setIsAnswered:(BOOL)isAnswered {
    _isAnswered = isAnswered;
    if (_isAnswered) {
        [_callState setImage:[UIImage imageNamed:@"doorbell_talk_icon"] forState:UIControlStateNormal];
        [_callState setTitle:[JfgLanguage getLanTextStrByKey:@"DOOR_CALL"] forState:UIControlStateNormal];
        self.redDot.hidden = YES;
    }else{
        [_callState setImage:[UIImage imageNamed:@"doorbell_not-talk_icon"] forState:UIControlStateNormal];
        [_callState setTitle:[JfgLanguage getLanTextStrByKey:@"DOOR_UNCALL"] forState:UIControlStateNormal];
        self.redDot.hidden = NO;
    }
}
#pragma mark - Init
-(void)initState{
    self.isSelected = NO;
}
-(void)initView{
    CGFloat scale = designHscale;
    [self addSubview:self.bgImageView];
    [_bgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self addSubview:self.dateLabel];
    [_dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(24*scale));
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_greaterThanOrEqualTo(@(32*scale));
        make.height.equalTo(@(16*scale));
    }];
    [self addSubview:self.timeLabel];
    [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dateLabel.mas_bottom).offset(8*scale);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_greaterThanOrEqualTo(@(75*scale));
        make.height.equalTo(@(16*scale));
    }];
    [self addSubview:self.Line];
    [_Line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(14*scale);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@(50*scale));
        make.height.equalTo(@1);
    }];
    [self addSubview:self.headerImageView];
    [_headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.Line.mas_bottom).offset(18*scale);
        make.centerX.equalTo(self.mas_centerX);
        make.width.equalTo(@(80*scale));
        make.height.equalTo(@(80*scale));
    }];
    [self addSubview:self.redDot];
    [_redDot mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerImageView.mas_top).offset(5*scale);
        make.right.mas_equalTo(self.headerImageView.mas_right).offset(5);
        //make.size.mas_equalTo(CGSizeMake(15*scale, 15*scale));
    }];
    [self addSubview:self.callState];
    [_callState mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerImageView.mas_bottom).offset(28*scale);
        make.centerX.equalTo(self.mas_centerX);
        make.width.mas_equalTo(self.mas_width);
        make.height.equalTo(@(16*scale));
    }];
    [self addSubview:self.coverImageView];
    [_coverImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    [self addSubview:self.selectedImage];
    [_selectedImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(10*scale));
        make.right.equalTo(@(-15*scale));
        make.size.mas_equalTo(CGSizeMake(13*scale, 13*scale));
    }];
}
-(UIImageView *)coverImageView{
    if (!_coverImageView) {
        _coverImageView = [[UIImageView alloc]init];
        _coverImageView.image = [UIImage imageNamed:@"doorbell_checkmask"];
        _coverImageView.userInteractionEnabled = YES;
        _coverImageView.hidden = YES;
    }
    return _coverImageView;
}
-(UIImageView *)bgImageView{
    if (!_bgImageView) {
        _bgImageView = [[UIImageView alloc]init];
        [_bgImageView setImage:[UIImage imageNamed:@"doorbell_normal"]];
    }
    return _bgImageView;
}
-(UILabel *)dateLabel{
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc]init];
        [_dateLabel setFont:[UIFont systemFontOfSize:16*designHscale]];
        [_dateLabel setTextColor:[UIColor colorWithHexString:@"#65cae4"]];
    }
    return _dateLabel;
}
-(UILabel *)timeLabel{
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc]init];
        [_timeLabel setFont:[UIFont systemFontOfSize:16*designHscale]];
        [_timeLabel setTextColor:[UIColor colorWithHexString:@"#6c7a92"]];
        [_timeLabel setTextAlignment:NSTextAlignmentCenter];
    }
    return _timeLabel;
}
-(UIView *)Line{
    if (!_Line) {
        //分割线
        _Line = [[UIView alloc]init];
        _Line.backgroundColor = [UIColor colorWithHexString:@"#efefef"];
    }
    return _Line;
}
-(UIImageView *)headerImageView{
    if (!_headerImageView) {
        _headerImageView = [[UIImageView alloc]init];
        _headerImageView.image = [UIImage imageNamed:@"friends_head"];
        _headerImageView.layer.cornerRadius = 79*designHscale/2;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headerImageView;
}
- (UIImageView *)redDot{
    if (!_redDot) {
        _redDot = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bell_red_dot"]];
    }
    return _redDot;
}
-(UIButton *)callState{
    if (!_callState) {
        _callState = [UIButton buttonWithType:UIButtonTypeCustom];
        [_callState setTitleColor:[UIColor colorWithHexString:@"#cbcfd0"] forState:UIControlStateNormal];
        [_callState.titleLabel setFont:[UIFont boldSystemFontOfSize:13*designHscale]];

        _callState.imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_callState setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
        [_callState setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        _callState.enabled = NO;
        _callState.adjustsImageWhenDisabled = NO;
    }
    return _callState;
}
-(UIImageView *)selectedImage{
    if (!_selectedImage) {
        _selectedImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"doorbell_check_icon"]];
        [_selectedImage setHidden:YES];
    }
    return _selectedImage;
}
@end
