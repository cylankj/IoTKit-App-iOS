//
//  JFGDraggableView.m
//  HFDraggableView
//
//  Created by 杨利 on 2017/11/21.
//  Copyright © 2017年 Henry. All rights reserved.
//

#import "JFGDraggableView.h"
#import "UIView+HFFoundation.h"

static const CGFloat kHandleWH = 30;

@interface JFGDraggableView()<UIGestureRecognizerDelegate>
{
    CGPoint _initialPoint;
    CGFloat _initialAngle;
    UIPanGestureRecognizer *_pangesture;
}
@property (nonatomic,strong)UIImageView *tlDragImageView;//上左
@property (nonatomic,strong)UIImageView *trDragImageView;//上右
@property (nonatomic,strong)UIImageView *blDragImageView;//下左
@property (nonatomic,strong)UIImageView *brDragImageView;//下右
@property (nonatomic,strong)UIView *panGRBgView;//中间移动手势背景图层
@property (nonatomic,strong)UILabel *titleLabel;

@end

@implementation JFGDraggableView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    _pangesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanView:)];
    [self addSubview:self.titleLabel];
    [self addSubview:self.panGRBgView];
    [self addSubview:self.tlDragImageView];
    [self addSubview:self.trDragImageView];
    [self addSubview:self.blDragImageView];
    [self addSubview:self.brDragImageView];
    [self.panGRBgView addGestureRecognizer:_pangesture];
    [self refreshHandles];
    [self refreshTitleSize];
    self.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.5];
    [self addObserver:self forKeyPath:@"frame" options:0 context:NULL];
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if(object == self && [keyPath isEqualToString:@"frame"]) {
//        CGRect newFrame = CGRectNull;
//        if([object valueForKeyPath:keyPath] != [NSNull null]) {
//            //此处为获取新的frame
//            //newFrame = [[object valueForKeyPath:keyPath] CGRectValue];
//            //此处为调用的方法
//            //[self setLayerFrame:newFrame];
//
//        }
        [self refreshHandles];
        [self refreshTitleSize];
        
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)didPanView:(UIPanGestureRecognizer *)pan
{
    NSLog(@"TapPanGestureRecognizer");
    CGPoint p = [pan translationInView:self.superview];
    if (pan.state == UIGestureRecognizerStateBegan) {
        _initialPoint = self.center;
    }
   
    [UIView animateWithDuration:0.3 animations:^{
        
        CGPoint resultPoint = CGPointMake(_initialPoint.x + p.x, _initialPoint.y + p.y);
        
        //设置移动的区域
        float halfx = CGRectGetMidX(self.bounds);
        resultPoint.x = MAX(halfx, resultPoint.x);
        resultPoint.x = MIN(self.superview.bounds.size.width - halfx, resultPoint.x);
        
        float halfy = CGRectGetMidY(self.bounds);
        resultPoint.y = MAX(halfy, resultPoint.y);
        resultPoint.y = MIN(self.superview.bounds.size.height - halfy, resultPoint.y);
        
        self.center = resultPoint;
        
    }];
}



- (void)didPanZoomHandle:(UIPanGestureRecognizer *)pan
{
    CGPoint translation = [pan translationInView:self];
    UIView *targetView = pan.view;
    NSLog(@"panGestureRecognizer");
    //[UIView animateWithDuration:0.3 animations:^{
        if ([targetView isEqual:self.tlDragImageView]) {
            if (pan.state == UIGestureRecognizerStateBegan) {
                [self hf_setAnchorPoint:CGPointMake(1, 1)];
            }
            
            //左上
            CGRect bounds = self.bounds;
            
            //控制最小
            bounds.size.width = MAX(bounds.size.width - translation.x, self.minDragViewSize.width);
            bounds.size.height = MAX(bounds.size.height - translation.y, self.minDragViewSize.height);
            
            
            //控制最大
            CGFloat maxWidth = self.frame.origin.x+self.frame.size.width;
            CGFloat maxHeight = self.frame.origin.y+self.frame.size.height;

            bounds.size.width = MIN(bounds.size.width, maxWidth);
            bounds.size.height = MIN(bounds.size.height, maxHeight);
            
            self.bounds = bounds;
            
        } else if ([targetView isEqual:self.blDragImageView]) {
            if (pan.state == UIGestureRecognizerStateBegan) {
                [self hf_setAnchorPoint:CGPointMake(1, 0)];
            }
            //左下
            CGRect bounds = self.bounds;
            bounds.size.width = MAX(bounds.size.width - translation.x, self.minDragViewSize.width);
            bounds.size.height = MAX(bounds.size.height + translation.y, self.minDragViewSize.height);
            
            CGFloat maxWidth = self.frame.origin.x+self.frame.size.width;
            CGFloat maxHeight = self.superview.bounds.size.height - self.frame.origin.y;
            
            bounds.size.width = MIN(bounds.size.width, maxWidth);
            bounds.size.height = MIN(bounds.size.height, maxHeight);
            
            
            self.bounds = bounds;
        } else if ([targetView isEqual:self.brDragImageView]) {
            if (pan.state == UIGestureRecognizerStateBegan) {
                [self hf_setAnchorPoint:CGPointMake(0, 0)];
            }
            CGRect bounds = self.bounds;
            bounds.size.width = MAX(bounds.size.width + translation.x, self.minDragViewSize.width);
            bounds.size.height = MAX(bounds.size.height + translation.y, self.minDragViewSize.height);
            
            
            //右下
            CGFloat maxWidth = self.superview.bounds.size.width - self.frame.origin.x;
            CGFloat maxHeight = self.superview.bounds.size.height - self.frame.origin.y;
            
            bounds.size.width = MIN(bounds.size.width, maxWidth);
            bounds.size.height = MIN(bounds.size.height, maxHeight);

            self.bounds = bounds;
            
        } else if ([targetView isEqual:self.trDragImageView]) {
            if (pan.state == UIGestureRecognizerStateBegan) {
                [self hf_setAnchorPoint:CGPointMake(0, 1)];
            }
            CGRect bounds = self.bounds;
            bounds.size.width = MAX(bounds.size.width + translation.x, self.minDragViewSize.width);
            bounds.size.height = MAX(bounds.size.height - translation.y, self.minDragViewSize.height);
            
            //右上
            CGFloat maxWidth = self.superview.bounds.size.width - self.frame.origin.x;
            CGFloat maxHeight = self.bounds.size.height + self.frame.origin.y;
            
            bounds.size.width = MIN(bounds.size.width, maxWidth);
            bounds.size.height = MIN(bounds.size.height, maxHeight);
            self.bounds = bounds;
        }
        
        [pan setTranslation:CGPointZero inView:self];
        [self refreshHandles];
        [self refreshTitleSize];
    //}];
    
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        [self hf_setAnchorPoint:CGPointMake(0.5, 0.5)];
    }
}

