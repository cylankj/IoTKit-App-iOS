//
//  MsgAIHeadPortraitView.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "MsgAIHeadPortraitView.h"
#import "MsgAIHeaderCollectionViewCell.h"
#import "UIColor+HexColor.h"
#import "UIView+FLExtensionForFrame.h"
#import "CommonMethod.h"
#import "FaceMsgViewController.h"
#import "DDCollectionViewHorizontalLayout.h"
#import "FaceCreateViewController.h"
#import "FaceAddressBookVC.h"
#import "UIAlertView+FLExtension.h"
#import "JfgTimeFormat.h"
#import "OemManager.h"
#import "LoginManager.h"
#import "SDWebImageCacheHelper.h"
#import "UIImageView+JFGImageView.h"
#import "AIRobotRequest.h"
#import "ProgressHUD.h"
#import "JfgCacheManager.h"
#import "LoginManager.h"
#import "FLLog.h"

#define collectionViewHeight 200
#define collectionViewCellHeight 90
#define selfHeight 255

@interface MsgAIHeadPortraitView()<UICollectionViewDelegate,UICollectionViewDataSource,MsgAIHeaderCollectionViewCellDelegate,UIAlertViewDelegate,MsgForAIRequestDelegate,FaceAddressBookVCDelegate,FaceCreateVCDelegate>
{
    NSIndexPath *cellSelectedIndexPath;
    NSInteger familiyCount;
    NSInteger strangerCount;
    BOOL familyIsDoubleLine;
    BOOL msrIsDoubleLine;
    BOOL hasNewMsg;
}
@property (nonatomic,strong)UICollectionView *headCollectionView;
@property (nonatomic,strong)MsgForAIRequest *msgRequest;
@property (nonatomic,strong)UILabel *pageLabel;//页数记录
@property (nonatomic,strong)UILabel *visitCountLabel;//访问次数
@property (nonatomic,strong)NSMutableArray *familyArray;//熟人
@property (nonatomic,strong)NSMutableArray *unKnowArray;//陌生人
@property (nonatomic,strong)NSMutableArray *dataArray;//总体展示用

@end

@implementation MsgAIHeadPortraitView


-(instancetype)initWithFrame:(CGRect)frame cid:(NSString *)cid
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, selfHeight)];
    self.clipsToBounds = YES;
    self.isFamilyshow = YES;
    msrIsDoubleLine = NO;
    familyIsDoubleLine = NO;
    cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.dataArray = self.familyArray;
    self.cid = cid;
    [self reqData];
    [self initView];
    return self;
}

