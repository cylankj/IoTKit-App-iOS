//
//  ExploreImageView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/7.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ExploreImageView.h"
#import "UIColor+HexColor.h"
#import "ExploreTableViewCell.h"
#import "ImageBrowser.h"
#import "Watch720PhotoVC.h"
#import "CommonMethod.h"

@implementation ExploreImageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(void)awakeFromNib{
    [super awakeFromNib];
    UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage)];
    [self addGestureRecognizer:tap];
}
-(instancetype)init{
    if (self = [super init]) {
//        self.layer.borderWidth = 0.5f;
//        self.layer.borderColor = [UIColor colorWithHexString:@"#f6f6f6"].CGColor;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)magnifyImage
{
    //每日精彩大图显示
    UIView* contentView = [self superview];
    NSMutableArray * arr = [NSMutableArray array];
    for (UIView * vi in contentView.subviews) {
        if ([vi isKindOfClass:[ExploreImageView class]]) {
            [arr addObject:vi];
        }
    }

    UIView *resultView = self;
    while (1) {
        resultView = resultView.superview;
        if (!resultView || [resultView isKindOfClass:[ExploreTableViewCell class]]) {
            break;
        }
    }
    if (!resultView) {
        return;
    }

    ExploreTableViewCell * cell = (ExploreTableViewCell *)resultView;
    
    int64_t timestamp = [cell.msgTime longLongValue];
    
    if (self.msgID == 606) {
        
        Watch720PhotoVC *vc = [Watch720PhotoVC new];
        vc.thumbNailImage = self.image;
        vc.titleTime = timestamp;
        vc.panoMediaType = mediaTypePhoto;
        //vc.panoMediaPath = self.imageUrl;
        vc.hidesBottomBarWhenPushed = YES;
        UIViewController *vct = [CommonMethod viewControllerForView:self];
        [vct.navigationController pushViewController:vc animated:YES];
        
    }else{
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        
        
        NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp];
        [formatter setDateFormat:@"yyyy"];
        NSInteger msgYear = [[formatter stringFromDate:msgDate] integerValue];
        NSInteger currentYear = [[formatter stringFromDate:[NSDate date]] integerValue];
        
        if (msgYear == currentYear) {
            [formatter setDateFormat:@"MM.dd-HH:mm"];
        }else{
            [formatter setDateFormat:@"yyyy.MM.dd-HH:mm"];
        }
        
        NSString *title = [formatter stringFromDate:msgDate];
        ImageBrowser * bro = [[ImageBrowser alloc]initWithImageView:arr Title:title currentImageIndex:0 isExpore:YES];
        //bro.cid = self.cid;
        bro.imagesUrl = [[NSMutableArray alloc]initWithObjects:self.imageUrl, nil];
        bro.imageNumber = (int)arr.count;
        bro._indexPath = cell._indexPath;
        [bro showCurrentImageViewIndex:0];//调用方法
    }
    
    
}

@end
