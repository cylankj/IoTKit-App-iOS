//
//  AddDeviceMainViewController.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/15.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "AddDeviceMainViewController.h"
#import "FLGlobal.h"
#import "UIColor+HexColor.h"
#import "QRViewController.h"
#import "JfgLanguage.h"
#import "AddDeviceGuideViewController.h"
#import "BindDevProgressViewController.h"
#import "OemManager.h"
#import "jfgConfigManager.h"
#import "CommentFrameButton.h"
#import "UIView+FLExtensionForFrame.h"
#import "SnScanViewController.h"
#import "MTA.h"

@interface AddDeviceMainViewController()

@property (strong, nonatomic) UITableView *addDeviceTableView;
@property (strong, nonatomic)NSArray *dataArray;
@property (strong, nonatomic)UIView *tableHeaderView;

@end


@implementation AddDeviceMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initView];
}

- (void)initView
{
    [self.view addSubview:self.addDeviceTableView];
    
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationView.backgroundColor = [UIColor colorWithHexString:@"#0ba8cf"];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"DEVICES_TITLE"];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}


#pragma mark  view --setter
- (UITableView *)addDeviceTableView
{
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = kheight - 64;
    CGFloat widgetX = 0;
    CGFloat widgetY = 64;
    
    if (_addDeviceTableView == nil)
    {
        _addDeviceTableView = [[UITableView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight) style:UITableViewStylePlain];
        _addDeviceTableView.dataSource = self;
        _addDeviceTableView.delegate = self;
        _addDeviceTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        _addDeviceTableView.separatorColor = [UIColor colorWithHexString:@"#e1e1e1"];
        _addDeviceTableView.tableHeaderView = self.tableHeaderView;
        _addDeviceTableView.tableFooterView = [UIView new];
    }
    return _addDeviceTableView;
}


#pragma mark  data
-(NSArray *)dataArray
{
    if (!_dataArray) {
        
        NSMutableArray *configData = [[NSMutableArray alloc]initWithArray:[jfgConfigManager getAddDevModel]];
        NSMutableArray *arr = [NSMutableArray new];
        for (NSArray *sbuArr in configData) {
            NSMutableArray *subArr = [NSMutableArray new];
            
            //去除半球机的添加方式，因为现实在头部视图上
            for (AddDevConfigModel *model in sbuArr) {
                if ([model.typeMark integerValue] != 9) {
                    [subArr addObject:model];
                }
            }

            [arr addObject:subArr];
        }
        
        _dataArray = [[NSArray alloc]initWithArray:arr];
    }
    return _dataArray;
}

-(UIView *)tableHeaderView
{
    if (!_tableHeaderView) {
        _tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 117+30)];
        _tableHeaderView.backgroundColor = [UIColor colorWithHexString:@"##f0f0f0"];
        
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(0, 15, self.view.width, 117)];
        bgView.backgroundColor = [UIColor whiteColor];
        [_tableHeaderView addSubview:bgView];
        
        UIButton *sBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sBtn.frame = CGRectMake(0, 20+15, 50, 50);
        sBtn.x = self.view.width/6;
        [sBtn setImage:[UIImage imageNamed:@"icon_scan"] forState:UIControlStateNormal];
        sBtn.tag = 1002;
        [sBtn addTarget:self action:@selector(headerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *sLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, sBtn.bottom+8, self.view.width/3, 19)];
        sLabel.textAlignment = NSTextAlignmentCenter;
        sLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        sLabel.font = [UIFont systemFontOfSize:15];
        sLabel.text = [JfgLanguage getLanTextStrByKey:@"Add_Device_Scan_QR"];
        
        
        //有线模式
        UIButton *yxBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        yxBtn.frame = CGRectMake(0, 20+15, 50, 50);
        yxBtn.x = self.view.width/2;
        [yxBtn setImage:[UIImage imageNamed:@"icon_wired"] forState:UIControlStateNormal];
        yxBtn.tag = 1004;
        [yxBtn addTarget:self action:@selector(headerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *yxLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.width/3, sBtn.bottom+8, self.view.width/3, 19)];
        yxLabel.textAlignment = NSTextAlignmentCenter;
        yxLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        yxLabel.font = [UIFont systemFontOfSize:15];
        yxLabel.text = [JfgLanguage getLanTextStrByKey:@"Cable_Mode"];
        
        //cid添加
        UIButton *nBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        nBtn.frame = CGRectMake(0, 20+15, 50, 50);
        nBtn.x = self.view.width/6*5;
        [nBtn setImage:[UIImage imageNamed:@"icon_sn"] forState:UIControlStateNormal];
        nBtn.tag = 1003;
        [nBtn addTarget:self action:@selector(headerBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        
        UILabel *nLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.view.width/3*2, sBtn.bottom+8, self.view.width/3, 19)];
        nLabel.textAlignment = NSTextAlignmentCenter;
        nLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        nLabel.font = [UIFont systemFontOfSize:15];
        nLabel.text = [JfgLanguage getLanTextStrByKey:@"Add_Device_S/N"];
        
        [_tableHeaderView addSubview:sBtn];
        [_tableHeaderView addSubview:sLabel];
        [_tableHeaderView addSubview:nBtn];
        [_tableHeaderView addSubview:nLabel];
        [_tableHeaderView addSubview:yxBtn];
        [_tableHeaderView addSubview:yxLabel];
        
    }
    return _tableHeaderView;
}

