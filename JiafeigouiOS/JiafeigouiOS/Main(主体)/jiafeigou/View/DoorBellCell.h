//
//  DoorBellCell.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BellView.h"

@protocol DoorBellCellTapDelegate <NSObject>

-(void)doorBellCellTap:(UITapGestureRecognizer *)tap indexPath:(NSIndexPath *)indexPath;

@end

@interface DoorBellCell : UITableViewCell

@property (nonatomic,assign)id <DoorBellCellTapDelegate> delegate;
@property(strong, nonatomic)BellView * bell;
@property(nonatomic,strong)NSIndexPath *indexPath;

@end
