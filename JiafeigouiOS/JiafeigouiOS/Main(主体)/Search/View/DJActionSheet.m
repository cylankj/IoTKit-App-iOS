//
//  DJActionSheet.m
//  PrettyRuler
//
//  Created by SghOmk on 16/6/3.
//  Copyright © 2016年 Tangxianhai. All rights reserved.
//

#import "DJActionSheet.h"
#import "UIColor+HexColor.h"
#import "FLGlobal.h"
#import "DelButton.h"
#import <Masonry.h>
#import "CommonMethod.h"

#define ConfirmImageTag 789
#define DJActionSheetTitleHeight 44.f //标题栏的高度
#define DJActionSheetSelectButtonHeight 50.f //按钮的高度
#define DJActionSheetLineHeight 0.5f //取消按钮的高度

void (^aSelectBlock) (NSInteger index) = nil;
void (^aDismissBlock) (void) =nil;

@interface DJActionSheet ()
@property(nonatomic, retain)UILabel * titleLabel;
@property(copy, nonatomic)NSString *title;
@end

@implementation DJActionSheet

- (void)dealloc{
    [self.titleLabel release];
    [self.titleArrays release];
    [super dealloc];
}

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)aTitle titleArray:(NSArray *)aTitleArray actionType:(actionType)type defaultIndex:(NSInteger)index{
    
    CGFloat screenWidth =CGRectGetWidth([UIScreen mainScreen].bounds);
    if (self =[super initWithFrame:frame]) {
        self.type = type;
        self.defaultIndex = index;
        self.titleArrays = aTitleArray;
        self.title = aTitle;
        
        [self setBackgroundColor:[UIColor whiteColor]];
       
        [self addSubview:self.titleLabel];
        //创建按钮
        for (NSInteger i =0; i <[aTitleArray count]; i ++) {
            UIButton *selectButton =[UIButton buttonWithType:UIButtonTypeSystem];
            [selectButton setBackgroundColor:[UIColor colorWithHex:0xfafafa]];
            [selectButton setFrame:CGRectMake(0, DJActionSheetTitleHeight +i *(DJActionSheetSelectButtonHeight +DJActionSheetLineHeight), screenWidth, DJActionSheetSelectButtonHeight)];

            [selectButton setTag:100 +i];
            [selectButton addTarget:self action:@selector(selectButtonClock:) forControlEvents:UIControlEventTouchUpInside];
            [selectButton addTarget:self action:@selector(selectButtonHighlight:) forControlEvents:UIControlEventTouchDown];
            [self addSubview:selectButton];
            
            //创建蒙在上面的label
            UILabel *buttonTitleLabel =[[UILabel alloc] initWithFrame:selectButton.frame];
            
            [buttonTitleLabel setTextAlignment:NSTextAlignmentCenter];
            [buttonTitleLabel setText:[aTitleArray objectAtIndex:i]];
            [buttonTitleLabel setFont:[UIFont fontWithName:@"PingFangSC-regular" size:17]];
            [buttonTitleLabel setFont:[UIFont systemFontOfSize:17]];
            [buttonTitleLabel setBackgroundColor:[UIColor clearColor]];
            
            if (type == actionTypeDelete) {
                if ([aTitleArray count] -1 ==i) {
                    [buttonTitleLabel setTextColor:[UIColor colorWithHex:0x333333]];
                }else{
                    [buttonTitleLabel setTextColor:[UIColor colorWithHex:0xff3b30]];
                }
            }
            if (type == actionTypeSelect) {
                [buttonTitleLabel setTextColor:[UIColor colorWithHex:0x333333]];
                UIImageView * confirmImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"install_btn_select"]];
                confirmImage.tag = ConfirmImageTag+i;
                [confirmImage setFrame:CGRectMake(Kwidth-40-22, (DJActionSheetSelectButtonHeight-15)/2.0, 22, 15)];
                [selectButton addSubview:confirmImage];
                if(i != index){
                    confirmImage.hidden = YES;
                }
                [confirmImage release];
            }
            [self addSubview:buttonTitleLabel];
            [buttonTitleLabel release];
            //横线
//            CGMutablePathRef linePath =CGPathCreateMutable();
//            
//            CAShapeLayer *lineLayer =[CAShapeLayer layer];
//            lineLayer.strokeColor =TableSeparatorColor.CGColor;
//            lineLayer.fillColor =TableSeparatorColor.CGColor;
//            lineLayer.lineWidth =DJActionSheetLineHeight;
//            lineLayer.lineCap =kCALineCapButt;
//            
//            CGPathMoveToPoint(linePath, NULL, 0, DJActionSheetTitleHeight +i *DJActionSheetSelectButtonHeight);
//            CGPathAddLineToPoint(linePath, NULL, screenWidth, DJActionSheetTitleHeight +i *DJActionSheetSelectButtonHeight);
//            
//            lineLayer.path = linePath;
//            [self.layer addSublayer:lineLayer];
            UIView *line =[UIView new];
            
            [line setFrame:CGRectMake(0, DJActionSheetTitleHeight +i *DJActionSheetSelectButtonHeight, screenWidth, 0.5f)];
            [line setBackgroundColor:TableSeparatorColor];
            
            [self addSubview:line];
        }
    }
    return self;
    
}
-(void)selectButtonHighlight:(UIButton *)button{
    [button setBackgroundColor:CellSelectedColor];
}
- (void)selectButtonClock:(UIButton *)sender{
    //传出点击按钮的index
    NSInteger index =[sender tag] -100;
    //type为选择时右边会有小勾
    if (self.type == actionTypeSelect) {
        for (int i=0; i<self.titleArrays.count; i++) {
            UIImageView * image = [self viewWithTag:ConfirmImageTag+i];
            image.hidden = YES;
        }
        UIImageView * image = [self viewWithTag:ConfirmImageTag+index];
        image.hidden = NO;
    }

    if (nil !=aSelectBlock) {
        aSelectBlock(index);
    }
    [self actionSheetDismiss];
}

