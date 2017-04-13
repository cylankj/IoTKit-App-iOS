//
//  SettingSearchViewModel.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewModel.h"

NSString *const timezoneKey = @"_id";
NSString *const timezoneValue = @"__text";

@interface SettingSearchViewModel : BaseViewModel

- (NSArray *)arrayWithSearchVale:(NSString *)searchStr;

@end
