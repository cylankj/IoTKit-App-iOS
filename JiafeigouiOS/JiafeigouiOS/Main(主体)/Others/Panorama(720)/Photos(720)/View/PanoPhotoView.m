//
//  PanoPhotoView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/4/25.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "PanoPhotoView.h"
#import "JfgGlobal.h"

@interface PanoPhotoView()

@property (nonatomic, strong)UIView *lineView;

@end

@implementation PanoPhotoView

- (instancetype)init
{
    self = [super init];
    
    if (self)
    {
        self.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview:newSuperview];
    
    [self addSubview:self.deleteButton];
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).with.offset(15);
        make.centerY.equalTo(self);
    }];
    [self addSubview:self.selectAllBtn];
    [self.selectAllBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).with.offset(-15.0);
        make.centerY.equalTo(self);
    }];
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.top.equalTo(self);
        make.width.mas_equalTo(@0.5);
    }];
}

- (DelButton *)deleteButton
{
    if (_deleteButton == nil)
    {
        _deleteButton = [[DelButton alloc] init];
        [_deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_deleteButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor colorWithHexString:@"#e1e1e1"] forState:UIControlStateDisabled];
        [_deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
        _deleteButton.enabled = NO;
    }
    
    return _deleteButton;
}

- (DelButton *)selectAllBtn
{
    if (_selectAllBtn == nil)
    {
        _selectAllBtn = [[DelButton alloc] init];
        [_selectAllBtn.titleLabel setFont:[UIFont systemFontOfSize:15]];
        [_selectAllBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_selectAllBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SELECT_ALL"] forState:UIControlStateNormal];
        [_selectAllBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
        _selectAllBtn.selected = NO;
    }
    
    return _selectAllBtn;
}

- (UIView *)lineView
{
    if (_lineView == nil)
    {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
    }
    return _lineView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
