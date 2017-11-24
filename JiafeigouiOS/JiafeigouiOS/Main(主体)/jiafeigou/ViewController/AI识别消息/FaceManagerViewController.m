//
//  FaceManagerViewController.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "FaceManagerViewController.h"
#import "FaceManagerCell.h"
#import "FaceAddressBookVC.h"
#import "UIImageView+JFGImageView.h"
#import "AIRobotRequest.h"
#import "UIAlertView+FLExtension.h"
#import "MsgForAIRequest.h"
#import "ProgressHUD.h"
#import "LoginManager.h"

@interface FaceManagerViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,MsgAIHeaderCollectionViewCellDelegate,MsgForAIRequestDelegate>
{
    BOOL isEditing;//是否正在编辑中
    BOOL isSelectedAll;
    MsgForAIRequest *msgReq;
}
@property (nonatomic,strong)UICollectionView *contentCollectionView;
@property (nonatomic,strong)UIButton *editBtn;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIView *noDataView;
@property (nonatomic,strong)UIView *bottomView;
@property (nonatomic,strong)UIButton *selectedAll;
@property (nonatomic,strong)UIButton *delBtn;

@end

@implementation FaceManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    msgReq = [MsgForAIRequest new];
    msgReq.delegate = self;
    
    for (StrangerModel *mod in self.msgModel.faceMsgList) {
        
        FaceManagerDataModel *model = [FaceManagerDataModel new];
        model.isSelected = NO;
        model.faceImageUrl = mod.faceImageUrl;
        model.face_id = mod.face_id;
        [self.dataArray addObject:model];
        
    }
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_MABAGE"];
    self.noDataView.hidden = YES;
    [self.view addSubview:self.contentCollectionView];
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.bottomView];
    [self.bottomView addSubview:self.selectedAll];
    [self.bottomView addSubview:self.delBtn];
    [self.topBarBgView addSubview:self.editBtn];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [msgReq addJfgDelegate];
    [msgReq reqFaceIDListForPerson:self.msgModel.person_id cid:self.cid];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [msgReq removeJfgDelegate];
}

-(void)msgForAIFaceList:(NSArray<StrangerModel *> *)faceList cid:(NSString *)cid person_id:(NSString *)person_id
{
    if ([cid isEqualToString:self.cid]) {
        [self.dataArray removeAllObjects];
        for (StrangerModel *mod in faceList) {
            
            FaceManagerDataModel *model = [FaceManagerDataModel new];
            model.isSelected = NO;
            model.faceImageUrl = mod.faceImageUrl;
            model.face_id = mod.face_id;
            [self.dataArray addObject:model];
            
        }

        self.msgModel.faceMsgList = [[NSMutableArray alloc]initWithArray:faceList];
        [self.contentCollectionView reloadData];
        
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.dataArray.count) {
        self.noDataView.hidden = YES;
        self.editBtn.hidden = NO;
    }else{
        self.noDataView.hidden = NO;
        self.editBtn.hidden = YES;
    }
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FaceManagerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FaceManagerCellIdentifier" forIndexPath:indexPath];
    cell.headerImageView.image = [UIImage imageNamed:@"test1"];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.headerImageView.menuItem2Type = MenuItemTypeMoveTo;
    FaceManagerDataModel *model = [self.dataArray objectAtIndex:indexPath.row];
    [cell.headerImageView jfg_setImageWithURL:[NSURL URLWithString:model.faceImageUrl] placeholderImage:[UIImage imageNamed:@"news_head128"]];
    if (isEditing) {
        cell.headerImageView.canShowMenuView = NO;
        cell.editImageView.hidden = NO;
        cell.isSelected = model.isSelected;
    }else{
        cell.headerImageView.canShowMenuView = YES;
        cell.editImageView.hidden = YES;
    }
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (isEditing) {
        
        FaceManagerDataModel *model = [self.dataArray objectAtIndex:indexPath.row];
        model.isSelected = !model.isSelected;
        FaceManagerCell *cell = (FaceManagerCell *)[collectionView cellForItemAtIndexPath:indexPath];
        if ([cell isKindOfClass:[FaceManagerCell class]]) {
            cell.isSelected = model.isSelected;
        }
        BOOL isHasSelected = NO;
        for (FaceManagerDataModel *model in self.dataArray) {
            
            if (model.isSelected) {
                isHasSelected = YES;
            }
            
        }
        self.delBtn.enabled = isHasSelected;
        
    }
}

