//
//  MsgAIHeaderCollectionViewCell.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "MsgAIHeaderCollectionViewCell.h"
#import "JfgLanguage.h"
#import "UIColor+HexColor.h"
#import "LoginManager.h"
#import "ProgressHUD.h"
#import "UIView+FLExtensionForFrame.h"

@implementation MsgAIHeaderCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = self.headImageView.bounds.size.width*0.5;
    self.headImageView.layer.borderColor = [UIColor colorWithHexString:@"#36bdff"].CGColor;
    self.headImageView.layer.borderWidth = 0;
    self.backgroundColor = [UIColor whiteColor];
    [self.contentView bringSubviewToFront:self.strangerIcon];
    __weak typeof(self) weakSelf = self;
    self.headImageView.menuActionBlock = ^(MenuItemType type) {
      
        if (weakSelf && weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(collectionViewCell:menuItemType:indexPath:)]) {
            [weakSelf.delegate collectionViewCell:self menuItemType:type indexPath:self.indexPath];
        }
        
    };
}

-(void)setIsSelected:(BOOL)isSelected
{
    if (_isSelected == isSelected) {
        return;
    }
    _isSelected = isSelected;
    if (_isSelected) {
        
        //增加4个像素的边框
        self.headerImageWidth.constant = 62+8;
        self.headerImageHeight.constant = 62+8;
        self.headerImageTop.constant = 1;
        self.headImageView.layer.cornerRadius = 70*0.5;
        self.headImageView.layer.borderWidth = 4;
        
    }else{
        
        self.headerImageWidth.constant = 62;
        self.headerImageHeight.constant = 62;
        self.headerImageTop.constant = 5;
        self.headImageView.layer.cornerRadius = 62*0.5;
        self.headImageView.layer.borderWidth = 0;
    }
}

@end

@implementation MsgAIHeaderImageView

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.canShowMenuView = YES;
    [self initLong];
}

-(void)initLong
{
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress)]];
}

-(void)longPress
{
    if (!self.canShowMenuView) {
        return;
    }
    //1.设置为第一响应者
    //通过设置第一响应者UIMenuController可以获得支持哪些操作的信息,操作怎么处理
    [self becomeFirstResponder];
    
    //2.设置UIMenuController
    UIMenuController * menu = [UIMenuController sharedMenuController];
    
    //当长按label的时候，这个方法会不断调用，menu就会出现一闪一闪不断显示，需要在此处进行判断
    if (menu.isMenuVisible || !self.menuItems)return;
    
    /*
     MenuItemTypeDel = 0,//删除
     MenuItemTypeLook = 1,//查看
     MenuItemTypeRecognition = 2,//识别
     MenuItemTypeMoveTo = 3,//移动到
     */
    
    NSMutableArray *menuItemObjS = [NSMutableArray new];
    for (NSNumber *type in self.menuItems) {
        
        if ([type intValue] == 0) {
            UIMenuItem * item = [[UIMenuItem alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] action:@selector(mydel:)];
            [menuItemObjS addObject:item];
        }else if([type intValue] == 1){
            UIMenuItem * item = [[UIMenuItem alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"DOOR_BELL_LOOK"] action:@selector(myLook)];
            [menuItemObjS addObject:item];
        }else if([type intValue] == 2){
            UIMenuItem * item = [[UIMenuItem alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_IDENTIFY"] action:@selector(myRecognize:)];
            [menuItemObjS addObject:item];
        }else if([type intValue] == 3){
            UIMenuItem * item = [[UIMenuItem alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_MOVE_BTN"] action:@selector(myMoveTo)];
            [menuItemObjS addObject:item];
        }
        
    }
    menu.menuItems = menuItemObjS;
    [menu setTargetRect:self.superview.bounds inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
    
}

-(void)myMoveTo
{
     [self meunItemActionForItemType:MenuItemTypeMoveTo];
}

-(void)myLook
{
    [self meunItemActionForItemType:MenuItemTypeLook];
}

- (void)myRecognize:(UIMenuController *)menu
{
    NSLog(@"识别");
    [self meunItemActionForItemType:MenuItemTypeRecognition];
}

-(void)mydel:(UIMenuController *)menu
{
    NSLog(@"删除");
    [self meunItemActionForItemType:MenuItemTypeDel];
}

-(void)meunItemActionForItemType:(MenuItemType)type
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
        return;
    }
    //复制文字到剪切板
    if (self.menuActionBlock) {
        self.menuActionBlock(type);
    }
}


-(BOOL)canBecomeFirstResponder
{
    return YES;
}


@end
