//
//  UITableView+ReloadData.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "UITableView+ReloadData.h"

@implementation UITableView (ReloadData)
- (void)reloadData:(BOOL)animated
{
    [self reloadData];
    
    if (animated) {
        
        CATransition *animation = [CATransition animation];
        [animation setType:kCATransitionMoveIn];
        [animation setSubtype:kCATransitionFade];
        [animation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
        [animation setFillMode:kCAFillModeBoth];
        [animation setDuration:1.3];
        [[self layer] addAnimation:animation forKey:@"UITableViewReloadDataAnimationKey"];
        
    }
}
@end
