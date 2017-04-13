//
//  CardViewController.m
//  卡片动画
//
//  Created by 杨利 on 16/8/24.
//  Copyright © 2016年 KuBao. All rights reserved.
//

#import "CardViewController.h"
#import <POP.h>
#import "SMPageControl.h"
#import "LoginLoadingViewController.h"
#import "JfgLanguage.h"
#import "LoginManager.h"
#import "AppDelegate.h"

@interface CardViewController ()
{
    UIImageView *bgImageView;
    
    SMPageControl *SMpage;
}
@property (nonatomic,strong)NSMutableArray *imageViews;
@end

@implementation CardViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    [self backImageView];
    [self createImageViews];
    
}

-(void)initPageControlTop:(CGFloat)top
{
    if (top+15>self.view.bounds.size.height) {
        top = self.view.bounds.size.height-15;
    }
    SMpage = [[SMPageControl alloc]initWithFrame:CGRectMake(0, top, self.view.bounds.size.width, 10)];
    SMpage.alignment = SMPageControlAlignmentCenter;
    SMpage.numberOfPages = 3;
    SMpage.indicatorMargin = 17.0f;//间距
    SMpage.hidesForSinglePage = YES;
    SMpage.indicatorDiameter = 10.0f;//直径
    SMpage.userInteractionEnabled = NO;//禁止点击
    SMpage.pageIndicatorImage = [UIImage imageNamed:@"point"];
    SMpage.currentPageIndicatorImage = [UIImage imageNamed:@"point2"];
    [self.view addSubview:SMpage];
}

-(void)backImageView
{
//    CGSize viewSize =self.view.bounds.size;
//    NSString*viewOrientation =@"Portrait";//横屏请设置成 @"Landscape"
//    NSString*launchImage =nil;
//    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
//    for(NSDictionary* dictinimagesDict in imagesDict) {
//        CGSize imageSize =CGSizeFromString(dictinimagesDict[@"UILaunchImageSize"]);
//        if(CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dictinimagesDict[@"UILaunchImageOrientation"]]) {
//            launchImage = dictinimagesDict[@"UILaunchImageName"];
//        }
//    }
    
    bgImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    bgImageView.image = [UIImage imageNamed:@"guideLoad"];
    bgImageView.userInteractionEnabled = YES;
    [self.view addSubview:bgImageView];
}

-(void)createImageViews
{
    self.imageViews = [[NSMutableArray alloc]init];
    CGFloat bottom = 0.0;
    
    if ([JfgLanguage languageType] == 0) {
        for (int i=1; i<4; i++) {
            
            UIImageView *imageView = [self createOneImageView:i];
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide-pages%d",i]];
            imageView.tag = i+100;
            [self.view insertSubview:imageView atIndex:0];
            [self.imageViews addObject:imageView];
            bottom = CGRectGetMaxY(imageView.frame);
        }
    }else{
        for (int i=1; i<4; i++) {
            
            UIImageView *imageView = [self createOneImageView:i];
            imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"guide-pages%d_eg",i]];
            imageView.tag = i+100;
            [self.view insertSubview:imageView atIndex:0];
            [self.imageViews addObject:imageView];
            bottom = CGRectGetMaxY(imageView.frame);
        }
    }
    
    
    [self initPageControlTop:bottom+15];
    [self.view insertSubview:bgImageView atIndex:0];
    
}


-(UIImageView *)createOneImageView:(NSInteger)index
{
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    
    UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"guide-pages%ld",(long)index]];
    
    CGFloat scale = image.size.height/image.size.width;
    CGFloat imageViewWidth = self.view.bounds.size.width*0.85;
    CGFloat imageViewHeight = imageViewWidth*scale;
    
    imageView.frame = CGRectMake(0, 0, imageViewWidth , imageViewHeight);
    imageView.center = self.view.center;
    imageView.layer.cornerRadius = 10;
    imageView.layer.masksToBounds = true;
    
    CGPoint targetCenter = CGPointMake(CGRectGetWidth(self.view.bounds)/2+index*4-8, CGRectGetHeight(self.view.bounds)/2-index*4);
    imageView.center = targetCenter;
    //[self setImageViewCenter:imageView index:index];
    
    UIPanGestureRecognizer *pan =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panPanGesture:)];
    [imageView addGestureRecognizer:pan];
    imageView.userInteractionEnabled = YES;
    return imageView;
}

