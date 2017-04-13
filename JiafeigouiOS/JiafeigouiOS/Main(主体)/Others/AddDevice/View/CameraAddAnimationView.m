//
//  CameraAddAnimationView.m
//  HeaderRotation
//
//  Created by 杨利 on 16/6/14.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "CameraAddAnimationView.h"
#import "JfgGlobal.h"

@interface CameraAddAnimationView()
{
    UIImageView *bgImageView;
    UIImageView *lightImageView;
    UIImageView *handImageView;
    UIImageView *redPointImageView;
}
@end

@implementation CameraAddAnimationView

-(instancetype)initWithFrame:(CGRect)frame
{
    CGFloat width = 294*0.5;
    CGFloat height = 490*0.5;
    CGFloat originX = (Kwidth - width)/2.0;
    CGRect newFrame = CGRectMake(originX, frame.origin.y, width, height);
    self = [super initWithFrame:newFrame];
    [self initializeView];
    return self;
}


-(void)initializeView
{
    self.backgroundColor = [UIColor whiteColor];
    
    bgImageView = [[UIImageView alloc]initWithFrame:self.bounds];
    bgImageView.image = [UIImage imageNamed:@"add_image_camera"];
    [self addSubview:bgImageView];
    
    lightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 38/2, 32/2)];
    lightImageView.center = CGPointMake(self.bounds.size.width*0.5, 122+13);
    lightImageView.image = [UIImage imageNamed:@"add_image_bulelight"];
    lightImageView.alpha = 0;
    [self addSubview:lightImageView];
    
    redPointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    redPointImageView.image = [UIImage imageNamed:@"add_image_redpoint"];
    redPointImageView.alpha = 0;
    redPointImageView.center = CGPointMake(self.bounds.size.width*0.5, 170+15);
    [self addSubview:redPointImageView];
    
    handImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 39, 104*0.5)];
    handImageView.center = CGPointMake(self.bounds.size.width-39*0.5, 170+50);
    handImageView.image =[ UIImage imageNamed:@"add_image_hand"];
    handImageView.alpha = 0;
    [self addSubview:handImageView];
    
    
    
}

-(void)startAnimation
{
    
    [UIView animateWithDuration:0.1 animations:^{
        handImageView.alpha = 1;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.8 animations:^{
            
            handImageView.center = CGPointMake(self.bounds.size.width*0.5+5, 170+40);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.1 animations:^{
                
                redPointImageView.alpha = 1;
                
            } completion:^(BOOL finished) {

                [self lightAnimation];
            }];
        }];
    }];
    
}

-(void)lightAnimation
{
    [UIView animateWithDuration:0.5 animations:^{
        
        lightImageView.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.3 animations:^{
            lightImageView.alpha = 0;
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                lightImageView.alpha = 1;
                
            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.3 animations:^{
                    lightImageView.alpha = 0;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.5 animations:^{
                        
                        lightImageView.alpha = 1;
                        
                    } completion:^(BOOL finished) {
                        
                        [UIView animateWithDuration:0.3 animations:^{
                            lightImageView.alpha = 0;
                        } completion:^(BOOL finished) {
                            [self finishedAnimation];
                        }];
                    }];
                }];
            }];
        }];
    }];
}

-(void)finishedAnimation
{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        redPointImageView.alpha = 0;
        handImageView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        handImageView.center = CGPointMake(self.bounds.size.width-39*0.5, 170+50);
        
        //重复
        [self performSelector:@selector(startAnimation) withObject:nil afterDelay:0.5];
        
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