#pragma mark  action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

-(void)headerBtnAction:(UIButton *)sender
{
    if (sender.tag == 1002) {
        //扫一扫
        QRViewController *qr = [QRViewController new];
        qr.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:qr animated:YES];
        [MTA trackCustomKeyValueEvent:@"AddDev_inletType" props:@{@"type":@"扫一扫"}];
        
    }else if (sender.tag == 1003){
        
        //cid添加
        SnScanViewController *sn = [SnScanViewController new];
        sn.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sn animated:YES];
        [MTA trackCustomKeyValueEvent:@"AddDev_inletType" props:@{@"type":@"cid添加"}];
        
    }else if (sender.tag == 1004){
        //有线模式添加
        AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
        addDeviceGuide.pType = productType_wired;
        [self.navigationController pushViewController:addDeviceGuide animated:YES];
        [MTA trackCustomKeyValueEvent:@"AddDev_inletType" props:@{@"type":@"有线模式添加"}];
    }
}

#pragma mark tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *rows = [self.dataArray objectAtIndex:section];
    return [rows count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierStr = @"addDeviceIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierStr];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor colorWithHexString:@"#666666"];
        cell.textLabel.font = [UIFont systemFontOfSize:17.0f];
        
        UIView *selectedView = [[UIView alloc] init];
        selectedView.backgroundColor = [UIColor colorWithHexString:@"#dfdfdf"];
        cell.selectedBackgroundView = selectedView;
    }
    
    AddDevConfigModel *model = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [JfgLanguage getLanTextStrByKey:model.title];
    cell.imageView.image = [UIImage imageNamed:model.iconName];
    
    return cell;
}

#pragma mark tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    if (section < self.dataArray.count - 1)
//    {
//        return 12.0f;
//    }
//    return 1.0f;
//}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [UIView new];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AddDevConfigModel *model = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [MTA trackCustomKeyValueEvent:@"AddDev_inletType" props:@{@"type":@"特定设备入口"}];
    switch ([model.typeMark intValue]) {
        case 0:{
            QRViewController *qr = [QRViewController new];
            qr.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:qr animated:YES];
        }
            break;
            
        case 1:{
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_WIFI;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            break;
            
        case 2:{
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_720;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            break;
            
        case 3:{
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_DoorBell;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            break;
            
        case 4:{
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_IPCam;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            
            break;
            
        case 5:{
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_ColudCameraOs;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            
            break;
            
        case 6:{
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_CatEye;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            
            break;
        case 7:{
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_DoorBell3;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            
            break;
        case 8:{
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_AI_Camera_outdoor;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            break;
        case 10:{
            //productType_AI_Camera_dome
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            addDeviceGuide.pType = productType_AI_Camera_dome;
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            
        default:
            break;
    }
}


@end
