//
//  BadgeLabel.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BadgeLabel.h"
#import <Masonry.h>
#import "UIColor+HexColor.h"
@interface BadgeLabel ()

@property (nonatomic,strong) UILabel *label;
@property (nonatomic,assign) NSInteger showMessageCount;

@end

@implementation BadgeLabel

- (instancetype)init{
    if (self =[super init]) {
        [self setBackgroundColor:[UIColor clearColor]];
        
        _label =[[UILabel alloc] init];
        
        [_label setBackgroundColor:[UIColor colorWithHexString:@"#f43531"]];
        [_label setTextColor:[UIColor whiteColor]];
        [_label setTextAlignment:NSTextAlignmentCenter];
        [_label setFont:[UIFont systemFontOfSize:10]];
        [_label setClipsToBounds:YES];
        [_label.layer setCornerRadius:8.f];
        [self setHidden:YES];
        
        [self addSubview:_label];
    }
    return self;
}

-(NSInteger)totalMessageCount{
    return _showMessageCount;
}

-(void)setNewMessageCount:(NSInteger)newMessageCount{
    _showMessageCount = newMessageCount;
    [self setLabelText];
}


-(void)setReadMessageCount:(NSInteger)readMessageCount{
    _showMessageCount =_showMessageCount -readMessageCount;
    [self setLabelText];
}

-(void)setLabelText{
    [self setHidden:NO];
    if (_showMessageCount >99) {
        [_label setText:@"99+"];
        [_label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@16);
            make.width.mas_equalTo(@22);
            make.center.mas_equalTo(self);
        }];
    }else if (_showMessageCount >9){
        [_label setText:[NSString stringWithFormat:@"%ld",(long)_showMessageCount]];
        [_label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@16);
            make.width.mas_equalTo(@19);
            make.center.mas_equalTo(self);
        }];
    }else if (_showMessageCount >0){
        [_label setText:[NSString stringWithFormat:@"%ld",(long)_showMessageCount]];
        [_label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(@16);
            make.width.mas_equalTo(@16);
            make.center.mas_equalTo(self);
        }];
    }else{
        [self setHidden:YES];
    }
}

@end