//有新的推送消息产生
-(void)hasNewMsgNotification
{
    hasNewMsg = YES;
    if (self.dataArray.count) {
        
        MsgAIheaderModel *aiModel = self.dataArray[0];
        if (aiModel.type == AIModelTypeAll) {
            MsgAIHeaderCollectionViewCell *cell = (MsgAIHeaderCollectionViewCell *)[self.headCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            if (cell) {
                UIView *redPoint = [cell.contentView viewWithTag:200001];
                if (redPoint) {
                    redPoint.hidden = NO;
                }
            }
        }
        
    }
}


-(void)reqData
{
    if ([LoginManager sharedManager].loginStatus == JFGSDKCurrentLoginStatusSuccess) {
        
        [self.msgRequest reqFamiliarPersonsForCid:self.cid timestamp:0];
        [self.msgRequest reqStrangerListForCid:self.cid timestamp:0];
        [self.msgRequest reqAccessCountForType:5 accessID:@"all" cid:self.cid];
        hasNewMsg = NO;
        if (self.dataArray.count) {
            
            MsgAIheaderModel *aiModel = self.dataArray[0];
            if (aiModel.type == AIModelTypeAll) {
                MsgAIHeaderCollectionViewCell *cell = (MsgAIHeaderCollectionViewCell *)[self.headCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                if (cell) {
                    UIView *redPoint = [cell.contentView viewWithTag:200001];
                    if (redPoint) {
                        redPoint.hidden = YES;
                    }
                }
            }
        }
        
    }else{
        
        NSArray *familiarArr = [JfgCacheManager getCacheMsgForAIIsFamiliarHeader:YES cid:self.cid];
        NSArray *unfamiliarArr = [JfgCacheManager getCacheMsgForAIIsFamiliarHeader:NO cid:self.cid];
        self.familyArray = [[NSMutableArray alloc]initWithArray:familiarArr];
        self.unKnowArray = [[NSMutableArray alloc]initWithArray:unfamiliarArr];
        
        NSInteger realUnKnowCount = 0;
        for (MsgAIheaderModel *model in self.unKnowArray) {
            if (model.type != AIModelTypeSimulate) {
                realUnKnowCount ++;
            }
        }
        
        NSInteger realfamiliarCount = 0;
        for (MsgAIheaderModel *model in self.familyArray) {
            if (model.type != AIModelTypeSimulate) {
                realfamiliarCount ++;
            }
        }
        
        if (realUnKnowCount<=3) {
            msrIsDoubleLine = NO;
        }else{
            msrIsDoubleLine = YES;
        }
        if (realfamiliarCount>3) {
            familyIsDoubleLine = YES;
        }else{
            familyIsDoubleLine = NO;
        }
        self.dataArray = self.familyArray;
        [self resetPageCount];
        [self updataLayout];
    }
    
    [self.headCollectionView reloadData];
}

-(void)cacheHeaderData
{
    [JfgCacheManager cacheMsgForAIIsFamiliarHeader:YES data:self.familyArray cid:self.cid];
    [JfgCacheManager cacheMsgForAIIsFamiliarHeader:NO data:self.unKnowArray cid:self.cid];
}

#pragma mark- 陌生人数据
//陌生人
-(void)msgForAIStranger:(NSArray<StrangerModel *> *)models total:(int)total
{
    [self.unKnowArray removeAllObjects];
    for (StrangerModel *model in models) {
        MsgAIheaderModel *aiModel = [MsgAIheaderModel new];
        aiModel.faceIDList = [[NSMutableArray alloc]initWithObjects:model.face_id, nil];
        aiModel.last_time = model.last_time;
        aiModel.person_id = @"";
        aiModel.visitCount = -1;
        aiModel.faceImageUrl = model.faceImageUrl;
        aiModel.type = AIModelTypePerson;
        [self.unKnowArray addObject:aiModel];
    }
    
    if (self.unKnowArray.count<=3) {
        msrIsDoubleLine = NO;
    }else{
        msrIsDoubleLine = YES;
    }

    if (self.unKnowArray.count%6 != 0) {
        
        NSUInteger count = 6-self.unKnowArray.count%6;
        for (int i=0; i<count; i++) {
            MsgAIheaderModel *aiModel = [MsgAIheaderModel new];
            aiModel.type = AIModelTypeSimulate;
            [self.unKnowArray addObject:aiModel];
        }
    }
    
    if (!self.isFamilyshow) {
        self.dataArray = self.unKnowArray;
        [self resetPageCount];
        [self updataLayout];
        [self.headCollectionView reloadData];
        if (self.dataArray.count>cellSelectedIndexPath.row) {
            MsgAIheaderModel *model = [self.dataArray objectAtIndex:cellSelectedIndexPath.row];
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidSelectedCellForModel:)]) {
                [self.delegate msgAIHeadPortraitViewDidSelectedCellForModel:model];
            }
        }
    }
}

-(void)dataDeal
{
    for (MsgAIheaderModel *aiModel in [self.dataArray copy]) {
        if (aiModel.type == AIModelTypeSimulate) {
            [self.dataArray removeObject:aiModel];
        }
    }
    
    if (self.isFamilyshow) {
        if (self.dataArray.count>3) {
            familyIsDoubleLine = YES;
        }else{
            familyIsDoubleLine = NO;
        }
    }else{
        if (self.dataArray.count<=3) {
            msrIsDoubleLine = NO;
        }else{
            msrIsDoubleLine = YES;
        }
    }
    
    if (self.dataArray.count<6) {
        NSUInteger count = 6-self.dataArray.count;
        for (int i=0; i<count; i++) {
            MsgAIheaderModel *aiModel = [MsgAIheaderModel new];
            aiModel.type = AIModelTypeSimulate;
            [self.dataArray addObject:aiModel];
        }
    }else{
        if (self.dataArray.count%6 != 0) {
            NSUInteger count = self.dataArray.count - (self.dataArray.count/6*6);
            for (int i=0; i<count; i++) {
                MsgAIheaderModel *aiModel = [MsgAIheaderModel new];
                aiModel.type = AIModelTypeSimulate;
                [self.dataArray addObject:aiModel];
            }
        }
    }
}

