//
//  SafaButton.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/6/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SafaButton.h"

#define kAngle(r) (r) * M_PI / 180
@implementation SafaButton

-(void)setIsFace:(BOOL)isFace
{
    if (isFace == _isFace) {
        return;
    }
    _isFace = isFace;
    [self flipAnimation];
}

-(void)didMoveToSuperview
{
    [self setImage:[UIImage imageNamed:@"camera_ico_safe"] forState:UIControlStateNormal];
    _isFace = YES;
}

-(void)transformAnimation
{
    self.isFace = !self.isFace;
}

//翻转
-(void)flipAnimation
{
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        if (_isFace) {
            self.imageView.layer.transform = CATransform3DIdentity;
        }else{
            self.imageView.layer.transform = CATransform3DMakeRotation(kAngle(180), 0, 1, 0);
        }
    
        [self performSelector:@selector(transImage) withObject:nil afterDelay:0.5];
        
    } completion:nil];
    
}

-(void)transImage
{
    if (self.isFace) {
        [self setImage:[UIImage imageNamed:@"camera_ico_safe"] forState:UIControlStateNormal];
    }else{
        [self setImage:[UIImage imageNamed:@"camera_ico_nosafe"] forState:UIControlStateNormal];
    }
}


-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, contentRect.size.height*0.5-10, 20, 20);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(24, 0, contentRect.size.width-24, contentRect.size.height);
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
