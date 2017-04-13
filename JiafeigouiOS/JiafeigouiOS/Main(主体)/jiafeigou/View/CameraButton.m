


//
//  CameraButton.m
//  HeaderRotation
//
//  Created by 杨利 on 16/6/30.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "CameraButton.h"
#import "UIView+FLExtensionForFrame.h"
#import "NSTimer+FLExtension.h"
#import <pop/POP.h>
#import "NSTimer+FLExtension.h"

@interface CameraButton()
{
    BOOL isBegin;
}
@property (nonatomic,strong)CAShapeLayer *backgroundShapeLayer;
@property (nonatomic,strong)CAShapeLayer *progressShaperLayer;
@property (nonatomic,strong)UIView *centerView;

@end

@implementation CameraButton

-(void)didMoveToSuperview
{
    [self.layer addSublayer:self.backgroundShapeLayer];
    [self.layer addSublayer:self.progressShaperLayer];
    [self addSubview:self.centerView];
   
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(touchDown)]) {
        [self.delegate touchDown];
    }
}

-(void)sendAction:(SEL)action to:(id)target forEvent:(UIEvent *)event
{
    
}

-(void)startAnimation
{
    if (isBegin == YES) {
        return;
    }
    
    isBegin = YES;
    //开始
    [self centerViewAnimationWithSize:CGSizeMake(self.width*0.5, self.width*0.5) radius:5 completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStartProgressAnimation)]) {
            [self.delegate didStartProgressAnimation];
        }
    }];
    
    [self startProgressAnimation];
}

-(void)stopAnimation
{
    if (isBegin == NO) {
        return;
    }
    isBegin = NO;
    [self centerViewAnimationWithSize:CGSizeMake(self.width-10, self.width-10) radius:(self.width-10)*0.5 completion:^{
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didStopAnimation)]) {
            [self.delegate didStopAnimation];
        }
    }];
    
    [self removeAllAnimations];
}


#pragma mark- 中间矩形块动画
-(void)centerViewAnimationWithSize:(CGSize)size
                            radius:(CGFloat)radius
                        completion:(void(^)(void))completionBlock
{
    //self.userInteractionEnabled = NO;
    
    POPBasicAnimation *scaleBaseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPViewSize];
    scaleBaseAnimation.toValue = [NSValue valueWithCGSize:size];
    scaleBaseAnimation.duration = 0.6;
    [self.centerView pop_addAnimation:scaleBaseAnimation forKey:@"size"];
    
    POPBasicAnimation *radiusBaseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerCornerRadius];
    radiusBaseAnimation.toValue = @(radius);
    radiusBaseAnimation.duration = 0.6;
    radiusBaseAnimation.completionBlock =  ^(POPAnimation *anim, BOOL finished){
        
        self.userInteractionEnabled = YES;
        if (completionBlock) {
            completionBlock();
        }
        
    };
    [self.centerView.layer pop_addAnimation:radiusBaseAnimation forKey:@"radius"];
}

#pragma mark- 进度条动画
-(void)startProgressAnimation
{
    [self removeAllAnimations];
    [self progressToEndAnimationWithDuration:1 completion:nil];
}

//进度条至1
-(void)progressToEndAnimationWithDuration:(CGFloat)duration
                               completion:(void(^)(void))completionBlock
{
    [self removeAllAnimations];
    POPBasicAnimation *storeEndBaseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    storeEndBaseAnimation.toValue = @(1);
    storeEndBaseAnimation.duration = duration;
    storeEndBaseAnimation.completionBlock =  ^(POPAnimation *anim, BOOL finished){
        
        
            
        [self progressRestartWithCompletion:nil];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didCameraOnePhoto)] && isBegin) {
            [self.delegate didCameraOnePhoto];
        }
        
        if (completionBlock) {
            completionBlock();
        }//822 6146
        
        
        
    };
    [self.progressShaperLayer pop_addAnimation:storeEndBaseAnimation forKey:@"storeEnd"];
}

//进度条颜色至透明，storeEnd设置为0
-(void)progressRestartWithCompletion:(void(^)(void))completionBlock
{
    [self removeAllAnimations];
    self.progressShaperLayer.strokeColor = [UIColor clearColor].CGColor;
    POPBasicAnimation *storeEndBaseAnimation  = [POPBasicAnimation animationWithPropertyNamed:kPOPShapeLayerStrokeEnd];
    storeEndBaseAnimation.toValue = @(0);
    storeEndBaseAnimation.duration = 0.2;
    storeEndBaseAnimation.completionBlock =  ^(POPAnimation *anim, BOOL finished){
        
        self.progressShaperLayer.strokeColor = [UIColor whiteColor].CGColor;
        if (!isBegin) {
            return ;
        }
        [self progressToEndAnimationWithDuration:self.intervalTime completion:nil];
        if (completionBlock) {
            completionBlock();
        }
    };
    [self.progressShaperLayer pop_addAnimation:storeEndBaseAnimation forKey:@"storeEnd"];
}



-(void)removeAllAnimations
{
    [self.progressShaperLayer pop_animationForKey:@"storeEnd"];
    [self.progressShaperLayer pop_removeAllAnimations];
}




#pragma mark- getter
-(UIView *)centerView
{
    if (_centerView == nil) {
        _centerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width-10, self.height-10)];
        _centerView.x = self.width*0.5;
        _centerView.y = self.height*0.5;
        [_centerView setCornerRadius:_centerView.width*0.5];
        _centerView.backgroundColor = [UIColor whiteColor];
        _centerView.userInteractionEnabled = YES;
    }
    return _centerView;
}

-(CAShapeLayer *)backgroundShapeLayer
{
    if (!_backgroundShapeLayer) {
        CAShapeLayer *ringShapeLayer = [CAShapeLayer layer];
        ringShapeLayer.frame = self.bounds;
        ringShapeLayer.position = CGPointMake(self.width*0.5, self.height*0.5);
        UIBezierPath *outsideBezierPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
        ringShapeLayer.path = outsideBezierPath.CGPath;
        ringShapeLayer.fillColor = [UIColor clearColor].CGColor;
        ringShapeLayer.lineWidth = 2;
        ringShapeLayer.strokeColor = [UIColor colorWithWhite:1 alpha:0.3].CGColor;
        ringShapeLayer.strokeEnd = 1;
        _backgroundShapeLayer = ringShapeLayer;
    }
    
    return _backgroundShapeLayer;

}


-(CAShapeLayer *)progressShaperLayer
{
    if (!_progressShaperLayer) {
        //创建shapeLayer
        CAShapeLayer *progressShapeLayer = [CAShapeLayer layer];
        progressShapeLayer.frame = self.bounds;
        progressShapeLayer.position = CGPointMake(self.width*0.5, self.height*0.5);
        //创建圆形贝塞尔曲线
        
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithOvalInRect:self.bounds];
        //关联贝塞尔曲线与shapeLayer
        progressShapeLayer.path = bezierPath.CGPath;
        //设置线条宽度
        progressShapeLayer.lineWidth = 2;
        progressShapeLayer.lineCap = kCALineCapRound;
        //设置路径颜色
        progressShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        //设置填充颜色
        progressShapeLayer.fillColor = [UIColor clearColor].CGColor;
        //设置路径结束位置(默认开始位置为0)
        progressShapeLayer.transform = CATransform3DMakeRotation((-90 * M_PI) / 180.0, 0, 0, 1);
        progressShapeLayer.strokeStart = 0;
        progressShapeLayer.strokeEnd = 0;
        _progressShaperLayer = progressShapeLayer;
    }
    return _progressShaperLayer;
}

@end