#pragma mark- 熟人数据
//熟人
-(void)msgForAIFamiliarPersons:(NSArray<FamiliarPersonsModel *> *)models total:(int)total
{
    [self.familyArray removeAllObjects];
    MsgAIheaderModel *allModel = [MsgAIheaderModel new];
    allModel.type = AIModelTypeAll;
    
    MsgAIheaderModel *msrModel = [MsgAIheaderModel new];
    msrModel.type = AIModelTypeUnknow;
    
    [self.familyArray addObject:allModel];
    [self.familyArray addObject:msrModel];
    
    for (FamiliarPersonsModel *model in models) {
        MsgAIheaderModel *aiModel = [MsgAIheaderModel new];
        aiModel.faceIDList = [[NSMutableArray alloc] initWithArray:model.face_id];
        //人1，猫2，狗3，车辆4
        aiModel.type = AIModelTypePerson;
        aiModel.last_time = model.last_time;
        aiModel.person_id = model.person_id;
        aiModel.name = model.person_name;
        aiModel.faceMsgList = [[NSArray alloc] initWithArray:model.strangerArr];
        aiModel.visitCount = -1;
        if (model.strangerArr.count) {
            StrangerModel *smodel = model.strangerArr[0];
            aiModel.faceImageUrl = smodel.faceImageUrl;
            [self.familyArray addObject:aiModel];
        }
        
    }
    if (self.familyArray.count>2) {
        FamiliarPersonsModel *model = self.familyArray[2];
        [self.msgRequest reqAccessCountForType:2 accessID:model.person_id cid:self.cid];
    }
    
    if (self.familyArray.count>3) {
        familyIsDoubleLine = YES;
    }else{
        familyIsDoubleLine = NO;
    }
    if (self.familyArray.count%6 != 0) {
        
        NSUInteger count = 6 - self.familyArray.count%6;
        for (int i=0; i<count; i++) {
            MsgAIheaderModel *aiModel = [MsgAIheaderModel new];
            aiModel.type = AIModelTypeSimulate;
            [self.familyArray addObject:aiModel];
        }
        
    }
    

    
    if (self.isFamilyshow) {
        self.dataArray = self.familyArray;
        [self resetPageCount];
        [self updataLayout];
        [self.headCollectionView reloadData];
        if (self.dataArray.count>cellSelectedIndexPath.row) {
            MsgAIheaderModel *model = [self.dataArray objectAtIndex:cellSelectedIndexPath.row];
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidSelectedCellForModel:)]) {
                [self.delegate msgAIHeadPortraitViewDidSelectedCellForModel:model];
            }
        }
    }
}


-(void)resetPageCount
{
    NSInteger allPage = 0;
    if (self.dataArray.count%6 == 0) {
        allPage = self.dataArray.count/6;
    }else{
        allPage = self.dataArray.count/6+1;
    }
    self.pageLabel.text = [NSString stringWithFormat:@"1/%ld",(long)allPage];
    if (allPage>1) {
        self.pageLabel.hidden = NO;
    }else{
        self.pageLabel.hidden = YES;
    }
}

-(void)msgForAIAccessCount:(int)count face_id:(NSString *)face_id cid:(NSString *)cid
{
    for (int i=0; i<self.dataArray.count; i++) {
        
        MsgAIheaderModel *model = self.dataArray[i];
        if (self.isFamilyshow) {
            
            if ([model.person_id isEqualToString:face_id]) {
                
                model.visitCount = count;
                if (cellSelectedIndexPath.row == i) {
                    self.visitCountLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_TIMES"],[NSString stringWithFormat:@"%d",count]];
                }
                break;
                
            }else if ([face_id isEqualToString:@"all"]){
                
                if (model.type == AIModelTypeAll) {
                    
                    model.visitCount = count;
                    if (cellSelectedIndexPath.row == i) {
                        self.visitCountLabel.text = [NSString stringWithFormat:@"今日来访%d人",count];
                    }
                }
                
            }
        }else{
            
            if (model.faceIDList.count && [model.faceIDList[0] isEqualToString:face_id]) {
                model.visitCount = count;
                if (cellSelectedIndexPath.row == i) {
                    self.visitCountLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_TIMES"],[NSString stringWithFormat:@"%d",count]];
                }
                break;
            }
        }
    }
}

-(void)faceAddressSelectedPersonForIndex:(NSIndexPath *)indexPath
{
    if (cellSelectedIndexPath.row == indexPath.row) {
        cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self reqData];
}

