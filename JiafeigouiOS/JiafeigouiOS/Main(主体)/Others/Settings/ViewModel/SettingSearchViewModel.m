//
//  SettingSearchViewModel.m
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "SettingSearchViewModel.h"
#import "XMLDictionary.h"
#import "JfgDataTool.h"
#import "JfgLanguage.h"

@implementation SettingSearchViewModel

// 根据searchValue 索引 返回的数据
- (NSArray *)arrayWithSearchVale:(NSString *)searchStr
{
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    
    NSArray *allDataArray = [[JfgDataTool timeZoneDict] objectForKey:@"timezone"];
    
    // 遍历所有数据 匹配 搜索字符串
    for (NSInteger i = 0; i < allDataArray.count; i ++)
    {
        NSDictionary *dataDict = [allDataArray objectAtIndex:i];
        NSString *dataStr = [dataDict objectForKey:timezoneValue];
        
        if ([dataStr rangeOfString:searchStr].location != NSNotFound) //options:NSCaseInsensitiveSearch
        {
            [resultArray addObject:dataDict];
        }
    }
    
    return resultArray;
}



@end
