//
//  SettingSearchVC.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SettingSearchVC.h"
#import "JfgGlobal.h"
#import <JFGSDK/JFGSDKDataPoint.h>
#import "JfgMsgDefine.h"
#import <JFGSDK/MPMessagePackWriter.h>
#import "SettingSearchViewModel.h"
#import "LSAlertView.h"

@interface SettingSearchVC()<UIAlertViewDelegate>
{
    NSInteger selectedIndex; // 当前选择的 单元格
}

@property (strong, nonatomic) SearchView *searchView;
@property (strong, nonatomic) SearchTableView *searchTableView;

@property (assign, nonatomic) NSInteger timeSecond;
@property (copy, nonatomic) NSString *zoneId;
@end

@implementation SettingSearchVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
    [self initNavigationView];
    [self addNotificationObserver];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self removeNotificationObserver];
    [super viewDidDisappear:animated];
}

#pragma mark view
- (void)initView
{
    [self.view addSubview:self.searchView];
    [self.view addSubview:self.searchTableView];
}

- (void)initNavigationView
{
    // 顶部 导航设置
    [self.leftButton addTarget:self action:@selector(leftButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    self.titleLabel.text = [JfgLanguage getLanTextStrByKey:@"SETTING_TIMEZONE"];
}

- (void)addNotificationObserver
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldsChanged:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)removeNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)leftButtonAction:(UIButton *)sender
{
    if ([self.oldZoneStr isEqualToString:self.zoneId] || self.zoneId == nil)
    {
        [super leftButtonAction:sender];
    }else{
        [LSAlertView showAlertWithTitle:[JfgLanguage getLanTextStrByKey:@"TIMEZONE_INFO"] Message:nil CancelButtonTitle:[JfgLanguage getLanTextStrByKey:@"CANCEL"] OtherButtonTitle:[JfgLanguage getLanTextStrByKey:@"CARRY_ON"] CancelBlock:nil OKBlock:^{
            [self.navigationController popViewControllerAnimated:YES];
            if ([_delegate respondsToSelector:@selector(timeZoneChanged:timeZone:)])
            {
                [_delegate timeZoneChanged:self.zoneId timeZone:self.timeSecond];
            }
            
        }];
    }
}


- (void)textFieldsChanged:(NSNotification *)notification
{
    if (self.searchView != nil)
    {
        [self.searchTableView updateData:self.searchView.searchTextField.text];
    }
}

#pragma mark SearchViewDelegate
- (void)didClickedCancelButton:(UIButton *)cancelButton
{
    [self.searchTableView updateData:nil];
}

#pragma mark SearchTableViewDelegate

- (void)scrollDidSroll:(UIScrollView *)scroll
{
    [self.searchView.searchTextField resignFirstResponder];
}

-(void)tableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo
{
    NSString *timeKey = [dataInfo objectForKey:timezoneKey];
    NSTimeZone *timezone = [[NSTimeZone alloc] initWithName:timeKey];
    
    self.timeSecond = [timezone secondsFromGMT];
    self.zoneId = [dataInfo objectForKey:timezoneKey];
}


#pragma mark getter

- (SearchView *)searchView
{
    CGFloat widgetX = 0;
    CGFloat widgetY = 64;
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = 44;
    
    if (_searchView == nil)
    {
        _searchView = [[SearchView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _searchView.searchDelegate = self;
        _searchView.showCancelButton = YES;
    }
    
    return _searchView;
}

- (SearchTableView *)searchTableView
{
    CGFloat widgetX = 0;
    CGFloat widgetY = self.searchView.bottom;
    CGFloat widgetWidth = Kwidth;
    CGFloat widgetHeight = kheight - widgetY;
    
    
    if (_searchTableView == nil)
    {
        _searchTableView = [[SearchTableView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight) style:UITableViewStyleGrouped];
        _searchTableView.searchTableViewDelegate = self;
        _searchTableView.zoneId = self.oldZoneStr;
    }
    
    return _searchTableView;
}

@end
