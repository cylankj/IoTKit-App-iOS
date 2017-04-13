//
//  FLCycleAdView.m
//  CycleScrollView
//
//  Created by 紫贝壳 on 15/8/17.
//  Copyright (c) 2015年 FL. All rights reserved.
//

#import "FLCycleAdView.h"

#pragma mark FLCycleAdCollectionViewCell

@interface FLCycleAdCollectionViewCell : UICollectionViewCell
{
    UILabel *titleLable;
}

@property (nonatomic,copy)NSString *title;
@property (nonatomic,weak)UIImageView *imageView;

@end


@implementation FLCycleAdCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initSubView];
    }
    return self;
}

-(void)initSubView
{
    UIImageView *imageView = [[UIImageView alloc] init];
    _imageView = imageView;
    [self addSubview:imageView];
    
    titleLable = [[UILabel alloc] init];
    titleLable.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    titleLable.hidden = YES;
    titleLable.textColor = [UIColor whiteColor];
    titleLable.font = [UIFont systemFontOfSize:14];
    [self addSubview:titleLable];
}

-(void)setTitle:(NSString *)title
{
    if ([title isEqualToString:_title]) {
        return;
    }
    _title = [title copy];
    titleLable.text = [NSString stringWithFormat:@"   %@", title];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    _imageView.frame = self.bounds;
    
    CGFloat titleLabelW = self.bounds.size.width;
    CGFloat titleLabelH = 30;
    
    CGFloat titleLabelX = 0;
    CGFloat titleLabelY = self.bounds.size.height - titleLabelH;
    
    titleLable.frame = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
    titleLable.hidden = !titleLable.text;
}

@end


#pragma mark FLCycleAdView.m

NSString * const FLCycID = @"cycleCellID";

@interface FLCycleAdView()<UICollectionViewDataSource, UICollectionViewDelegate,UIScrollViewDelegate>
{
    UICollectionView *_collectionView; // 显示图片的collectionView
    UICollectionViewFlowLayout *flowLayout;//collectionView布局约束
    UIPageControl *_pageControl;
    NSTimer *timer;//定时器
    NSInteger totalItemsCount;//需要创建cell个数
}
@end


@implementation FLCycleAdView

-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initCollectionView];
    }
    return self;
}

+(instancetype)flCycleAdViewWithFrame:(CGRect)frame
                         imageList:(NSArray *)imageList
                         timeInterval:(NSTimeInterval)timeInterval
{
    FLCycleAdView *adView = [[FLCycleAdView alloc]initWithFrame:frame];
    adView.imagesList = imageList;
    adView.autoScrollerTimeInterval = timeInterval;
    [adView reloadData];
    return adView;
}

+(instancetype)flCycleAdViewWithFrame:(CGRect)frame
                         imageList:(NSArray *)imageList
                            titleList:(NSArray *)titleList
                         timeInterval:(NSTimeInterval)timeInterval
{
    FLCycleAdView *adView = [[FLCycleAdView alloc]initWithFrame:frame];
    adView.titlesList = titleList;
    adView.imagesList = imageList;
    adView.autoScrollerTimeInterval = timeInterval;
    [adView reloadData];
    return adView;
}

#pragma mark initSubView
-(void)initCollectionView
{
    flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = self.frame.size;
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    _collectionView.backgroundColor = [UIColor lightGrayColor];
    _collectionView.pagingEnabled = YES;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    [_collectionView registerClass:[FLCycleAdCollectionViewCell class] forCellWithReuseIdentifier:FLCycID];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    [self addSubview:_collectionView];

}

-(void)initTimer
{
    if (!timer || ![timer isValid]) {
        timer = [NSTimer scheduledTimerWithTimeInterval:_autoScrollerTimeInterval target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    }
}

-(void)updateTimer
{
    int currentIndex = _collectionView.contentOffset.x / flowLayout.itemSize.width;
    int nextIndex = currentIndex+1;
    
    if (nextIndex == totalItemsCount) {
        nextIndex = 2;
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:nextIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}

-(void)initPageView
{
    if (_pageControl) {
        [_pageControl removeFromSuperview];
        _pageControl = nil;
    }
    
    _pageControl = [[UIPageControl alloc] init];
    _pageControl.superview.backgroundColor = [UIColor redColor];
    _pageControl.numberOfPages = _imagesList.count;
    //默认是0
    _pageControl.currentPage = 0;
    //自动计算大小尺寸
    CGSize pageSize = [_pageControl sizeForNumberOfPages:_imagesList.count];
    CGFloat x = self.center.x-(pageSize.width/2.0)+5;
    if (_titlesList) {
        x = self.bounds.size.width - pageSize.width - 10;
    }
    
    _pageControl.frame = CGRectMake(x, self.frame.size.height - 15-(pageSize.height/2.0),pageSize.width,pageSize.height);
    
    _pageControl.pageIndicatorTintColor = [UIColor orangeColor];
    _pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    [_pageControl addTarget:self action:@selector(pageChange:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_pageControl];
}

-(void)pageChange:(UIPageControl *)page
{
    [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:page.currentPage+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
}


-(void)reloadData
{
    [_collectionView reloadData];
    if (_imagesList) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        [self initTimer];
        [self initPageView];
    }
}

#pragma mark setMeoth
-(void)setImagesList:(NSArray *)imagesList
{
    _imagesList = imagesList;
    totalItemsCount = imagesList.count+2;
}

-(void)setAutoScrollerTimeInterval:(NSInteger)autoScrollerTimeInterval
{
    _autoScrollerTimeInterval = autoScrollerTimeInterval;
    
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
    [self initTimer];
}

#pragma mark scrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //偏移量为零时
    if (scrollView.contentOffset.x < flowLayout.itemSize.width) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:_imagesList.count+1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    //偏移超过
    if (scrollView.contentOffset.x > flowLayout.itemSize.width * (_imagesList.count + 1)) {
        [_collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    }
    
    int pageCount = scrollView.contentOffset.x / flowLayout.itemSize.width;
    if (pageCount > _imagesList.count) {
        pageCount = 0;
    }else if (pageCount == 0){
        pageCount = (int)_imagesList.count - 1;
    }else{
        pageCount--;
    }
    if (_pageControl) {
        _pageControl.currentPage = pageCount;
    }
}


//停止减速
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self initTimer];
}


//开始拖拽
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([timer isValid]) {
        [timer invalidate];
        timer = nil;
    }
}


//停止拖拽
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        [self initTimer];
    }
}

#pragma mark collectionViewDelegate
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return totalItemsCount;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLCycleAdCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FLCycID forIndexPath:indexPath];
    
    int pageCount = indexPath.row;
    if (pageCount > _imagesList.count) {
        pageCount = 0;
    }else if (pageCount == 0){
        pageCount = (int)_imagesList.count - 1;
    }else{
        pageCount--;
    }
    cell.imageView.image = _imagesList[pageCount];
    
    if (_titlesList) {
        if (pageCount < _titlesList.count) {
            cell.title = _titlesList[pageCount];
        }
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    int pageCount = indexPath.row;
    if (pageCount > _imagesList.count) {
        pageCount = 0;
    }else if (pageCount == 0){
        pageCount = (int)_imagesList.count - 1;
    }else{
        pageCount--;
    }
    
    
    //代理回调
    if (_delegate && [_delegate respondsToSelector:@selector(flCycAdView:didSelectItemAtIndex:)]) {
        
        [_delegate flCycAdView:self didSelectItemAtIndex:pageCount];
        
    }
    
    //block回调
    if (_tapItemBlock) {
        _tapItemBlock(pageCount);
    }
    
}


@end




