//
//  MessageImageView.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/20.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "MessageImageView.h"
#import "UIColor+HexColor.h"
#import "ImageBrowser.h"
#import "MessageViewCell.h"
#import "CommonMethod.h"
#import "MessageViewController.h"
#import "Watch720PhotoVC.h"
#import "jfgConfigManager.h"
#import "SDWebImageCacheHelper.h"

@interface MessageImageView()<watchPhotoDelegate>

@end

@implementation MessageImageView


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
-(instancetype)init{
    if (self = [super init]) {
        self.layer.borderWidth = 0.5f;
        self.layer.borderColor = [UIColor colorWithHexString:@"#f6f6f6"].CGColor;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFill;
        self.clipsToBounds = YES;
        UITapGestureRecognizer *tap  = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(magnifyImage)];
        [self addGestureRecognizer:tap];
    }
    return self;
}
- (void)drawRect:(CGRect)rect {
    // Drawing code


}
- (void)magnifyImage
{
    UIView* contentView = [self superview];
    NSMutableArray * arr = [NSMutableArray array];
    for (UIView * vi in contentView.subviews) {
        if ([vi isKindOfClass:[MessageImageView class]]) {
            [arr addObject:vi];
        }
    }
    
    NSInteger index = 0;
    for (MessageImageView * imageV in arr) {
        if (imageV == self) {
            break;
        }
        index++;
    }

    
    UIView *resultView = self;
    while (1) {
        resultView = resultView.superview;
        if (!resultView || [resultView isKindOfClass:[MessageViewCell class]]) {
            break;
        }
    }
    if (!resultView) {
        return;
    }
    
    MessageViewCell * cell = (MessageViewCell *)resultView;
    
     int64_t timestamp = cell.timestamp;
     NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
     
     
     NSDate *msgDate = [NSDate dateWithTimeIntervalSince1970:timestamp/1000];
     [formatter setDateFormat:@"yyyy"];
     NSInteger msgYear = [[formatter stringFromDate:msgDate] integerValue];
     NSInteger currentYear = [[formatter stringFromDate:[NSDate date]] integerValue];
     
     if (msgYear == currentYear) {
     [formatter setDateFormat:@"MM.dd-HH:mm"];
     }else{
     [formatter setDateFormat:@"yyyy.MM.dd-HH:mm"];
     }
     
     NSString *title = [formatter stringFromDate:msgDate];
    
    //
    
    BOOL is720Dev = NO;
    NSArray <NSArray <AddDevConfigModel *>*>* allType = [jfgConfigManager getAddDevModel];
    for (NSArray *subArr in allType) {
        for (AddDevConfigModel *_model in subArr) {
            if ([_model.typeMark intValue] == 2) {
                for (NSNumber *osNum in _model.osList) {
                    if ([osNum intValue] == [self.pid intValue]) {
                        is720Dev = YES;
                        break;
                    }
                }
            }
            if (is720Dev) {
                break;
            }
        }
        if (is720Dev) {
            break;
        }
    }
    if (is720Dev) {
        
        NSString *localPath = [SDWebImageCacheHelper sdwebImageLocalPathForUrl:self.url];
        Watch720PhotoVC *watchVC = [[Watch720PhotoVC alloc] init];
        watchVC.cid = self.cid;
        watchVC.pType = productType_720;
        watchVC.panoModel = nil;
        watchVC.myDelegate = self;
        watchVC.nickName = self.fileName;
        watchVC.panoMediaType = mediaTypePhoto;
        watchVC.existType = FileExistTypeLocal;
        watchVC.thumbNailImage = self.image;
        watchVC.titleTime = timestamp/1000;
        watchVC.originType = SourceTypeMSGPhoto;
        watchVC.panoMediaPath = localPath;
        MessageViewController * msgVC = (MessageViewController *)[CommonMethod viewControllerForView:self.superview];
        [msgVC.navigationController pushViewController:watchVC animated:YES];
        
    }else{
        ImageBrowser * bro;
        if (self.isPanorama) {
            bro = [[ImageBrowser alloc]initAllAnglePicViewWithImageView:arr Title:title tly:self.tly currentImageIndex:index cid:self.cid];
        }else{
            bro = [[ImageBrowser alloc]initWithImageView:arr Title:title currentImageIndex:index isExpore:NO];
        }
        bro.timestamp = timestamp;
        bro.imageNumber = (int)arr.count;
        bro.cid = self.cid;
        bro.fileName = self.fileName;
        bro.url = self.url;
        bro.regionType = self.regionType;
        bro.deviceVersion = self.deviceVersion;
        [bro showCurrentImageViewIndex:index];//调用方法
    }
}

- (void)deleteModelInLocal:(Pano720PhotoModel *)model;
{
    [[NSNotificationCenter defaultCenter] postNotificationName:MessageVDelegateDataNotificationKey object:self.selectedIndexPath];
}

@end
