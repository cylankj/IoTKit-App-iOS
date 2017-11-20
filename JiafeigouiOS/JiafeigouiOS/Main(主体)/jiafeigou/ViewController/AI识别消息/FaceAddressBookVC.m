//
//  FaceAddressBookVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/10/18.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "FaceAddressBookVC.h"
#import "MsgForAIRequest.h"
#import "ProgressHUD.h"
#import "BMChineseSort.h"
#import "AIRobotRequest.h"
#import "UIImageView+JFGImageView.h"
#import "LoginManager.h"
#import "MsgForAIModel.h"

@interface FaceAddressBookVC ()<UITableViewDelegate,UITableViewDataSource,MsgForAIRequestDelegate>
{
    NSIndexPath *_indexPath;
}
@property (nonatomic,strong)UITableView *contactTableView;
@property (nonatomic,strong)NSMutableArray *indexArray;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)UIView *headview;
@property (nonatomic,strong)UIView *noDataView;
@property (nonatomic,strong)UIButton *doneBtn;
@property (nonatomic,strong)MsgForAIRequest *msgRequest;
@property (nonatomic,strong)UIButton *cancelBtn;

@end

@implementation FaceAddressBookVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_FACE_MOVE"];
    
    [self performSelector:@selector(loadingTimeout) withObject:nil afterDelay:10];
    [self.msgRequest reqFamiliarPersonsForCid:self.cid timestamp:0];

    self.backBtn.hidden = YES;
    
    [self.view addSubview:self.contactTableView];
    [self.view addSubview:self.noDataView];
    [self.topBarBgView addSubview:self.doneBtn];
    [self.topBarBgView addSubview:self.cancelBtn];
    self.doneBtn.enabled = NO;
    [ProgressHUD showProgress:nil];
    
    // Do any additional setup after loading the view.
}


-(void)msgForAIFamiliarPersons:(NSArray<FamiliarPersonsModel *> *)models total:(int)total
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(loadingTimeout) object:nil];
    if (models.count) {
        [ProgressHUD dismiss];
        self.contactTableView.hidden = NO;
        self.noDataView.hidden = YES;
        
        self.indexArray = [BMChineseSort IndexWithArray:models Key:@"person_name"];
        self.dataArray = [BMChineseSort sortObjectArray:models Key:@"person_name"];
        
        if ([self.person_id isKindOfClass:[NSString class]]) {
            
            BOOL isBreak = NO;
            for (NSArray *arr in self.dataArray) {
                for (FamiliarPersonsModel *md in arr) {
                    if ([md.person_id isEqualToString:self.person_id]) {
                        _indexPath = [NSIndexPath indexPathForRow:[arr indexOfObject:md] inSection:[self.dataArray indexOfObject:arr]];
                        isBreak = YES;
                        break;
                    }
                }
                if (isBreak) break;
            }
            
        }
        
        [self.contactTableView reloadData];
    }else{
        [ProgressHUD dismiss];
        self.contactTableView.hidden = YES;
        self.noDataView.hidden = NO;
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.msgRequest addJfgDelegate];
   
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.msgRequest removeJfgDelegate];
}

-(void)doneAction:(UIButton *)sender
{
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"GLOBAL_NO_NETWORK"]];
        return;
    }
    if (_indexPath) {
        
        [ProgressHUD showProgress:nil];
        __weak typeof(self) weakSelf = self;
        NSArray *sectionArr = self.dataArray[_indexPath.section];
        FamiliarPersonsModel *model = sectionArr[_indexPath.row];
        [AIRobotRequest robotAddFace:self.face_id toPerson:model.person_id cid:self.cid sucess:^(id responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dict = responseObject;
                int ret = [dict[@"ret"] intValue];
                if (ret == 0) {
                    
                    if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(faceAddressSelectedPersonForIndex:)]) {
                        [weakSelf.delegate faceAddressSelectedPersonForIndex:weakSelf.selectedIndexPath];
                    }
                    
                    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SCENE_SAVED"]];
                    
                    int64_t delayInSeconds = 1.0;
                    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                        
                        if (weakSelf.navigationController && [weakSelf.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
                            [weakSelf.navigationController popViewControllerAnimated:YES];
                        }else{
                            [weakSelf dismissViewControllerAnimated:YES completion:nil];
                        }
                        
                    });
                    
                    
                    return ;
                }
            }
            //
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
            
        } failure:^(NSError *error) {
            [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"SETTINGS_FAILED"]];
        }];
    }
}

-(void)loadingTimeout
{
    [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"Request_TimeOut"]];
}

