//
//  PickerAssetsViewController.m
//  PhotoPickerDemo
//
//  Created by 杨利 on 16/7/30.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "PickerAssetsViewController.h"
#import "AsseetsCollectionViewCell.h"
#import "LGPhotoPickerDatas.h"
#import "LGPhotoAssets.h"
#import "PickerEditImageViewController.h"


static NSString *assetCellID = @"asstecellid";

@interface PickerAssetsViewController ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong)UICollectionView *assetsCollectionView;
@property (nonatomic,strong)NSMutableArray *dataArray;

@end

@implementation PickerAssetsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self.view addSubview:self.assetsCollectionView];
    [self getData];
    // Do any additional setup after loading the view.
}

-(void)getData
{
    LGPhotoPickerDatas *datas = [LGPhotoPickerDatas defaultPicker];
    [datas getGroupPhotosWithGroup:self.assetsGroup finished:^(NSArray *assets) {
        
        NSMutableArray *assetsM = [NSMutableArray new];
        [assets enumerateObjectsUsingBlock:^(ALAsset *asset, NSUInteger idx, BOOL *stop) {
            LGPhotoAssets *lgAsset = [[LGPhotoAssets alloc] init];
            lgAsset.asset = asset;
            [assetsM addObject:lgAsset];
        }];
        self.dataArray = [[NSMutableArray alloc]initWithArray:assetsM];
        [self.assetsCollectionView reloadData];
        
    }];
}

-(UICollectionView *)assetsCollectionView
{
    if (!_assetsCollectionView) {
        
        CGFloat itemWidth = [UIScreen mainScreen].bounds.size.width*0.25-2;
        CGFloat itemHeight = itemWidth;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 2;
        flowLayout.minimumInteritemSpacing = 2;
        [flowLayout setItemSize:CGSizeMake(itemWidth, itemHeight)];//设置cell的尺寸
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];//设置其布局方向
        //flowLayout.sectionInset = UIEdgeInsetsMake(2, 0, 2, 0);//设置其边界
        
        _assetsCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height-64) collectionViewLayout:flowLayout];
        _assetsCollectionView.pagingEnabled = NO;
        _assetsCollectionView.backgroundColor = [UIColor clearColor];
        [_assetsCollectionView registerClass:[AsseetsCollectionViewCell class] forCellWithReuseIdentifier:assetCellID];
        _assetsCollectionView.delegate = self;
        _assetsCollectionView.dataSource = self;
        
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
//        [_assetsCollectionView addGestureRecognizer:tap];
       // [self.view addSubview:_assetsCollectionView];
        
        
        
    }
    return _assetsCollectionView;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AsseetsCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:assetCellID forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    LGPhotoAssets *lgAsset = [_dataArray objectAtIndex:indexPath.row];
    cell.imageView.image = [lgAsset thumbImage];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    LGPhotoAssets *lgAsset = [_dataArray objectAtIndex:indexPath.row];
    PickerEditImageViewController *clip = [PickerEditImageViewController new];
    clip.image = lgAsset.originImage;
    [self.navigationController pushViewController:clip animated:YES];
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
