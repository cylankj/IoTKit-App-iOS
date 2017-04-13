//
//  doorBellTableView.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol doorBellTableViewDelegate;

@interface doorBellTableView : UITableView
//是否开始编辑View
@property (assign, nonatomic)BOOL isEditingView;

@property (strong, nonatomic) NSMutableArray *tableModelArray;

@property (assign, nonatomic)id<doorBellTableViewDelegate>viewDelegate;

@end

@protocol doorBellTableViewDelegate <NSObject>

@optional

-(void)isEditingView:(BOOL)isEditing;

@end
