//
//  SearchTableView.h
//  JiafeigouiOS
//
//  Created by lirenguang on 16/6/25.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import "BaseDeviceTableView.h"

@protocol SearchTableViewDelegate <NSObject>

@optional

- (void)tableViewDidSelect:(NSIndexPath *)indexPath withData:(NSDictionary *)dataInfo;

- (void)scrollDidSroll:(UIScrollView *)scroll;

@end


@interface SearchTableView : BaseDeviceTableView<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) id<SearchTableViewDelegate> searchTableViewDelegate;
@property (copy, nonatomic) NSString *zoneId;

- (void)updateData:(NSString *)searchValue;

@end
