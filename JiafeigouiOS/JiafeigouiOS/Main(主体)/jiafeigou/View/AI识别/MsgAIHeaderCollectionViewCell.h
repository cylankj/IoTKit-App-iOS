//
//  MsgAIHeaderCollectionViewCell.h
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MsgAIHeaderImageView;

typedef NS_ENUM(NSInteger,MenuItemType) {
    
    MenuItemTypeDel,//删除
    MenuItemTypeLook,//查看
    MenuItemTypeRecognition,//识别
    MenuItemTypeMoveTo,//移动到
    MenuItemTypeNone,//没有
    
};

typedef void (^MsgAIHeaderMenuActionBlock)(MenuItemType type);

@protocol MsgAIHeaderCollectionViewCellDelegate <NSObject>

//选择菜单栏回调
-(void)collectionViewCell:(UICollectionViewCell *)cell menuItemType:(MenuItemType)itemType indexPath:(NSIndexPath *)indexPath;

@end

@interface MsgAIHeaderCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet MsgAIHeaderImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *strangerIcon;
@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,weak)id <MsgAIHeaderCollectionViewCellDelegate> delegate;
@property (nonatomic,assign)BOOL isSelected;

@end


@interface MsgAIHeaderImageView : UIImageView

//菜单选项第二项显示内容
@property (nonatomic,assign)MenuItemType menuItem2Type;
//是否支持长按显示菜单选项，默认YES
@property (nonatomic,assign)BOOL canShowMenuView; //default YES
//菜单选项回调
@property (nonatomic,copy)MsgAIHeaderMenuActionBlock menuActionBlock;

@end
