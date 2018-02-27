//
//  MessageViewCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "MessageViewCell.h"
#import "TimeLineView.h"
#import <Masonry.h>
#import "MessageImageView.h"
#import "DelButton.h"
#import "UIColor+FLExtension.h"
#import "FLGlobal.h"
#import "JfgLanguage.h"
#import "UIButton+Addition.h"
#import <CoreText/CoreText.h>
#import <NSObject+FBKVOController.h>
#import <KVOController/KVOController.h>
#import "CommonMethod.h"


@implementation MessageViewCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    //修改编辑模式下,选中的按钮图片
    if (self.isEditing && self.isSelected) {
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellEditControl")]) {
                UIControl *control = (UIControl *)subview;
                if ([control subviews].count>0) {
                    UIImageView * imgView = [[control subviews] objectAtIndex:0];
                    imgView.image = [UIImage imageNamed:@"camera_icon_Selected"];
                }
            }
        }
        
       
        
    }//编辑模式下,取消选中的图片
    else if(self.isEditing && !self.isSelected){
        
        for (UIView *subview in self.subviews) {
            if ([subview isKindOfClass:NSClassFromString(@"UITableViewCellEditControl")]) {
                UIControl *control = (UIControl *)subview;
                if ([control subviews].count>0) {
                    UIImageView * imgView = [[control subviews] objectAtIndex:0];
                    imgView.image = [UIImage imageNamed:@"camera_icon_Select"];
                }
            }
        }

        
    }
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
}

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [self handleMasonry:editing];
    [self handleHiddenView:editing];
    
    [super setEditing:editing animated:animated];
    if(self.isEditing){
        for (UIView * vi in self.contentView.subviews) {
            if ([vi isKindOfClass:[MessageImageView class]]) {
                [vi setUserInteractionEnabled:NO];
            }
        }
    }else{
        for (UIView * vi in self.contentView.subviews) {
            if ([vi isKindOfClass:[MessageImageView class]]) {
                if (vi.userInteractionEnabled == NO) {
                    [vi setUserInteractionEnabled:YES];
                }
            }
        }
    }
    
}
-(void)setHiddenSubviews:(BOOL)hiddenSubviews{
    _hiddenSubviews =hiddenSubviews;
    [self.tip setHidden:hiddenSubviews];
    [self.line setHidden:hiddenSubviews];
    [self.deleteBtn setHidden:hiddenSubviews];
    [self.avBtn setHidden:hiddenSubviews];
}

-(void)handleHiddenView:(BOOL)edting{
    if (edting) {
        [self performSelector:@selector(leftView:) withObject:[NSNumber numberWithBool:edting] afterDelay:0.f];
    }else{
        [self performSelector:@selector(leftView:) withObject:[NSNumber numberWithBool:edting] afterDelay:0.3f];
    }
}

-(void)leftView:(NSNumber *)edting{
    [_tip setHidden:[edting boolValue]];
    [_line setHidden:[edting boolValue]];
    [_deleteBtn setHidden:[edting boolValue]];
    
    if ([edting boolValue]) {
        _avBtn.hidden = YES;
    }else{
        _avBtn.hidden = self.hiddenAvBtn;
    }
    
}

-(void)handleMasonry:(BOOL)edting{
    if (edting) {
        [_label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@7);
        }];
        [_deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
        }];
    }else{
        [_label mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@37);
        }];
        [_deleteBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@45);
        }];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //时间线
        [self.contentView addSubview:self.line];
        [_line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@0);
            make.top.equalTo(@0);
            make.bottom.equalTo(@0);
            make.width.equalTo(@37);
        }];
        //小图片
        [self.contentView addSubview:self.tip];
        [_tip mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(15, 15));
            make.left.equalTo(@16);
            make.top.equalTo(@21);
        }];
        
        //上面的文字label
        [self.contentView addSubview:self.label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@37);
            make.top.equalTo(@22);
            make.width.mas_greaterThanOrEqualTo(@36);
            CGFloat maxWidth = self.contentView.bounds.size.width - 37;
            make.width.mas_lessThanOrEqualTo(@(maxWidth));
            make.height.equalTo(@14);
        }];
    }
    return self;
}

