//
//  DJActionSheet.h
//  PrettyRuler
//
//  Created by SghOmk on 16/6/3.
//  Copyright © 2016年 Tangxianhai. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum actionType
{
    actionTypeDelete,
    actionTypeSelect,
    
}actionType;


@interface DJActionSheet : UIView
//弹框款式
@property(nonatomic, assign) actionType type;
@property(nonatomic, assign) NSInteger defaultIndex;
@property(nonatomic, retain) NSArray * titleArrays;

/**
 *  弹框
 *
 *  @param aTitle        标题
 *  @param aTitleArray   按钮s文字
 *  @param type          actionType
 *  @param index         actionType=actionTypeSelect时默认选中的index
 *  @param selectedBlock 选中按钮的回调
 *  @param dismissBlock  dismiss的回调
 */
+ (void)showDJActionSheetWithTitle:(NSString *)aTitle buttonTitleArray:(NSArray *)aTitleArray actionType:(actionType)type defaultIndex:(NSInteger)index didSelectedBlock:(void (^) (NSInteger index))selectedBlock didDismissBlock:(void (^) (void))dismissBlock;

/** 这个方法不需要调用*/
-(instancetype)initWithFrame:(CGRect)frame title:(NSString *)aTitle titleArray:(NSArray *)aTitleArray actionType:(actionType)type defaultIndex:(NSInteger)index;

/** 这个方法不需要调用*/
- (void)actionSheetDismiss;

@end

@interface MaskView : UIView

@end