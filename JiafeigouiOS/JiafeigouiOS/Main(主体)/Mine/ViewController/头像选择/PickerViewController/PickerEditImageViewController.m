//
//  PickerEditImageViewController.m
//  GestureRecognizerDemoi
//
//  Created by 杨利 on 16/8/2.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "PickerEditImageViewController.h"
#import "PickerShadeView.h"
#import "JfgLanguage.h"
//放大最大倍数
#define MaxZoonScale 5
#define SCREEN_SIZE [UIScreen mainScreen].bounds.size


@interface PickerEditImageViewController ()

@property (nonatomic, retain) UIImage *originalImage;

@property (nonatomic, retain) UIImageView *showImgView;
//遮罩frame
@property (nonatomic, assign) CGRect cropFrame;
//缩放最小尺寸
@property (nonatomic, assign) CGRect oldFrame;
//缩放最大尺寸
@property (nonatomic, assign) CGRect largeFrame;
//记录移动，缩放后的尺寸
@property (nonatomic, assign) CGRect latestFrame;

@end

@implementation PickerEditImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBarHidden = YES;
    [self initView];
    // Do any additional setup after loading the view.
}

- (void)initView
{
    
    CGFloat cropheight = 300;
    
    self.originalImage = self.image;
    CGFloat scale = self.originalImage.size.height/self.originalImage.size.width;
    
    //设置裁剪图像框框的大小
    self.cropFrame = CGRectMake(0, (SCREEN_SIZE.height-cropheight)*0.5, SCREEN_SIZE.width, cropheight);
    self.cropFrame = CGRectMake((SCREEN_SIZE.width-cropheight)*0.5, (SCREEN_SIZE.height-cropheight)*0.5, cropheight, cropheight);
    
    self.showImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    [self.showImgView setImage:self.originalImage];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setMultipleTouchEnabled:YES];
    
    
    // scale to fit the screen  截取面积
//    CGFloat oriWidth = self.cropFrame.size.width;
//    CGFloat oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
//    CGFloat oriX = self.cropFrame.origin.x;
//    CGFloat oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
//    
//    //图片frame
//    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    
    
    //图片最小尺寸
    CGRect leastFrame;
    CGFloat leastWidth = self.cropFrame.size.width;
    CGFloat leastHeight = leastWidth * scale;
    if (leastHeight < self.cropFrame.size.height) {
        
        leastHeight = self.cropFrame.size.height;
        leastWidth = leastHeight/scale;
    }
    CGFloat leastX = (self.view.bounds.size.width - leastWidth)*0.5;
    CGFloat leastY = (self.view.bounds.size.height - leastHeight)*0.5;
    leastFrame = CGRectMake(leastX, leastY, leastWidth, leastHeight);
    self.oldFrame = leastFrame;
    self.latestFrame = self.oldFrame;
    
    //开始图片显示大小
    CGFloat showWidth = self.view.bounds.size.width;
    
    CGFloat showHeight = showWidth*scale;
    
    if (showHeight < self.cropFrame.size.height) {
        
        showHeight = self.cropFrame.size.height;
        showWidth = showHeight/scale;
        
    }
    
    CGFloat showX = (self.view.bounds.size.width - showWidth)*0.5;
    CGFloat showY = (self.view.bounds.size.height - showHeight)*0.5;
    
    self.showImgView.frame = CGRectMake(showX, showY, showWidth, showHeight);
    
    //放大最大尺寸
    self.largeFrame = CGRectMake(0, 0, MaxZoonScale * self.oldFrame.size.width, MaxZoonScale * self.oldFrame.size.height);
    
    [self addGestureRecognizers];
    [self.view addSubview:self.showImgView];


    //遮罩视图
    PickerShadeView *shadeView = [[PickerShadeView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    shadeView.backgroundColor = [ UIColor clearColor];
    shadeView.userInteractionEnabled = YES;
    [self.view addSubview:shadeView];
    
    //下方两个按钮
    UIButton *quxiaoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quxiaoBtn.frame = CGRectMake(15, shadeView.bounds.size.height-25-25, 100, 30);
    [quxiaoBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
    quxiaoBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    quxiaoBtn.titleLabel.textAlignment = NSTextAlignmentLeft;
    [quxiaoBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quxiaoBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [shadeView addSubview:quxiaoBtn];
    
    UIButton *quedingBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    quedingBtn.frame = CGRectMake(shadeView.bounds.size.width-100-15, shadeView.bounds.size.height-25-25, 100, 30);
    
    [quedingBtn setTitle:[JfgLanguage getLanTextStrByKey:@"Tap3_Userinfo_UsePhoto"] forState:UIControlStateNormal];
    quedingBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    quedingBtn.titleLabel.textAlignment = NSTextAlignmentRight;
    [quedingBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [quedingBtn addTarget:self action:@selector(capture) forControlEvents:UIControlEventTouchUpInside];
    [shadeView addSubview:quedingBtn];
    
}

-(void)cancel
{
    
    if (self.sourceType == PickerEditImageSourceTypeCamera) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PickerEditAlwaysCancel" object:nil];
        [self dismissViewControllerAnimated:YES completion:nil];
    }else{
        if (self.navigationController) {
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"PickerEditAlwaysCancel" object:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    self.navigationController.navigationBarHidden = NO;
}

-(void)capture
{
    UIImage *image = [self getSubImage];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PickerEditFinisehImage" object:image];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)addGestureRecognizers
{
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
    
}

- (void)pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer
{
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
        
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.1 animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
        
    }
    else if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleScaleOverflow:newFrame];
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.1 animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

// pan gesture handler
- (void)panView:(UIPanGestureRecognizer *)panGestureRecognizer
{
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        // calculate accelerator
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        // bounce to original frame
        CGRect newFrame = self.showImgView.frame;
        newFrame = [self handleBorderOverflow:newFrame];
        [UIView animateWithDuration:0.3 animations:^{
            self.showImgView.frame = newFrame;
            self.latestFrame = newFrame;
        }];
    }
}

//大小处理
- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2, newFrame.origin.y + newFrame.size.height/2);
    
    if (newFrame.size.width < self.cropFrame.size.width) {
        newFrame = self.oldFrame;
        newFrame.size.width = self.oldFrame.size.width;
        
    }
    if (newFrame.size.width > self.largeFrame.size.width) {
        newFrame = self.largeFrame;
    }
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    return newFrame;
}

//超出遮罩框边界处理
- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // horizontally
    if (newFrame.origin.x > self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.size.width+self.cropFrame.origin.x) newFrame.origin.x = self.cropFrame.size.width + self.cropFrame.origin.x - newFrame.size.width;
    // vertically
    if (newFrame.origin.y > self.cropFrame.origin.y) newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.height && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    return newFrame;
}

-(UIImage *)getSubImage
{
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.height / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newW; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newW; h = newH;
    }
    CGRect myImageRect = CGRectMake(x, y, w, h);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = myImageRect.size.width;
    size.height = myImageRect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    return smallImage;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