- (void)setBothUIButtonMasonry:(UIView *)view{
    //下面的删除按钮
    [self.contentView addSubview:self.deleteBtn];
    [_deleteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@45);
        make.top.mas_equalTo(view.mas_bottom).offset(20);
        make.width.mas_greaterThanOrEqualTo(@24);
        make.height.equalTo(@12);
    }];
    
    //if ([view isKindOfClass:[UILabel class]]) return;
    
    //看视频的按钮
    [self.contentView addSubview:self.avBtn];
    
    [_avBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(@-15);
        make.top.mas_equalTo(view.mas_bottom).offset(20);
        make.width.mas_greaterThanOrEqualTo(@69);
        make.centerY.equalTo(_deleteBtn.mas_centerY);
    }];
}

#pragma mark - 公共控件
-(TimeLineView *)line{
    if (!_line) {
        _line =[[TimeLineView alloc] init];
        [_line setBackgroundColor:[UIColor whiteColor]];
    }
    return _line;
}

-(UIImageView *)tip{
    if (!_tip) {
        _tip =[[UIImageView alloc] init];
        [_tip setImage:[UIImage imageNamed:@"image_timeLine_circle"]];
    }
    return _tip;
}

-(UILabel *)label
{
    if (!_label) {
        _label =[[UILabel alloc] init];
        [_label setFont:[UIFont systemFontOfSize:14]];
        //_label.numberOfLines = 2;
        _label.textAlignment = NSTextAlignmentLeft;
        //_label.backgroundColor = [UIColor orangeColor];
        [_label setTextColor:[UIColor colorWithHexString:@"#666666"]];
        [_label setText:[NSString stringWithFormat:@"12:30 %@",[JfgLanguage getLanTextStrByKey:@"MSG_WARNING"]]];
        
    }
    return _label;
}


-(DelButton *)deleteBtn{
    if (!_deleteBtn) {
        _deleteBtn =[DelButton buttonWithType:UIButtonTypeCustom];
        [_deleteBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC-Regular" size:12]];
        [_deleteBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_deleteBtn setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
        [_deleteBtn setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
    }
    return _deleteBtn;
}

-(UIButton *)avBtn{
    if (!_avBtn) {
        _avBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [_avBtn.titleLabel setFont:[UIFont fontWithName:@"PingFangSC" size:12]];
        [_avBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [_avBtn setTitleColor:[UIColor colorWithHexString:@"#9a9a9a"] forState:UIControlStateNormal];
        [_avBtn setTitleColor:[UIColor colorWithHex:0x9a9a9a alpha:0.5] forState:UIControlStateDisabled];
        [_avBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Messages_ViewTheVideo"] forState:UIControlStateNormal];
        [_avBtn setImage:[UIImage imageNamed:@"camera_icon_look"] forState:UIControlStateNormal];
        [_avBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, -3)];
        [_avBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -3, 0, 0)];
        
    }
    return _avBtn;
}


@end
@implementation MessageViewCell1

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    if (editing) {
        [_imgv1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@7);
        }];
        [_imgv3 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(0);
        }];
    }else{
        [_imgv1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@37);
        }];
        [_imgv3 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        }];
    }
    
    [super setEditing:editing animated:animated];
    
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //显示的3张图片
        _imgv1 =[[MessageImageView alloc] init];
        
        [_imgv1 setImage:[UIImage imageNamed:@"beautyGirl"]];
        
        [self.contentView addSubview:_imgv1];
        
        _imgv2 =[[MessageImageView alloc] init];
        
        [_imgv2 setImage:[UIImage imageNamed:@"beautyGirl"]];
        
        [self.contentView addSubview:_imgv2];
        
        _imgv3 =[[MessageImageView alloc] init];
        
        [_imgv3 setImage:[UIImage imageNamed:@"beautyGirl"]];
        
        [self.contentView addSubview:_imgv3
         ];
        
        [_imgv1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.label.mas_bottom).offset(15);
            make.left.equalTo(@37);
            make.right.mas_equalTo(_imgv2.mas_left).offset(-4);
            make.height.mas_equalTo(_imgv1.mas_width).multipliedBy(1.f);
            make.height.width.mas_equalTo(_imgv2);
        }];
        
        [_imgv2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_imgv1.mas_centerY);
            make.left.mas_equalTo(_imgv1.mas_right).offset(4);
            make.right.mas_equalTo(_imgv3.mas_left).offset(-4);
            make.height.mas_equalTo(_imgv2.mas_width).multipliedBy(1.f);
            make.height.width.mas_equalTo(_imgv3);
        }];
        
        [_imgv3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_imgv1.mas_centerY);
            make.left.mas_equalTo(_imgv2.mas_right).offset(4);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
            make.height.mas_equalTo(_imgv3.mas_width).multipliedBy(1.f);
            make.height.width.mas_equalTo(_imgv1);
        }];
        
        [self setBothUIButtonMasonry:_imgv1];
        
    }
    return self;
}