-(void)collectionViewCell:(UICollectionViewCell *)cell menuItemType:(MenuItemType)itemType indexPath:(NSIndexPath *)indexPath
{
    FaceManagerDataModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (itemType == MenuItemTypeMoveTo) {
        
        FaceAddressBookVC *facebook = [FaceAddressBookVC new];
        facebook.cid = self.cid;
        facebook.face_id = model.face_id;
        facebook.person_id = self.msgModel.person_id;
        facebook.selectedIndexPath = indexPath;
        facebook.vcType = FaceAddressBookVCTypeMoveTo;
        [self presentViewController:facebook animated:YES completion:nil];
        
    }else if(itemType == MenuItemTypeDel){
        
        __weak typeof(self) weakSelf = self;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"MESSAGES_DELETE_FCAE_POP"] delegate:nil cancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"OK"], nil];
        
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            FaceManagerDataModel *model = [weakSelf.dataArray objectAtIndex:indexPath.row];
            if (buttonIndex == 1) {
                
                [AIRobotRequest robotDelFaceIDList:@[model.face_id] person_id:weakSelf.msgModel.person_id cid:weakSelf.cid sucess:^(id responseObject) {
                    
                } failure:^(NSError *error) {
                    
                }];
                [weakSelf.dataArray removeObject:model];
                [weakSelf.contentCollectionView reloadData];
                
            }
            
        } otherDelegate:nil];
        
       
        
    }
}

-(void)editAction:(UIButton *)btn
{
    btn.selected = !btn.selected;
    if (btn.selected) {
        //编辑状态
        isEditing = YES;
        self.bottomView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomView.bottom = self.view.height;
        }];
        self.contentCollectionView.height = self.view.height-64-50;
        [self.contentCollectionView reloadData];
        
    }else{
        //一般状态
        isEditing = NO;
        for (FaceManagerDataModel *model in self.dataArray) {
            model.isSelected = NO;
        }
        [UIView animateWithDuration:0.3 animations:^{
            self.bottomView.top = self.view.height;
        } completion:^(BOOL finished) {
            self.bottomView.hidden = YES;
        }];
        self.delBtn.enabled = NO;
        self.contentCollectionView.height = self.view.height-64;
        [self.contentCollectionView reloadData];
    }
}

-(void)selectedAll:(UIButton *)sender
{
    sender.selected = !sender.selected;
    isSelectedAll = sender.selected;
    self.delBtn.enabled = isSelectedAll;
    for (FaceManagerDataModel *model in self.dataArray) {
        model.isSelected = sender.selected;
    }
    [self.contentCollectionView reloadData];
}

-(void)delAction:(UIButton *)sender
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
        return;
    }
    NSMutableArray *delArr = [NSMutableArray new];
    for (FaceManagerDataModel *model in [self.dataArray copy]) {
        if (model.isSelected) {
            [delArr addObject:model.face_id];
        }
    }
    __weak typeof(self) weakSelf = self;
    [AIRobotRequest robotDelFaceIDList:delArr person_id:self.msgModel.person_id cid:self.cid sucess:^(id responseObject) {
        
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            
            NSDictionary *dic = responseObject;
            int ret = [dic[@"ret"] intValue];
            if (ret == 0) {
                
                for (FaceManagerDataModel *model in [weakSelf.dataArray copy]) {
                    if (model.isSelected) {
                        //            [self.dataArray removeObject:model];
                        [delArr addObject:model.face_id];
                    }
                }
                [weakSelf.contentCollectionView reloadData];
                [msgReq reqFaceIDListForPerson:self.msgModel.person_id cid:self.cid];
                return ;
            }
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tips_DeleteFail"]];
        }
        
    } failure:^(NSError *error) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Tips_DeleteFail"]];
    }];
    
    isSelectedAll = NO;
    self.selectedAll.selected = NO;
    [self editAction:self.editBtn];
    
}

