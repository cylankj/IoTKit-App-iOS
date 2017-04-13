//
//  SearchTableView.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SearchTableView.h"
#import "BaseTableViewCell.h"
#import "JfgDataTool.h"
#import "JfgGlobal.h"
#import "SettingSearchViewModel.h"

@interface SearchTableView()
{
    NSInteger selectedIndex; // 选中 的 单元格
}

@property (strong, nonatomic) NSMutableArray *searchDataArray;

@property (nonatomic, strong) UIView *withoutDataView;
@property (nonatomic, strong) UIImageView *noDataImageView;
@property (nonatomic, strong) UILabel *noDataLabel;

@end


@implementation SearchTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style
{
    self = [super initWithFrame:frame style:style];
    if (self)
    {
        self.delegate = self;
        self.dataSource = self;
        selectedIndex = -1; // Default -1
        
        [self addSubview:self.withoutDataView];
    }
    
    return self;
}

#pragma mark  data
// 额外处理 数据源 数据
- (NSString *)GMTDataWithKey:(NSString *)key
{
    NSTimeZone *timezone = [[NSTimeZone alloc] initWithName:key];
    NSInteger second = [timezone secondsFromGMT];
    
    return [NSString stringWithFormat:@" (GMT%+ld%@)",(long)second/3600, [NSString stringWithFormat:@":%.2ld", labs((second%3600)/60)]];
}

// 没有搜索到 的 UI
- (void)withoutSearch:(BOOL)hasData
{
    self.withoutDataView.hidden = hasData;
}

- (void)updateData:(NSString *)searchValue
{
    [self.searchDataArray removeAllObjects];
    
    SettingSearchViewModel *searchVM = [[SettingSearchViewModel alloc] init];
    
    if (![searchValue isEqualToString:@""] && searchValue != nil)
    {
        NSArray *searchArr = [searchVM arrayWithSearchVale:searchValue];
        [self.searchDataArray addObjectsFromArray:searchArr];
    }
    else
    {
        NSDictionary *dataDict = [JfgDataTool timeZoneDict];
        [_searchDataArray addObjectsFromArray:[dataDict objectForKey:@"timezone"]];
    }
    
    [self update];
}

- (void)update
{
    [self withoutSearch:self.searchDataArray.count>0];
    [self reloadData];
}

#pragma mark tableView delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"searchCell";
    BaseTableViewCell *searchCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDictionary *dataDict = [self.searchDataArray objectAtIndex:indexPath.row];
    
    if (searchCell == nil)
    {
        searchCell = [[BaseTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        
    }
    NSString *timeStr = [self GMTDataWithKey:[dataDict objectForKey:timezoneKey]];
    NSString *zoneStr = [dataDict objectForKey:timezoneValue];
    searchCell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([[dataDict objectForKey:timezoneKey] isEqualToString:self.zoneId] && selectedIndex == -1)
    {
        selectedIndex = indexPath.row;
    }
    
    if (selectedIndex == indexPath.row)
    {
        searchCell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    searchCell.textLabel.text = [NSString stringWithFormat:@"%@%@",zoneStr,timeStr];
    return searchCell;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchDataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1.0f;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    NSDictionary *dataDict = [self.searchDataArray objectAtIndex:indexPath.row];

    [self tableViewDidSelect:indexPath withData:dataDict];
    
    [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0]].accessoryType = UITableViewCellAccessoryNone;
    selectedIndex = indexPath.row;
    [self reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:selectedIndex inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
    
}
#pragma mark ScrollView delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([_searchTableViewDelegate respondsToSelector:@selector(scrollDidSroll:)])
    {
        [_searchTableViewDelegate scrollDidSroll:scrollView];
    }
}
- (void)tableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo{
    if ([_searchTableViewDelegate respondsToSelector:@selector(scrollDidSroll:)])
    {
        [_searchTableViewDelegate tableViewDidSelect:indexPath withData:dataInfo];
    }
}



#pragma mark  getter
- (NSMutableArray *)searchDataArray
{
    if (_searchDataArray == nil)
    {
        _searchDataArray = [[NSMutableArray alloc] init];
        NSDictionary *dataDict = [JfgDataTool timeZoneDict];
        [_searchDataArray addObjectsFromArray:[dataDict objectForKey:@"timezone"]];
        
        [self update];
    }
    
    return _searchDataArray;
}


- (UIView *)withoutDataView
{
    if (_withoutDataView == nil)
    {
        CGFloat width = 157.0;
        CGFloat height = 125.0f ;
        CGFloat x = (self.width - width)*0.5;
        CGFloat y = 0.25*self.height;
        
        _withoutDataView = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _withoutDataView.hidden = YES;
        
        [_withoutDataView addSubview:self.noDataImageView];
        [_withoutDataView addSubview:self.noDataLabel];
    }
    return _withoutDataView;
}

- (UIImageView *)noDataImageView
{
    if (_noDataImageView == nil)
    {
        CGFloat width = 157.0;
        CGFloat height = 125.0f;
        CGFloat x = 0;
        CGFloat y = 0;
        
        _noDataImageView = [[UIImageView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _noDataImageView.image = [UIImage imageNamed:@"pic_tips _none"];
    }
    
    return _noDataImageView;
}

- (UILabel *)noDataLabel
{
    if (_noDataLabel == nil)
    {
        CGFloat width = self.withoutDataView.width;
        CGFloat height = 15.0;
        CGFloat x = 0;
        CGFloat y = self.noDataImageView.bottom + 18.0;
        
        _noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, y, width, height)];
        _noDataLabel.font = [UIFont systemFontOfSize:height];
        _noDataLabel.textColor = [UIColor colorWithHexString:@"#aaaaaa"];
        _noDataLabel.textAlignment = NSTextAlignmentCenter;
        _noDataLabel.text = [JfgLanguage getLanTextStrByKey:@"Tap3_FriendsAdd_NoContent"];
    }
    return _noDataLabel;
}

@end
