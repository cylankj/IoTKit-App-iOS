//
//  tableViewDelegate.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/8/10.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#ifndef tableViewDelegate_h
#define tableViewDelegate_h

@protocol tableViewDelegate <NSObject>

@optional
- (void)updateData;
- (void)fetchDataArray:(NSArray *)fetchArray;
- (void)updatedDataArray:(NSArray *)updatedArray;
@end
#endif /* tableViewDelegate_h */
