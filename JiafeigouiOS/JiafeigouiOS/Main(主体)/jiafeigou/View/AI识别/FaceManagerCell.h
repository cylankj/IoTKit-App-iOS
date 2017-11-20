//
//  FaceManagerCell.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgAIHeaderCollectionViewCell.h"

@interface FaceManagerCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet MsgAIHeaderImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UIImageView *editImageView;
@property (nonatomic,assign) BOOL isSelected;//default NO
@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,weak)id <MsgAIHeaderCollectionViewCellDelegate> delegate;

@end
