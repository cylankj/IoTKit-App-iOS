//
//  UITableView+FLExtension.h
//  FLExtension
//
//  Created by 紫贝壳 on 15/8/11.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (FLExtension)

+ (UITableView *)initWithFrame:(CGRect)frame style:(UITableViewStyle)style cellSeparatorStyle:(UITableViewCellSeparatorStyle)cellSeparatorStyle
                separatorInset:(UIEdgeInsets)separatorInset
                    dataSource:(id <UITableViewDataSource>)dataSource
                      delegate:(id <UITableViewDelegate>)delegate;

@end
