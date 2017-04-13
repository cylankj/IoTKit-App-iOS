//
//  ExploreTableView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/2.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ExploreTableView.h"
#import "ExploreTableViewCell.h"
#import "FLGlobal.h"
#import "UIColor+HexColor.h"
@interface ExploreTableView()


@end

@implementation ExploreTableView

-(instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];

    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [self setSeparatorColor:TableSeparatorColor];
    self.backgroundColor = [UIColor whiteColor];
    [self setSeparatorInset:UIEdgeInsetsMake(0, 37, 0, 0)];

    return self;
}



@end
