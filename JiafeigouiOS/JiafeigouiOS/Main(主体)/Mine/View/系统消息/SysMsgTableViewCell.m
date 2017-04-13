//
//  SysMsgTableViewCell.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/9/21.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SysMsgTableViewCell.h"

@implementation SysWebView

@end

@interface SysMsgTableViewCell()

@end

@implementation SysMsgTableViewCell

+(CGSize)heightForRowWithString:(NSString *)string
{
    if (![string isKindOfClass:[NSString class]]) {
        return CGSizeMake(0, 0);
    }
    NSNumber *number = [[NSUserDefaults standardUserDefaults] objectForKey:SysViewWidth];
    CGFloat width = 0;
    if (!number) {
        width = [UIScreen mainScreen].bounds.size.width;
    }else{
        width = [[[NSUserDefaults standardUserDefaults] objectForKey:SysViewWidth] floatValue];
    }
    
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0f]};
    CGSize size = [string boundingRectWithSize:CGSizeMake(width-82-55, MAXFLOAT) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    
    
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
//    //set the line break mode
//    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
//    
//    NSDictionary *attrDict = [NSDictionary dictionaryWithObjectsAndKeys:
//                              [UIFont systemFontOfSize:15],
//                              NSFontAttributeName,
//                              paragraphStyle,
//                              NSParagraphStyleAttributeName,
//                              nil];
//    
//    
//    
//    //assume your maximumSize contains {250, MAXFLOAT}
//    CGRect lblRect = [string boundingRectWithSize:(CGSize){width-82-55, MAXFLOAT}
//                                              options:NSStringDrawingUsesLineFragmentOrigin
//                                           attributes:attrDict
//                                              context:nil];
    
    CGFloat rowHeight = 80+size.height+30;
    //NSLog(@"cellWidth:%@",NSStringFromCGRect(lblRect));
    return CGSizeMake(size.width, rowHeight);
}



- (void)awakeFromNib {
    
    [super awakeFromNib];
    
    CGFloat top = 20; // 顶端盖高度
    CGFloat bottom = 5 ; // 底端盖高度
    CGFloat left = 45; // 左端盖宽度
    CGFloat right = 30; // 右端盖宽度
    UIEdgeInsets insets = UIEdgeInsetsMake(top, left, bottom, right);
    UIImage *bgImage = [UIImage imageNamed:@"efamily_cellbg"];
    // 伸缩后重新赋值
    bgImage = [bgImage resizableImageWithCapInsets:insets];
    self.msgBgImageView.image = bgImage;
    self.editSelectedBtn.hidden = YES;
    
    self.msgLabel.numberOfLines = 0;
    self.msgWebView.hidden = YES;
    self.msgWebView.scrollView.scrollEnabled = NO;
    //self.msgLabel.adjustsFontSizeToFitWidth = YES;
    // Initialization code
}

-(void)setIsEditing:(BOOL)isEditing
{
    if (_isEditing == isEditing) {
        return;
    }
    self.iconImageView.hidden = isEditing;
    self.editSelectedBtn.hidden = !isEditing;
    _isEditing = isEditing;
}

-(void)setIsEditSelected:(BOOL)isEditSelected
{
    if (!self.isEditing) {
        return;
    }
    if (isEditSelected) {
        self.editSelectedBtn.image = [UIImage imageNamed:@"camera_icon_Selected"];
    }else{
        self.editSelectedBtn.image = [UIImage imageNamed:@"camera_icon_Select"];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