- (void)actionSheetDismiss{
    if (nil !=aDismissBlock){
        aDismissBlock();
    }
    CGFloat screenWidth =CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight =CGRectGetHeight([UIScreen mainScreen].bounds);
    UIWindow *appWindow =[[[UIApplication sharedApplication] delegate] window];
    UIView *maskView =(UIView *)[appWindow viewWithTag:1000];
    [UIView animateWithDuration:0.3 animations:^{
        [self setFrame:CGRectMake(0 ,screenHeight, screenWidth, 0)];
        maskView.alpha = 0;
    } completion:^(BOOL finished) {
        [maskView removeFromSuperview];
        [self removeFromSuperview];
    }];
    [aSelectBlock release];
    aSelectBlock =nil;
    [aDismissBlock release];
    aDismissBlock =nil;
}


+ (void)showDJActionSheetWithTitle:(NSString *)aTitle buttonTitleArray:(NSArray *)aTitleArray actionType:(actionType)type defaultIndex:(NSInteger)index didSelectedBlock:(void (^)(NSInteger))selectedBlock didDismissBlock:(void (^) (void))dismissBlock{
    
    CGFloat screenWidth =CGRectGetWidth([UIScreen mainScreen].bounds);
    CGFloat screenHeight =CGRectGetHeight([UIScreen mainScreen].bounds);
    
    DJActionSheet *actionSheet =[[DJActionSheet alloc] initWithFrame:CGRectMake(0, screenHeight, screenWidth, DJActionSheetTitleHeight +[aTitleArray count] *(DJActionSheetLineHeight +DJActionSheetSelectButtonHeight)) title:aTitle titleArray:aTitleArray actionType:type defaultIndex:index];
    
    actionSheet.tag =1001;
    
    UIWindow *appWindow =[[[UIApplication sharedApplication] delegate] window];
    
    MaskView *maskView =[[MaskView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)];
    
    maskView.backgroundColor =[UIColor blackColor];
    maskView.alpha =0;
    maskView.tag =1000;
    
    [appWindow addSubview:maskView];
    [maskView release];
    
    [appWindow addSubview:actionSheet];
    [actionSheet release];
    
    CGFloat sheetHeight = DJActionSheetTitleHeight +[aTitleArray count] *(DJActionSheetLineHeight +DJActionSheetSelectButtonHeight);
    
    [UIView animateWithDuration:[CommonMethod sheetAnimationTimeIntervalForHeight:sheetHeight] animations:^{
        maskView.alpha = 0.4;
        [actionSheet setFrame:CGRectMake(0, screenHeight - sheetHeight, screenWidth, sheetHeight)];
    }];
    aSelectBlock =[selectedBlock copy];
    aDismissBlock =[dismissBlock copy];
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        //显示title
        _titleLabel =[[UILabel alloc] initWithFrame:CGRectMake(0, 0, Kwidth, DJActionSheetTitleHeight)];
        [_titleLabel setText:self.title];
        [_titleLabel setBackgroundColor:[UIColor colorWithHex:0xf0f0f0]];
        [_titleLabel setTextColor:[UIColor colorWithHex:0x888888]];
        [_titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_titleLabel setFont:[UIFont fontWithName:@"PingFangSC-regular" size:16]];
        [_titleLabel setFont:[UIFont systemFontOfSize:16]];
    }
    return _titleLabel;
}
@end


@implementation MaskView

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UIWindow *appWindow =[[[UIApplication sharedApplication] delegate] window];
    DJActionSheet *actionSheet =(DJActionSheet *)[appWindow viewWithTag:1001];
    [actionSheet actionSheetDismiss];
}

@end
