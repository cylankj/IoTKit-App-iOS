//
//  SearchFriendsView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/8/3.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SearchFriendsView.h"
#import "JfgGlobal.h"
#import "ProgressHUD.h"
#import "BaseColourView.h"
#import "FriendsMainCell.h"
#import "PopAnimation.h"
#import <JFGSDK/JFGSDK.h>
#import "LoginManager.h"
#import "ProgressHUD.h"
#import "CommonMethod.h"
#import "NSString+FLExtension.h"

@interface SearchFriendsView()<UITableViewDelegate, UITableViewDataSource, FriendsSearchDelegate, UITextFieldDelegate, JFGSDKCallbackDelegate>
{
    CGFloat changeY; // 需要移动的位移
}


/**
 *  搜索列表
 */
@property (nonatomic, strong) UITableView *searchTableView;
/**
 * 数据源
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation SearchFriendsView

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    [super willMoveToSuperview: newSuperview];
    
    [self initView];
}

- (void)initView
{
//    self.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    [self addSubview:self.searchBar];
    [self addSubview:self.searchTableView];
    
    changeY = (86.0f - self.searchBar.y);
    
}

#pragma mark animation
- (void)animationToTop
{
    self.searchBar.y = self.searchBar.y + changeY;
    self.searchTableView.y = self.searchTableView.y + changeY;
    self.hidden = NO;
    
    [UIView animateWithDuration:0.2f animations:^{
        self.searchBar.y = self.searchBar.y - changeY;
        self.searchTableView.y = self.searchTableView.y - changeY;
    } completion:^(BOOL finished) {
        [self.searchBar.searchField becomeFirstResponder];
    }];
}

- (void)animationToBottom
{
    if (self.hidden) {
        return;
    }
    [UIView animateWithDuration:0.2f animations:^{
        self.searchBar.y = self.searchBar.y + changeY;
        self.searchTableView.y = self.searchTableView.y + changeY;
    } completion:^(BOOL finished) {
        self.hidden = YES;
        // 还原坐标
        self.searchBar.y = self.searchBar.y - changeY;
        self.searchTableView.y = self.searchTableView.y - changeY;
        [self.searchBar.searchField resignFirstResponder];
    }];
}

#pragma mark tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *searchCellIdentifier = @"searchFriends";
//    FriendsMainCell *cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
//    if (!cell)
//    {
//        cell = [[FriendsMainCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
//    }
//    cell.cusTextLabel.text = self.dataArray[indexPath.row];
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:searchCellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:searchCellIdentifier];
    }
//    cell.textLabel.text = self.dataArray[indexPath.row];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}

#pragma mark TextField delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    
    if ([LoginManager sharedManager].loginStatus != JFGSDKCurrentLoginStatusSuccess) {
        
        [CommonMethod showNetDisconnectAlert];
        
        return NO;
    }
    
    
    
    if (![textField.text isEmail] && ![textField.text isMobileNumber]) {
        
        //ACCOUNT_ERR
        [ProgressHUD showText:[JfgLanguage getLanTextStrByKey:@"ACCOUNT_ERR"]];
        return NO;
    }
    
    JFGSDKAcount *acc = [LoginManager sharedManager].accountCache;
    if ([acc.account isEqualToString:textField.text] || [acc.phone isEqualToString:textField.text] || [acc.email isEqualToString:textField.text]) {
        [ProgressHUD showText:[CommonMethod languageKeyForAddFriendErrorType:JFGErrorTypeFriendToSelf]];
        return YES;
    }
    
    [self.searchBar.searchField resignFirstResponder];
    if (textField.text.length>0) {
        [ProgressHUD showProgress:nil];
        [JFGSDK checkFriendIsExistWithAccount:textField.text];
    }

    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    //不能输入空字符
//    if ([string isEqualToString:@" "]) {
//        return NO;
//    }
    //禁止输入表情
    if ([[[UITextInputMode currentInputMode] primaryLanguage]         isEqualToString:@"emoji"]) {
        return NO;
    }
    
    NSString *str = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (str.length>65) {
        return NO;
    }
    return YES;
}




#pragma mark delegate
- (void)didClickedCancelButton:(UIButton *)cancelButton
{
    [self animationToBottom];
}

#pragma mark property
- (FriendsSearchBar *)searchBar
{
    if (_searchBar == nil)
    {
        CGFloat widgetX = 0;
        CGFloat widgetY = 0;
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = 64.0f;
        
        _searchBar = [[FriendsSearchBar alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight)];
        _searchBar.searchDelegate = self;
        _searchBar.searchField.delegate = self;
        
    }
    return _searchBar;
}


- (UITableView *)searchTableView
{
    if (_searchTableView == nil)
    {
        CGFloat widgetX = 0;
        CGFloat widgetY = self.searchBar.bottom; //
        CGFloat widgetWidth = Kwidth;
        CGFloat widgetHeight = kheight - widgetY;
        
        _searchTableView = [[UITableView alloc] initWithFrame:CGRectMake(widgetX, widgetY, widgetWidth, widgetHeight) style:UITableViewStylePlain];
        _searchTableView.delegate = self;
        _searchTableView.dataSource = self;
        _searchTableView.showsVerticalScrollIndicator = NO;
        _searchTableView.showsHorizontalScrollIndicator = NO;
        [_searchTableView setTableFooterView:[UIView new]];
        _searchTableView.separatorColor = TableSeparatorColor;
        _searchTableView.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
    }
    
    return _searchTableView;
}

- (NSMutableArray *)dataArray
{
    if (_dataArray == nil)
    {
        _dataArray = [[NSMutableArray alloc] initWithCapacity:5];
    }
    return _dataArray;
}

@end