-(void)faceCreateSuccessForIndex:(NSIndexPath *)indexPath
{
    if (cellSelectedIndexPath.row == indexPath.row) {
        cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self reqData];
}

-(void)initView
{
    //[self simulateData];
    [self updataLayout];
    [self addSubview:self.headCollectionView];
    [self addSubview:self.pageLabel];
    [self addSubview:self.visitCountLabel];
    self.visitCountLabel.hidden = NO;
    self.visitCountLabel.text = [NSString stringWithFormat:@"今天来访0人"];
}

-(void)backFamily
{
    cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.dataArray = self.familyArray;
    self.isFamilyshow = YES;
    [self updataLayout];
    [self resetPageCount];
    [self.headCollectionView reloadData];
    [self.headCollectionView setContentOffset:CGPointMake(0, 0) animated:NO];
    self.pageLabel.x = self.width*0.5;
    self.pageLabel.textAlignment = NSTextAlignmentCenter;
    self.visitCountLabel.hidden = NO;

    
    if (self.dataArray.count>cellSelectedIndexPath.row) {
        MsgAIheaderModel *model = [self.dataArray objectAtIndex:cellSelectedIndexPath.row];
        self.visitCountLabel.text = [NSString stringWithFormat:@"今天来访%d次",model.visitCount];
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidSelectedCellForModel:)]) {
            [self.delegate msgAIHeadPortraitViewDidSelectedCellForModel:model];
        }
    }
}

-(void)updataLayout
{
    if (self.dataArray.count == 0) {
        
        self.height = 0;
        self.pageLabel.bottom = self.height-8;
        self.visitCountLabel.bottom = self.pageLabel.bottom;
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewHeightChanged:)]) {
            [self.delegate msgAIHeadPortraitViewHeightChanged:self.height];
        }
        [self scrollViewDidEndDecelerating:self.headCollectionView];
        return;
        
    }
    
    
    BOOL isDoubleLine = YES;
    if (self.isFamilyshow) {
        isDoubleLine = familyIsDoubleLine;
    }else{
        isDoubleLine = msrIsDoubleLine;
    }
    
    if (isDoubleLine) {
        if (self.height != selfHeight) {
            self.height = selfHeight;
            self.pageLabel.bottom = self.height-8;
            self.visitCountLabel.bottom = self.pageLabel.bottom;
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewHeightChanged:)]) {
            [self.delegate msgAIHeadPortraitViewHeightChanged:self.height];
        }
        
    }else{
        CGFloat newHeight = selfHeight-collectionViewCellHeight;
        if (newHeight != self.height) {
            self.height = newHeight;
            
            self.pageLabel.bottom = self.height-8;
            self.visitCountLabel.bottom = self.pageLabel.bottom;
            
            if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewHeightChanged:)]) {
                [self.delegate msgAIHeadPortraitViewHeightChanged:self.height];
            }
        }
    }
    
    [self scrollViewDidEndDecelerating:self.headCollectionView];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    MsgAIHeaderCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MsgAIHeaderCell" forIndexPath:indexPath];
    UIView *redPoint = [cell.contentView viewWithTag:200001];
    if (!redPoint) {
        
        redPoint = [[UIView alloc]initWithFrame:CGRectMake(self.width/6+22.4, 9.6, 8, 8)];
        redPoint.tag = 200001;
        redPoint.layer.masksToBounds = YES;
        redPoint.layer.cornerRadius = 4;
        redPoint.backgroundColor = [UIColor redColor];
        [cell.contentView addSubview:redPoint];
    }
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.nameLabel.textAlignment = NSTextAlignmentCenter;

    MsgAIheaderModel *model = self.dataArray[indexPath.row];
    if (model.type == AIModelTypeAll && hasNewMsg) {
        redPoint.hidden = NO;
    }else{
        redPoint.hidden = YES;
    }
    
    if (cellSelectedIndexPath.row == indexPath.row) {
        cell.isSelected = YES;
    }else{
        cell.isSelected = NO;
    }

    if (model.type == AIModelTypeAll) {
        cell.headImageView.canShowMenuView = NO;
        cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_ALL"];
        if (cell.isSelected) {
            cell.headImageView.image = [UIImage imageNamed:@"news_icon_all_selected"];
        }else{
            cell.headImageView.image = [UIImage imageNamed:@"news_icon_all_normal"];
        }
        
    }else if (model.type == AIModelTypeUnknow){
        
        cell.headImageView.canShowMenuView = NO;
        cell.headImageView.image = [UIImage imageNamed:@"news_icon_stranger"];
        cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FILTER_STRANGER"];
        
    }else if (model.type == AIModelTypeSimulate){
        
        cell.headImageView.canShowMenuView = NO;
        cell.headImageView.image = nil;
        cell.nameLabel.text = @"";
        
    }else if (model.type == AIModelTypePerson){
        
        cell.nameLabel.text = [JfgTimeFormat transToAITime:(int)model.last_time];
        NSString *imageUrl = model.faceImageUrl;
        [cell.headImageView jfg_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"news_head128"]];
        cell.headImageView.canShowMenuView = YES;
        if (self.isFamilyshow) {
            cell.headImageView.menuItem2Type = MenuItemTypeLook;
        }else{
            cell.headImageView.menuItem2Type = MenuItemTypeRecognition;
        }
    }else{
        
        /*
         "AI_CAT" = "猫";
         "AI_DOG" = "狗";
         "AI_VEHICLE" = "车辆";
         */
        
        cell.headImageView.menuItem2Type = MenuItemTypeNone;
        cell.headImageView.canShowMenuView = YES;
        if (model.type == AIModelTypeCar) {
            
            cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"AI_VEHICLE"];
            cell.headImageView.image = [UIImage imageNamed:@"news_icon_car_normal"];
            if (cell.isSelected) {
                cell.headImageView.image = [UIImage imageNamed:@"news_icon_car_selected"];
            }
            
        }else if (model.type == AIModelTypeDog){
            cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"AI_DOG"];
            cell.headImageView.image = [UIImage imageNamed:@"news_icon_dog_normal"];
            if (cell.isSelected) {
                cell.headImageView.image = [UIImage imageNamed:@"news_icon_dog_selected"];
            }
        }else if (model.type == AIModelTypeCat){
            
            cell.nameLabel.text = [JfgLanguage getLanTextStrByKey:@"AI_CAT"];
            cell.headImageView.image = [UIImage imageNamed:@"news_icon_cat_normal"];
            if (cell.isSelected) {
                cell.headImageView.image = [UIImage imageNamed:@"news_icon_cat_selected"];
            }
            
        }
    }
    if (self.isFamilyshow) {
        //陌生人右上角问好图标
        cell.strangerIcon.hidden = YES;
    }else{
        if (model.type != AIModelTypePerson) {
            cell.strangerIcon.hidden = YES;
        }else{
            cell.strangerIcon.hidden = NO;
        }
        
    }
    return cell;
}