-(UICollectionView *)contentCollectionView
{
    if (!_contentCollectionView) {
        UICollectionViewFlowLayout *flowLayout= [[UICollectionViewFlowLayout alloc]init];
        flowLayout.minimumLineSpacing = 3;//左右距离
        flowLayout.minimumInteritemSpacing = 3;
        flowLayout.itemSize = CGSizeMake((self.view.width-15)/4, (self.view.width-15)/4);
        flowLayout.sectionInset = UIEdgeInsetsMake(3, 3, 3, 3);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _contentCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) collectionViewLayout:flowLayout];
        [_contentCollectionView registerNib:[UINib nibWithNibName:@"FaceManagerCell" bundle:nil] forCellWithReuseIdentifier:@"FaceManagerCellIdentifier"];
        _contentCollectionView.delegate = self;
        _contentCollectionView.dataSource = self;
        _contentCollectionView.backgroundColor = [UIColor whiteColor];
        _contentCollectionView.showsHorizontalScrollIndicator = NO;
    }
    return _contentCollectionView;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

-(UIButton *)editBtn
{
    if (!_editBtn) {
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.frame = CGRectMake(0, 32, 60, 20);
        _editBtn.right = self.view.width;
        [_editBtn setTitle:[JfgLanguage getLanTextStrByKey:@"EDIT_THEME"] forState:UIControlStateNormal];
        [_editBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
        [_editBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        _editBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _editBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_editBtn addTarget:self action:@selector(editAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _editBtn;
}

-(UIView *)noDataView
{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 140, 140+40)];
        _noDataView.x = self.view.width*0.5;
        _noDataView.y = (self.view.height-64)*0.5+64*0.5;
        UIImageView *imagev = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 140, 140)];
        imagev.image = [UIImage imageNamed:@"png_no-share"];
        [_noDataView addSubview:imagev];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 160, 140, 20)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        label.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_NONE"];
        label.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:label];
    }
    return _noDataView;
}

-(UIView *)bottomView
{
    if (!_bottomView) {
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.height, self.view.width, 50)];
        _bottomView.backgroundColor = [UIColor colorWithHexString:@"#f7f8fa"];
        UIView *lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 0.5)];
        lineView.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
        [_bottomView addSubview:lineView];
    }
    return _bottomView;
}

-(UIButton *)selectedAll
{
    if (!_selectedAll) {
        _selectedAll = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectedAll.frame = CGRectMake(30, 14, 50, 21);
        _selectedAll.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_selectedAll setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
        _selectedAll.titleLabel.font = [UIFont systemFontOfSize:15];
        [_selectedAll setTitle:[JfgLanguage getLanTextStrByKey:@"SELECT_ALL"] forState:UIControlStateNormal];
        [_selectedAll setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateSelected];
        _selectedAll.titleLabel.textAlignment = NSTextAlignmentLeft;
        [_selectedAll addTarget:self action:@selector(selectedAll:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectedAll;
}

-(UIButton *)delBtn
{
    if (!_delBtn) {
        _delBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _delBtn.frame = CGRectMake(130, 14, 50, 21);
        _delBtn.right = self.view.width - 30;
        _delBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_delBtn setTitleColor:[UIColor colorWithHexString:@"#4B9FD5"] forState:UIControlStateNormal];
        [_delBtn setTitleColor:[[UIColor colorWithHexString:@"#4B9FD5"] colorWithAlphaComponent:0.5] forState:UIControlStateDisabled];
        _delBtn.enabled = NO;
        _delBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_delBtn setTitle:[JfgLanguage getLanTextStrByKey:@"DELETE"] forState:UIControlStateNormal];
        [_delBtn addTarget:self action:@selector(delAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _delBtn;
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

@implementation FaceManagerDataModel

@end
