//
//  SetAngleVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 2017/2/17.
//  Copyright © 2017年 lirenguang. All rights reserved.
//

#import "SetAngleVC.h"
#import "DeviceInfoFootView.h"
#import "JfgTableViewCellKey.h"
#import "DeviceSettingCell.h"
#import "JfgGlobal.h"

@interface SetAngleVC ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) int angleType;

@property (nonatomic, strong) UITableView *angleTableView;

@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SetAngleVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initView];
    [self initNavigation];
    
    self.angleType = self.oldAngleType;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initView
{
    [self.view addSubview:self.angleTableView];
}

- (void)initNavigation
{
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_ViewAngle"];
}

#pragma mark
#pragma mark  == tableView delegate =====
- (void)leftButtonAction:(UIButton *)sender
{
    [super leftButtonAction:sender];
    
    if (self.oldAngleType != self.angleType)
    {
        if ([self.angleDelegate respondsToSelector:@selector(angleChanged:)])
        {
            [self.angleDelegate angleChanged:self.angleType];
        }
    }
    
}

#pragma mark
#pragma mark  == tableView delegate =====
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.dataArray objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifierStr = @"angleCell";
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    DeviceSettingCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierStr];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if (!cell)
    {
        cell = [[DeviceSettingCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifierStr];
        cell.textLabel.text = nil;
        cell.imageView.image = nil;
    }
    
    cell.cusLabel.text = [dataInfo objectForKey:cellTextKey];
    cell.cusImageVIew.image = [UIImage imageNamed:[dataInfo objectForKey:cellIconImageKey]];
    
    switch (self.angleType)
    {
        case angleType_Front:
        {
            if (indexPath.section == 0)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
        case angleType_Over:
        {
            if (indexPath.section == 1)
            {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    CGFloat stanrdSpace = 10.0f;
    
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        CGSize labelSize = CGSizeOfString([dataInfo objectForKey:cellFootViewTextKey], CGSizeMake(footLabelWidth, kheight), [UIFont systemFontOfSize:14.0f]);
        return labelSize.height + stanrdSpace;
    }
    
    if (section == [self.dataArray count] - 1)
    {
        return stanrdSpace;
    }
    
    return 1.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) return 20.0f;
    return 10.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    NSDictionary *dataInfo = [[self.dataArray objectAtIndex:section] lastObject];
    
    if ([[dataInfo allKeys] containsObject:cellFootViewTextKey])
    {
        DeviceInfoFootView *footView =[[DeviceInfoFootView alloc] init];
        footView.footLabel.text = [dataInfo objectForKey:cellFootViewTextKey];
        footView.footLabel.font = [UIFont systemFontOfSize:14.0f];
        return footView;
    }
    
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section)
    {
        case 0:
            self.angleType = angleType_Front;
            break;
        case 1:
            self.angleType = angleType_Over;
            break;
        default:
            break;
    }
    
    
    [self.angleTableView reloadData];
}

#pragma mark
#pragma mark  == getting =====
- (UITableView *)angleTableView
{
    if (_angleTableView == nil)
    {
        _angleTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _angleTableView.frame = CGRectMake(0, 64, Kwidth, kheight - 64.0f);
        _angleTableView.delegate = self;
        _angleTableView.dataSource = self;
    }
    
    return _angleTableView;
}

- (NSArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:2];
        [_dataArray addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                                         @"install_icon_angle-front",cellIconImageKey,
                                                         [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Front"],cellTextKey,
                                                         @"",cellDetailTextKey,
                                                         [JfgLanguage  getLanTextStrByKey:@"Tap1_Camera_FrontTips"],cellFootViewTextKey,
                                                         nil],nil]];
        
        [_dataArray addObject:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                                @"install_icon_angle-top",cellIconImageKey,
                                [JfgLanguage getLanTextStrByKey:@"Tap1_Camera_Overlook"],cellTextKey,
                                 [JfgLanguage  getLanTextStrByKey:@"Tap1_Camera_OverlookTips"],cellFootViewTextKey,
                                @"",cellDetailTextKey,nil],nil]];
    }
    return _dataArray;
}

@end