- (NSString *)imageUrlWithPerson_id:(NSString *)person_id
{
    //@"/long/vid/account/AI/cid/face_id.jpg";
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    JFGSDKAcount *acm = [[LoginManager sharedManager] accountCache];
    if (acm) {
        account = acm.account;
    }
    NSString *fileName = [NSString stringWithFormat:@"/long/%@/%@/AI/%@/%@.jpg",[OemManager getOemVid],account,self.cid,person_id];
    
    BOOL isExist = [SDWebImageCacheHelper diskImageExistsForFileName:fileName];
    if (isExist) {
        return [SDWebImageCacheHelper sdwebCacheForTempPathForFileName:fileName];
    }else{
        return [JFGSDK getCloudUrlWithFlag:1 fileName:fileName];
    }
}

-(NSString *)imageUrlWithFace_id:(NSString *)face_id
{
    ///7day/
    NSString *account = [LoginManager sharedManager].currentLoginedAcount;
    JFGSDKAcount *acm = [[LoginManager sharedManager] accountCache];
    if (acm) {
        account = acm.account;
    }
    NSString *fileName = [NSString stringWithFormat:@"/7day/%@/%@/AI/%@/%@.jpg",[OemManager getOemVid],account,self.cid,face_id];
    BOOL isExist = [SDWebImageCacheHelper diskImageExistsForFileName:fileName];
    if (isExist) {
        return [SDWebImageCacheHelper sdwebCacheForTempPathForFileName:fileName];
    }else{
        return [JFGSDK getCloudUrlWithFlag:1 fileName:fileName];
    }
}

