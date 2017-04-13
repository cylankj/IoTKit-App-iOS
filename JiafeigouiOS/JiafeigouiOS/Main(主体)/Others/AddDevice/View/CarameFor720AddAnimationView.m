//
//  CarameFor720AddAnimationView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/3/6.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "CarameFor720AddAnimationView.h"
#import "JfgGlobal.h"

@implementation CarameFor720AddAnimationView
{
    UIImageView *bgImageView;
    UIImageView *lightImageView;
    UIImageView *lightBgImageView;
    UIImageView *handImageView;
    UIImageView *redPointImageView;
}


-(instancetype)initWithFrame:(CGRect)frame
{
    CGFloat width = 294*0.5;
    CGFloat height = 558*0.5;
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
    bgImageView.image = [UIImage imageNamed:@"add_image_panoramic_camera"];
    [self addSubview:bgImageView];
    
    redPointImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
    redPointImageView.image = [UIImage imageNamed:@"add_image_redpoint"];
    redPointImageView.alpha = 0;
    redPointImageView.center = CGPointMake(self.bounds.size.width*0.5-1, 238*0.5);
    [self addSubview:redPointImageView];
    
    handImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 39, 104*0.5)];
    handImageView.center = CGPointMake(self.bounds.size.width-39*0.5-1, 170);
    handImageView.image =[UIImage imageNamed:@"add_image_hand"];
    handImageView.alpha = 0;
    [self addSubview:handImageView];
    
    //116 × 66  146  204
    lightBgImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 63, 33)];
    lightBgImageView.image = [UIImage imageNamed:@"add_image_pop"];
    lightBgImageView.left = 73+0.5;
    lightBgImageView.y = 102+1;
    lightBgImageView.alpha = 0;
    [self addSubview:lightBgImageView];
    
    lightImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 38/2, 32/2)];//61  27
    lightImageView.center = CGPointMake(33, 11);
    lightImageView.image = [UIImage imageNamed:@"add_image_bulelight"];
    lightImageView.alpha = 0;
    [lightBgImageView addSubview:lightImageView];
    
}

-(void)startAnimation
{
    
    [UIView animateWithDuration:0.1 animations:^{
        handImageView.alpha = 1;
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.8 animations:^{
            
            handImageView.center = CGPointMake(self.bounds.size.width*0.5+3, 170+40-67);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
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
        lightBgImageView.alpha = 1;
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
    }];
    
    
    
}


-(void)finishedAnimation
{
    
    [UIView animateWithDuration:0.5 animations:^{
        
        redPointImageView.alpha = 0;
        handImageView.alpha = 0;
        lightBgImageView.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        handImageView.center = CGPointMake(self.bounds.size.width-39*0.5-1, 170);
        
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
