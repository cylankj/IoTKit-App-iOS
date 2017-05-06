//
//  DoorBellCell.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DoorBellCell.h"
#import "UIColor+HexColor.h"
#import <Masonry.h>

@implementation DoorBellCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.bell = [[BellView alloc]init];
        
        [self.contentView addSubview:self.bell];
        
        [self.bell mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 9, 0));
        }];
        self.bell.headerImageView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        [self.bell.headerImageView addGestureRecognizer:tap];
        
        [self setBackgroundColor:[UIColor clearColor]];
        self.contentView.backgroundColor = [UIColor clearColor];
        [self setTransform:CGAffineTransformMakeRotation(M_PI /2)];
        [self setSelectionStyle:UITableViewCellSelectionStyleNone];

    }
    return self;
}

-(void)tap:(UITapGestureRecognizer *)tap
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(doorBellCellTap:indexPath:)]) {
        [self.delegate doorBellCellTap:tap indexPath:self.indexPath];
    }
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