@end


@implementation MessageViewCell2

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    if (editing) {
        [_imgv1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@7);
        }];
        [_imgv2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(0);
        }];
    }else{
        [_imgv1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@37);
        }];
        [_imgv2 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
        }];
    }
    [super setEditing:editing animated:animated];
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //显示的2张图片
        _imgv1 =[[MessageImageView alloc] init];
        
        [_imgv1 setImage:[UIImage imageNamed:@"beautyGirl"]];
        
        [self.contentView addSubview:_imgv1];
        
        _imgv2 =[[MessageImageView alloc] init];
        
        [_imgv2 setImage:[UIImage imageNamed:@"beautyGirl"]];
        
        [self.contentView addSubview:_imgv2];
        
        [_imgv1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.label.mas_bottom).offset(15);
            make.left.equalTo(@37);
            make.right.mas_equalTo(_imgv2.mas_left).offset(-4);
            make.height.mas_equalTo(_imgv1.mas_width).multipliedBy(1.f);
            make.height.width.mas_equalTo(_imgv2);
        }];
        
        [_imgv2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(_imgv1.mas_centerY);
            make.left.mas_equalTo(_imgv1.mas_right).offset(4);
            make.right.mas_equalTo(self.contentView.mas_right).offset(-15);
            make.height.mas_equalTo(_imgv2.mas_width).multipliedBy(1.f);
            make.height.width.mas_equalTo(_imgv1);
        }];
        
        [self setBothUIButtonMasonry:_imgv1];
        
    }
    return self;
}

@end


@interface MessageViewCell3()
{
    BOOL isShowMoreBtn;//是否显示更多按钮
}

@end
@implementation MessageViewCell3

-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    
    [UIView animateWithDuration:0.33f animations:^{
        if (editing) {
            [_imgv1 mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@7);
                //make.right.mas_equalTo(self.contentView.mas_right).offset(-155.f *designWscale);
            }];
        }else{
            [_imgv1 mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@37);
                //make.right.mas_equalTo(self.contentView.mas_right).offset(-170.f *designWscale);
            }];
        }
    }];
    [super setEditing:editing animated:animated];
    
}

- (instancetype)initForAIWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        isShowMoreBtn = YES;
        
        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@37);
            make.top.equalTo(@22);
            //make.width.mas_greaterThanOrEqualTo(@36);
            CGFloat maxWidth = [UIScreen mainScreen].bounds.size.width - 104;
            //make.width.mas_lessThanOrEqualTo(@(maxWidth));
            make.width.equalTo(@(maxWidth));
            make.height.equalTo(@14);
        }];
        //self.label.backgroundColor = [UIColor orangeColor];
        self.moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.moreBtn setTitle:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_ALL"] forState:UIControlStateNormal];
        [self.moreBtn setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
        self.moreBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        self.moreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [self.moreBtn addTarget:self action:@selector(moreAction) forControlEvents:UIControlEventTouchUpInside];
        self.moreBtn.hidden = YES;
        [self.contentView addSubview:self.moreBtn];
        
        [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
           
            make.top.mas_equalTo(self.label.mas_top);
            make.left.mas_equalTo(self.label.mas_right).offset(10);
            make.width.equalTo(@90);
            make.height.mas_equalTo(self.label.mas_height);
            
        }];
        
        //显示的1张图片
        self.imgv1 =[[MessageImageView alloc] init];
        [self.imgv1 setImage:[UIImage imageNamed:@"beautyGirl"]];
        [self.contentView addSubview:self.imgv1];
        
        [self.imgv1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.label.mas_bottom).offset(15);
            make.left.equalTo(@37);
            make.height.equalTo(@(125));
            make.width.equalTo(@(125*1.78));
            
        }];
        
