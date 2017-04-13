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


@interface AddDeviceMainViewController()

@property (strong, nonatomic) UITableView *addDeviceTableView;
@property (strong, nonatomic) NSArray *imageGroupArray;
@property (strong, nonatomic) NSArray *dataGroupArray;

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
    }
    
    return _addDeviceTableView;
}


#pragma mark  data

- (NSArray *)dataGroupArray
{
    if (_dataGroupArray == nil)
    {
        
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
        if ([appCurVersionNum hasPrefix:@"3.2"]) {
            _dataGroupArray = [[NSArray alloc] initWithObjects: @[[JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_QR"]], @[[JfgLanguage getLanTextStrByKey:@"DOG_CAMERA_NAME"], @"720°全景摄像头",[JfgLanguage getLanTextStrByKey:@"CALL_CAMERA_NAME"]], nil];
        }else{
            _dataGroupArray = [[NSArray alloc] initWithObjects: @[[JfgLanguage getLanTextStrByKey:@"Tap1_AddDevice_QR"]], @[[JfgLanguage getLanTextStrByKey:@"DOG_CAMERA_NAME"],[JfgLanguage getLanTextStrByKey:@"CALL_CAMERA_NAME"]], nil];
        }
        
        
        //
        
    }
    return _dataGroupArray;
}

- (NSArray *)imageGroupArray
{
    if (_imageGroupArray == nil)
    {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
        if ([appCurVersionNum hasPrefix:@"3.2"]) {
            _imageGroupArray = [[NSArray alloc] initWithObjects:@[@"add_icon_scancode"], @[@"add_icon_camera",@"home_icon_720camera", @"add_icon_ring"], nil];
        }else{
            _imageGroupArray = [[NSArray alloc] initWithObjects:@[@"add_icon_scancode"], @[@"add_icon_camera", @"add_icon_ring"], nil];
        }
        //
        
    }
    return _imageGroupArray;
}


#pragma mark  action
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
}

#pragma mark tableView datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataGroupArray objectAtIndex:section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataGroupArray.count;
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
    
    cell.textLabel.text = [[self.dataGroupArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageNamed:[[self.imageGroupArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark tableView delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section < self.dataGroupArray.count - 1)
    {
        return 12.0f;
    }
    return 1.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section)
    {
        case 0: //扫一扫
        {
            QRViewController *qr = [QRViewController new];
            qr.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:qr animated:YES];
        }
            break;
        case 1:
        {
            AddDeviceGuideViewController *addDeviceGuide = [[AddDeviceGuideViewController alloc] init];
            switch (indexPath.row)
            {
                case 0:
                {
                    addDeviceGuide.pType = productType_WIFI;
                }
                    break;
                case 1:
                {
                    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
                    NSString *appCurVersionNum = [infoDictionary objectForKey:@"CFBundleVersion"];
                    if ([appCurVersionNum hasPrefix:@"3.2"]) {
                        addDeviceGuide.pType = productType_720;
                    }else{
                        addDeviceGuide.pType = productType_DoorBell;
                    }
                    //
                    
                }
                    break;
                case 2:
                {
                    addDeviceGuide.pType = productType_DoorBell;
                }
                    break;
                default:
                    break;
            }
            
           
            
            [self.navigationController pushViewController:addDeviceGuide animated:YES];
        }
            break;
        default:
            break;
    }
    
}


@end
