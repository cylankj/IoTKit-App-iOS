//
//  JFGBigImageView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 16/11/13.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "JFGBigImageView.h"
#import "UIAlertView+FLExtension.h"
#import "JFGAlbumManager.h"
#import "JfgLanguage.h"
#import "ProgressHUD.h"
#import "LSAlertView.h"

#define MaxScale 2.0
#define MinScale 1.0


@interface JFGBigImageView()<UIScrollViewDelegate>
{
    BOOL addLongPress;
    CGFloat currentScale;
}
@property (nonatomic,strong)UIImage *image;
@property (nonatomic,copy)NSString *imageUrl;
@property (nonatomic,strong)UIScrollView *bgScrollerView;
@property (nonatomic,strong)UIImageView *showImageView;
@property(strong, nonatomic)UIButton *exitBtn;
@property (nonatomic,strong)UIView *topView;

@end

@implementation JFGBigImageView

+(instancetype)initWithImage:(UIImage *)image
{
    JFGBigImageView *imageVi = [[JFGBigImageView alloc]init];
    imageVi.frame = [UIScreen mainScreen].bounds;
    imageVi.image = image;
    [imageVi intiView];
    return imageVi;
}

+(instancetype)initWithImage:(UIImage *)image showLongPress:(BOOL)show
{
    JFGBigImageView *imageVi = [[JFGBigImageView alloc]initWithLong:show];
    imageVi.frame = [UIScreen mainScreen].bounds;
    imageVi.image = image;
    [imageVi intiView];
    return imageVi;
}

+(instancetype)initWithImageUrl:(NSString *)imageUrl
{
    JFGBigImageView *imageVi = [[JFGBigImageView alloc]initWithLong:NO];
    imageVi.frame = [UIScreen mainScreen].bounds;
    imageVi.imageUrl = imageUrl;
    return imageVi;
}

-(instancetype)initWithLong:(BOOL)addLong
{
    self = [super init];
    addLongPress = addLong;
    return self;
}

-(void)intiView
{
    [self addSubview:self.bgScrollerView];
    [self.bgScrollerView addSubview:self.showImageView];
    CGRect frame = CGRectZero;
    
    frame.size.width = self.bgScrollerView.frame.size.width;
    frame.size.height =frame.size.width*(_image.size.height/_image.size.width);
    self.showImageView.frame = frame;
    self.showImageView.center=self.bgScrollerView.center;
    self.bgScrollerView.contentSize=self.showImageView.frame.size;
    
    [self addSubview:self.topView];
    [self.topView addSubview:self.exitBtn];
    
}

-(void)show
{
    self.alpha = 0;
    [[[UIApplication sharedApplication] keyWindow] addSubview:self];
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 1;
    }];
}

-(void)dismiss
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

-(UIButton *)exitBtn{
    if (!_exitBtn) {
        _exitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _exitBtn.frame = CGRectMake(14, 30, 30, 30);
        [_exitBtn setImage:[UIImage imageNamed:@"qr_backbutton_normal"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    }
    return _exitBtn;
}

-(void)doubletapImage:(UIGestureRecognizer *)doubleTap{
    
    UIScrollView *scroll =(UIScrollView *)doubleTap.view.superview;
    //当前为最大倍数,双击回复原装
    if(scroll.zoomScale == MaxScale){
        currentScale= MinScale;
        [scroll setZoomScale:currentScale animated:YES];
        return;
    }
    //当前是最小倍数,双击放大到最大倍数
    if(scroll.zoomScale == MinScale){
        currentScale = MaxScale;
        [scroll setZoomScale:currentScale animated:YES];
        return;
    }
    CGFloat aveScale = MinScale+(MaxScale-MinScale)/2;
    //当前倍数大于平均倍数
    if(scroll.zoomScale>=aveScale){
        currentScale = MaxScale;
        [scroll setZoomScale:currentScale animated:YES];
        return;
    }
    //当前倍数小于平均数
    if(scroll.zoomScale<aveScale){
        currentScale = MinScale;
        [scroll setZoomScale:currentScale animated:YES];
        return;
    }
}

//代理方法
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.showImageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView

{
    CGFloat xcenter = scrollView.center.x , ycenter = scrollView.center.y;
    
    //目前contentsize的width是否大于原scrollview的contentsize，如果大于，设置imageview中心x点为contentsize的一半，以固定imageview在该contentsize中心。如果不大于说明图像的宽还没有超出屏幕范围，可继续让中心x点为屏幕中点，此种情况确保图像在屏幕中心。
    xcenter = scrollView.contentSize.width > scrollView.frame.size.width ? scrollView.contentSize.width/2 : xcenter;
    ycenter = scrollView.contentSize.height > scrollView.frame.size.height ? scrollView.contentSize.height/2 : ycenter;
    [self.showImageView setCenter:CGPointMake(xcenter, ycenter)];
    
}


-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    
    currentScale = scale;
    
}

-(UIScrollView *)bgScrollerView
{
    if (!_bgScrollerView) {
        
        UIScrollView *bgView = [[UIScrollView alloc] init];
        bgView.frame = [UIScreen mainScreen].bounds;
        bgView.backgroundColor = [UIColor blackColor];
        bgView.maximumZoomScale = MaxScale;
        bgView.minimumZoomScale = MinScale;
        bgView.delegate = self;
        //隐藏滚动条
        bgView.showsVerticalScrollIndicator = NO;
        bgView.showsHorizontalScrollIndicator = NO;
        _bgScrollerView = bgView;
        
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
//        tap.numberOfTouchesRequired = 1;
//        [_bgScrollerView addGestureRecognizer:tap];
    }
    return _bgScrollerView;
}

-(UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 64)];
        _topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.30];;
        
    }
    return _topView;
}


-(UIImageView *)showImageView
{
    if (!_showImageView) {
        _showImageView = [[UIImageView alloc] initWithImage:self.image];
        [_showImageView setContentMode:UIViewContentModeScaleAspectFit];
        _showImageView.userInteractionEnabled = YES;
        if (addLongPress) {
            UILongPressGestureRecognizer * longPressGr = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressToDo:)];
            longPressGr.minimumPressDuration = 1.0;
            [_showImageView addGestureRecognizer:longPressGr];
        }
        UITapGestureRecognizer * doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubletapImage:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.numberOfTouchesRequired = 1;
        [_showImageView addGestureRecognizer:doubleTap];
    }
    return _showImageView;
}

-(void)longPressToDo:(UILongPressGestureRecognizer *)gesture
{
    if(gesture.state == UIGestureRecognizerStateBegan)
    {
        
        __weak typeof(self) weakSelf = self;
        [LSAlertView showAlertWithTitle:nil Message:[NSString stringWithFormat:@"%@?",[JfgLanguage getLanTextStrByKey:@"Tap3_SavePic"]] CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"WELL_OK"] CancelBlock:^{
            
        } OKBlock:^{
            
            [JFGAlbumManager jfgWriteImage:weakSelf.showImageView.image toPhotosAlbum:nil completionHandler:^(UIImage *image, NSError *error) {
                [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SAVED_PHOTOS"]];
            }];
            
        }];
        
    
    }
}

@end