- (void)refreshHandles
{
    self.tlDragImageView.frame = CGRectMake(0, 0, 30, 30);
    self.trDragImageView.frame = CGRectMake(self.bounds.size.width-30, 0, 30, 30);
    self.blDragImageView.frame = CGRectMake(0, self.bounds.size.height-30, 30, 30);
    self.brDragImageView.frame = CGRectMake(self.bounds.size.width-30, self.bounds.size.height-30, 30, 30);
    self.panGRBgView.frame = CGRectMake(0, 0, self.bounds.size.width-kHandleWH*2, self.bounds.size.height-kHandleWH*2);
    self.panGRBgView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
}

-(void)refreshTitleSize
{
    CGSize size = [self.titleLabel sizeThatFits:CGSizeMake(self.bounds.size.width-20, 40)];
    if (size.width > self.bounds.size.width-10 || size.height > self.bounds.size.height - 10) {
        self.titleLabel.hidden = YES;
    }else{
        self.titleLabel.hidden = NO;
    }
    self.titleLabel.bounds = CGRectMake(0, 0, size.width, size.height);
    self.titleLabel.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    [self.titleLabel layoutIfNeeded];
}

-(UIImageView *)tlDragImageView
{
    if (!_tlDragImageView) {
        _tlDragImageView = [self createconerImageViewImage:[UIImage imageNamed:@"top_left_corner"]];
    }
    return _tlDragImageView;
}

-(UIImageView *)trDragImageView
{
    if (!_trDragImageView) {
        _trDragImageView = [self createconerImageViewImage:[UIImage imageNamed:@"upper_right_corner"]];
    }
    return _trDragImageView;
}

-(UIImageView *)blDragImageView
{
    if (!_blDragImageView) {
        _blDragImageView = [self createconerImageViewImage:[UIImage imageNamed:@"lower_left_corner"]];
    }
    return _blDragImageView;
}

-(UIImageView *)brDragImageView
{
    if (!_brDragImageView) {
        _brDragImageView = [self createconerImageViewImage:[UIImage imageNamed:@"lower_right_corner"]];
    }
    return _brDragImageView;
}

-(UIImageView *)createconerImageViewImage:(UIImage *)image
{
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.userInteractionEnabled = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPanZoomHandle:)];
    pan.delegate = self;
    [imageView addGestureRecognizer:pan];
    return imageView;
}

-(UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, self.bounds.size.width-20, 40)];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.numberOfLines = 0;
        //_titleLabel.text = @"拖拽红色方框，设置侦测区域，哈哈哈";
    }
    return _titleLabel;
}


//防止手势冲突
-(UIView *)panGRBgView
{
    if (!_panGRBgView) {
        _panGRBgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width-kHandleWH*2, self.bounds.size.height-kHandleWH*2)];
        _panGRBgView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
        _panGRBgView.userInteractionEnabled = YES;
        _panGRBgView.backgroundColor = [UIColor clearColor];
    }
    return _panGRBgView;
}

-(void)setHint:(NSString *)hint
{
    self.titleLabel.text = hint;
    [self refreshTitleSize];
}

//一句话总结就是此方法返回YES时，手势事件会一直往下传递，不论当前层次是否对该事件进行响应。
-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] &&
        [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
        return NO;
    }
    return YES;
}

-(void)dealloc
{
    [self removeObserver:self forKeyPath:@"frame" context:NULL];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
