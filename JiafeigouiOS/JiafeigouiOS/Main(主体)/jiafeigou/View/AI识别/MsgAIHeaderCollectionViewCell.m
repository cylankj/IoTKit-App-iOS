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

@implementation MsgAIHeaderCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.headImageView.layer.masksToBounds = YES;
    self.headImageView.layer.cornerRadius = self.headImageView.bounds.size.width*0.5;
    self.headImageView.layer.borderColor = [UIColor colorWithHexString:@"#36bdff"].CGColor;
    self.headImageView.layer.borderWidth = 0;
    self.backgroundColor = [UIColor whiteColor];
    
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
        self.headImageView.layer.borderWidth = 2;
    }else{
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
    if (menu.isMenuVisible)return;
    //自定义 UIMenuController
    UIMenuItem * item1 = [[UIMenuItem alloc]initWithTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] action:@selector(mydel:)];
    NSString *item2Title = @"";
    if (self.menuItem2Type == MenuItemTypeLook) {
        //查看
        item2Title = [JfgLanguage getLanTextStrByKey:@"DOOR_BELL_LOOK"];
    }else if(self.menuItem2Type == MenuItemTypeMoveTo){
        //移动到
        item2Title = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_MOVE_BTN"];
    }else{
        //识别
        item2Title = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_IDENTIFY"];
    }
    UIMenuItem * item2 = [[UIMenuItem alloc]initWithTitle:item2Title action:@selector(myrecognize:)];
    
    if (self.menuItem2Type == MenuItemTypeNone) {
        //只显示删除
        menu.menuItems = @[item1];
    }else{
        menu.menuItems = @[item1,item2];
    }
    
    [menu setTargetRect:self.superview.bounds inView:self.superview];
    //  [menu setTargetRect:self.frame inView:self.superview];
    [menu setMenuVisible:YES animated:YES];
    
}

- (void)myrecognize:(UIMenuController *)menu
{
    NSLog(@"识别");
    //复制文字到剪切板
    //清空文字
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
        return;
    }
    
    if (self.menuActionBlock) {
        self.menuActionBlock(self.menuItem2Type);
    }
}

-(void)mydel:(UIMenuController *)menu
{
    NSLog(@"删除");
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
        return;
    }
    //复制文字到剪切板
    if (self.menuActionBlock) {
        self.menuActionBlock(MenuItemTypeDel);
    }
}


-(BOOL)canBecomeFirstResponder
{
    return YES;
}


@end
