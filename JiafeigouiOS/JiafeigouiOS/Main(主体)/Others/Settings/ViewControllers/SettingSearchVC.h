//
//  SettingSearchVC.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/24.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseViewController.h"
#import "SearchTableView.h"
#import "SearchView.h"

@protocol settingSearchVCDelegate <NSObject>

@optional

- (void)timeZoneChanged:(NSString *)zoneID timeZone:(int)timeZone;

@end

@interface SettingSearchVC : BaseViewController<searchViewDelegate, SearchTableViewDelegate>

@property (assign, nonatomic) id<settingSearchVCDelegate> delegate;

@property(nonatomic, assign)NSInteger oldTimeSecond;
@property(nonatomic, copy)NSString *oldZoneStr; 
@end
