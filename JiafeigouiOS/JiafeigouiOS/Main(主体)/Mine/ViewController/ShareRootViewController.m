//
//  ShareRootViewController.m
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/27.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "ShareRootViewController.h"
#import "JfgGlobal.h"
#import "ShareDeviceCell.h"
#import "ShareDeviceModel.h"
#import "ShareClassView.h"
#import "ShareManagerVC.h"
#import "UIButton+Click.h"
#import "JFGBoundDevicesMsg.h"
#import "JfgTypeDefine.h"
#import "ShareForSomeOneVC.h"
#import "CommonMethod.h"


@interface ShareRootViewController ()<UITableViewDelegate,UITableViewDataSource,JFGSDKCallbackDelegate>
@property (nonatomic, strong)UITableView * devicesTableView;

@property (nonatomic, strong)NSMutableArray * dataArray;
@property (nonatomic, strong)UIView * noDataView;
@property (nonatomic,strong)NSMutableDictionary *myFriendListDict;
@end

@implementation ShareRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_ShareDevice"];
    [self.leftButton addTarget:self action:@selector(leftButtonAction) forControlEvents:UIControlEventTouchUpInside];
    //self.dataArray = [NSMutableArray array];
    
    NSMutableArray * list = [[JFGBoundDevicesMsg sharedDeciceMsg]getDevicesList];
    self.dataArray = [[NSMutableArray alloc]init];
    for (JiafeigouDevStatuModel * m in list) {
        if (m.shareState != DevShareStatuOther && m.deviceType != JFGDeviceTypeDoorSensor) {
            [self.dataArray addObject:m];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [JFGSDK addDelegate:self];
    NSMutableArray * cidsArr = [NSMutableArray new];
    //查询每个设备被分享了多少次,没办法,服务器不给接口
    for (int i = 0; i<self.dataArray.count; i++) {
        JiafeigouDevStatuModel * m = [self.dataArray objectAtIndex:i];
        [cidsArr addObject:m.uuid];
    }
    [JFGSDK getDeviceSharedListForCids:cidsArr];
    [self initView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [JFGSDK removeDelegate:self];
}

-(void)initView{
    [self.view addSubview:self.noDataView];
    [self.view addSubview:self.devicesTableView];
    if (self.dataArray.count==0) {
        self.noDataView.hidden = NO;
        self.devicesTableView.hidden = YES;
    }else{
        self.noDataView.hidden = YES;
        self.devicesTableView.hidden = NO;
    }
}


#pragma  mark - JFGSDKCallBcak
-(void)jfgDeviceShareList:(NSDictionary <NSString *,NSArray <JFGSDKFriendInfo *>*> *)friendList {
    
    //NSLog(@"+++++++%@",friendList);
    self.myFriendListDict = [[NSMutableDictionary alloc]initWithDictionary:friendList];
    
    for (JiafeigouDevStatuModel * m in self.dataArray) {
        NSArray * cidsArr = [friendList allKeys];
        for (int i = 0; i < cidsArr.count; i++) {
            NSArray * frinedsArr = [friendList allValues][i];
            if ([[cidsArr objectAtIndex:i] isEqualToString:m.uuid]) {
                m.shareCount = frinedsArr.count;
                break;
            }
        }
    }
    [self.devicesTableView reloadData];
}

#pragma mark - UITableViewDatasource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *IDCell = @"shareCell";
    ShareDeviceCell * cell = [tableView dequeueReusableCellWithIdentifier:IDCell];
    if (!cell) {
        cell = [[ShareDeviceCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:IDCell];
    }
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = CellSelectedColor;
    
    UIView *topLineView = [cell.contentView viewWithTag:1023];
    if (topLineView) {
        
        if (indexPath.row == 0) {
            topLineView.hidden = NO;
        }else{
            topLineView.hidden = YES;
        }
        
    }else{
        
        if (indexPath.row == 0) {
            topLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 0.5)];
            topLineView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
            topLineView.tag = 1023;
            [cell.contentView addSubview:topLineView];
        }
    }
    
    UIView *bottomLineView = [cell.contentView viewWithTag:1025];
    if (bottomLineView) {
        
        if (indexPath.row == self.dataArray.count-1) {
            bottomLineView.hidden = NO;
        }else{
            bottomLineView.hidden = YES;
        }
        
    }else{
        
        if (indexPath.row == self.dataArray.count-1) {
            bottomLineView = [[UIView alloc]initWithFrame:CGRectMake(0, 69.5, self.view.bounds.size.width, 0.5)];
            bottomLineView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
            bottomLineView.tag = 1025;
            [cell.contentView addSubview:bottomLineView];
        }
    }
    
    
    
    JiafeigouDevStatuModel * m = [self.dataArray objectAtIndex:indexPath.row];
    UIImage * image;
    switch (m.deviceType) {
        case JFGDeviceTypeCameraWifi:
            image = [UIImage imageNamed:@"add_icon_camera"];
            break;
        case JFGDeviceTypeDoorBell:
            image = [UIImage imageNamed:@"add_icon_ring"];
            break;
        case JFGDeviceTypeEfamily:
            image = [UIImage imageNamed:@"add_icon_photo"];
            break;
        default:
            image = [UIImage imageNamed:@"add_icon_camera"];
            break;
    }
    [cell.iconImageView setImage:image];
    [cell.deviceNameLabel setText:m.alias];
    [cell.deviceNumLabel setText:[NSString stringWithFormat:@"%d/5",m.shareCount]];
    if (m.shareCount >= 5) {
        cell.shareButton.layer.borderColor = [UIColor colorWithHexString:@"#cecece"].CGColor;
        [cell.shareButton setTitleColor:[UIColor colorWithHexString:@"#cecece"]forState:UIControlStateNormal];
        cell.shareButton.enabled = NO;
    }else{
        cell.shareButton.layer.borderColor = [UIColor colorWithHexString:@"#4b9fd5"].CGColor;
        [cell.shareButton setTitleColor:[UIColor colorWithHexString:@"#4b9fd5"]forState:UIControlStateNormal];
        cell.shareButton.enabled = YES;
    }
    
    [cell.shareButton addTarget:self action:@selector(buttonBackGroundHighlighted:) forControlEvents:UIControlEventTouchDown];
    [cell.shareButton addTarget:self action:@selector(shareBtnUp:) forControlEvents:UIControlEventTouchUpOutside];
    
    [UIButton button:cell.shareButton touchUpInSideHander:^(UIButton *button) {
        
        
        if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
            [CommonMethod showNetDisconnectAlert];
            [cell.shareButton setBackgroundColor:[UIColor clearColor]];
            return;
        }

        
        [cell.shareButton setBackgroundColor:[UIColor clearColor]];
        ShareClassView *shareView = [ShareClassView showShareViewWitnContent:nil withType:shareTypeDevice navigationController:self.navigationController Cid:m.uuid];
        
        if (self.myFriendListDict) {
            
            NSArray *friendlist = self.myFriendListDict[m.uuid];
            shareView.obj = friendlist;
            
        }
        
    }];
    
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([JFGSDK currentNetworkStatus] == JFGNetTypeOffline) {
        [CommonMethod showNetDisconnectAlert];
        return;
    }
    
    ShareManagerVC * managerVC = [ShareManagerVC new];
    JiafeigouDevStatuModel * m= [self.dataArray objectAtIndex:indexPath.row];
    managerVC.cid = m.uuid;
    managerVC.devAlias = m.alias;
    [self.navigationController pushViewController:managerVC animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

-(UITableView *)devicesTableView{
    if (!_devicesTableView) {
        _devicesTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64) style:UITableViewStylePlain];
        _devicesTableView.delegate = self;
        _devicesTableView.dataSource = self;
        _devicesTableView.contentInset = UIEdgeInsetsMake(20, 0, 0, 0);
        _devicesTableView.separatorColor = TableSeparatorColor;
        _devicesTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        [_devicesTableView setTableFooterView:[UIView new]];
        [_devicesTableView setSeparatorInset:UIEdgeInsetsMake(0, 73, 0, 0)];
        [_devicesTableView setShowsVerticalScrollIndicator:NO];
        [_devicesTableView setShowsVerticalScrollIndicator:NO];
        [_devicesTableView registerClass:[ShareDeviceCell class] forCellReuseIdentifier:@"shareCell"];
    }
    return _devicesTableView;
}

-(UIView *)noDataView{
    if (!_noDataView) {
        _noDataView = [[UIView alloc]initWithFrame:CGRectMake(0, 64, self.view.width, self.view.height-64)];
        UIImageView * iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.width-157)/2.0, 0.24*kheight, 157, 125.0)];
        iconImageView.image = [UIImage imageNamed:@"pic_tips_none"];
        [_noDataView addSubview:iconImageView];
        UILabel * noShareLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, iconImageView.bottom+20, Kwidth, 15)];
        noShareLabel.font = [UIFont systemFontOfSize:15];
        noShareLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        noShareLabel.text = [JfgLanguage getLanTextStrByKey:@"EFAMILY_NO_DOOR"];
        noShareLabel.textAlignment = NSTextAlignmentCenter;
        [_noDataView addSubview:noShareLabel];
    }
    return _noDataView;
}

-(void)buttonBackGroundHighlighted:(UIButton *)btn{
    [btn setBackgroundColor:[UIColor colorWithHexString:@"#e5f0f8"]];
}

-(void)shareBtnUp:(UIButton *)sender
{
    [sender setBackgroundColor:[UIColor clearColor]];
}

-(void)leftButtonAction{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