#pragma mark- 菜单选项回调
-(void)collectionViewCell:(UICollectionViewCell *)cell menuItemType:(MenuItemType)itemType indexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"%d",itemType);
    if (itemType == MenuItemTypeLook) {
        MsgAIheaderModel *model = [self.dataArray objectAtIndex:indexPath.row];
        FaceMsgViewController *faceVC = [FaceMsgViewController new];
        faceVC.cid = self.cid;
        faceVC.person_id = model.person_id;
        faceVC.person_name = model.name;
        faceVC.faceList = model.faceIDList;
        faceVC.headImageUrl = model.faceImageUrl;
        faceVC.msgModel = model;
        UIViewController *supVC = [CommonMethod viewControllerForView:self];
        if (supVC) {
            [supVC.navigationController pushViewController:faceVC animated:YES];
        }
    }else if (itemType == MenuItemTypeRecognition){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"MESSAGES_IDENTIFY_POP"] delegate:self cancelButtonTitle:nil otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"MESSAGES_IDENTIFY_CREATE_BTN"],[JfgLanguage getLanTextStrByKey:@"MESSAGES_IDENTIFY_ADD_BTN"],[JfgLanguage getLanTextStrByKey:@"CANCEL"], nil];
        
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            MsgAIheaderModel *model = [self.dataArray objectAtIndex:indexPath.row];
            if (buttonIndex == 0) {
                FaceCreateViewController *faceCreate = [FaceCreateViewController new];
                faceCreate.cid = self.cid;
                faceCreate.delegate = self;
                faceCreate.selectedIndexPath = indexPath;
                faceCreate.headImageUrl = model.faceImageUrl;
                if (model.faceIDList.count) {
                    faceCreate.access_id = model.faceIDList[0];
                }
                UIViewController *vc = [CommonMethod viewControllerForView:self];
                if (vc) {
                    [vc presentViewController:faceCreate animated:YES completion:nil];
                }
            }else if (buttonIndex == 1){
                MsgAIheaderModel *model = [self.dataArray objectAtIndex:indexPath.row];
                FaceAddressBookVC *abVC = [FaceAddressBookVC new];
                abVC.cid = self.cid;
                abVC.face_id = model.faceIDList[0];
                abVC.selectedIndexPath = indexPath;
                abVC.delegate = self;
                abVC.vcType = FaceAddressBookVCTypeRecognition;
                UIViewController *vc = [CommonMethod viewControllerForView:self];
                
                if (vc) {
                    [vc presentViewController:abVC animated:YES completion:nil];
                }
                
            }
            
        } otherDelegate:nil];
        
        
        
    }else if (itemType == MenuItemTypeDel){
        
        __weak typeof(self) weakSelf = self;
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:[JfgLanguage getLanTextStrByKey:@"MESSAGES_DELETE_POP"] delegate:self cancelButtonTitle:nil otherButtonTitles:[JfgLanguage getLanTextStrByKey:@"MESSAGES_DELETE_FACE_BTN"],[JfgLanguage getLanTextStrByKey:@"MESSAGES_DELETE_FACE_MES"],[JfgLanguage getLanTextStrByKey:@"CANCEL"], nil];
        [alert showAlertViewWithClickedButtonBlock:^(NSInteger buttonIndex) {
            
            
            if (buttonIndex == 0 || buttonIndex == 1) {
                //删除头像
                
                [ProgressHUD showProgress:nil];
                MsgAIheaderModel *model = [weakSelf.dataArray objectAtIndex:indexPath.row];
                if (cellSelectedIndexPath.row == indexPath.row) {
                    cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
                }
                //删除头像
                if (weakSelf.isFamilyshow) {
                    
                    [AIRobotRequest robotDelPerson:model.person_id cid:weakSelf.cid sucess:^(id responseObject) {
                        
                        [weakSelf reqData];
                        [ProgressHUD dismiss];
                    } failure:^(NSError *error) {
                        [ProgressHUD dismiss];
                    }];
                    
                }else{
                    
                    [AIRobotRequest robotDelFaceIDList:@[model.faceIDList[0]] person_id:nil cid:self.cid sucess:^(id responseObject) {
                        NSLog(@"%@",responseObject);
                        [weakSelf reqData];
                        [ProgressHUD dismiss];
                    } failure:^(NSError *error) {
                        [ProgressHUD dismiss];
                    }];
                    
                    
                }
                
                
                if (buttonIndex == 1) {
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDelModel:isReloadModel:)]) {
                        
                        [weakSelf.delegate msgAIHeadPortraitViewDelModel:model isReloadModel:nil];
                        
                    }
                }
                
            }
            
        } otherDelegate:nil];
        
    }
}



