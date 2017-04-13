//
//  ExploreTableViewCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/5/31.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ExploreTableViewCell.h"
#import "FLGlobal.h"
#import "UIColor+HexColor.h"
#import <Masonry/Masonry.h>
#import "JfgLanguage.h"
@implementation ExploreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLineTimeLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    self.timeLineTimeLabel1.textColor = [UIColor colorWithHexString:@"#666666"];
    //删除
    [self.deleteButton setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
    [self.deleteButton1 setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
    self.deleteButton1.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.deleteButton1.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [_deleteButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [_deleteButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];//[UIColor colorWithHexString:@"#4b9fd5"]
    [_deleteButton1.titleLabel setFont:[UIFont systemFontOfSize:12]];
    
    [_deleteButton1 setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"] forState:UIControlStateNormal];
    [_deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        CGSize size =[_deleteButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName :[UIFont systemFontOfSize:12]}];
        CGFloat width =(int)size.width +1;
        make.size.mas_equalTo(CGSizeMake(width, 12));
    }];
    
    [_shareButton1 setTitleColor:[UIColor colorWithHexString:@"#909090"] forState:UIControlStateNormal];
    _shareButton1.titleLabel.font = [UIFont systemFontOfSize:12];
    [_shareButton1 setImage:[UIImage imageNamed:@"btn_share"] forState:UIControlStateNormal];
    
    [_shareButton setTitleColor:[UIColor colorWithHexString:@"#909090"] forState:UIControlStateNormal];
     _shareButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_shareButton setImage:[UIImage imageNamed:@"btn_share"] forState:UIControlStateNormal];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    // Configure the view for the selected state
}


@end

@implementation ExploreShareButton

-(CGRect)imageRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(0, (contentRect.size.height-14)*0.5, 14, 14);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect
{
    return CGRectMake(20, 0, contentRect.size.width-16, contentRect.size.height);
}

@end
