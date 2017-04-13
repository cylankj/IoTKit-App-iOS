//
//  DeviceWifiTableView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/29.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "DeviceWifiTableView.h"
#import "DeviceWifiCell.h"
#import "JfgTableViewCellKey.h"
#import "DeviceHeadView.h"
#import "JfgGlobal.h"

@interface DeviceWifiTableView()

@property (strong, nonatomic) NSMutableArray *dataArray;

@property (strong, nonatomic) DeviceWifiSetViewModel *deviceWifiSetVM;

@end


@implementation DeviceWifiTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.delegate = self;
        self.dataSource = self;
    }

    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
//    [self.deviceWifiSetVM requestDataWithCid:self.cid];
    [self.deviceWifiSetVM requestDataWithCid:self.cid connectedWifi:self.selectedWifi];
}

//- (void)updateWifiTableView:(NSString *)wifiName
//{
//    NSMutableArray * arr = self.dataArray[1];
//    for (int i = 0; i<arr.count; i++) {
//        NSDictionary * dic = arr[i];
//        if (![[dic objectForKey:cellTextKey] isEqualToString:wifiName]) {
//            [arr addObject:@{cellTextKey:wifiName}];
//            [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:arr.count-1 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
//        }
//    }
////    for (NSDictionary * dic in arr) {
////        if (![[dic allValues] containsObject:wifiName])
////        {
////            
////            [self.dataArray addObject:wifiName];
////            [self insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:self.dataArray.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
////        }
////    }
//
//    
//}
//-(void)jfgScanWifiRespose:(JFGSDKUDPResposeScanWifi *)ask{
//    [self updateWifiTableView:ask.ssid];
//}
#pragma mark getter
- (DeviceWifiSetViewModel *)deviceWifiSetVM
{
    if (_deviceWifiSetVM == nil)
    {
        _deviceWifiSetVM = [[DeviceWifiSetViewModel alloc] init];
        _deviceWifiSetVM.deviceWifiSetdelegate = self;
    }
    
    return _deviceWifiSetVM;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _dataArray;
}


#pragma mark VM delegate
- (void)fetchData:(NSDictionary *)dataDict
{
    [self.dataArray addObject:dataDict];
    [self reloadData];
}

- (void)updatedData:(NSDictionary *)updateDict
{
    
}

#pragma mark tableview delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"deviceSetWifi";
    DeviceWifiCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell)
    {
        cell = [[DeviceWifiCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.textLabel.text = nil;
        cell.imageView.image = nil;
    }
    
    switch (indexPath.section)
    {
        case 0:
        {
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.cusTextLabel.text = self.selectedWifi;
            cell.signalImageView.image = [UIImage imageNamed:@"wifi_signal_1"];
            cell.cusImageView.image = [UIImage imageNamed:@"wifi_check"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.isHiddenImage = NO;
        }
            break;
        case 1:
        {
            NSDictionary *dataDict = [self.dataArray objectAtIndex:indexPath.row];
            cell.accessoryType = (UITableViewCellAccessoryType)[[dataDict objectForKey:cellAccessoryKey] intValue];
            cell.cusTextLabel.text = [dataDict objectForKey:cellTextKey];
            cell.lockImageView.hidden = ![[dataDict objectForKey:isLocked] boolValue];
            cell.isHiddenImage = YES;

        }
            break;
        default:
            break;
    }

    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            return self.dataArray.count;
            break;
        default:
            return 1;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    int stanrdSpace = 20.0f; // 标准 间距
    
    switch (section)
    {
        case 1:
        {
            CGSize labelSize = CGSizeOfString([JfgLanguage getLanTextStrByKey:@"CHOOSE_WIFI"], CGSizeMake(headLabelWidth, kheight), [UIFont systemFontOfSize:14.0f]);
            return labelSize.height + 8 + stanrdSpace - 3;
        }
            break;
            
        default:
            return stanrdSpace;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0f;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section)
    {
        case 1:
        {
            DeviceHeadView *headView =[[DeviceHeadView alloc] init];
            headView.headLabel.text = [JfgLanguage getLanTextStrByKey:@"CHOOSE_WIFI"];
            return headView;
        }
            break;
            
        default:
            return nil;
            break;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [self deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([self.deviceWifiDelegate respondsToSelector:@selector(tableViewDidSelect:withData:)])
        {
            [self.deviceWifiDelegate tableViewDidSelect:indexPath withData:[self.dataArray objectAtIndex:indexPath.row]];
        }
    }
}

@end
