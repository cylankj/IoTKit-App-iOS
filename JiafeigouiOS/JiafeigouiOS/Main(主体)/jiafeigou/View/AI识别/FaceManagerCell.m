//
//  FaceManagerCell.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "FaceManagerCell.h"

@implementation FaceManagerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headerImageView.layer.masksToBounds = YES;
    self.headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    __weak typeof(self) weakSelf = self;
    self.headerImageView.menuActionBlock = ^(MenuItemType type) {
        
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(collectionViewCell:menuItemType:indexPath:)]) {
            [weakSelf.delegate collectionViewCell:self menuItemType:type indexPath:self.indexPath];
        }
        
    };
    
    // Initialization code
}

-(void)setIsSelected:(BOOL)isSelected
{
    if (_isSelected == isSelected) {
        return;
    }
    _isSelected = isSelected;
    if (isSelected) {
        self.editImageView.image = [UIImage imageNamed:@"camera_icon_Selected"];
    }else{
        self.editImageView.image = [UIImage imageNamed:@"camera_icon_Select"];
    }
}

@end
