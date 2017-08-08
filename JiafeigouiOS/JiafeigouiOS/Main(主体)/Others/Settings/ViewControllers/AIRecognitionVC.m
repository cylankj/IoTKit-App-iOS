//
//  AIRecognitionVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/8/3.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "AIRecognitionVC.h"
#import "JfgGlobal.h"
#import "AICollectionCell.h"
#import "JfgUserDefaultKey.h"
#import "AIRecognitionVIewModel.h"

static NSString *const headerId = @"collViewHeaderID";
static NSString *const footerId = @"collViewFooterID";
static NSString *const cellId = @"collViewCellID";

#define btnHeight(w) 110.0*w/125.0
#define column  3


@interface AIRecognitionVC ()<UICollectionViewDelegate, UICollectionViewDataSource, tableViewDelegate>
{
    UICollectionViewFlowLayout *_customLayout;
}

@property (nonatomic, strong) UICollectionView *aiRecognitionCollection;
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, strong) AIRecognitionVIewModel *aiViewModel;

@end

@implementation AIRecognitionVC

- (void)viewDidLoad{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initView];
    [self initData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)initView
{
    [self initNavigation];
    [self.view addSubview:self.aiRecognitionCollection];
}

- (void)initNavigation
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SETTING_SECURE_AI"];
}

- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
    
    NSArray *changedAITypes = [self.aiViewModel aiRecgnitions];
    if (changedAITypes != nil)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(updateAIRecognition:)])
        {
            [_delegate updateAIRecognition:[self.aiViewModel aiRecgnitions]];
        }
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData
{
    [self.aiViewModel requestFromServer];
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:isShowSafeAIRedDot(self.cid)];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)updateData:(NSArray *)newArray
{
    JFG_WS(weakSelf);
    
    [self.dataArray removeAllObjects];
    [self.dataArray addObjectsFromArray:newArray];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [weakSelf.aiRecognitionCollection reloadData];
    });
}

#pragma mark fecth data
- (void)updatedDataArray:(NSArray *)updatedArray
{
    [self updateData:updatedArray];
}

- (void)fetchDataArray:(NSArray *)fetchArray
{
    [self updateData:fetchArray];
}

#pragma mark
#pragma mark collectionView datasource & delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return column;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataArray.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AICollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor whiteColor];
    
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];

    [cell.aiImageButton setBackgroundImage:[UIImage imageNamed:[dataInfo objectForKey:normalImageKey]] forState:UIControlStateNormal];
    [cell.aiImageButton setBackgroundImage:[UIImage imageNamed:[dataInfo objectForKey:selectedImageKey]] forState:UIControlStateSelected];
    
    cell.aiImageButton.selected = [[dataInfo objectForKey:isSelectedItemKey] boolValue];
    
    cell.aiLabel.text = [dataInfo objectForKey:titleKey];
    
    return cell;
}

#pragma mark 

#pragma mark ---- UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return (CGSize){(Kwidth-(column - 1))/column, static_cast<CGFloat>(btnHeight((Kwidth-(column))/column))};
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(1.0, 0.0, 1.0, -1.0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 2.f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return (CGSize){10.0, 20.0};
    }
    return (CGSize){0.0, 0.0};
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return (CGSize){0.0, 0.0};
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    [self.aiViewModel selectedItem:[[dataInfo objectForKey:aiTypeKey] integerValue]];
}

#pragma mark getter
- (UICollectionView *)aiRecognitionCollection
{
    if (_aiRecognitionCollection == nil)
    {
        _customLayout = [[UICollectionViewFlowLayout alloc] init];
        _customLayout.itemSize = self.view.frame.size;
        _customLayout.minimumLineSpacing = 0;
        _customLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _aiRecognitionCollection = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 64, Kwidth, kheight - 64) collectionViewLayout:_customLayout];
        _aiRecognitionCollection.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _aiRecognitionCollection.delegate = self;
        _aiRecognitionCollection.dataSource = self;
        
        // 注册cell、sectionHeader、sectionFooter
        [_aiRecognitionCollection registerClass:[AICollectionCell class] forCellWithReuseIdentifier:cellId];
        [_aiRecognitionCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:headerId];
        [_aiRecognitionCollection registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:footerId];
    }
    
    return _aiRecognitionCollection;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _dataArray;
}

- (AIRecognitionVIewModel *)aiViewModel
{
    if (_aiViewModel == nil)
    {
        _aiViewModel = [[AIRecognitionVIewModel alloc] init];
        _aiViewModel.delegate = self;
        _aiViewModel.cid = self.cid;
        _aiViewModel.pType = self.pType;
    }
    return _aiViewModel;
}

@end
