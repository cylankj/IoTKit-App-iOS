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
    
    MenuItemTypeDel = 0,//删除
    MenuItemTypeLook = 1,//查看
    MenuItemTypeRecognition = 2,//识别
    MenuItemTypeMoveTo = 3,//移动到
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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerImageTop;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerImageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerImageWidth;

@property (weak, nonatomic) IBOutlet UIImageView *strangerIcon;

@property (nonatomic,strong) NSIndexPath *indexPath;
@property (nonatomic,weak)id <MsgAIHeaderCollectionViewCellDelegate> delegate;
@property (nonatomic,assign)BOOL isSelected;

@end


@interface MsgAIHeaderImageView : UIImageView

//@property (nonatomic,assign)MenuItemType menuItem2Type;
//菜单选项显示内容(MenuItemType集合)
@property (nonatomic,strong)NSArray <NSNumber *>*menuItems;

//是否支持长按显示菜单选项，默认YES
@property (nonatomic,assign)BOOL canShowMenuView; //default YES
//菜单选项回调
@property (nonatomic,copy)MsgAIHeaderMenuActionBlock menuActionBlock;

@end