-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    MsgAIheaderModel *model = [self.dataArray objectAtIndex:indexPath.row];
    if (model.type == AIModelTypeSimulate) {
        //占位model，不用处理
        return;
    }
    
    NSString *imageUrl = model.faceImageUrl;
    FLLog(@"%@",imageUrl);
    
    if (self.isFamilyshow && indexPath.row == 1) {
        
        cellSelectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        self.dataArray = self.unKnowArray;
        self.isFamilyshow = NO;
        [self updataLayout];
        [self resetPageCount];
        [self.headCollectionView reloadData];
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidUnkonwItemHasData:)]) {
            [self.delegate msgAIHeadPortraitViewDidUnkonwItemHasData:self.dataArray.count>0];
        }
        
    }else{
        
        MsgAIHeaderCollectionViewCell *currentCell = (MsgAIHeaderCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
        MsgAIHeaderCollectionViewCell *oldCell = (MsgAIHeaderCollectionViewCell *)[collectionView cellForItemAtIndexPath:cellSelectedIndexPath];
        if (currentCell != oldCell) {
            
            [self especialCellForSelectedIndexPath:indexPath];
            cellSelectedIndexPath = indexPath;
            currentCell.isSelected = YES;
            if (oldCell) {
                oldCell.isSelected = NO;
            }
        }
        
    }
    
    if (self.isFamilyshow) {
        //选中某个cell，下方来访人数显示处理
        if (indexPath.row == 0) {
            [self.msgRequest reqAccessCountForType:5 accessID:@"all" cid:self.cid];
            self.pageLabel.x = self.width*0.5;
            self.pageLabel.textAlignment = NSTextAlignmentCenter;
            self.visitCountLabel.hidden = NO;
            
        }else{
            
            self.pageLabel.left = 15;
            self.pageLabel.textAlignment = NSTextAlignmentLeft;
            self.visitCountLabel.hidden = NO;
        }
        
    }else{
        self.pageLabel.left = 15;
        self.pageLabel.textAlignment = NSTextAlignmentLeft;
        self.visitCountLabel.hidden = NO;
    }

    if (self.dataArray.count>cellSelectedIndexPath.row) {
        MsgAIheaderModel *model = [self.dataArray objectAtIndex:cellSelectedIndexPath.row];
        if (model.type != AIModelTypeAll && model.type != AIModelTypeUnknow && model.type != AIModelTypeSimulate) {
            
            if (model.visitCount>=0) {
                self.visitCountLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_TIMES"],[NSString stringWithFormat:@"%d",model.visitCount]];
            }else if (model.type == AIModelTypeAll){
                
                self.visitCountLabel.text = [NSString stringWithFormat:@"今日来访%d人",model.visitCount];
                                             
                                           
            }else{
                
                self.visitCountLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_TIMES"],[NSString stringWithFormat:@"%d",0]];
                if (self.isFamilyshow) {
                    [self.msgRequest reqAccessCountForType:2 accessID:model.person_id cid:self.cid];
                }else{
                    if (model.faceIDList.count) {
                        [self.msgRequest reqAccessCountForType:1 accessID:model.faceIDList[0] cid:self.cid];
                    }
                }
            }
            
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(msgAIHeadPortraitViewDidSelectedCellForModel:)]) {
            [self.delegate msgAIHeadPortraitViewDidSelectedCellForModel:model];
        }
    }
    
}


//全部，猫，狗等特殊筛选项图标变更处理
-(void)especialCellForSelectedIndexPath:(NSIndexPath *)indexPath
{
    MsgAIHeaderCollectionViewCell *currentCell = (MsgAIHeaderCollectionViewCell *)[self.headCollectionView cellForItemAtIndexPath:indexPath];
    MsgAIHeaderCollectionViewCell *allCell = (MsgAIHeaderCollectionViewCell *)[self.headCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    if (self.isFamilyshow) {
        if (allCell) {
            allCell.headImageView.image = [UIImage imageNamed:@"news_icon_all_normal"];
        }
        
        if (indexPath.row == 0) {
            currentCell.headImageView.image = [UIImage imageNamed:@"news_icon_all_selected"];
        }
    }
}


-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 10000+10) {
        
    }
    
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/self.headCollectionView.width;
    if (page*self.headCollectionView.width < scrollView.contentOffset.x) {
        page = page+1;
    }
    NSInteger allPage = 0;
    if (self.dataArray.count%6 == 0) {
        allPage = self.dataArray.count/6;
    }else{
        allPage = self.dataArray.count/6+1;
    }
    
    if (page+1>allPage) {
        page = page-1;
    }
    
    self.pageLabel.text = [NSString stringWithFormat:@"%d/%d",(int)page+1,(int)allPage];
}



