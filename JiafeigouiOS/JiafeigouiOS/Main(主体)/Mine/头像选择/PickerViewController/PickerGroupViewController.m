//
//  PickerGroupViewController.m
//  PhotoPickerDemo
//
//  Created by 杨利 on 16/7/30.
//  Copyright © 2016年 yangli. All rights reserved.
//

#import "PickerGroupViewController.h"
#import "LGPhotoPickerDatas.h"
#import "PickerAssetsViewController.h"
#import "PickerGroupTableViewCell.h"

@interface PickerGroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong)NSMutableArray *groupList;
@property (nonatomic,strong)UITableView *tableView;

@end

@implementation PickerGroupViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    [self getGroupData];
    
    // Do any additional setup after loading the view.
}



-(void)getGroupData
{
    LGPhotoPickerDatas *datas = [LGPhotoPickerDatas defaultPicker];
    [datas getAllGroupWithPhotos:^(NSArray *groups) {
        
        NSArray *arr  = [[groups reverseObjectEnumerator] allObjects];
        
        for (LGPhotoPickerGroup *group in arr) {
            
            if ([group.groupName isEqualToString:@"Camera Roll"]) {
                
                PickerAssetsViewController *asset = [[PickerAssetsViewController alloc]init];
                asset.assetsGroup = group;
                [self.navigationController pushViewController:asset animated:NO];
                
            }
            
        }
        
        self.groupList = [[NSMutableArray alloc]initWithArray:arr];
        [self.tableView reloadData];
        
    }];
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.groupList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *idCell = @"assetCellID";
    PickerGroupTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:idCell];
    if (!cell) {
        
        cell = [[[NSBundle mainBundle] loadNibNamed:@"PickerGroupTableViewCell" owner:self options:nil] lastObject];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    LGPhotoPickerGroup *group = self.groupList[indexPath.row];
    
    cell.titleLabel.text = [NSString stringWithFormat:@"%@",group.groupName];
    cell.assetcountLabel.text = [NSString stringWithFormat:@"%ld",(long)group.assetsCount];
    cell.headImageView.image = group.thumbImage;
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 178*0.5;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    LGPhotoPickerGroup *group = self.groupList[indexPath.row];
    PickerAssetsViewController *asset = [[PickerAssetsViewController alloc]init];
    asset.assetsGroup = group;
    [self.navigationController pushViewController:asset animated:YES];
}

-(UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
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
