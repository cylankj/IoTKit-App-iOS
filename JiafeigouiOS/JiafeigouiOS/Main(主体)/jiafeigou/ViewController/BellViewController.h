//
//  BellViewController.h
//  JiafeigouiOS
//
//  Created by Michiko on 16/7/12.
//  Copyright © 2016年 lirenguang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JiafeigouDevStatuModel.h"

typedef enum{
    BellStateOnline,
    BellStateOffline,
    BellStateNonet,
    BellStateRefreshing,
}BellState;
//
@interface BellViewController : UIViewController
@property (nonatomic, assign) BellState state;
@property (nonatomic, copy) NSString *alias;
@property (nonatomic, copy) NSString *cid;
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic,strong)JiafeigouDevStatuModel *devModel;
@end