-(DDCollectionViewHorizontalLayout *)colloctionLayouForLine:(NSInteger)line
{
    DDCollectionViewHorizontalLayout *flowLayout= [[DDCollectionViewHorizontalLayout alloc]init];
    flowLayout.minimumLineSpacing = 0;//左右距离
    flowLayout.minimumInteritemSpacing = 5;
    flowLayout.itemSize = CGSizeMake(self.width/3, collectionViewCellHeight);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.itemCountPerRow = 3;
    flowLayout.rowCount = line;
    if (line == 1) {
        self.headCollectionView.height = collectionViewHeight - collectionViewCellHeight;
    }else{
        self.headCollectionView.height = collectionViewHeight;
    }
    return flowLayout;
}

-(UICollectionView *)headCollectionView
{
    if (!_headCollectionView) {
        DDCollectionViewHorizontalLayout *flowLayout= [[DDCollectionViewHorizontalLayout alloc]init];
        flowLayout.minimumLineSpacing = 0;//左右距离
        flowLayout.minimumInteritemSpacing = 5;
        flowLayout.itemSize = CGSizeMake(self.width/3, collectionViewCellHeight);
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.itemCountPerRow = 3;
        flowLayout.rowCount = 2;
        _headCollectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 20, self.width, collectionViewHeight) collectionViewLayout:flowLayout];
        _headCollectionView.pagingEnabled = YES;
        [_headCollectionView registerNib:[UINib nibWithNibName:@"MsgAIHeaderCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"MsgAIHeaderCell"];
        _headCollectionView.delegate = self;
        _headCollectionView.dataSource = self;
        _headCollectionView.backgroundColor = [UIColor whiteColor];
        _headCollectionView.showsHorizontalScrollIndicator = NO;
    }
    return _headCollectionView;
}

-(UILabel *)pageLabel
{
    if (!_pageLabel) {
        _pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.headCollectionView.bottom+15, self.width, 17)];
        _pageLabel.font = [UIFont systemFontOfSize:12];
        _pageLabel.textColor = [UIColor colorWithHexString:@"#b8b8b8"];
        _pageLabel.textAlignment = NSTextAlignmentCenter;
        NSInteger allPage = 0;
        if (self.dataArray.count%6 == 0) {
            allPage = self.dataArray.count/6;
        }else{
            allPage = self.dataArray.count/6+1;
        }
        _pageLabel.text = [NSString stringWithFormat:@"1/%ld",(long)allPage];
    }
    return _pageLabel;
}

-(UILabel *)visitCountLabel
{
    if (!_visitCountLabel) {
        _visitCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.pageLabel.top, self.width*0.5-15, 17)];
        _visitCountLabel.font = [UIFont systemFontOfSize:12];
        _visitCountLabel.right = self.width-15;
        _visitCountLabel.textColor = self.pageLabel.textColor;
        _visitCountLabel.textAlignment = NSTextAlignmentRight;
        _visitCountLabel.text = [NSString stringWithFormat:[JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_VISIT_TIMES"],@"0"];
        _visitCountLabel.hidden = YES;
    }
    return _visitCountLabel;
}

-(NSMutableArray *)familyArray
{
    if (!_familyArray) {
        _familyArray = [NSMutableArray new];
        MsgAIheaderModel *allModel = [MsgAIheaderModel new];
        allModel.type = AIModelTypeAll;
        MsgAIheaderModel *msrModel = [MsgAIheaderModel new];
        msrModel.type = AIModelTypeUnknow;
        [_familyArray addObject:allModel];
        [_familyArray addObject:msrModel];
    }
    return _familyArray;
}

-(NSMutableArray *)dataArray
{
    if(!_dataArray){
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

-(NSMutableArray *)unKnowArray
{
    if (!_unKnowArray) {
        _unKnowArray = [NSMutableArray new];
    }
    return _unKnowArray;
}

-(MsgForAIRequest *)msgRequest
{
    if (!_msgRequest) {
        _msgRequest = [MsgForAIRequest new];
        _msgRequest.delegate = self;
        [_msgRequest addJfgDelegate];
    }
    return _msgRequest;
}

-(void)removeFromSuperview
{
    [super removeFromSuperview];
    [self.msgRequest removeJfgDelegate];
}

@end

