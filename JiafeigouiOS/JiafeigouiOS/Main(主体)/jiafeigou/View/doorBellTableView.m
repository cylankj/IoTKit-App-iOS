//
//  doorBellTableView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "doorBellTableView.h"
#import "DoorBellCell.h"
@implementation doorBellTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style{
    if (self =[super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.height, frame.size.width) style:style]) {
        self.transform =CGAffineTransformMakeRotation(- M_PI /2);
        self.showsVerticalScrollIndicator =NO;
        self.showsHorizontalScrollIndicator =NO;
        [self setContentInset:UIEdgeInsetsMake(9, 0, 9, 0)];
        [self registerClass:[DoorBellCell class] forCellReuseIdentifier:@"doorBellCell"];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self setDecelerationRate:0.9f];
        [self setBackgroundColor:[UIColor clearColor]];
        
    }
    return self;
}

- (void)setIsEditingView:(BOOL)isEditingView{
    _isEditingView =isEditingView;
    if ([self.viewDelegate respondsToSelector:@selector(isEditingView:)]) {
        [self.viewDelegate isEditingView:_isEditingView];
    }
}


@end
