//
//  SearchView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SearchView.h"
#import "JfgGlobal.h"

@interface SearchView()

@property (strong, nonatomic) UIView *bgView;// 整块背景的view
@property (strong, nonatomic) UIView *bgCenterView; // 中间一块的背景view

// 搜索框 和 icon 图片
@property (strong, nonatomic) UIImageView *searchBarImageView;
@property (strong, nonatomic) UIImageView *iconImageView;
// 取消 按钮
@property (strong, nonatomic) UIButton *cancelButton;

@end


@implementation SearchView

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [self initView];
    [self initViewLayout];
    [self addNotificationObserver];
}

- (void)willRemoveSubview:(UIView *)subview
{
    [self removeNotificationObserver];
}


- (void)initView
{
    [self addSubview:self.bgView];
    [self.bgView addSubview:self.searchBarImageView];
    [self.bgView addSubview:self.cancelButton];
    [self.searchBarImageView addSubview:self.bgCenterView];
    [self.searchBarImageView addSubview:self.searchTextField];
    [self.bgCenterView addSubview:self.iconImageView];
    [self.bgCenterView addSubview:self.tipLabel];
}

- (void)initViewLayout
{
    [self.searchBarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView.mas_left).with.offset(15.0f);
        make.right.equalTo(self.bgView.mas_right).with.offset(-15.0f);
        make.height.mas_equalTo(@30.0);
        make.centerY.equalTo(self.bgView.mas_centerY);
    }];
    
    [self.bgCenterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.searchBarImageView);
        make.width.mas_greaterThanOrEqualTo(@50);
        make.height.mas_greaterThanOrEqualTo(@20);
    }];
    
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.bgCenterView.mas_centerY);
        make.left.equalTo(self.bgCenterView).with.offset(0);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconImageView.mas_right).with.offset(8);
        make.centerY.equalTo(self.bgCenterView.mas_centerY);
    }];
    
    [self.searchTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBarImageView).with.offset(37.0f);
        make.right.equalTo(self.searchBarImageView).with.offset(-5.0f);
        make.centerY.equalTo(self.searchBarImageView.mas_centerY);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(0.0);
        make.width.equalTo(@50);
        make.centerY.equalTo(self.mas_centerY);
    }];
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldsChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark animation
- (void)startAnimation
{
    [self layoutIfNeeded];
    
    [UIView animateWithDuration:.2f animations:^{
        // 如果按钮 则不需要动画
        if (self.showCancelButton == YES)
        {
            [self.searchBarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.bgView).with.offset(15.0f);
                make.right.equalTo(self.bgView).with.offset(-50.0f);
                make.height.mas_equalTo(@30.0);
                make.centerY.equalTo(self.bgView.mas_centerY);
                
            }];
        }
        [self.bgCenterView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.searchBarImageView).with.offset(15.0f);
            make.centerY.equalTo(self.searchBarImageView.mas_centerY);
            make.width.mas_greaterThanOrEqualTo(@50);
            make.height.mas_greaterThanOrEqualTo(@20);
        }];
        
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.cancelButton.hidden = !self.showCancelButton;
    }];
}

- (void)recoverSearchBar
{
    self.searchTextField.text = nil;
    [self.searchTextField resignFirstResponder];
    self.cancelButton.hidden = YES;
    self.tipLabel.text = [JfgLanguage getLanTextStrByKey:@"Search"];
    
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.2f animations:^{
        [self.bgCenterView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.searchBarImageView);
            make.width.mas_greaterThanOrEqualTo(@50);
            make.height.mas_greaterThanOrEqualTo(@20);
        }];
        [self.searchBarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.bgView).with.offset(15.0f);
            make.right.equalTo(self.bgView).with.offset(-15.0f);
            make.height.mas_equalTo(@30.0);
            make.centerY.equalTo(self.bgView.mas_centerY);
        }];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
    }];
}


#pragma mark getter

- (UIView *)bgView
{
    if (_bgView == nil)
    {
        _bgView = [[UIView alloc] init];
        _bgView.frame = CGRectMake(0, 0, Kwidth, 44);
        _bgView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    }
    
    return _bgView;
}

- (UIView *)bgCenterView
{
    if (_bgCenterView == nil)
    {
        _bgCenterView = [[UIView alloc] init];
    }
    
    return _bgCenterView;
}

- (UIImageView *)searchBarImageView
{
    if (_searchBarImageView == nil)
    {
        _searchBarImageView = [[UIImageView alloc] init];
        _searchBarImageView.image = [UIImage imageNamed:@"search_bar"];
        _searchBarImageView.userInteractionEnabled = YES;
    }
    
    return _searchBarImageView;
}

- (UIImageView *)iconImageView
{
    if (_iconImageView == nil)
    {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.image = [UIImage imageNamed:@"search_icon"];
    }
    
    return _iconImageView;
}

- (UILabel *)tipLabel
{
    if (_tipLabel == nil)
    {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.text = [JfgLanguage getLanTextStrByKey:@"Search"];
        _tipLabel.textColor = [UIColor colorWithHexString:@"#dddddd"];
        _tipLabel.font = [UIFont fontWithName:@"PingFangSC" size:15.0f];
    }
    
    return _tipLabel;
}

- (UITextField *)searchTextField
{
    if (_searchTextField == nil)
    {
        _searchTextField = [[UITextField alloc] init];
        _searchTextField.delegate = self;
    }
    
    return _searchTextField;
}

- (UIButton *)cancelButton
{
    if (_cancelButton == nil)
    {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.hidden = YES; // 默认隐藏
        [_cancelButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"4b9fd5"] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-medium" size:15.0f]];
    }
    
    return _cancelButton;
}

#pragma mark action
- (void)cancelButtonAction:(UIButton *)sender
{
    [self recoverSearchBar];
    
    if ([self.searchDelegate respondsToSelector:@selector(didClickedCancelButton:)])
    {
        [self.searchDelegate didClickedCancelButton:nil];
    }
}

#pragma mark delegate

- (void)textFieldsChanged:(NSNotificationCenter *)notification
{
    if (self.searchTextField.text == nil || [self.searchTextField.text isEqualToString:@""])
    {
        self.tipLabel.text = [JfgLanguage getLanTextStrByKey:@"Search"];
    }
    else
    {
        self.tipLabel.text = nil;
    } 
    
}


- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self startAnimation];
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

@end
