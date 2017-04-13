//
//  DoorAddLoadView.m
//  HeaderRotation
//
//  Created by 杨利 on 16/6/14.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "DoorAddAnimationView.h"
#import "JfgGlobal.h"
#import <POP.h>
#define kAngle(r) (r) * M_PI / 180

@interface DoorAddAnimationView()
{
    UIView *bgView;
    UIImageView *bgImageView1;
    UIImageView *bgImageView2;
    UIImageView *handImageView;
    UIImageView *lightImageView;
    UIImageView *redPointImageView;
}
@end


@implementation DoorAddAnimationView

//494 507

-(instancetype)initWithFrame:(CGRect)frame
{
    CGFloat width = 494*0.5;
    CGFloat height = 507*0.5;
    CGFloat originX = (Kwidth - width)/2.0;
    CGRect newFrame = CGRectMake(originX, frame.origin.y, width, height);
    self = [super initWithFrame:newFrame];
    [self initializeView];
    return self;
}

-(void)initializeView
{
    bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    [self addSubview:bgView];
    
    bgImageView1 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
    bgImageView1.image = [UIImage imageNamed:@"add_image_back"];
    bgImageView1.userInteractionEnabled = YES;
    
//    bgImageView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width)];
//    bgImageView2.image = [UIImage imageNamed:@"add_image_front"];
//    bgImageView2.userInteractionEnabled = YES;
    
   
    [bgView addSubview:bgImageView1];
    
    
    redPointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 15, 15)];
    redPointImageView.center = CGPointMake(24, 246*0.5-2);
    redPointImageView.image = [UIImage imageNamed:@"add_image_redpoint"];
    redPointImageView.alpha = 0;
    [self addSubview:redPointImageView];
    
    handImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 78*0.5, 104*0.5)];
    handImageView.image = [UIImage imageNamed:@"add_image_hand"];
    handImageView.center = CGPointMake(self.bounds.size.width*0.5, 200);
    handImageView.alpha = 0;
    [self addSubview:handImageView];
    
    lightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 41, 18)];
    lightImageView.center = CGPointMake(self.bounds.size.width*0.5-3, 200);
    lightImageView.alpha = 0;
    lightImageView.image = [UIImage imageNamed:@"add_image_redlight"];
    [self addSubview:lightImageView];
    
    
}

-(void)startAnimation
{
    [UIView animateWithDuration:0.1 animations:^{
        //显示小手
        handImageView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        //小手移到左侧
        [UIView animateWithDuration:0.8 animations:^{
            
            handImageView.center = CGPointMake(28, self.bounds.size.height*0.5+18);
            
        } completion:^(BOOL finished) {
            
            //左侧红点闪烁
            redPointImageView.alpha = 1;
            [UIView animateWithDuration:0.5 animations:^{
                
                redPointImageView.bounds = CGRectMake(0, 0, 20, 20);
                
            } completion:^(BOOL finished) {
                //隐藏红点，并移到右侧
                redPointImageView.alpha = 0;
                redPointImageView.bounds = CGRectMake(0, 0, 15, 15);
                redPointImageView.center = CGPointMake(446*0.5, 246*0.5-2);
                
            }];
            
            //隐藏小手
            [UIView animateWithDuration:0.5 animations:^{
                
                handImageView.alpha = 0;
                
            } completion:^(BOOL finished) {
                
                //小手移回底部
                handImageView.center = CGPointMake(self.bounds.size.width*0.5, 200);
                
                //显示小手
                [UIView animateWithDuration:0.3 animations:^{
                    
                    handImageView.alpha = 1;
                    
                } completion:^(BOOL finished) {
                    
                    [UIView animateWithDuration:0.8 animations:^{
                        
                        //小手移到右侧
                        handImageView.center = CGPointMake(227, self.bounds.size.height*0.5+18);
                        
                    } completion:^(BOOL finished) {
                        
                        //右侧红点闪烁
                        redPointImageView.alpha = 1;
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            
                            redPointImageView.bounds = CGRectMake(0, 0, 20, 20);
                            
                        } completion:^(BOOL finished) {
                            
                            //隐藏红点，并移回左侧
                            redPointImageView.alpha = 0;
                            redPointImageView.bounds = CGRectMake(0, 0, 15, 15);
                            redPointImageView.center = CGPointMake(24, 246*0.5-2);
                            
                        }];
                        
                        [UIView animateWithDuration:0.5 animations:^{
                            
                            //隐藏小手
                            handImageView.alpha = 0;
                            
                        } completion:^(BOOL finished) {
                            
                            //小手移回底部
                            handImageView.center = CGPointMake(self.bounds.size.width*0.5, 200);
                            
                            //翻转，呈现背面视图
//                            [UIView beginAnimations:nil context:nil];
//                            [UIView setAnimationDelay:0.5];
//                            
//                            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//                            [UIView setAnimationDuration:1];
//                            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:bgView cache:YES];
//                            [bgView exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
//                            [UIView commitAnimations];
//                            
//                            //延迟1秒后，开始背面动画
//                            [self performSelector:@selector(backAnimation) withObject:nil afterDelay:1];
                            
                            [self flipAnimation];
                            
                        }];
                    }];
                }];
            }];
        }];
    }];
    
}

//翻转
-(void)flipAnimation
{
    [UIView animateWithDuration:2 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        
        bgImageView1.layer.transform = CATransform3DMakeRotation(kAngle(180), 0, 1, 0);

        [self performSelector:@selector(transImage) withObject:nil afterDelay:1];
        
    } completion:^(BOOL finished) {
        
        //延迟1秒后，开始背面动画
        [self performSelector:@selector(backAnimation) withObject:nil afterDelay:1];
    }];

}

-(void)transImage
{
    bgImageView1.image = [UIImage imageNamed:@"add_image_front"];
}

-(void)backAnimation
{
    //灯光效果
    [UIView animateWithDuration:1 animations:^{
        
        lightImageView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        lightImageView.alpha = 0;
        
        [UIView animateWithDuration:1 animations:^{
            
            lightImageView.alpha = 1;
            
        } completion:^(BOOL finished) {
            
            lightImageView.alpha = 0;
            
            [UIView animateWithDuration:1 animations:^{
                
                lightImageView.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                lightImageView.alpha = 0;
                bgImageView1.layer.transform = CATransform3DMakeRotation(kAngle(0), 0, 1, 0);
                bgImageView1.image = [UIImage imageNamed:@"add_image_back"];
                
                [UIView animateWithDuration:2 animations:^{
                    
                    //[bgView  exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
                    
                    
                } completion:^(BOOL finished) {
                    
                    //重复动画
                    [self performSelector:@selector(replace) withObject:nil afterDelay:1];
                    
                }];
            }];
            
            
            
            
        }];
    }];
    
}


-(void)replace
{
    [self startAnimation];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