//        __weak typeof(self) weakSelf = self;
//
//        [self.KVOController observe:self.label keyPath:@"text" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionInitial block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
//
//            //根据文字长度决定是否显示更多按钮
//            if (object == weakSelf.label) {
//
//                if ([change isKindOfClass:[NSDictionary class]]) {
////                    NSDictionary *changeDict = change;
////                    NSString *newValue = changeDict[@"new"];
////
////                    CGSize size = [newValue boundingRectWithSize:CGSizeMake(MAXFLOAT, 15) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:weakSelf.label.font} context:nil].size;
////                    CGFloat maxWidth = self.contentView.bounds.size.width - 104;
////                    if (size.width > maxWidth) {
////                        self.moreBtn.hidden = NO;
////                    }else{
////                        self.moreBtn.hidden = YES;
////                    }
//
//                    //NSLog(@"%@ %f %f  %d",newValue,size.width,weakSelf.label.bounds.size.width,self.moreBtn.hidden);
//
//                }
//
//            }
//
//
//
//        }];
        
        [self setBothUIButtonMasonry:_imgv1];
        
    }
    return self;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        //显示的1张图片
        _imgv1 =[[MessageImageView alloc] init];
        
        [_imgv1 setImage:[UIImage imageNamed:@"beautyGirl"]];
  
        [self.contentView addSubview:_imgv1];
        
        /*
         make.right.mas_equalTo(self.contentView.mas_right).offset(-170.f *designWscale);
         make.height.mas_equalTo(_imgv1.mas_width).multipliedBy(125.f /168.f);

         
         */
        
        [_imgv1 mas_makeConstraints:^(MASConstraintMaker *make) {
        
           make.top.mas_equalTo(self.label.mas_bottom).offset(15);
            make.left.equalTo(@37);
           
            //CGFloat w = (self.contentView.bounds.size.width-170.f *designWscale-37)*(125.f /168.f);
            make.height.equalTo(@(125));
            make.width.equalTo(@(125*1.78));
            
        }];
        
        [self setBothUIButtonMasonry:_imgv1];
        
    }
    return self;
}


-(void)moreAction
{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:self.aiName preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:[JfgLanguage getLanTextStrByKey:@"OK"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alertController addAction:action1];
    
    UIViewController *vc = [CommonMethod viewControllerForView:self];
    if (vc) {
        [vc presentViewController:alertController animated:YES completion:nil];
    }
}

@end


@implementation MessageViewCell4

-(void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    
    [super setEditing:editing animated:animated];
    [UIView animateWithDuration:0.33f animations:^{
//        if (editing) {
//            [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(@7);
//            }];
//        }else{
//            [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(@37);
//            }];
//        }
        
//        [self.label mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(@37);
//        }];
        
        
//        if (!editing) {
//            [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.left.equalTo(@37);
//                make.top.equalTo(@22);
//                make.width.mas_greaterThanOrEqualTo(@36);
//                make.height.equalTo(@14);
//            }];
//        }
        
        [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.label.mas_right).offset(13);
        }];

    }];
    
    
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self =[super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.label.text = @"12:30";
        
        self.label.mas_key = @"timeLabel";
    
        //重新修改label的布局
//        [self.label mas_remakeConstraints:^(MASConstraintMaker *make) {
//            make.left.equalTo(@37);
//            make.top.equalTo(@22);
//            make.width.mas_greaterThanOrEqualTo(@36);
//            make.height.equalTo(@14);
//        }];
        
        //显示内容的label
        _contentLabel =[[UITextView alloc] init];
        [_contentLabel setText:[JfgLanguage getLanTextStrByKey:@"MSG_SD_OFF"]];
        [_contentLabel setFont:[UIFont systemFontOfSize:14]];
        [_contentLabel setTextColor:[UIColor colorWithHexString:@"#666666"]];
        _contentLabel.editable = NO;
        _contentLabel.scrollEnabled = NO;
        _contentLabel.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        [self.contentView addSubview:_contentLabel];
        self.contentLabel.mas_key = @"contentView";
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        if (width == 320) {
            width = 215;
        }else{
            width = 215+55;
        }
        //_contentLabel.backgroundColor = [UIColor orangeColor];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.label.mas_right).offset(13);
            make.top.mas_equalTo(self.label.mas_top).offset(-2);
            make.height.equalTo(@35);
            make.width.equalTo(@(width));
            
        }];
        
        [self setBothUIButtonMasonry:self.label];
        
        [self.avBtn setTitle:[JfgLanguage getLanTextStrByKey:@"MSG_DETAILS"] forState:UIControlStateNormal];
    }
    return self;
}

@end
