//
//  ImageBrowser.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/6/23.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageBrowser : UIView<UIScrollViewDelegate>
{
    CGFloat currentScale;
}
@property(nonatomic, copy)NSString * cid;

@property(nonatomic, copy)NSString * url;

@property (nonatomic,copy)NSString *fileName;

@property (nonatomic,assign)uint64_t timestamp;

@property (nonatomic,assign)int regionType;

@property (nonatomic,assign)int deviceVersion;
//标题
@property(nonatomic, strong)UILabel * titleLabel;

@property (nonatomic,strong)NSIndexPath *_indexPath;

@property (nonatomic,strong)NSMutableArray *imagesUrl;

//点击的Cell一共有多少张图
@property(assign, nonatomic)int imageNumber;

//传过来的所有图片(点击一张图,当前Cell上的所有图,最大3,最小1)
@property(strong, nonatomic)NSMutableArray * oldImageViews;

/**
 *  初始化查看大图的视图
 *
 *  @param oldImageViews 图片的数组
 *  @param title         当前的标题
 *  @param index         当前点击的图片的index(0,....)
 *
 *  @return nil
 */
-(instancetype)initWithImageView:(NSArray<UIImageView *> *)oldImageViews Title:(NSString *)title currentImageIndex:(NSInteger)index isExpore:(BOOL)isExpore;


-(instancetype)initAllAnglePicViewWithImageView:(NSArray<UIImageView *> *)oldImageViews Title:(NSString *)title tly:(int)tly currentImageIndex:(NSInteger)index;

/**
 *  动态放大显示点击的图片
 *
 *  @param curImageViewIndex 当前点击的图片的index
 */
-(void)showCurrentImageViewIndex:(NSInteger)curImageViewIndex;

@end
