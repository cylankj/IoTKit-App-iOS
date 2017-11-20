//
//  FBPravicyChooseVC.m
//  JiafeigouiOS
//
//  Created by 杨利 on 2017/9/14.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "FBPravicyChooseVC.h"
#import "FacebookLiveAPIHelper.h"

@interface FBPravicyChooseVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,copy)NSString *chooseType;
@property (nonatomic,strong)UITableView *myTableView;
@property (nonatomic,strong)NSMutableArray *dataArray;
@property (nonatomic,strong)NSIndexPath *selectedIndexPath;
@property (nonatomic,strong)FacebookLiveAPIHelper *facebookHelper;
@property (nonatomic,strong)NSMutableArray *groupModelList;

@end

@implementation FBPravicyChooseVC

- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"LIVE_FACEBOOK_PERMISSIONS"];
    self.selectedIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.dataArray addObjectsFromArray:[FacebookLiveAPIHelper fbPrivacy]];
    NSNumber *chooseType = [[NSUserDefaults standardUserDefaults] objectForKey:FBLiveVideoAuthorityKey];
    if (chooseType) {
        self.selectedIndexPath = [NSIndexPath indexPathForRow:[chooseType intValue] inSection:0];
    }else{
        self.selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    [self.view addSubview:self.myTableView];
}

-(void)backAction
{
    [super backAction];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didChooseForType:)]) {
        [[NSUserDefaults standardUserDefaults] setObject:@(self.selectedIndexPath.row) forKey:FBLiveVideoAuthorityKey];
        [self.delegate didChooseForType:self.dataArray[self.selectedIndexPath.row]];
    }
}

-(void)groupData
{
    __weak typeof(self) weakSelf = self;
    [self.facebookHelper groupListWithHandler:^(NSError *error, id result) {
        if (!error) {
            
            if ([result isKindOfClass:[NSDictionary class]]) {
                
                NSDictionary *sourceDict = result;
                NSArray *dataA = sourceDict[@"data"];
                if ([dataA isKindOfClass:[NSArray class]]) {
                    
                    NSMutableArray *nameArr = [NSMutableArray new];
                    for (NSDictionary *dic in dataA) {
                        
                        if ([dic isKindOfClass:[NSDictionary class]]) {
                            
                            FBGroupModel *model = [FBGroupModel new];
                            model.groupID = dic[@"id"];
                            model.groupName = dic[@"name"];
                            model.groupPrivacy = dic[@"privacy"];
                            weakSelf.groupModelList = [NSMutableArray new];
                            [weakSelf.groupModelList addObject:model];
                            [nameArr addObject:model.groupName];
                        
                        }
                        
                    }
//                    [weakSelf.dataArray removeAllObjects];
//                    [weakSelf.dataArray addObject:@[@"公开",@"好友",@"仅自己"]];
//                    [weakSelf.dataArray addObject:nameArr];
//                    [self.myTableView reloadData];
                    
                }
                
            }
            
        }
    }];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *IDForCell = @"fbCellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:IDForCell];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDForCell];
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
    }
    if (self.selectedIndexPath.section == indexPath.section && self.selectedIndexPath.row == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45.0f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:self.selectedIndexPath];
    selectedCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.selectedIndexPath = indexPath;
}

-(UITableView *)myTableView
{
    if (!_myTableView) {
        _myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _myTableView.delegate = self;
        _myTableView.dataSource = self;
        _myTableView.tableFooterView = [UIView new];
        _myTableView.backgroundColor = [UIColor colorWithHexString:@"#ebebec"];
    }
    return _myTableView;
}

-(NSMutableArray *)dataArray
{
    if (!_dataArray) {
        _dataArray = [NSMutableArray new];
    }
    return _dataArray;
}

-(FacebookLiveAPIHelper *)facebookHelper
{
    if (!_facebookHelper) {
        _facebookHelper = [FacebookLiveAPIHelper new];
    }
    return _facebookHelper;
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


@implementation FBGroupModel


@end
