//
//  PhotoSelectionAlertView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/7/30.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "PhotoSelectionAlertView.h"
#import "UIView+FLExtensionForFrame.h"
#import "UIColor+HexColor.h"
#import "CommonMethod.h"
#import "JfgLanguage.h"

@interface PhotoSelectionAlertView()

@property (nonatomic,strong)UIView *containerView;

@property (nonatomic,weak)id<PhotoSelectionAlertViewDelegate> delegate;

@property (nonatomic,copy)NSString *mark;

@end

@implementation PhotoSelectionAlertView

-(instancetype)init
{
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    }
    return  self;
}


-(instancetype)initWithMark:(NSString *)mark
                   delegate:(id<PhotoSelectionAlertViewDelegate>)delegate
          otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    self = [self init];
    
    _delegate = delegate;
    _mark = mark;
    
    NSMutableArray *titleArray = [[NSMutableArray alloc]init];
    
    va_list argList;
    // 从 otherButtonTitles 开始遍历参数，不包括 otherButtonTitles 本身.
    va_start(argList, otherButtonTitles);
    
    [titleArray addObject:otherButtonTitles];
    
    NSString* eachArg;
    while ((eachArg = va_arg(argList, NSString*))) {// 从 args 中遍历出参数，NSString* 指明类型
        [titleArray addObject:eachArg];
        
    }
    
    //置空
    va_end(argList);
    
    [self addButtonWithTitles:titleArray];
    
    return self;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self dismiss];
}

-(void)addButtonWithTitles:(NSArray *)titles
{
    self.containerView.height = titles.count*50;
    self.containerView.top = self.height;
    [self addSubview:self.containerView];
    
    [titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, self.width, 50);
        btn.top = idx*50;
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor colorWithHexString:@"#383838"] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setBackgroundImage:[self imageWithColor:[UIColor colorWithHexString:@"#fafafa"] size:CGSizeMake(btn.width, btn.height)]  forState:UIControlStateNormal];
        
        if ([title isEqualToString:[JfgLanguage getLanTextStrByKey:@"LOGOUT"]]) {
            [btn setTitleColor:[UIColor colorWithHexString:@"#ff3b30"] forState:UIControlStateNormal];
            
        }
        
        UIImage *highImage = [self imageWithColor:[UIColor colorWithHexString:@"#dfdfdf"] size:btn.bounds.size];
        [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
        [btn setBackgroundImage:highImage forState:UIControlStateSelected];

        btn.tag = 100+idx;
        [btn addTarget:self action:@selector(clickBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *lineLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, btn.height-0.5, btn.width, 0.5)];
        lineLabel.backgroundColor = [UIColor colorWithHexString:@"#e1e1e1"];
        lineLabel.text = @"";
        [btn addSubview:lineLabel];
        
        [self.containerView addSubview:btn];
        
    }];
    
    
}

-(void)clickBtn:(UIButton *)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(actionSheet:mark:clickedButtonAtIndex:)]) {
        
        [self.delegate actionSheet:self mark:_mark clickedButtonAtIndex:sender.tag-100];
        
    }
    [self dismiss];
}

-(void)show
{
    self.alpha = 0;
    UIWindow *keyWindows = [UIApplication sharedApplication].keyWindow;
    [keyWindows addSubview:self];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:[CommonMethod sheetAnimationTimeIntervalForHeight:self.containerView.height] delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerView.bottom = self.height;
        } completion:^(BOOL finished) {
            
        }];
    }];
}

-(void)dismiss
{
    [UIView animateWithDuration:[CommonMethod sheetAnimationTimeIntervalForHeight:self.containerView.height] animations:^{
        self.containerView.top = self.height;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.alpha = 0;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }];
    
}

-(UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0,self.width, 0)];
        _containerView.backgroundColor = [UIColor whiteColor];
        _containerView.clipsToBounds = YES;
    }
    return _containerView;
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context,color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
