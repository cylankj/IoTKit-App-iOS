//
//  AiButton.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/2.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AiButton.h"
#import "UIColor+HexColor.h"

@interface AiButton()
@property (nonatomic,assign)CGRect titleRect;
@property (nonatomic,assign)CGRect imageRect;

@end

@implementation AiButton

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
    self.layer.borderColor = [UIColor colorWithHexString:@"#f0f0f0"].CGColor;
    self.layer.borderWidth = 1;
}



-(instancetype)initWithFrame:(CGRect)frame titleFrame:(CGRect)titleFrame imageRect:(CGRect)imageRect
{
    self = [super initWithFrame:frame];
    self.titleRect = titleFrame;
    self.imageRect = imageRect;
    return self;
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return self.titleRect;
}

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return self.imageRect;
}


@end