-(void)setImageViewCenter:(UIImageView *)imageView index:(NSInteger)index
{
    CGPoint targetCenter = CGPointMake(CGRectGetWidth(self.view.bounds)/2+index*4-8, CGRectGetHeight(self.view.bounds)/2-index*4);
    [self setCenter:targetCenter Duration:0.25 Card:imageView];
}

-(void)setCenter:(CGPoint)center Duration:(CGFloat)duration Card:(UIImageView *)card
{
    POPBasicAnimation * bAni = [POPBasicAnimation animationWithPropertyNamed:kPOPViewCenter];
    bAni.toValue = [NSValue valueWithCGPoint:center];
    bAni.duration = duration;
    [bAni setCompletionBlock:^(POPAnimation *ani, BOOL is) {
        if (is) {
            card.hidden = NO;
        }
    }];
    [card pop_addAnimation:bAni forKey:@"center"];
}

-(void)setRorationWithAngle:(CGFloat)angele Duration:(CGFloat)duration Card:(UIImageView *)card
{
    POPBasicAnimation * bAni = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    bAni.duration = duration;
    bAni.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    bAni.toValue = [NSNumber numberWithFloat:angele];
    [card.layer pop_addAnimation:bAni forKey:@"213"];
}

-(void)cardReCenterOrDismiss:(BOOL)isDismiss Card:(UIImageView *)card{
    if (isDismiss) {
        
        if (card.center.x<CGRectGetWidth(self.view.bounds)/2) {
            
            [self setCenter:CGPointMake(-card.bounds.size.width-50, card.center.y) Duration:0.5 Card:card];
            
        }else{
            
            [self setCenter:CGPointMake(CGRectGetWidth(self.view.bounds)+card.bounds.size.width+50,card.center.y) Duration:0.5f Card:card];
        }
        [self performSelector:@selector(cardRemove:) withObject:card afterDelay:0.5];
        
    }else{
        
        [self setRorationWithAngle:0 Duration:0.25 Card:card];
        [self setImageViewCenter:card index:card.tag-100];
        
    }
    
}

-(void)cardRemove:(UIImageView *)imageview
{
    if (imageview) {
        
        if (imageview.tag == 3+100) {
            [self gotoLoginLoadingView];
        }
        
        [imageview removeFromSuperview];
        [self.imageViews removeObject:imageview];
        SMpage.currentPage = imageview.tag-100;
        
       
    }
}

-(void)panPanGesture:(UIPanGestureRecognizer *)pan
{
    UIImageView * card = (UIImageView *)pan.view;
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint transLcation = [pan translationInView:self.view];
        card.center = CGPointMake(card.center.x+transLcation.x, card.center.y+transLcation.y);
        CGFloat XOffPercent = (card.center.x-CGRectGetWidth(self.view.bounds)/2)/(CGRectGetWidth(self.view.bounds)/2);
        CGFloat rotation = M_PI_2/4*XOffPercent;
        [self setRorationWithAngle:rotation Duration:0.001f Card:card];
        [pan setTranslation:CGPointZero inView:self.view];
        
    }else if (pan.state == UIGestureRecognizerStateEnded){
        
        if (card.center.x>60&&card.center.x<CGRectGetWidth(self.view.bounds)-60){
            [self cardReCenterOrDismiss:NO Card:card];
        }else{
            [self cardReCenterOrDismiss:YES Card:card];
        }
        
    }
}

-(void)gotoLoginLoadingView
{
    if ([LoginManager sharedManager].currentLoginedAcount && ![[LoginManager sharedManager] isExited])
    {
        //已经登录过,跳转到加菲狗主页
        [[LoginManager sharedManager] loginForLastTimeAccount];
        AppDelegate * delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [delegate goToJFGViewContrller];
        
    }
    else
    {
        //未登录,跳转到欢迎页
//        LoginLoadingViewController *lo = [LoginLoadingViewController new];
//        UINavigationController * nav = [[UINavigationController alloc]initWithRootViewController:lo];
//        self.window.rootViewController = nav;
        LoginLoadingViewController *login = [LoginLoadingViewController new];
        login.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        //login.modalPresentationStyle = UIModalPresentationPageSheet;
        [self presentViewController:login animated:YES completion:nil];
    }
    
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
