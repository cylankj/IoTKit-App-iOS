//
//  JFGDatePickerCollectionViewCell.m
//  Demo
//
//  Created by 杨利 on 2017/1/18.
//  Copyright © 2017年 yangli. All rights reserved.
//

#import "JFGDatePickerCollectionViewCell.h"
#import "UIColor+FLExtension.h"

@implementation JFGDatePickerCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
    self.contentLabel.layer.masksToBounds = YES;
    self.contentLabel.layer.cornerRadius = self.contentLabel.bounds.size.width*0.5;
    
    // Initialization code
}

-(void)setViewMode:(pickerViewMode)viewMode
{
    switch (viewMode) {
        case pickerViewModeNotData:{
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.textColor = [UIColor colorWithHexString:@"#cecece"];
        }
            break;
        case pickerViewModeHasData:{
            _contentLabel.backgroundColor = [UIColor clearColor];
            _contentLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        }
            break;
        case pickerViewModeSelected:{
            [UIView animateWithDuration:0.5 animations:^{
                _contentLabel.backgroundColor = [UIColor colorWithHexString:@"#73a0ce"];
                _contentLabel.textColor = [UIColor whiteColor];
            }];
            
        }
            break;
        default:
            break;
    }
}

@end
