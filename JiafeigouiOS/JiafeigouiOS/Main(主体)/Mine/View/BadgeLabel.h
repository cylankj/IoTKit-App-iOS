//
//  BadgeLabel.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BadgeLabel : UIView

/** 新来了几条数据*/
@property (nonatomic,assign,getter=totalMessageCount) NSInteger newMessageCount;
/** 读取了几条数据*/
@property (nonatomic,assign) NSInteger readMessageCount;
@end
