//
//  FriendsSearchBar.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/4.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "FriendsSearchBar.h"
#import "JfgGlobal.h"

@interface FriendsSearchBar()<UITextFieldDelegate>

// 搜索框 和 icon 图片
@property (strong, nonatomic) UIImageView *searchBarImageView;
@property (strong, nonatomic) UIImageView *iconImageView;
// 取消 按钮
@property (strong, nonatomic) UIButton *cancelButton;

@end

@implementation FriendsSearchBar



- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    [self initView];
}

#pragma mark view
- (void)initView
{
    [self addSubview:self.searchBarImageView];
    [self.searchBarImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15.0f);
        make.right.equalTo(self).with.offset(-50.0f);
        make.height.mas_equalTo(@30.0);
        make.bottom.equalTo(self).with.offset(-7.0f);
    }];
    
    [self.searchBarImageView addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBarImageView.mas_left).offset(15.0f);
        make.centerY.equalTo(self.searchBarImageView);
    }];
    
    [self addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(0.0);
        make.width.equalTo(@50);
        make.height.equalTo(@15.0);
        make.centerY.equalTo(self.searchBarImageView.mas_centerY);
    }];
    
    [self.searchBarImageView addSubview:self.searchField];
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.searchBarImageView).with.offset(37.0f);
        make.right.equalTo(self.searchBarImageView).with.offset(-5.0f);
        make.centerY.equalTo(self.searchBarImageView.mas_centerY); 
    }];
}

#pragma mark action
- (void)cancelButtonAction:(UIButton *)sender
{
    if ([_searchDelegate respondsToSelector:@selector(didClickedCancelButton:)])
    {
        [_searchDelegate didClickedCancelButton:self.cancelButton];
    }
}

#pragma mark property

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


- (UIButton *)cancelButton
{
    if (_cancelButton == nil)
    {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_cancelButton setTitleColor:[UIColor colorWithHexString:@"ffffff"] forState:UIControlStateNormal];
        [_cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15.0f]];
    }
    
    return _cancelButton;
}

- (UITextField *)searchField
{
    if (_searchField == nil)
    {
        _searchField = [[UITextField alloc] init];
        _searchField.returnKeyType = UIReturnKeySearch;
        _searchField.delegate = self;
        _searchField.keyboardType = UIKeyboardTypeEmailAddress;
        _searchField.placeholder = [JfgLanguage getLanTextStrByKey:@"Search"];
        [_searchField addTarget:self action:@selector(textFieldValueChanged:)  forControlEvents:UIControlEventAllEditingEvents];
    }
    return _searchField;
}

-(void)textFieldValueChanged:(UITextField *)textField
{
    NSString *lang = [[UITextInputMode currentInputMode]primaryLanguage];//键盘输入模式
    if ([lang isEqualToString:@"zh-Hans"]) {// 简体中文输入，包括简体拼音，健体五笔，简体手写
        UITextRange *selectedRange = [textField markedTextRange];
        //获取高亮部分
        UITextPosition *position = [textField positionFromPosition:selectedRange.start offset:0];
        //没有高亮选择的字，则对已输入的文字进行字数统计和限制
        if (!position) {
            if (textField.text.length >65) {
                textField.text = [textField.text substringToIndex:65];
            }
        }
        //有高亮选择的字符串，则暂不对文字进行统计和限制
        else{
            
        }
    }
    // 中文输入法以外的直接对其统计限制即可，不考虑其他语种情况
    else{
        if (textField.text.length >65) {
            textField.text = [textField.text substringToIndex:65];
        }
    }
    
    
    
    
}

@end