#pragma mark -UITableViewDataSource

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *bgv = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.width, 29)];
    bgv.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(15, 0, 20, 29)];
    label.font = [UIFont systemFontOfSize:17];
    label.textColor = [UIColor colorWithHexString:@"#232323"];
    label.text = [self.indexArray objectAtIndex:section];
    [bgv addSubview:label];
    
    return bgv;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *didSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
    if (_indexPath && (_indexPath.section != indexPath.section || _indexPath.row != indexPath.row )) {
        UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:_indexPath];
        oldCell.accessoryType = UITableViewCellAccessoryNone;
    }
    didSelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    _indexPath = indexPath;
    self.doneBtn.enabled = YES;
    if (self.person_id) {
        NSArray *sectionArr = self.dataArray[indexPath.section];
        FamiliarPersonsModel *model = sectionArr[indexPath.row];
        if ([model.person_id isEqualToString:self.person_id]) {
            self.doneBtn.enabled = NO;
        }
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.indexArray count];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = [self.dataArray objectAtIndex:section];
    return [arr count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *iDForCell = @"cCell";
    UITableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:iDForCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:iDForCell];
        cell.textLabel.hidden = YES;
        cell.imageView.hidden = YES;
        
        UIImageView *headImageView = [[UIImageView alloc]initWithFrame:CGRectMake(15, 13, 44, 44)];
        headImageView.layer.masksToBounds = YES;
        headImageView.layer.cornerRadius = 22;
        headImageView.tag = 10000+1;
        [cell.contentView addSubview:headImageView];
        
        UILabel *nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(84, 27, self.view.width-100, 20)];
        nameLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        nameLabel.font = [UIFont systemFontOfSize:17];
        nameLabel.tag = 10000+2;
        [cell.contentView addSubview:nameLabel];
        
    }
    
    UIImageView *headerImageV = [cell.contentView viewWithTag:10000+1];
    UILabel *nameLabel = [cell.contentView viewWithTag:10000+2];
    
    NSArray *sectionArr = self.dataArray[indexPath.section];
    FamiliarPersonsModel *model = sectionArr[indexPath.row];
    NSString *imageUrl = @"";
    if (model.strangerArr && model.strangerArr.count) {
        StrangerModel *smodel = model.strangerArr[0];
        imageUrl= smodel.faceImageUrl;
    }
    
    [headerImageV jfg_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"news_head128"]];
    nameLabel.text = model.person_name;
    if (_indexPath && _indexPath.section == indexPath.section && _indexPath.row == indexPath.row) {
        cell.accessoryType =  UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType =  UITableViewCellAccessoryNone;
    }
    
    return cell;
}


#pragma mark -UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 29;
}


#pragma mark- 索引相关
//section右侧index数组
-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.indexArray;
}

//点击右侧索引表项时调用 索引与section的对应关系
- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return index;
}


-(UITableView *)contactTableView
{
    if (!_contactTableView) {
        _contactTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _contactTableView.delegate = self;
        _contactTableView.dataSource = self;
        _contactTableView.showsVerticalScrollIndicator = NO;
        _contactTableView.showsHorizontalScrollIndicator = NO;
        [_contactTableView setTableFooterView:[UIView new]];
        _contactTableView.tableHeaderView = self.headview;
        _contactTableView .backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _contactTableView.sectionIndexBackgroundColor = [UIColor clearColor];
        [_contactTableView setSeparatorColor:[UIColor colorWithHexString:@"#e1e1e1"]];
        [_contactTableView setSeparatorInset:UIEdgeInsetsMake(0, 84, 0, 0)];
    }
    return _contactTableView;
}

-(UIView *)headview
{
    if (!_headview) {
        _headview = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, 64)];
        _headview.backgroundColor = [UIColor colorWithHexString:@"#f9f9f9"];
        
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(16, 22, self.view.width-32, 30)];
        label.font = [UIFont systemFontOfSize:14];
        label.textColor = [UIColor colorWithHexString:@"#888888"];
        label.text = [JfgLanguage getLanTextStrByKey:@"MESSAGES_ADD_FACE_TIPS"];
        CGSize maxSize = [label sizeThatFits:CGSizeMake(self.view.width-32, MAXFLOAT)];
        label.size = maxSize;
        [_headview addSubview:label];
        _headview.height = maxSize.height+44;
    }
    return _headview;
}

-(UIButton *)doneBtn
{
    if (!_doneBtn) {
        _doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _doneBtn.frame = CGRectMake(0, 32, 60, 20);
        _doneBtn.right = self.view.width;
        [_doneBtn setTitle:[JfgLanguage getLanTextStrByKey:@"SAVE"] forState:UIControlStateNormal];
        [_doneBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_doneBtn setTitleColor: [UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        _doneBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _doneBtn.titleLabel.textAlignment = NSTextAlignmentRight;
        [_doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _doneBtn;
}

-(MsgForAIRequest *)msgRequest
{
    if (!_msgRequest) {
        _msgRequest = [[MsgForAIRequest alloc]init];
        _msgRequest.delegate = self;
        [_msgRequest addJfgDelegate];
    }
    return _msgRequest;
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
        _noDataView.hidden = YES;
    }
    return _noDataView;
}

-(UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(15, 32, 60, 20);
        [_cancelBtn setTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithHexString:@"#ffffff"] forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[UIColor colorWithWhite:1 alpha:0.5] forState:UIControlStateDisabled];
        _cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _cancelBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_cancelBtn addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelBtn;
}

-(void)cancelAction:(UIButton *)sender
{
    if (self.navigationController && [self.navigationController respondsToSelector:@selector(popViewControllerAnimated:)]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self dismissViewControllerAnimated:YES completion:nil];
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
