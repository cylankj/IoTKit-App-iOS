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
#import "JfgLanguage.h"

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
    self.titleLabel.text = self.assetsGroup.groupName;
    [self cancelButton];
    [self.view addSubview:self.assetsCollectionView];
    [self getData];
    // Do any additional setup after loading the view.
}

-(void)cancelButton
{
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(self.view.bounds.size.width-35-15, 33, 35, 20);
    [cancelBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarBgView addSubview:cancelBtn];
}

-(void)cancel
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PickerEditAlwaysCancel" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)getData
{
    if (self.assetsGroup == nil) {
        
        LGPhotoPickerDatas *datas = [LGPhotoPickerDatas defaultPicker];
        [datas getAllGroupWithPhotos:^(NSArray *groups) {
            
            NSArray *arr  = [[groups reverseObjectEnumerator] allObjects];
            
            for (LGPhotoPickerGroup *group in arr) {
                
                if ([group.groupName isEqualToString:@"Camera Roll"] || [group.groupName isEqualToString:@"相机胶卷"]) {
                    
                    self.assetsGroup = group;
                    [self getAssets];
                }
                
            }
            
           
            
        }];
        
    }else{
        [self getAssets];
    }
    
}

-(void)getAssets
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
        _assetsCollectionView.bounces = YES;
        _assetsCollectionView.alwaysBounceVertical = YES;
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
