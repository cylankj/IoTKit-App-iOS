//
//  BaseDeviceTableView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseDeviceTableView.h"
#import "JfgGlobal.h"

@implementation BaseDeviceTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        self.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
    }
    return self;
}

@end
